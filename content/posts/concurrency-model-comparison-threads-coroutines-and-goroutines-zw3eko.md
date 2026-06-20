---
title: 并发模型对比：线程、协程与 goroutine
slug: concurrency-model-comparison-threads-coroutines-and-goroutines-zw3eko
date: '2026-06-05 00:48:36+08:00'
lastmod: '2026-06-20 16:57:41+08:00'
tags:
  - 并发
  - 线程
  - 协程
  - gmp
  - io模型
categories:
  - 并发
  - 协程
  - 线程
keywords: 并发,线程,协程,gmp,io模型
description: >-
  本文对比了进程、线程、协程与 goroutine 等并发模型的差异，并分析了 Python asyncio 和 Go GMP
  的设计哲学。首先梳理了同步/异步（编程模型层面）与阻塞/非阻塞（内核层面）的区别，指出“异步一定是非阻塞的，但非阻塞不一定是异步的”。接着详细解析了 I/O
  的两个阶段（数据准备和数据拷贝）及五种 Linux I/O 模型，明确 Python asyncio 底层使用 I/O 多路复用（epoll）而非
  POSIX 异步 I/O——它对协程非阻塞，但 epoll_wait 和 recv 会阻塞线程，属于“编程模型异步”+“内核 I/O
  同步”。随后，从层次结构说明进程、线程、协程的关系，强调协程切换不涉及内核，开销极低。通过 Python asyncio 线上故障案例（CPU
  密集型任务阻塞事件循环导致超时）引出问题：Python asyncio 本质是单线程并发，无法利用多核，CPU 密集型任务会阻塞所有协程。对此分析 Go
  goroutine 和 GMP 模型：每个 goroutine 由逻辑处理器 P 绑定到系统线程 M 执行，遇到阻塞时 M 可绑定其他
  G，实现并行与阻塞解耦。最终总结：Python asyncio 适合高 I/O 密集型场景，编程简单但无法利用多核；Go goroutine
  适合高并发场景，通过 GMP 模型实现高效并行，能自动调度和切换。选择方案需根据业务是 I/O 密集还是 CPU 密集。

  本文深入对比了进程、线程、协程与 Go goroutine 等并发模型的差异，并分析了 Python asyncio 与 Go GMP
  的设计哲学。首先澄清了同步/异步（编程模型层面）与阻塞/非阻塞（内核层面）的区别，指出“异步一定是非阻塞的，但非阻塞不一定是异步的”。接着详细解析了 I/O
  的两个阶段（数据准备和数据拷贝）及五种 Linux I/O 模型，明确 Python asyncio 底层使用 I/O 多路复用（epoll）而非
  POSIX 异步 I/O——它对协程非阻塞，但 epoll_wait 和 recv 会阻塞线程，属于“编程模型异步”+“内核 I/O
  同步”。随后，从层次结构说明进程、线程、协程的关系，强调协程切换不涉及内核，开销极低。通过 Python asyncio 线上故障案例（CPU
  密集型任务阻塞事件循环导致超时）引出问题：Python asyncio 本质是单线程并发，无法利用多核，CPU 密集型任务会阻塞所有协程。对此分析 Go
  goroutine 和 GMP 模型：每个 goroutine 由逻辑处理器 P 绑定到系统线程 M 执行，遇到阻塞时 M 可绑定其他
  G，实现并行与阻塞解耦。最终总结：Python asyncio 适合高 I/O 密集型场景，编程简单但无法利用多核；Go goroutine
  适合高并发场景，通过 GMP 模型实现高效并行，能自动调度和切换。选择方案需根据业务是 I/O 密集还是 CPU 密集。
toc: true
isCJKLanguage: true
---



# 并发模型对比：线程、协程与 goroutine

# 并发模型对比：线程、协程与 goroutine

> 从一次 Python asyncio 线上故障出发，梳理进程、线程、协程三种并发原语的本质区别，  
> 以及 Python asyncio 与 Go GMP 模型的设计哲学差异。

---

## 一、基础概念：同步 vs 异步，阻塞 vs 非阻塞

### 同步 / 异步 —— 说的是"编程模型层面等不等结果"

||含义|代码示例|
| ------| -----------------------------------| ----------|
|同步|调用后必须等返回值才能继续|​`resp = requests.get(url)`|
|异步|调用后先去做别的，完成后回调/通知|​`resp = await httpx.get(url)`|

### 阻塞 / 非阻塞 —— 说的是"内核层面卡不卡线程"

||含义|系统调用|
| --------| ---------------------------| ---------------|
|阻塞|数据没到，线程挂起等待|​`read()` 默认模式|
|非阻塞|数据没到，立即返回 EAGAIN|​`fcntl(O_NONBLOCK)`|

**异步一定是非阻塞的，但非阻塞不一定是异步的**（可以非阻塞轮询，那叫忙等待）。

---

## 二、I/O 的两个阶段与 Linux 五种 I/O 模型

任何一次网络 I/O 在内核里分两步：

```
用户进程                             内核
   │                                  │
   │  ① 等待数据到达网卡 → 内核缓冲区   │  ← "数据准备阶段"（网络延迟，几十~几百ms）
   │                                  │
   │  ② 内核缓冲区 → 用户空间内存       │  ← "数据拷贝阶段"（内存拷贝，通常几微秒）
   │                                  │
```

|模型|阶段① 等数据|阶段② 拷数据|代表|
| --------------| ---------------| ---------------| --------------------|
|阻塞 I/O|阻塞|阻塞|​`read()` 默认|
|非阻塞 I/O|返回 EAGAIN|阻塞|​`O_NONBLOCK` + 轮询|
|I/O 多路复用|​`epoll` 统一等|阻塞|nginx、Redis|
|信号驱动 I/O|信号通知|阻塞|SIGIO，少见|
|**异步 I/O (AIO)**|**不等**|**不等**|​`io_uring`、Windows IOCP|

按 POSIX 严格定义：**前四种都是同步 I/O**（阶段②会阻塞调用者），只有最后一种是真异步。

### Python asyncio 属于哪种？

**Python asyncio 底层使用 I/O 多路复用（Linux** **​`epoll`​**​  **/ macOS** **​`kqueue`​**​ **），不是 POSIX 异步 I/O。**

```
Python asyncio 内部执行流：

用户代码           asyncio event loop             内核
  │                      │                         │
  │ await sock.read()    │                         │
  │ ──暂停协程──→        │                         │
  │                      │  epoll_wait()           │
  │                      │ ──线程阻塞等事件──→     │  ← 阶段①: 线程阻塞在 epoll
  │                      │                         │     但其他协程可被调度
  │                      │  ← 事件就绪 ──────      │
  │                      │                         │
  │                      │  recv(fd, buf, n)        │  ← 阶段②: 数据拷贝，同步阻塞
  │                      │ ──阻塞──→               │
  │                      │  ← 数据返回 ──────      │
  │  ← 恢复协程 ───      │                         │
```

准确描述：

> **Python asyncio = 对协程非阻塞 + 对线程阻塞（I/O 多路复用） + 数据拷贝阶段同步。**   
> 叫 "async" 是编程模型层面的异步，不是内核 I/O 层面的异步。

### "异步"这个词的两层含义

容易混淆的原因是 "异步" 在不同语境下指不同的东西：

||编程模型层面 (Programming Model)|内核 I/O 层面 (POSIX I/O Model)|
| --------------------| ----------------------------------| --------------------------------------|
|含义|代码不用同步等结果|两个阶段都不阻塞，内核完成后主动通知|
|Python asyncio|✓ 是|✗ 不是（底层是 epoll 多路复用）|
|JavaScript Promise|✓ 是|✗ 不是（底层是 libuv + epoll）|
|Go goroutine|✓ 是（虽然语法是同步的）|✗ 不是（底层是 netpoller + epoll）|
|Linux io_uring|-|✓ 是|
|Windows IOCP|-|✓ 是|

所以严格来说：**Python asyncio 是"编程模型异步 + 内核 I/O 同步"** 。  
对 LWP（内核线程）来说，`epoll_wait`​ 阶段线程阻塞，`recv`​ 阶段数据拷贝也阻塞；  
但对协程来说，`await` 只是让出控制权，协程本身不阻塞。

---

## 三、进程、线程、协程的层次关系

```
┌───────────────────────────────────────────────────┐
│                   操作系统                          │
│                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ 进程 A    │  │ 进程 B    │  │ 进程 C    │        │
│  │          │  │          │  │          │        │
│  │ ┌──┐ ┌──┐│  │ ┌──┐     │  │ ┌──┐     │        │
│  │ │T1│ │T2││  │ │T1│     │  │ │T1│     │← 线程  │
│  │ └──┘ └──┘│  │ └──┘     │  │ └──┘     │  OS 调度│
│  │          │  │          │  │          │        │
│  │ c1 c2 c3 │  │          │  │          │← 协程  │
│  │ (在 T1 内)│  │          │  │          │  用户态 │
│  └──────────┘  └──────────┘  └──────────┘        │
└───────────────────────────────────────────────────┘
```

||进程 (Process)|线程 (Thread)|协程 (Coroutine)|
| --| ------------------------------| --------------------------| ----------------------------------|
|**调度者**|OS 内核|OS 内核|用户程序（event loop / runtime）|
|**切换成本**|最大（TLB 刷新、内存隔离）|中等（内核态 ↔ 用户态）|极小（函数调用级别）|
|**内存**|独立地址空间|共享进程地址空间|共享线程栈|
|**数量上限**|几十~几百|几百~几千|几万~几十万|
|**是否并行**|真并行（各进程可跑在不同核）|Python 受 GIL 限制|取决于调度模型（见下）|

> **协程能不能并行？**  取决于它的调度模型：
>
> - **N:1 模型**（Python asyncio）：所有协程跑在一个线程上 → **不能并行，只能并发**
> - **M:N 模型**（Go goroutine）：协程被分配到多个内核线程上 → **能并行**
>
> "协程" 是一个宽泛的概念（可暂停恢复的执行单元），并行与否取决于底层怎么把它映射到内核线程。  
> Go goroutine 本质也是协程，但因为 GMP 调度器把 G 分散到多个 M（LWP）上，所以能利用多核并行。

---

## 四、协程的核心原理

协程不是操作系统概念，本质是**一个可以暂停和恢复的函数**。

```python
async def task_a():
    print("A: 开始请求")
    await asyncio.sleep(1)     # 暂停 task_a，让出执行权给 event loop
    print("A: 请求完成")       # 1 秒后 event loop 恢复执行

async def task_b():
    print("B: 开始请求")
    await asyncio.sleep(1)
    print("B: 请求完成")

# 两个协程在同一个线程内交替执行
await asyncio.gather(task_a(), task_b())
```

时序图：

```
时间轴：─────────────────────────────────>
线程：  [A:开始] [B:开始] ...等 epoll... [A:完成] [B:完成]
          ↓       ↓                        ↓        ↓
      A 遇到 await B 遇到 await       A 的 I/O 回来 B 的 I/O 回来
      让出控制权   让出控制权          event loop   event loop
                                      恢复 A       恢复 B
```

### Event Loop（事件循环）

Event loop 是协程的调度器，一个无限循环：

```
┌──────────────────────────┐
│      Event Loop          │
│                          │
│  1. epoll_wait() 等事件  │
│         ↓                │
│  2. 事件就绪 → 恢复对应  │
│     协程继续执行         │
│         ↓                │
│  3. 协程遇到 await       │
│     → 注册等待事件       │
│     → 回到步骤 1         │
└──────────────────────────┘
```

**关键约束：一个 event loop 绑定一个线程。所有 asyncio 对象（Event、Lock、Future）都隐式绑定到创建它们的 event loop。**

---

## 五、Python 线程的本质

### Python 线程 = 1:1 映射到内核 LWP

```
threading.Thread()
    │
    ▼
pthread_create()          ← CPython 直接调 POSIX 线程库
    │
    ▼
clone(CLONE_THREAD)       ← Linux 内核创建轻量级进程 (LWP)
    │
    ▼
内核调度器调度             ← 和 C/Java 线程完全一样
```

Python 没有自己的线程调度器，完全依赖 OS 内核。

### GIL（全局解释器锁）的影响

```
GIL 限制的范围：

  ✗ 纯 Python 字节码：同一时刻只有一个线程能执行
    Thread-1: a.append(4)    ← 需要 GIL
    Thread-2: b["k"] = "v"  ← 需要 GIL → 必须等

  ✓ I/O 操作：释放 GIL，可以真并行
    Thread-1: socket.recv()  ← 释放 GIL
    Thread-2: file.read()    ← 释放 GIL → 可以同时跑

  ✓ C 扩展（numpy 等）：内部释放 GIL
    Thread-1: numpy.dot(a, b)  ← C 代码释放 GIL
    Thread-2: cv2.resize(img)  ← C 代码释放 GIL → 可以同时跑
```

所以 Python 多线程对 **I/O 密集型** 任务仍然有效（GIL 在 I/O 时释放），  
但对**纯计算密集型**任务没有加速效果（需要多进程）。

---

## 六、Go GMP 模型

Go 的并发模型是 M:N 调度——M 个 goroutine 映射到 N 个 OS 线程。

### 三个角色

|角色|含义|数量|
| --------------| -----------------------------| ----------------------|
|**G** (Goroutine)|用户态协程，2KB 栈|几十万~百万|
|**M** (Machine)|OS 内核线程|通常几个~几十个|
|**P** (Processor)|逻辑处理器，持有本地 G 队列|= `GOMAXPROCS`（默认=CPU核数）|

### 调度流程

**正常执行：**

```
M0 ──── P0 ──── [G1 执行中]
                 [G2 等待中]
                 [G3 等待中]
```

**场景 1：G 发起网络 I/O（非阻塞，最常见）**

```
G1: conn.Read()
  → Go runtime 把 fd 注册到 netpoller（底层就是 epoll）
  → G1 挂起，放入 netpoller 等待队列
  → P0 直接从队列取 G2 执行
  → M0 全程不阻塞！

  M0 ──── P0 ──── [G2 执行中]       ← M 和 P 都没换
                   [G3 等待中]

  netpoller 检测到 G1 的 fd 就绪 → G1 放回 P 的本地队列等调度
```

**场景 2：G 发起系统调用（阻塞，如文件 I/O）——Hand-off 机制**

```
G1 调用 syscall read(file_fd)，M0 被阻塞：

  M0 ──(脱离 P0)── [G1 阻塞在 syscall]    ← M0 被 G1 拖住
  M1 ──── P0 ──── [G2 开始执行]            ← 调度器新建/唤醒 M1 接管 P0
  (新线程)         [G3 等待中]                 这个过程叫 hand-off

  syscall 返回后：M0 尝试拿回 P0（或找其他空闲 P），G1 放回队列
```

> **hand-off**：当 M 因系统调用阻塞时，Go 调度器将 P（及其 G 队列）  
> "移交"给另一个 M，确保其他 goroutine 不被一个阻塞调用拖住。

**场景 3：P 的工作窃取（Work Stealing）**

```
P0 的队列：[G1, G2, G3]    忙
P1 的队列：[]               空闲

P1 从 P0 队列尾部偷走一半：
P0: [G1, G2]
P1: [G3]                    ← 保证多核负载均衡
```

---

## 七、为什么 Go 不需要 async/await

这是最核心的设计差异。

**Python：开发者必须选择同步还是异步，两个世界不能混用**

```python
# 同步版
def sync_fetch():
    return requests.get(url)        # 阻塞当前线程

# 异步版 —— 完全不同的函数签名、不同的库、不同的调用方式
async def async_fetch():
    return await httpx.get(url)     # 必须在 event loop 内调用

# 混用就出 bug（就像我们遇到的）
```

**Go：只有一个世界，写同步代码自动获得异步效果**

```go
func fetch() string {
    resp, _ := http.Get(url)            // 看起来是"同步"的
    body, _ := io.ReadAll(resp.Body)    // 但 runtime 自动：
    return string(body)                 //   1. 非阻塞 I/O
}                                       //   2. 挂起当前 goroutine
                                        //   3. M 去跑别的 goroutine
                                        //   4. I/O 完成后恢复
go fetch()  // 一个关键字就完事
```

---

## 八、全景对比

||Python 多线程|Python asyncio|Go goroutine|
| --| ----------------| --------------------------| --------------------------|
|**本质**|内核线程 (LWP)|用户态生成器对象|用户态协程|
|**调度者**|OS 内核|event loop|Go runtime 调度器|
|**映射模型**|1:1|N:1 (N 协程 : 1 线程)|**M:N** (M goroutine : N 线程)|
|**栈大小**|8MB（默认）|无独立栈|2KB（动态增长）|
|**创建开销**|高|极低|低|
|**数量上限**|~千|~万|~百万|
|**利用多核**|受 GIL 限制|单线程不能|✓ 天然多核|
|**I/O 阻塞**|整个线程阻塞|只挂起当前协程|只挂起 G，M 继续跑别的|
|**开发体验**|需关注锁|两个世界 (sync ≠ async)|一个世界，无 async/await|

---

## 九、总结

1. **Python 多线程**：真正的内核线程，GIL 限制了 CPU 并行但不限制 I/O 并发。  
   适合 I/O 密集型的传统 Web 服务。
2. **Python asyncio 协程**：单线程 + event loop + I/O 多路复用。  
   高并发低开销，但需要 async/await 标记，与同步代码不兼容。
3. **多线程 + 协程混用**：在同步框架里跑异步代码的妥协方案。  
   每个线程需要独立的 event loop，跨线程共享 async 对象会出问题  
   （就是我们遇到的 `bound to a different event loop`）。
4. **Go goroutine**：M:N 调度，用户写同步代码，runtime 自动异步。  
   天然多核并行，无 GIL，无 async/await 的心智负担。  
   代价是 runtime 更重、GC 暂停需要调优、错误处理冗长（`if err != nil`）、  
   缺少异常机制和早期缺少泛型（Go 1.18 后已支持）。

‍
