---
title: 计算机通用知识
slug: general-computer-knowledge-1wculg
date: '2026-04-19 16:26:39+08:00'
lastmod: '2026-06-24 00:05:24+08:00'
tags:
  - 限流
  - 固定窗口
  - 滑动窗口
  - 漏桶
  - 令牌桶
categories:
  - 技术
keywords: 限流,固定窗口,滑动窗口,漏桶,令牌桶
description: >-
  本文介绍了四种核心限流算法：**固定窗口**（设定固定时间块计数，超时清零，适合长周期配额但存在临界双倍流量风险）；**滑动窗口**（记录每个请求时间戳，严格统计滚动周期内请求数，防刷能力强但内存开销大）；**漏桶**（固定速率处理请求，保护脆弱下游，但会扼杀正常突发）；**令牌桶**（匀速生成令牌，允许积攒和突发，适合网关和客户端限流，但参数配置不当易引发瞬时并发）。文章还详细对比了各算法的适用场景、资源开销及致命坑点，帮助开发者在实际系统中根据流量特征和下游稳定性需求选择合适的限流策略。
toc: true
isCJKLanguage: true
---



# 计算机通用知识

## 限流

### 核心限流算法全景对比表

|**算法名称**|**核心机制**|**流量输出特征**|**资源开销**|**典型适用场景**|**致命坑点 (Gotchas)**|
| --| ----------------------------------------------------------| ----------------| --------------------------------------------| ---------------------------------------------------| --|
|**固定窗口**|划定固定时间块，块内计数，超时清零。|阶梯式突发|极低（只需存时间和计数值）|​**宽泛配额管理**（如：SaaS 免费版每月 1000 次 API 调用）。|**临界点突发（双倍流量攻击）**|
|**滑动窗口**|记录每次请求时间，只统计当前时刻往前推的滚动周期。|极其平滑且严格|较高（需记录大量时间戳，高并发清理成本高）|​**严格防刷/风控**（如：短信验证码 1分钟 1次、高频交易限制）。|**内存占用大、大流量下存在性能瓶颈**|
|**漏桶**|桶充当缓冲队列，系统以绝对恒定速率处理队列中的请求。|**绝对匀速**|中等（取决于队列长度）|​**脆弱下游保护**（如：秒杀订单异步削峰、老旧单体系统保护）。|**扼杀正常突发流量，导致用户无谓排队**|
|**令牌桶**|匀速生成令牌放入桶中，请求消耗令牌。允许积攒，允许突发。|**匀速 + 允许突发**|低（纯数学计算，无复杂数据结构）|​**网关限流、客户端主动限流**（如：微服务 API 保护、调用第三方限流接口）。|**防刷场景下会被黑客利用积攒额度**|

---

#### 深入剖析与避坑指南

##### 1. 固定窗口 (Fixed Window)

- **适用场景：**  长周期的业务配额限制。比如“每天最多上传 500 个文件”、“每月 API 调用 1 万次限制”。这种长周期下，根本不需要关心一秒内的流量抖动。
- **⚠️ 坑点：**

  - **临界点双倍流量：**  如果限制 `100次/分钟`​，黑客在 `00:59`​ 瞬间打满 100 次，在 `01:01` 再次打满 100 次。系统虽然没判定违规，但服务器在 2 秒内承受了 200 次并发，很容易被打挂。

##### 2. 滑动窗口 (Sliding Window)

- **适用场景：**  零容忍的防刷系统。任何需要严格校验“在过去的一段时间内绝对不能超过 X 次”的场景，比如密码试错、短信轰炸防御。
- **⚠️ 坑点：**

  - **内存与计算压力：**  在高并发下，你需要记录每一个请求的时间点。如果限流阈值是 `10万次/小时`，你就得在内存（或 Redis 的 ZSet）里维护 10 万个时间戳，并且每次请求都要执行 O(N) 或 O(logN) 的清理过期数据的操作，容易拖垮限流器本身。

##### 3. 漏桶 (Leaky Bucket)

- **适用场景：**  把漏桶当作“稳压器”。当你背后是一个随时可能崩溃的脆弱系统（比如很老的数据库、复杂的报表生成逻辑），你不管上游流量怎么狂暴，漏桶都会把请求变成一秒一个的“滴答”声喂给下游。
- **⚠️ 坑点：**

  - **用户体验极差（误伤）：**  如果限流 `60次/分钟`​，相当于 `1次/秒`。正常用户快速连点两下鼠标（间隔 0.5 秒），第二次点击就会被漏桶判定为“超速”而丢弃或强行挂起，用户会觉得系统非常卡顿或出现 Bug。

##### 4. 令牌桶 (Token Bucket)

- **适用场景：**  互联网业务的“万金油”，绝大多数网关（Nginx, Gateway）和官方组件（Go `x/time/rate`​）的默认选择。它最符合人类的行为习惯：允许偶尔的连续操作（消耗积攒的令牌），但长期看又有整体速率限制。特别适合​**你目前的场景（客户端主动限流第三方）** ，通过调小桶的容量，可以兼顾平滑发送和灵活排队。
- **⚠️ 坑点：**

  - **参数配置极具迷惑性：**  令牌桶的安全性极大地依赖于 `Burst`（桶容量/最大突发量）的设置。如果你的速率是 1000/s，为了应对突发你把 Burst 设为了 1000，那么在系统闲置一段时间后，瞬间是允许 1000 个并发打穿系统的。如果后端扛不住这 1000 个瞬时并发，令牌桶就失去了保护意义。
  - **分布式排队难：**  如我们上一轮讨论的，单机令牌桶很容易做到 `Wait()` 阻塞排队，但在 Redis 分布式环境下，由于 Lua 脚本的瞬间返回特性，很难实现原生的、不浪费 CPU 的排队机制（必须依赖 MQ 或客户端自旋 Sleep）。

### 计数器算法

保存一个计数器，处理了一个请求计数器+1，处理完毕之后-1，每次来请求就看看计数器的值，如果超过阈值就拒绝

优点：简单粗暴，单机在Java中可用Atomic等原子类，分布式就是Redis incr

缺点：假设允许的阈值是1万，计数器的值是0，当1万个请求在前1秒一股脑儿的都涌进来，突发的流量顶不住，缓缓增加和一下子涌入对程序来说是不一样的

```go
package main

import (
	"sync/atomic"
)

type CounterLimiter struct {
	count atomic.Int32 // 当前正在处理的请求数
	limit int32        // 最大允许的并发阈值
}

func NewCounterLimiter(limit int32) *CounterLimiter {
	return &CounterLimiter{limit: limit}
}

// Allow 请求到来时调用
func (c *CounterLimiter) Allow() bool {
	// 先加 1
	if c.count.Add(1) <= c.limit {
		return true
	}
	// 如果超过阈值了，说明拒绝，把刚才加的 1 减回去
	c.count.Add(-1)
	return false
}

// Done 请求处理完毕后【必须】调用释放
func (c *CounterLimiter) Done() {
	c.count.Add(-1)
}
```

### 固定窗口限流算法

固定窗口其实就是时间窗口，这个算法规定了我们单位时间内处理的请求数量

首先规定单位时间的长度time，给定一个变量counter来记录当前接口处理的请求数量，初始值为0，在time的时间内，处理一个请求就+1，当counter到达阈值时，后续的请求就会被拒绝，time时间过后重新开始计数

缺点：无法保证限流速率，无法保证突然激增的流量

- **核心思想：**  利用时间戳对齐的特性，将当前时间（如分钟、小时）作为 Key 的一部分。所有实例对同一个 Key 进行原子递增，超过阈值则拒绝。
- **依赖中间件：**  Redis。
- **用到数据结构：**  `String`（简单的 Key-Value）。
- **实现细节（Redis 命令）：**

  1. 客户端应用获取当前时间，截断到当前窗口。例如当前是 `14:05:33`​，截断为按分钟的字符串 `20231024-14:05`。
  2. 拼接 Redis Key，例如 `limit:api_login:20231024-14:05`。
  3. 使用 `INCR` 命令对这个 Key 进行原子加 1。
  4. 如果返回值等于 1（说明是当前窗口的第一个请求），顺手设置一个过期时间 `EXPIRE key 60`（防止垃圾数据堆积）。
  5. 判断 `INCR` 的返回值是否大于设定的阈值。大于则限流，小于等于则放行。
- **避坑提示：**  虽然简单，但依然存在“临界点突发”问题。

```go
package main

import (
	"sync"
	"time"
)

type FixedWindowLimiter struct {
	mu        sync.Mutex
	limit     int           // 窗口内允许的最大请求数
	window    time.Duration // 窗口大小
	count     int           // 当前窗口内的请求数
	startTime time.Time     // 当前窗口的起始时间
}

func NewFixedWindowLimiter(limit int, window time.Duration) *FixedWindowLimiter {
	return &FixedWindowLimiter{
		limit:     limit,
		window:    window,
		startTime: time.Now(),
	}
}

func (l *FixedWindowLimiter) Allow() bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	now := time.Now()
	// 如果当前时间已经超过了当前窗口的结束时间，开启新窗口
	if now.Sub(l.startTime) > l.window {
		l.count = 0
		l.startTime = now
	}

	// 判断是否超过限制
	if l.count < l.limit {
		l.count++
		return true
	}
	return false
}
```

### 滑动窗口算法

滑动窗口相比于固定窗口将时间做了优化：把时间以一定比例分片

假设将时间以1s进行分片，滑动窗口记录了窗口内每个请求到达的时间点，统计此请求到达前1s内接受到的请求数量，如果统计的请求数小于阈值就循序通过，反之则拒绝

缺点：记录到达时间需要更多的内存，无法解决短时间之内集中流量的突击

- **核心思想：**  利用支持范围查询的有序集合，把请求的时间戳作为分数进行排序。每次检查前，先删掉窗口之外的旧数据，然后统计剩下的数据量。
- **依赖中间件：**  Redis。
- **用到数据结构：**  `ZSet` (有序集合 Sorted Set)。
- **实现细节（通常需要 Lua 脚本保证原子性）：**

  1. 生成当前请求的唯一 ID（必须要有，比如 `UUID`​）和当前时间戳（精确到毫秒，设为 `now`）。
  2. 计算窗口的起始时间 `window_start = now - window_size`。
  3. **清理过期数据：**  `ZREMRANGEBYSCORE key 0 window_start`（移除所有分数小于起始时间的值）。
  4. **统计当前窗口请求数：**  `ZCARD key`。
  5. 如果数量小于阈值，则把当前请求放进去：`ZADD key now UUID`，并更新整个 ZSet 的过期时间（避免冷数据残留）。
- **避坑提示（极其关键）：**  ZSet 的 `Member`​（成员）必须是唯一的！千万不要把时间戳同时当做分数和成员。如果两个请求在同一毫秒并发到达，它们的时间戳一样，如果把时间戳当成员存入 ZSet，第二个请求会覆盖第一个请求，导致计数丢失。**正确做法是：Score 存时间戳，Member 存 UUID。**

```go
package main

import (
	"sync"
	"time"
)

type SlidingWindowLimiter struct {
	mu     sync.Mutex
	limit  int
	window time.Duration
	reqs   []time.Time // 记录每个请求到达的时间点
}

func NewSlidingWindowLimiter(limit int, window time.Duration) *SlidingWindowLimiter {
	return &SlidingWindowLimiter{
		limit:  limit,
		window: window,
		reqs:   make([]time.Time, 0),
	}
}

func (l *SlidingWindowLimiter) Allow() bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	now := time.Now()
	// 计算窗口的起始线
	cutoff := now.Add(-l.window)

	// 清理掉窗口之外的旧数据 (模拟滑动)
	newReqs := l.reqs[:0] 
	for _, t := range l.reqs {
		if t.After(cutoff) {
			newReqs = append(newReqs, t)
		}
	}
	l.reqs = newReqs

	// 判断当前窗口内的请求数是否小于阈值
	if len(l.reqs) < l.limit {
		l.reqs = append(l.reqs, now)
		return true
	}
	return false
}
```

### 漏桶算法

漏桶算法的基本思想是请求可以以任意的速度进入，但是服务器按照固定的速率处理，当超过桶的请求过来时就丢弃，保证了整体的速率

具体实现可以准备一个队列来保存请求，我们定期从队列中拿出请求处理（类似于使用消息队列异步处理请求来进行流量削峰）

缺点：面对大量突发请求，只能以一定速率处理，用户体验不好

- **核心思想：**  请求不再直接打到下游服务，而是全部暂存到一个巨大的、可靠的容器中（桶）。下游服务根据自身的处理能力，以匀速、可控的节奏从容器中拉取任务执行。
- **依赖中间件：**  分布式消息队列（如 RabbitMQ, Kafka, RocketMQ） 或 Redis `List/Stream`。
- **用到数据结构：**  `FIFO Queue`（先进先出队列）。
- **实现细节：**

  1. **注水（上游生产）：**  所有的 API 请求到达网关后，网关只负责将请求打包成 Message，推入 MQ。如果 MQ 的队列长度（`LLEN`）超过了设定的最大容量，网关直接丢弃请求，返回“系统繁忙”。
  2. **漏水（下游消费）：**  后端应用实例作为 Consumer，设置并发度（例如单机开启 5 个 Goroutine）。它们以固定的速率从 MQ 拉取消息并处理。不论上游推得有多快，下游消费的速率永远是恒定的。
- **适用性：**  极其适合异步任务（如下单、发邮件、数据同步）。

```go
package main

import (
	"time"
)

type LeakyBucket struct {
	bucket chan struct{} // 桶，容量就是队列大小
}

// rate: 漏水速率 (例如每 100ms 漏一滴)
// capacity: 桶的容量 (应对突发请求的缓冲大小)
func NewLeakyBucket(rate time.Duration, capacity int) *LeakyBucket {
	lb := &LeakyBucket{
		bucket: make(chan struct{}, capacity),
	}

	// 开启一个后台协程模拟匀速“漏水”（匀速处理请求）
	go func() {
		ticker := time.NewTicker(rate)
		for range ticker.C {
			select {
			case <-lb.bucket:
				// 成功漏出了一滴水（这里代表系统拿去处理了）
			default:
				// 桶是空的，什么也不做
			}
		}
	}()

	return lb
}

// Allow 请求尝试进入桶
func (lb *LeakyBucket) Allow() bool {
	select {
	case lb.bucket <- struct{}{}:
		// 成功放进桶里，等待被匀速处理
		return true
	default:
		// 通道满了，桶溢出，直接丢弃拒绝
		return false
	}
}
```

### 令牌桶算法

我们以一定的速率向桶中生产一定数量的令牌，如果桶满了就不再放入，请求只有获取到令牌之后才能进行处理，如果没有获取到令牌就丢弃

优点：不仅可以限流，还允许一定程度的流量突发

- **核心思想：**  放弃“后台定时任务发令牌”的传统思维，转为​ **“惰性计算（Lazy Evaluation）”** 。在请求到达的那一瞬间，根据当前时间与上次更新时间的“差值”，动态计算出应该补充多少令牌。
- **依赖中间件：**  Redis + Lua 脚本。
- **用到数据结构：**  `Hash`。
- **实现细节：**

  1. Redis Key \= `limit:api_name`。
  2. Hash 内部只有两个 Field：`last_time`​ (上次更新时间戳) 和 `tokens` (剩余令牌数)。
  3. 通过 Lua 脚本原子执行：读取 Hash -\> 计算逝去的时间 -\> 乘以速率得出新增令牌 -\> 累加但受限于最大容量 -\> 尝试扣减 -\> 将最新时间和剩余令牌写回 Hash。

```go
package main

import (
	"sync"
	"time"
)

type TokenBucket struct {
	mu         sync.Mutex
	capacity   float64   // 桶的容量（最多存多少令牌，允许的突发量）
	tokens     float64   // 当前令牌数量
	rate       float64   // 生成速率 (每秒生成多少个令牌)
	lastUpdate time.Time // 上次更新令牌的时间
}

func NewTokenBucket(rate float64, capacity float64) *TokenBucket {
	return &TokenBucket{
		capacity:   capacity,
		tokens:     capacity, // 初始时把桶装满
		rate:       rate,
		lastUpdate: time.Now(),
	}
}

func (tb *TokenBucket) Allow() bool {
	tb.mu.Lock()
	defer tb.mu.Unlock()

	now := time.Now()
	// 1. 计算距离上次请求过去了多久（秒）
	elapsed := now.Sub(tb.lastUpdate).Seconds()

	// 2. 补发这段时间内产生的令牌
	tb.tokens += elapsed * tb.rate
	if tb.tokens > tb.capacity {
		tb.tokens = tb.capacity // 不能超过桶的容量
	}
	tb.lastUpdate = now

	// 3. 判断令牌是否足够 (每次消耗 1 个)
	if tb.tokens >= 1.0 {
		tb.tokens -= 1.0
		return true
	}
	
	// 令牌不够，拒绝请求
	return false
}
```

在 Redis 中实现令牌桶，我们通常只会用到一种最基础的数据结构：**Hash（哈希表）** 。

我们需要在 Hash 中存两个字段（Field）：

1. ​`last_time`：上次更新令牌桶的时间戳（精确到微秒或毫秒）。
2. ​`tokens`：当前桶里还剩下多少个令牌。

#### 核心思想与执行流程

使用 Lua 脚本的核心目的，是​**保证“读 -\> 计算 -\> 写”这一连串动作的绝对原子性**。在执行这段 Lua 脚本时，Redis 会把它当作一个单线程的命令，在此期间不会有其他并发请求干扰，完美避开了多实例并发导致的超卖问题。

它的核心流程和你之前看的单机版几乎一样，只不过计算环境搬到了 Redis 里：

1. 调用 Redis 的 `TIME` 命令获取当前绝对时间。
2. 从 Hash 中读取 `last_time`​ 和 `tokens`。
3. ​**计算补发**​：`(当前时间 - last_time) * 速率`​ \= 这段时间新产生的令牌。
4. ​**合并并限制**：把新令牌加到旧令牌上，但不超过桶的容量（Capacity）。
5. **判断与扣减**：如果够用就减 1，保存最新时间和最新令牌数，返回 1（允许）；不够就直接保存最新时间，返回 0（拒绝）。

```lua
-- KEYS[1]: 限流器的 Key (例如 "api_limiter:app_id_123")
-- ARGV[1]: 桶的容量 (capacity，例如 60)
-- ARGV[2]: 令牌生成速率 (rate，每秒生成多少个，例如 60)
-- ARGV[3]: 当前请求需要的令牌数 (通常是 1)

local key = KEYS[1]
local capacity = tonumber(ARGV[1])
local rate = tonumber(ARGV[2])
local requested = tonumber(ARGV[3])

-- 1. 获取 Redis 当前时间 (返回一个数组：[秒, 微秒])
-- 为了计算精准，我们将其转换为带小数的秒
local time = redis.call('TIME')
local now = tonumber(time[1]) + tonumber(time[2]) / 1000000

-- 2. 从 Redis Hash 中获取上次的时间和剩下的令牌
local bucket = redis.call('HMGET', key, 'last_time', 'tokens')
local last_time = tonumber(bucket[1])
local tokens = tonumber(bucket[2])

-- 3. 初始化：如果之前没有记录，说明是第一次访问，桶是满的
if last_time == nil then
    tokens = capacity
    last_time = now
end

-- 4. 计算：根据时间差，计算这段时间应该生成的令牌数
local elapsed = math.max(0, now - last_time)
local generated_tokens = elapsed * rate

-- 5. 补充：把新生成的令牌放进桶里，但不能超过最大容量
tokens = math.min(capacity, tokens + generated_tokens)

-- 6. 判断：看当前的令牌够不够本次请求扣减
if tokens >= requested then
    -- 够用：扣减令牌
    tokens = tokens - requested
    -- 将最新的时间和剩余令牌写回 Redis
    redis.call('HMSET', key, 'last_time', now, 'tokens', tokens)
    
    -- 可选：设置个过期时间，防止冷数据的 Key 永远占用内存 (按装满桶需要的时间计算)
    redis.call('EXPIRE', key, math.ceil(capacity / rate) + 10)
    
    return 1 -- 返回 1 表示放行
else
    -- 不够用：拒绝请求。
    -- 注意：被拒绝时，也要把刚才计算的最新时间（now）和累加过的残余令牌（tokens）写回去，
    -- 这样可以把 0.x 个令牌积攒起来，留给下一次请求。
    redis.call('HMSET', key, 'last_time', now, 'tokens', tokens)
    
    return 0 -- 返回 0 表示限流排队/丢弃
end
```

## JWT

JWT是token验证的一种实现方式

#### 利用token进行用户身份验证的流程

1、客户端使用用户名和密码请求登录

2、服务端收到，验证用户名和密码

3、验证成功后，服务端会签发一个token，再把token返回客户端

4、客户端收到token之后可以把它存储起来，比如放到cookie中

5、客户端每次向服务端请求资源时，需要携带服务端签发的token，可以在cookie或者header中携带

6、服务端收到请求，然后去验证客户端请求里面带着token，如果验证成功，就向客户端返回请求数据

#### cookie、session有什么区别

1、cookie存储在用户电脑的浏览器上，他人可以刨析存放在当地的cookie并展开cookie蒙骗，

2、session会在一段时间内存储在服务器上，访问增多时，会影响服务器性能

3、cookie存储限制了数据量只允许4K，而session可以认为是无限的

#### 基于session和cookie的用户认证

由于只使用cookie会有安全问题，所以产生了两种会话技术结合的方式

1、客户端使用用户名和密码请求登录

2、服务端收到之后，验证用户名和密码

3、验证成功之后，服务端会将信息保存在session中，并将sessionID返回

4、客户端收到session之后可以把它存储起来，比如放到cookie中

5、客户端每次向服务端请求时，将sessionID存放到cookie中携带过去

6、服务端收到请求之后，通过sessionID获取用户信息

缺点：

1、随着用户增多，服务器开销会明显增大

2、session存储在服务器的内存中，在分布式系统中，这种方式将会失效

3、cookie无法跨域，所以session的认证也无法跨域，对单点登录不适用

#### JWT组成

头部+负载+签名

头部：有令牌的类型和所使用的签名算法

负载：声明是有关实体（通常是用户）和其他数据的声明，不放用户敏感的信息，如密码。

签名：使用编码后的header和payload加上我们提供的一个密钥，保证JWT没有被篡改过

#### 开发中的使用

1. 在登录验证通过后，给用户生成一个对应的随机token（注意这个token不是jwt，可以用uuid等算法生成）然后将这个token作为key的一部分，用户信息作为value存入redis，并设置过期时间，这个过期时间就是登录失效的时间
2. 将第1步中生成的随机token作为JWT的payload生成的JWT字符串返回给前端
3. 前端之后每次请求都在请求头中的Authorization字段中携带JWT字符串
4. 后端定义拦截器，每次收到前端请求时，都先从请求头中的Authorization字段中取出JWT字符串并进行验证，验证通过后解析除payload中的随机token，然后再用这个随机token得到key，从Redis中获取用户信息，如果能获取到就说明用户已经登录

#### Cookie的跨域问题

​`cookie`​不具有跨域性质，只会将属于该域名的`cookie`​信息添加到`header`​中传到`server`端。

这个域名如果没有指定`domain`字段的话，浏览器会默认加上，加上浏览器访问的域名，如果指定了domain字段的话。浏览器就会将这个字段里的域名和自己的域名对比，一样的时候才可以访问到，如果不一样是不能访问的

## 加密

### bcrypt

原理：

是一种加盐的加密方法，MD5加密时候，同一个密码经过hash的时候生成的是同一个hash值，在大数据的情况下，有些经过`md5`加密的方法将会被破解.

使用Bcrypt进行加密，同一个密码每次生成的hash值都是不相同的。 每次加密的时候首先会生成一个随机数就是盐，之后将这个随机数与密码进行hash，得到一个hash值存到数据库。 当用户在登陆的时候，输入的是明文的密码， 从数据库中取出保存密码对其hash值进行分离，前面的22位就是加的盐，之后将随机数与前端输入的密码进行组合求hash值判断是否相同。

# 字符编码

[原文](https://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html)

# DNS排查

[文章](https://juejin.cn/post/7029513668946018317)

## 域名状态

通过whois查询发现域名处于clienthold、serverhold、inactive这三种状态，一般可以确认为域名状态异常导致解析错误。另外如果域名过期没有及时续费，也是会导致解析出错的。

## 机器未配置DNS配置

查看并配置`/etc/resolv.con`DNS服务器

实在不行直接修改`/etc/hosts`文件

# CDN

## CDN的概念

CDN（​**内容分发网络**）是指一种通过互联网互相连接的电脑网络系统，利用最靠近每位用户的服务器，更快、更可靠地将音乐、图片、视频、应用程序及其他文件发送给用户，来提供高性能、可扩展性及低成本的网络内容传递给用户。

典型的CDN系统由下面三个部分组成：

- **分发服务系统：** 最基本的工作单元就是Cache设备，cache（边缘cache）负责直接响应最终用户的访问请求，把缓存在本地的内容快速地提供给用户。同时cache还负责与源站点进行内容同步，把更新的内容以及本地没有的内容从源站点获取并保存在本地。Cache设备的数量、规模、总服务能力是衡量一个CDN系统服务能力的最基本的指标。
- **负载均衡系统：** 主要功能是负责对所有发起服务请求的用户进行访问调度，确定提供给用户的最终实际访问地址。两级调度体系分为全局负载均衡（GSLB）和本地负载均衡（SLB）。**全局负载均衡**主要根据用户就近性原则，通过对每个服务节点进行“最优”判断，确定向用户提供服务的cache的物理位置。**本地负载均衡**主要负责节点内部的设备负载均衡
- **运营管理系统：** 运营管理系统分为运营管理和网络管理子系统，负责处理业务层面的与外界系统交互所必须的收集、整理、交付工作，包含客户管理、产品管理、计费管理、统计分析等功能。

## CDN的作用

CDN一般会用来托管Web资源（包括文本、图片和脚本等），可供下载的资源（媒体文件、软件、文档等），应用程序（门户网站等）。使用CDN来加速这些资源的访问。

1. 在性能方面，引入CDN的作用在于：

   1. 用户收到的内容来自最近的数据中心，延迟更低，内容加载更快
   2. 部分资源请求分配给了CDN，减少了服务器的负载
2. 在安全方面，CDN有助于防御DDoS、MITM等网络攻击：

   1. 针对DDoS：通过监控分析异常流量，限制其请求频率
   2. 针对MITM：从源服务器到 CDN 节点到 ISP（Internet Service Provider），全链路 HTTPS 通信除此之外，CDN作为一种基础的云服务，同样具有资源托管、按需扩展（能够应对流量高峰）等方面的优势。

## CDN的原理

CDN和DNS有着密不可分的联系，先来看一下DNS的解析域名过程，在浏览器输入 www.test.com 的解析过程如下：

1. 检查浏览器缓存
2. 检查操作系统缓存，常见的如`hosts`文件
3. 检查路由器缓存
4. 如果前几步都没没找到，会向ISP(网络服务提供商)的LDNS服务器查询
5. 如果LDNS服务器没找到，会向根域名服务器(Root Server)请求解析，分为以下几步：

   1. 根服务器返回顶级域名(TLD)服务器如`.com`​，`.cn`​，`.org`​等的地址，该例子中会返回`.com`的地址
   2. 接着向顶级域名服务器发送请求，然后会返回次级域名(SLD)服务器的地址，本例子会返回`.test`的地址
   3. 接着向次级域名服务器发送请求，然后会返回通过域名查询到的目标IP，本例子会返回`www.test.com`的地址
   4. ​`Local DNS Server`会缓存结果，并返回给用户，缓存在系统中

## CDN的工作原理

1. 用户未使用CDN缓存资源的过程

   1. 浏览器通过DNS对域名进行解析（就是上面的DNS解析过程），依次得到此域名对应的IP地址
   2. 浏览器根据得到的IP地址，向域名的服务主机发送数据请求
   3. 服务器向浏览器返回响应数据
2. 用户使用CDN缓存资源的过程：

   1. 对于点击的数据的URL，经过本地DNS系统的解析，发现该URL对应的是一个CDN专用的DNS服务器，DNS系统就会将域名解析权交给CNAME指向的CDN专用的DNS服务器。
   2. CND专用DNS服务器将CDN的全局负载均衡设备IP地址返回给用户
   3. 用户向CDN的全局负载均衡设备发起数据请求
   4. CDN的全局负载均衡设备根据用户的IP地址，以及用户请求的内容URL，选择一台用户所属区域的区域负载均衡设备，告诉用户向这台设备发起请求
   5. 区域负载均衡设备选择一台合适的缓存服务器来提供服务，将该缓存服务器的IP地址返回给全局负载均衡设备
   6. 全局负载均衡设备把服务器的IP地址返回给用户
   7. 用户向该缓存服务器发起请求，缓存服务器响应用户的请求，将用户所需内容发送至用户终端。

如果缓存服务器没有用户想要的内容，那么缓存服务器就会向它的上一级缓存服务器请求内容，以此类推，直到获取到需要的资源。最后如果还是没有，就会回到自己的服务器去获取资源。

![](http://127.0.0.1:55684/assets/network-asset-asynccode-20260419162736-d406htw.png)

CNAME（意为：别名）：在域名解析中，实际上解析出来的指定域名对应的IP地址，或者该域名的一个CNAME，然后再根据这个CNAME来查找对应的IP地址。

# Ssh

SSH 是一种网络安全协议，通过加密和认证机制实现安全的访问和文件传输等业务。

传统远程登录（Telnet）或文件传输方式（FTP）使用明文传输数据，存在很多的安全隐患。

## SSH端口号是什么？

当SSH应用于STelnet，SFTP以及SCP时，使用的默认SSH端口都是`22`​。当`SSH`​应用于`NETCONF`​时，可以指定`SSH`​端口是`22`​或者`830`​。`SSH`​端口支持修改，更改后当前所有的连接都会断开，`SSH`服务器开始侦听新的端口。

## SSH是如何工作的？

SSH由**服务器和客户端**组成，在整个通信过程中，为建立安全的SSH通道，会经历如下几个阶段：

### 连接建立

SSH服务器在指定的端口侦听客户端的连接请求，在客户端向服务器发起连接请求后，双方建立一个TCP连接。

### 版本协商

SSH存在不同版本，`2.0`​版本多了一些拓展，支持更多认证和交换密钥方式，同时提高了服务能力。**SSH服务器和客户端通过协商确定最终使用的SSH版本号。**

### 算法协商

协商出

1. 最终用于产生**会话密钥**的密钥交换算法、
2. 用于**数据信息加密**的加密算法、
3. 用于**进行数字签名和认证**的公钥算法
4. 用于**数据完整性保护**的HMAC算法。

### 密钥交换

服务器和客户端通过密钥交换算法，动态生成共享的会话密钥和会话ID，建立加密通道。**会话密钥主要用于后续数据传输的加密，会话ID用于在认证过程中标识该SSH连接。**

### 用户认证

SSH客户端向服务器端发起认证请求，服务器端对客户端进行认证。SSH支持以下几种认证方式：

- 密码认证
- 密钥(publickey)认证：客户端通过用户名，公钥以及公钥算法等信息来与服务器进行认证。
- ​`password-publickey`认证：指用户需要同时满足密码认证和密钥认证才能登录。
- all认证：只要满足**密码认证和密钥认证**其中一种即可。

### 会话请求

认证通过后，SSH客户端向服务器端发送会话请求，请求服务器提供某种类型的服务，即请求与服务器建立相应的会话。

### 会话交互

会话建立后，SSH服务器端和客户端在该会话上进行数据信息的交互。

## SSH密钥认证登录流程

- 在进行`SSH`​连接之前，`SSH`​客户端需要先生成自己的​**公钥私钥对**​，并将自己的**公钥存放在**​**​`SSH`​**​​**服务器上**。
- ​`SSH`​客户端发送登录请求，`SSH`​服务器就会根据请求中的用户名等信息在本地搜索客户端的公钥，并用这个公钥加密一个`随机数`发送给客户端。
- 客户端使用自己的私钥对返回信息进行解密，并发送给服务器。
- 服务器验证客户端解密的信息是否正确，如果正确则认证通过。

# `paseto`​和`jwt`

## JWT 的弃用

1. 可选择的加密算法参差不齐，有些已经失效12
2. 黑客可以将非对称加密方式更改为对称加密，然后使用公钥加密JWT然后欺骗服务器

## PASETO 的使用

1. 算法强大而稳定，使用者只需要考虑其版本即可。
2. PASETO 也存在两套加密算法。本地使用对称加密。外部使用非对称。
3. PASETO 对整个token进行加密和验证,无法伪造算法头
4. PASETO 分为四个部分

   1. 本地: 1. 版本号 v2 2. 使用场景 3. 有效载荷 1. 数据信息和到期时间 2. nonce 用于加密和消息认证过程中 3. 消息认证标签 用于验证加密消息和与其关联的未加密消息(版本号，使用场景和页脚) 4. 公共信息(仅用base64编码)
   2. 外部: 1. 版本号 2. 使用场景 3. 有效载荷 1. 数据信息和到期时间(base64编码) 2. 使用私钥进行加密的数字证书用于校验真实性

# 接口执行缓慢排查

1. 首先排查是不是网络问题：和网络运营商联系解决。
2. 查机器负载

   1. ​`free -m`​：内存高：内存泄露；频繁`gc`​导致`CPU`满了
   2. ​`top -c`​：CPU高：死循环等  
      **通过pprof查看包括(阻塞信息、cpu信息、内存堆信息、锁信息、goroutine信息等等)**
3. 日志信息查询：第三方接口对接（尝试异步化）

   1. 查`redis slowlog`​（slowlog 最直接简单）  
      本地抓包，看日志中 redis 的 `get key` 网络耗时跟日志的时间是否对的上；
   2. 数据库查询。

## 调试Go程序

### 调试Go程序

[原文](https://github.com/aceld/golang/blob/main/1%E3%80%81%E6%9C%80%E5%B8%B8%E7%94%A8%E7%9A%84%E8%B0%83%E8%AF%95golang%E7%9A%84bug%E4%BB%A5%E5%8F%8A%E6%80%A7%E8%83%BD%E9%97%AE%E9%A2%98%E7%9A%84%E5%AE%9E%E8%B7%B5%E6%96%B9%E6%B3%95%EF%BC%9F.md)

#### 如何分析程序的运行时间与CPU利用率情况？

1. ​`shell`​内置`time`指令

   ```Shell
   $ time go run test2.go 
   &{{0 0} 张三 0}

   real        0m0.843s
   user        0m0.216s
   sys         0m0.389s
   ```

   上面是使用time对 `go run test2.go`对执行程序坐了性能分析，得到3个指标。

   1. ​`real`：从程序开始到结束，实际度过的时间；
   2. ​`user`：程序在用户态度过的时间；
   3. ​`sys`​：程序在内核态度过的时间。  
      一般情况下 `real`​ \>\= `user`​ + `sys`，因为系统还有其它进程(切换其他进程中间对于本进程会有空白期)。

#### 如何分析golang程序的内存使用情况？

1. ##### 内存占用情况查看

   ​`$top -p $(pidof 程序名)`

   ![](http://127.0.0.1:55684/assets/network-asset-asynccode-20260419162739-nm5bz94.png)

   没有退出的snippet\_mem进程有约830m的内存被占用。
2. ##### GODEBUG与gctrace

   用法

   执行`程序`​之前添加环境变量`GODEBUG='gctrace=1'`来跟踪打印垃圾回收器信息

   ​`$ GODEBUG='gctrace=1' ./snippet_mem`

   设置`gctrace=1`会使得垃圾回收器在每次回收时汇总所回收内存的大小以及耗时， 并将这些内容汇总成单行内容打印到标准错误输出中。

   格式：

   ​`gc # @#s #%: #+#+# ms clock, #+#/#/#+# ms cpu, #->#-># MB, # MB goal, # P`

   含义：

   ```Python
           gc #        GC次数的编号，每次GC时递增
           @#s         距离程序开始执行时的时间
           #%          GC占用的执行时间百分比
           #+...+#     GC使用的时间
           #->#-># MB  GC开始，结束，以及当前活跃堆内存的大小，单位M
           # MB goal   全局堆内存大小
           # P         使用processor的数量
   ```
   如果每条信息最后，以`(forced)`​结尾，那么该信息是由`runtime.GC()`调用触发

   eg：

   ​`gc 17 @0.149s 1%: 0.004+36+0.003 ms clock, 0.009+0/0.051/36+0.006 ms cpu, 181->181->101 MB, 182 MB goal, 2 P`

   该条信息含义如下：

   - ​`gc 17`: Gc 调试编号为17
   - ​`@0.149s`:此时程序已经执行了0.149s
   - ​`1%`: 0.149s中其中gc模块占用了1%的时间
   - ​`0.004+36+0.003 ms clock`: 垃圾回收的时间，分别为STW（stop-the-world）清扫的时间+并发标记和扫描的时间+STW标记的时间
   - ​`0.009+0/0.051/36+0.006 ms cpu`: 垃圾回收占用cpu时间
   - ​`181->181->101 MB`： GC开始前堆内存181M， GC结束后堆内存181M，当前活跃的堆内存101M
   - ​`182 MB goal`: 全局堆内存大小
   - ​`2 P`: 本次GC使用了2个P(调度器中的Processer)
3. ​`runtime.ReadMemStats`​  
   换另一种方式查看内存的方式 利用 runtime库里的`ReadMemStats()`方法

   ```Go
   var ms runtime.MemStatsruntime.ReadMemStats(&ms)
   runtime.ReadMemStats(&ms)
   log.Printf(" ===> Alloc:%d(bytes) HeapIdle:%d(bytes) HeapReleased:%d(bytes)", ms.Alloc, ms.HeapIdle, ms.HeapReleased)
   ```
   ```Go
   $ go run demo2.go 
   2020/03/02 18:21:17  ===> [Start].
   2020/03/02 18:21:17  ===> Alloc:71280(bytes) HeapIdle:66633728(bytes) HeapReleased:66600960(bytes)
   2020/03/02 18:21:17  ===> loop begin.
   2020/03/02 18:21:18  ===> Alloc:132535744(bytes) HeapIdle:336756736(bytes) HeapReleased:155721728(bytes)
   2020/03/02 18:21:38  ===> loop end.
   2020/03/02 18:21:38  ===> Alloc:598300600(bytes) HeapIdle:609181696(bytes) HeapReleased:434323456(bytes)
   2020/03/02 18:21:38  ===> [force gc].
   2020/03/02 18:21:38  ===> [Done].
   2020/03/02 18:21:38  ===> Alloc:55840(bytes) HeapIdle:1207427072(bytes) HeapReleased:434266112(bytes)
   2020/03/02 18:21:38  ===> Alloc:56656(bytes) HeapIdle:1207394304(bytes) HeapReleased:434266112(bytes)
   2020/03/02 18:21:48  ===> Alloc:56912(bytes) HeapIdle:1207394304(bytes) HeapReleased:1206493184(bytes)
   2020/03/02 18:21:58  ===> Alloc:57488(bytes) HeapIdle:1207394304(bytes) HeapReleased:1206493184(bytes)
   2020/03/02 18:22:08  ===> Alloc:57616(bytes) HeapIdle:1207394304(bytes) HeapReleased:1206493184(bytes)
   c2020/03/02 18:22:18  ===> Alloc:57744(bytes) HeapIdle:1207394304(bytes) HeapReleased:1206493184(by
   ```
4. pprof工具  
   pprof工具支持网页上查看内存的使用情况，需要在代码中添加一个协程即可。

   ```Go
   import(
           "net/http"
           _ "net/http/pprof"
   )

   go func() {
           log.Println(http.ListenAndServe("0.0.0.0:10000", nil))
   }()
   ```
   我们正常运行程序，然后同时打开浏览器，

   输入地址：[http://127.0.0.1:10000/debug/pprof/heap?debug=1](http://127.0.0.1:10000/debug/pprof/heap?debug=1)

   浏览器的内容其中有一部分如下，记录了目前的内存情况

   **通过pprof查看包括(阻塞信息、cpu信息、内存堆信息、锁信息、goroutine信息等等)**
5. 可视化查看  
   ​`go tool pprof ./demo4 profile`​需要`graphviz`
