---
title: "计算机网络学习" # 标题
subtitle: "计算机网络学习" # 副标题
description: "计算机网路总结,来自小林coding" # 文章内容描述
date: 2023-04-26T00:05:23+08:00 # 时间
lastmod: 2023-04-26T00:05:23+08:00 # 上次修改时间
tags: ["计网"] # 标签
categories: ["计网","总结"] # 分类
featuredImagePreview: "https://raw.githubusercontent.com/0RAJA/img/main/20230426000844-071-1652169609_225303.jpg" # 封面链接
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人
---
<!--more-->

# 计网总结

## OSI七层模型

OSI七层模型：应用层、表示层、会话层、运输层、网络层、数据链路层、物理层

TCP/IP 四层模型： 应用层、运输层、网络层、网络接口层

五层模型：应用层、运输层、网络层、数据链路层、物理层

### 应用层，表示层，会话层

1. 应用层：负责给应用程序提供统一的接口。

2. 表示层：主要负责数据格式的转换，压缩与解压缩，加密与解密，为系统提供特殊的数据处理能力，负责把数据转换成兼容另一个系统能识别的格式。
3. 会话层：是在发送方和接收方之间进行通信时创建、维持、之后终止或断开连接的地方，与电话通话有点相似。主要功能是对会话进行管理和控制，保证会话的可靠传输。

但是实际上表示层和会话层并未完全的独立实现，不同的应用程序有大同小异的会话表示需求，这些代码并不能完全抽象出独立的会话层、表示层。现在各个应用层协议已经比较完美并符合自我的实现了会话层和表示层，自身已经完成了上三层协议，因此在实际工业层面的实现中，将上三层协议划分在一起，称之为应用层。

主要用到的协议有HTTP、FTP、Telnet、DNS、SMTP

### 传输层

该层的协议为应用进程提供端到端的传输服务。主要用到的协议有TCP，UDP

### 网络层

在网络中进行通信的两个计算机之间回经过很多的通信子网。网络层的作用就是选择合适的网间路由和交换节点进行路由转发，确保数据及时送达。网络层把运输层产生的报文段封装成分组和包进行传送。在TCP/IP体系中，由于网络层使用IP协议，因此分组也叫IP数据报，简称数据报。

主要协议有IP、ICMP 。

### 数据链路层

主机之间通信总是在一段一段的链路上进行传送的，而数据链路层就是作用在这一个个链路上的协议。两个相邻节点之间传送数据时，数据链路层将网络层传来的IP数据报组装成帧，在两个相邻节点之间的链路上传送。每一帧包括数据和必要的控制信息。

数据的封帧和差错检测，以及 MAC 寻址；

### 物理层

物理层上所传输的数据单位是比特。

负责在物理网络中传输数据帧。

## 网络请求流程

![简单的网络模型](https://raw.githubusercontent.com/0RAJA/img/main/20230426002909-706-20230426000547-554-2.jpg)

### 应用层

#### HTTP

1. 解析URL 获取请求信息

   ![URL 解析](https://raw.githubusercontent.com/0RAJA/img/main/20230426002920-068-3-20230426002919414.jpg)

2. 生成HTTP请求报文

   需要：**请求方法，URL，版本，请求头，请求体**

   ![HTTP 的消息格式](https://raw.githubusercontent.com/0RAJA/img/main/20230426000547-554-4.jpg)

3. DNS查询IP

   域名解析：本地DNS->根->顶级->权威(解析结果的出处找到IP)->本地DNS->应用程序，亲力亲为。

   通过DNS服务器将目标域名转换为目标IP(浏览器域名缓存->操作系统缓存->hosts文件->本地DNS服务器)

生成HTTP报文后将传输工作通过Socket给协议栈。

#### Socket

	是应用程序中的编程接口API，是对传输层的抽象封装，可以更方便地调用TCP/IP协议的功能。

![基于 TCP 协议的客户端和服务器工作](https://raw.githubusercontent.com/0RAJA/img/main/20230426002929-410-format%252Cpng-20230426002928817.png)

- 服务端和客户端初始化 `socket`，得到文件描述符；
- 服务端调用 `bind`，将 socket 绑定在指定的 IP 地址和端口；
- 服务端调用 `listen`，进行监听；
- 服务端调用 `accept`，等待客户端连接；
- 客户端调用 `connect`，向服务器端的地址和端口发起连接请求；
- 服务端 `accept` 返回用于传输的 `socket` 的文件描述符；
- 客户端调用 `write` 写入数据；服务端调用 `read` 读取数据；
- 客户端断开连接时，会调用 `close`，那么服务端 `read` 读取数据的时候，就会读取到了 `EOF`，待处理完数据后，服务端调用 `close`，表示连接关闭。

#### 协议栈

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000547-646-7.jpg)

上半部分TCP/IP收发数据，下半部分IP协议（切片，路由），IP中还存在ICMP（告知传输错误），ARP协议（IP换MAC）。

IP 下面的网卡驱动程序负责控制网卡硬件，而最下面的网卡则负责完成实际的收发操作，也就是对网线中的信号执行发送和接收操作。

### 传输层

HTTP基于TCP协议进行传输。

#### TCP

![TCP 包头格式](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/键入网址过程/8.jpg)

需要：

1. 源端口，目标端口
2. 包序号：解决包乱序
3. 确认号：确认是否送达，解决丢包。
4. 状态位：`SYN`发起连接，`ACK`回复，`RST`重连，`FIN`结束。
5. 窗口大小：流量控制，调整速率。
6. 拥塞控制：控制速率。

查看tcp连接状态：`netstat -napt`

功能：

1. 三次握手：保证双方都有发送和接收的能力
2. 分割数据：HTTP长度超过MSS进行分片

TCP报文生成后交给网络层处理。

### 网络层

#### IP

TCP在连接，收发，断开等操作时，都需要IP模块将数据封装为网络包进行通信。

IP报文：

![IP 包头格式](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/键入网址过程/14.jpg)

需要：

1. 源IP，目标IP

   存在多个网卡时，通过路由表规则判断选择哪个IP。即选择和目标IP处于同一网段的网卡IP作为源IP，如果没有就选择路由IP，后续把包发给路由器。

2. 协议号：TCP

### 网络接口层

生成了 IP 头部之后，接下来网络包还需要在 IP 头部的前面加上 **MAC 头部**。

#### MAC

![MAC 包头格式](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/键入网址过程/18.jpg)

MAC头部是以太网使用的头部，包含：

1. 源和目标MAC地址

   源MAC在本机ROM中。目标MAC则需要通过ARP进行获取。先看ARP缓存，没有就对当前子网中所有设备广播ARP协议，然后获取到MAC。如果目标和自己不在同一网段，就ARP网关，获取对方MAC地址，把数据发给网关。

2. 协议类型：TCP/IP中一般只有IP和ARP协议。

#### 网卡

网卡驱动程序控制网卡将网络包转换为电信号。

网卡驱动获取网络包后会将其**复制**到网卡内的缓存区中，接着会在其**开头加上报头和起始帧分界符，在末尾加上用于检测错误的帧校验序列**。

![数据包](https://raw.githubusercontent.com/0RAJA/img/main/20230426000548-131-%E6%95%B0%E6%8D%AE%E5%8C%85.drawio.png)

#### linux下发送网络包：

1. 应用层：调用Socket发送数据包，陷入内核态，申请内核sk_buf并拷贝，进入发送缓冲区。

   传输层：从发送缓冲区取sk_buf按照协议栈处理（如果是TCP就拷贝一个新的sk_buf（丢失重传用）,sk_buf中data指针指向协议首部）。

   网络层：获取IP，填充IP，分片。

   网络接口层：ARP获取MAC，填充帧头帧尾。把sk_buf放在**发送队列**，触发软中断。

2. 网卡驱动程序从发送队列读取sk_buf挂在循环缓冲区。

3. 通过DMA读取数据进行发送。

4. 最后通过硬中断清理sk_buf和循环缓冲区。

#### linux下接收网络包：

1. 网卡收到网络包后，通过DMA将网络包写入到指定内存地址（环形缓冲区），触发硬中断

2. CPU执行对应中断处理函数：屏蔽中断（数据直接写入缓冲区），触发软中断

3. 内核中单独一个线程收到软中断后来轮训处理数据，从环形缓冲区中读一个数据帧(sk_buff)，交给网络协议栈处理。

4. 网络接口层：判断报文合法性，然后去除帧头帧尾，根据IP协议类型给网络层

   网络层：去除IP包判断下一步走向，如果是本机就查看上一层协议（TCP/UDP），去除IP头，给传输层

   传输层：取出TCP或UDP头，找到目标Socket，把数据放到Socket内核接收缓冲区。

   应用层：调用Scoket接口将内核缓冲区中的数据靠拷贝到应用层缓冲区，唤醒用户进程。

### 交换机

网卡会将包转为电信号，通过网线发送出去。电信号会被交换机所接收（交换机的端口不核对接收方 MAC 地址，而是直接接收所有的包并存放到缓冲区中。因此，和网卡不同，**交换机的端口不具有 MAC 地址**。）

将包存入缓冲区后交换机查询自身MAC表，找到目标MAC对应的端口进行发送。

> 如果找不到MAC记录？

交换机会将包发送给所有端口。

### 路由器

因为**路由器**是基于 IP 设计的，俗称**三层**网络设备，路由器的各个端口都具有 MAC 地址和 IP 地址；

当转发包时，首先路由器端口会接收发给自己的以太网包(MAC地址是自己)，然后**路由表**查询转发目标，再由相应的端口作为发送方将以太网包发送出去。

1. 查询路由表确定输出端口

   查询路由表，通过路由匹配查询同一子网的设备并进行转发，否则默认路由进行转发。

2. 路由器的发送操作

   * 如果目标网关是IP，则说明仍需要路由器进行转发
   * 如果目标网关为空，则说明到达目标地址。

   之后通过ARP协议获取目标IP的MAC地址，然后封包转发给目标。

## 应用层协议

### HTTP

#### 什么是HTTP

超文本传输协议，是一个应用层协议。HTTP是一个在计算机领域内，专门在两点之间传输文字、图片、音视频等超文本数据的约定和规范。

**常见字段**

*Host* 字段：客户端发送请求时，用来指定服务器的域名。

*Content-Length 字段*：服务器在返回数据时，会有 `Content-Length` 字段，表明本次回应的数据长度。

*Connection 字段*：`Connection` 字段最常用于客户端要求服务器使用 TCP 持久连接，以便其他请求复用。

*Content-Type 字段*：`Content-Type` 字段用于服务器回应时，告诉客户端，本次数据是什么格式。

*Content-Encoding 字段*：`Content-Encoding` 字段说明数据的压缩方法。表示服务器返回的数据使用了什么压缩格式

#### HTTP协议内容

![HTTP 的消息格式](https://raw.githubusercontent.com/0RAJA/img/main/20230426000547-554-4.jpg)

##### 请求报文

- 请求报文由三部分组成，分别是**请求行**、**请求头、请求正文**

- 请求方法：

  ![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000548-502-1418466-20180810112625596-2103906128.png)

  是否 安全，幂等？

  1. 安全：请求方法不会破坏服务器上资源
  2. 幂等：多次执行相同操作，结果相同。

##### 响应报文

- 响应报文也是由三个部分组成，分别是：**状态行、响应头、响应正文**
- 状态行由协议版本、数字形式的状态代码、及相应的状态描述，各元素之间以空格分隔。
- 状态码有：
  - `200 OK` 客户端请求成功
  - `301 Moved Permanently` 请求永久重定向
  - `302 Moved Temporarily` 请求临时重定向
  - `304 Not Modified` 文件未修改，可以直接使用缓存的文件。
  - `400 Bad Request` 由于客户端请求有语法错误，不能被服务器所理解。
  - `403 Forbidden` 服务器收到请求，但是拒绝提供服务。服务器通常会在响应正文中给出不提供服务的原因
  - `404 Not Found` 请求的资源不存在，例如，输入了错误的URL
  - `500 Internal Server Error` 服务器发生不可预期的错误，导致无法完成客户端的请求。
  - `503 Service Unavailable` 服务器当前不能够处理客户端的请求，在一段时间之后，服务器可能会恢复正常。

#### HTTP 缓存

##### 强制缓存（浏览器）

如果浏览器判断缓存未过期就用本地

![image-20220929223409644](https://raw.githubusercontent.com/0RAJA/img/main/20230426000548-646-image-20220929223409644.png)

利用两个HTTP响应头来表示有效期

`Cache-Control` 相对时间（优先） 和 `Expires`过期时间

##### 协商缓存（服务器）

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000548-936-%E7%BC%93%E5%AD%98etag.png)

**协商缓存这两个字段都需要配合强制缓存中 Cache-control 字段来使用，只有在未能命中强制缓存的时候，才能发起带有协商缓存字段的请求**。

#### HTTP1.0和HTTP1.1

##### HTTP1.0

1. 优点

   1. 简单

      报文格式：首部+body，首部信息也是kv形式。

   2. 灵活易拓展

      请求方法，URI和URL，状态码，头部字段等没有硬性要求。且因为其工作在应用层，下层可以随意替换。

   3. 应用广泛，跨平台

2. 缺点：

   1. 无状态：关联性操作很麻烦。
   2. 明文传输：易窃听
   3. 不验证通信方的身份，因此有可能遭遇伪装
   4. 无法证明报文的完整性，所以有可能已遭篡改

##### HTTP1.1

相比于1.0在性能上的改进，使用长链接，支持pipe。

连接方式：减少TCP建立次数

1. 短连接：每一个 HTTP 请求之前都会有一次 TCP 握手，耗费时间。

2. 长连接：一个长连接会保持一段时间，重复用于发送一系列请求，节省了新建 TCP 连接握手的时间，还可以利用 TCP 的性能增强能力。当然这个连接也不会一直保留着：连接在空闲一段时间后会被关闭。

   （支持pipe传输成为可能）

3. 流水线：流水线是在同一条长连接上发出连续的请求，而不用等待应答返回。这样可以避免连接延迟。

   但是服务器必须按照发送请求的顺序来响应这些请求。（容易出现响应的队头阻塞）

   与之相对应的非流水线方式是客户在收到前一个响应后才能发送下一个请求。（容易出现请求的队头阻塞）

#### HTTP1.1优化

##### 缓存：避免发送HTTP请求

第一次请求把`url-资源`缓存在本地，同时保存过期时间。过期就携带缓存摘要重新请求，服务器比较相同则返回304,

##### 减少HTTP请求次数

1. 重定向交给代理服务器

   而且当代理服务器知晓了重定向规则后，可以进一步减少消息传递次数

   依赖于重定向码的拓展

   ![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000549-091-%E9%87%8D%E5%AE%9A%E5%90%91%E5%93%8D%E5%BA%94%E7%A0%81.png)

2. 合并请求

   可以通过将多个小资源合并为一个大资源来请求。或者直接把数据一起发回来。

   1. 减少重复的http头部信息
   2. 减少TCP握手次数

   但是如果一个资源发生改变，需要重新请求所有数据。

3. 延迟发送

   按需请求数据。

##### 减少响应数据大小。

客户端：`Accept-Encoding`字段告知支持的加密方式。

服务端：`content-encoding` 告知加密方式。

#### HTTPS

`HTTP1.1`明文，不验证身份，不验证数据完整性。

`HTTPS`在应用层和传输层之间加入`SSL/TLS`协议保证安全性。

![HTTP 与 HTTPS 网络层](https://raw.githubusercontent.com/0RAJA/img/main/20230426000549-091-19-HTTPS%E4%B8%8EHTTP.png)

1. 信息加密：混合加密（对称和非对称加密）

   通信建立前采用非对称加密交换会话密钥，后续使用会话密钥对称加密数据。

   私钥加密，公钥解密：不会被修改（加密摘要）

   公钥加密，私钥解密：保证数据传输（加密信息）

2. 校验机制：摘要算法（服务端私钥加密）

3. 身份证书：服务器公钥给CA机构，防止被伪造

##### SSL/TLS协议

1. 客户端向服务端索要并验证服务器`公钥`。
2. 协商`会话密钥`
3. 采用`会话密钥`通信

##### RSA四次握手

用于计算`会话密钥`

1. 客户端请求：

   1. 支持`TLS/SSL协议`版本
   2. 客户端`随机数A`（公开）
   3. 客户端支持的加密算法（RSA）

2. 服务端请求：

   1. 确认`SSL/TLS`版本
   2. 服务端`随机数B`（公开）
   3. 确认加密算法
   4. 服务器证书

3. 客户端响应：

   先验证证书获取`服务器公钥`，生成`随机数C`，计算出`会话密钥`

   1. 公钥加密`随机数C`（加密信息）
   2. 标志加密
   3. 通信摘要

4. 服务器响应：

   根据`ABC`计算出`会话密钥`

   1. 标志加密
   2. 通信摘要

缺陷：不支持前向加密：服务器私钥泄漏后，之前的数据都可以解密。

##### ECDHE 握手

确认会话密钥算法：

> 双方确定`圆锥曲线`和`基点G`
>
> 客户端随机生成密钥`d1`，计算出公钥`Q1 = d1 * G`
>
> 服务端随机生成密钥`d2`，计算出公钥`Q2 = d2 * G`
>
> 客户端获取`Q2`,计算出`(x1,y1) = d1*Q2`
>
> 服务端获取`Q1`,计算出`(x2,y2) = d2*Q1`
>
> 因为`d1*Q2 = d1*d2*G = d2*Q1`，可以得到`x1 = x2`相同
>
> 所以`x`就是确定的会话密钥

1. 客户端：

   1. `Client Hello`
      1. 支持`TLS/SSL协议`版本
      2. 客户端`随机数X`（公开）
      3. 客户端支持的加密算法（ECDHE）

2. 服务端：

   1. `Server Hello`
      1. 确认`SSL/TLS`版本
      2. 服务端`随机数Y`（公开）
      3. 确认加密算法
         1. 密钥协商算法：ECDHE
         2. 签名算法：RSA
         3. 握手后通信使用AES对称算法
         4. 摘要算法

   2. `Certificate`：证书消息
   3. `Server Key Exchange`：选取的`椭圆曲线和基点G`
      1. 选好椭圆曲线
      2. 生成随机数`b`作为私钥,保留本地
      3. 服务器公钥`B`给服务端
      4. RSA摘要算法签名公钥（服务器私钥）。

   4. `Server Hello Done`：结束

3. 客户端

   客户端收到证书去CA校验并获取服务器公钥，使用服务器公钥验证公钥`B`。

   客户端生成`a`作为客户端私钥，椭圆曲线公钥`A`

   客户端计算出`会话密钥x`+客户端`随机数X`+服务端`随机数Y` = `会话密钥`

   1. `Client Key Exchange`

      客户端公钥`A`

   2. `Change Cipher Spec`：后续采用加密通信

   3. `Encrypted Handshake Message`：之前发送数据的摘要，使用会话密钥加密（验证是否可用）。

4. 服务端

   服务端拿到公钥`A`，算出`x`。

   服务端计算出`椭圆曲线x`+客户端`随机数X`+服务端`随机数Y`= `会话密钥`

   1. `Change Cipher Spec`：后续采用加密通信
   2. `Encrypted Handshake Message`：之前发送数据的加密摘要

提升：

1. 往返时间减少

   客户端可以在第三次握手后计算出密钥之后就发送数据，将2RTT减少为1RTT。

2. 重连恢复

   1. 会话复用Session：

      TLS握手后双方缓存`会话密钥`和`SessionID`标记这次TLS握手

      缺点：

      1. 服务端内存压力增大
      2. 服务器负载均衡，不一定命中缓存

   2. 把`会话密钥`加密成`token`给客户端保存

      注：`TLS1.3`直接第一次就把数据和`会话token`发送给服务端

      缺点：容易被截获（需要设置合理的过期时间）

##### 中间人问题

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/network/http/https中间人.drawio.png)

相当于客户端和中间人加密通信，中间人和服务器加密通信。

但是前提是我们可以从CA解析中间人提供的自己的服务器证书。

中间人能够解密数据需要：

1. 去服务端拿到私钥
2. 去CA签发私钥
3. 自己签发证书，需要被浏览器信任
   1. 本机中病毒，添加根证书
   2. 信任不受保护的连接

保护方式：可以采用双向认证。

#### HTTP2

![HTT/1 ~ HTTP/2](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/HTTP/25-HTTP2.png)

##### 基于HTTPS

##### HPACK 头部压缩

使用`HPACK算法`压缩头部，共同维护头信息表，每次发送可以只发送索引号

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000549-816-index.png)

`1`表示表中存在，剩下位数可以表示对应编号。

1. 静态字典

   存放常见的字段和对应的值

   ![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/http2/静态表.png)

   如果头部字段属于静态表范围，并且 Value 是变化，那么它的 HTTP/2 头部前 2 位固定为 `01`

   ![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/http2/静态头部.png)

   第二个字节的首个比特位表示 Value 是否经过 Huffman 编码，剩余的 7 位表示 Value 的长度，比如这次例子的第二个字节为 `10000110`，首位比特位为 1 就代表 Value 字符串是经过 Huffman 编码的，经过 Huffman 编码的 Value 长度为 6。

   ![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/http2/静态头部2.png)

2. 动态字典

   不在静态表中的字段就在huffman编码之后添加到双方动态表中，之后每次只需要发这个字段对应表中的下标即可。

   限制：

   1. 同一个连接下，相同的字段名
   2. 双方的字典占用会越来越大

##### 二进制帧

将原本HTTP纯文本更改为二进制帧形式（头信息帧+数据帧），计算机可以直接解析二进制数据。

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/http2/二进制帧.png)

二进制帧结构

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/http2/帧格式.png)

帧类型：控制帧，数据帧

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000550-556-%E5%B8%A7%E7%B1%BB%E5%9E%8B.png)

标志位：控制信息

- **END_HEADERS** 表示头数据结束标志，相当于 HTTP/1 里头后的空行（“\r\n”）；
- **END_Stream** 表示单方向数据发送结束，后续不会再有数据帧。
- **PRIORITY** 表示流的优先级；

流标志符（StreamID）：

它的作用是用来标识该 Frame 属于哪个 Stream，接收方可以根据这个信息从乱序的帧里找到相同 Stream ID 的帧，从而有序组装信息。

最后面就是**帧数据**了，它存放的是通过 **HPACK 算法**压缩过的 HTTP 头部或包体

##### 并发传输

引入`stram`概念。

1. 1个TCP中有多个`Stream`（一个HTTP的请求与响应都在一个`Stream`）
2. 一个`Stream`包含多个`Message` (一个请求或者响应)
3. 一个`Message`里面存着很多`二进制帧`，一个帧存一个二进制`头部`或`包体`

**不同`Stream`的`frame`可以乱序发送（frame中有stream id，可以被组装），但是一个`Stream`中的`frame`是顺序的。一个`frame`丢失则会阻塞后面的`frame`即其他响应。**

客户端主动建立的`Stream ID`为奇数

服务端主动建立的`Stream ID`为偶数

`Stream ID`有限，用完需要断开TCP连接。

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000550-752-http2%E5%A4%9A%E8%B7%AF%E5%A4%8D%E7%94%A8.jpeg)

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000551-252-stream.png)

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/http2/stream2.png)

##### 服务器推送

在 Nginx 中，如果你希望客户端访问 /test.html 时，服务器直接推送 /test.css，那么可以这么配置：

```nginx
location /test.html { 
  http2_push /test.css; 
}
```

客户端发起的请求，必须使用的是奇数号 Stream，服务器主动的推送，使用的是偶数号 Stream。服务器在推送资源时，会通过 `PUSH_PROMISE` 帧传输 HTTP 头部，并通过帧中的 `Promised Stream ID` 字段告知客户端，接下来会在哪个偶数号 Stream 中发送包体。

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000552-490-push2.png)

##### TCP队头阻塞

存在TCP层次的队头阻塞。

HTTP基于TCP，TCP是字节流协议，TCP层必须保证收到的字节数是完整且连续的，内核才会将内核缓冲区中的数据返回给应用。所以只要存在一个字节数据丢失，剩下的数据都会阻塞在内核缓冲区。

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/network/quic/http2阻塞.jpeg)

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/http3/tcp队头阻塞.gif)

packetID类似于tcp的序列号，其中一个丢失需要等待重传才会把数据给应用。

#### HTTP3

HTTP1.1 解决了发送方队头阻塞，但是存在服务端队头阻塞

HTTP2 解决了HTTP队头阻塞，但是丢包会阻塞所有HTTP请求。

所以HTTP3.0把TCP换成UDP

![HTTP/1 ~ HTTP/3](https://raw.githubusercontent.com/0RAJA/img/main/20230426000553-237-27-HTTP3.png)

##### QUIC

UDP不可靠，通过QUIC来实现可靠传输

###### 无队头阻塞

**当某个流发生丢包时，只会阻塞这个流，其他流不会受到影响，因此不存在队头阻塞问题**。

但是QUIC保证数据包的可靠性，每个数据包会有一个序号，即使该`Stream`中一个数据包丢失，该`Stream`中其他数据包也需要等待。

QUIC协议建立在UDP基础上，所以`Stream`之间彼此独立。

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/network/quic/quic无阻塞.jpeg)

###### 更快的连接建立

HTTP1或HTTP2，TLS和TCP是分层的，需要分批次去握手。

HTTP3中QUIC携带TLS，只需要1个往返时间就可以同时建立连接和密钥协商

![TCP HTTPS（TLS/1.3） 和 QUIC HTTPS ](https://raw.githubusercontent.com/0RAJA/img/main/20230426000553-871-28-HTTP3%E4%BA%A4%E4%BA%92%E6%AC%A1%E6%95%B0.png)

甚至在第二次连接时，数据包就可以和QUIC（连接信息+TLS信息）一起发送。

同时重新建立会话时间也很短

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000554-322-4cad213f5125432693e0e2a512c2d1a1.png)

###### 连接迁移

TCP使用`源IP，源端口，目标IP，目标端口`确定一条连接

在切换网络时需要重新建立TCP连接

QUIC通过`连接ID+TLS密钥等`确定一条连接。

#### 跨域资源共享

CORS 需要浏览器和服务器同时支持，整个 CORS 通信过程，都是浏览器自动完成，不需要用户参与。对于开发者来说，**CORS 通信与同源的 AJAX 通信没有差别，代码完全一样。浏览器一旦发现 AJAX 请求跨源，就会自动添加一些附加的头信息，有时还会多出一次附加的请求**，但用户不会有感觉。

浏览器将 CORS 请求分成两类：简单请求（simple request）和非简单请求（not-so-simple request）。

1. 简单请求

   只要同时满足以下两大条件，就属于简单请求。

   （1) 请求方法是以下三种方法之一：

   - HEAD
   - GET
   - POST

   （2）HTTP 的头信息不超出以下几种字段：

   - Accept
   - Accept-Language
   - Content-Language
   - Last-Event-ID
   - Content-Type：只限于三个值 `application/x-www-form-urlencoded`、`multipart/form-data`、`text/plain`

   这是为了兼容表单（form），因为历史上表单一直可以发出跨域请求。AJAX 的跨域设计就是，只要表单可以发，AJAX 就可以直接发。

##### 简单请求

对于简单请求，浏览器直接发出 CORS 请求。具体来说，就是在头信息之中，增加一个 `Origin` 字段。

```http
GET /cors HTTP/1.1
Origin: http://api.bob.com
Host: api.alice.com
Accept-Language: en-US
Connection: keep-alive
User-Agent: Mozilla/5.0...
```

上面的头信息中，`Origin` 字段用来说明，本次请求来自哪个源（协议 + 域名 + 端口）。服务器根据这个值，决定是否同意这次请求。

**如果 `Origin` 指定的源，不在许可范围内，服务器会返回一个正常的 HTTP 回应**。浏览器发现，这个回应的头信息没有包含 `Access-Control-Allow-Origin` 字段（详见下文），就知道出错了，从而抛出一个错误，被 `XMLHttpRequest` 的 `onerror` 回调函数捕获。注意，这种错误无法通过状态码识别，因为 HTTP 回应的状态码有可能是 200。

如果 `Origin` 指定的域名在许可范围内，服务器返回的响应，会多出几个头信息字段。

```http
Access-Control-Allow-Origin: http://api.bob.com
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: FooBar
Content-Type: text/html; charset=utf-8
```

**（1）Access-Control-Allow-Origin**

该字段是必须的。它的值要么是请求时 `Origin` 字段的值，要么是一个 `*`，表示接受任意域名的请求。

**（2）Access-Control-Allow-Credentials**

该字段可选。它的值是一个布尔值，表示是否允许发送 Cookie。默认情况下，Cookie 不包括在 CORS 请求之中。设为 `true`，即表示服务器明确许可，Cookie 可以包含在请求中，一起发给服务器。这个值也只能设为 `true`，如果服务器不要浏览器发送 Cookie，删除该字段即可。

**（3）Access-Control-Expose-Headers**

该字段可选。CORS 请求时，`XMLHttpRequest` 对象的 `getResponseHeader()` 方法只能拿到 6 个基本字段：`Cache-Control`、`Content-Language`、`Content-Type`、`Expires`、`Last-Modified`、`Pragma`。如果想拿到其他字段，就必须在 `Access-Control-Expose-Headers` 里面指定。上面的例子指定，`getResponseHeader('FooBar')` 可以返回 `FooBar` 字段的值。

**withCredentials属性**

上面说到，CORS 请求默认不发送 Cookie 和 HTTP 认证信息。如果要把 Cookie 发到服务器，一方面要服务器同意，指定 `Access-Control-Allow-Credentials` 字段。

```http
Access-Control-Allow-Credentials: true
```

另一方面，开发者必须在 AJAX 请求中打开 `withCredentials` 属性。

```javascript
var xhr = new XMLHttpRequest();
xhr.withCredentials = true;
```

否则，即使服务器同意发送 Cookie，浏览器也不会发送。或者，服务器要求设置 Cookie，浏览器也不会处理。

需要注意的是，如果要发送 Cookie，`Access-Control-Allow-Origin` 就不能设为星号，必须指定明确的、与请求网页一致的域名。同时，Cookie 依然遵循同源政策，只有用服务器域名设置的 Cookie 才会上传，其他域名的 Cookie 并不会上传，且（跨源）原网页代码中的 `document.cookie` 也无法读取服务器域名下的 Cookie。

##### 非简单请求

非简单请求是那种对服务器有特殊要求的请求，比如请求方法是 `PUT` 或 `DELETE`，或者 `Content-Type` 字段的类型是 `application/json`。

1. 预检请求

   非简单请求的 CORS 请求，会在正式通信之前，增加一次 HTTP 查询请求，称为 "预检" 请求（preflight）。

   浏览器先询问服务器，当前网页所在的域名是否在服务器的许可名单之中，以及可以使用哪些 HTTP 动词和头信息字段。只有得到肯定答复，浏览器才会发出正式的 `XMLHttpRequest` 请求，否则就报错。

   ```http
   OPTIONS /cors HTTP/1.1
   Origin: http://api.bob.com
   Access-Control-Request-Method: PUT
   Access-Control-Request-Headers: X-Custom-Header
   Host: api.alice.com
   Accept-Language: en-US
   Connection: keep-alive
   User-Agent: Mozilla/5.0...
   ```

   "预检" 请求用的请求方法是 `OPTIONS`，表示这个请求是用来询问的。头信息里面，关键字段是 `Origin`，表示请求来自哪个源。

   除了 `Origin` 字段，"预检" 请求的头信息包括两个特殊字段。

   **（1）Access-Control-Request-Method**

   该字段是必须的，用来列出浏览器的 CORS 请求会用到哪些 HTTP 方法，上例是 `PUT`。

   **（2）Access-Control-Request-Headers**

   该字段是一个逗号分隔的字符串，指定浏览器 CORS 请求会额外发送的头信息字段，上例是 `X-Custom-Header`。

2. 预检请求的回应

   服务器收到 "预检" 请求以后，检查了 `Origin`、`Access-Control-Request-Method` 和 `Access-Control-Request-Headers` 字段以后，确认允许跨源请求，就可以做出回应。

   ```http
   HTTP/1.1 200 OK
   Date: Mon, 01 Dec 2008 01:15:39 GMT
   Server: Apache/2.0.61 (Unix)
   Access-Control-Allow-Origin: http://api.bob.com
   Access-Control-Allow-Methods: GET, POST, PUT
   Access-Control-Allow-Headers: X-Custom-Header
   Content-Type: text/html; charset=utf-8
   Content-Encoding: gzip
   Content-Length: 0
   Keep-Alive: timeout=2, max=100
   Connection: Keep-Alive
   Content-Type: text/plain
   ```

   上面的 HTTP 回应中，关键的是 `Access-Control-Allow-Origin` 字段，表示 `http://api.bob.com` 可以请求数据。该字段也可以设为星号，表示同意任意跨源请求。

   **（1）Access-Control-Allow-Methods**

   该字段必需，它的值是逗号分隔的一个字符串，表明服务器支持的所有跨域请求的方法。注意，返回的是所有支持的方法，而不单是浏览器请求的那个方法。这是为了避免多次 "预检" 请求。

   **（2）Access-Control-Allow-Headers**

   如果浏览器请求包括 `Access-Control-Request-Headers` 字段，则 `Access-Control-Allow-Headers` 字段是必需的。它也是一个逗号分隔的字符串，表明服务器支持的所有头信息字段，不限于浏览器在 "预检" 中请求的字段。

   **（3）Access-Control-Allow-Credentials**

   该字段与简单请求时的含义相同。

   **（4）Access-Control-Max-Age**

   该字段可选，用来指定本次预检请求的有效期，单位为秒。上面结果中，有效期是 20 天（1728000 秒），即允许缓存该条回应 1728000 秒（即 20 天），在此期间，不用发出另一条预检请求。

### RPC

TCP采用无边界的数据流，需要应用层来定义消息格式来确认消息边界。

RPC和HTTP都是在应用层实现的协议或方法，RPC用于远程过程调用，属于一种方法，可以像调用本地方法一样调用远程方法，RPC在中间屏蔽了很多细节。

#### 服务发现

建立连接需要获取目标`IP+端口`，获取的过程就是服务发现。

RPC会通过中间服务商去保存相关信息，HTTP则通过DNS服务去获取`IP`。

#### 底层连接

HTTP1.1采用复用TCP长连接

RPC也是采用TCP长连接，同时会存在连接池来缓存连接。

#### 传输内容

同时通过TCP进行传输，所以都是消息头+消息体

HTTP1.1头部冗余，包体明文消耗大。

RPC可以根据好的协议来序列化结构体信息等。

但是HTTP2性能比RPC还好，所以很多RPC协议都底层采用HTTP2

### Websocket

> https://zhuanlan.zhihu.com/p/407711596
>
> https://www.infoq.cn/article/deep-in-websocket-protocol/

WebSocket 协议主要为了解决基于 HTTP/1.x 的 Web 应用无法实现服务端向客户端主动推送的问题，为了兼容现有的设施，WebSocket 协议使用与 HTTP 协议相同的端口，并使用 HTTP Upgrade 机制来进行 WebSocket 握手，当握手完成之后，通信双方便可以按照 WebSocket 协议的方式进行交互

WebSocket 使用 TCP 作为传输层协议，与 HTTP 类似，WebSocket 也支持在 TCP 上层引入 TLS 层，以建立加密数据传输通道，即 WebSocket over TLS, WebSocket 的 URI 与 HTTP URI 的结构类似，对于使用 80 端口的 WebSocket over TCP, 其 URI 的一般形式为 ws://host:port/path/query 对于使用 443 端口的 WebSocket over TLS, 其 URI 的一般形式为 wss://host:port/path/query

对大部分 web 开发者来说，上面这段描述有点枯燥，其实只要记住几点：

1. WebSocket 可以在浏览器里使用
2. 支持双向通信
3. 使用很简单

优点：

1. 支持双向通信，实时性更强。
2. 更好的二进制支持。
3. 较少的控制开销。连接创建后，ws 客户端、服务端进行数据交换时，协议控制的数据包头部较小。在不包含头部的情况下，服务端到客户端的包头只有 2~10 字节（取决于数据包长度），客户端到服务端的的话，需要加上额外的 4 字节的掩码。而 HTTP 协议每次通信都需要携带完整的头部。
4. 支持扩展。ws 协议定义了扩展，用户可以扩展协议，或者实现自定义的子协议。（比如支持自定义压缩算法等）

#### 握手

当客户端想要使用 WebSocket 协议与服务端进行通信时，首先需要确定服务端是否支持 WebSocket 协议，因此 WebSocket 协议的第一步是进行握手，WebSocket 握手采用 HTTP Upgrade 机制，客户端可以发送如下所示的结构发起握手 (请注意 WebSocket 握手只允许使用 HTTP GET 方法):

```c
GET /chat HTTP/1.1
Host: server.example.com
Upgrade: websocket // 必填
Connection: Upgrade // 必填
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Origin: http://example.com
Sec-WebSocket-Protocol: chat, superchat
Sec-WebSocket-Version: 13
```

客户端发起握手时除了设置 Upgrade 之外，还需要设置其它的 Header 字段

- `Connection: Upgrade`：表示要升级协议
- `Upgrade: websocket`：表示要升级到 websocket 协议。
- `Sec-WebSocket-Version: 13`：表示 websocket 的版本。如果服务端不支持该版本，需要返回一个 `Sec-WebSocket-Version`header，里面包含服务端支持的版本号。
- `Sec-WebSocket-Key`：与后面服务端响应首部的 `Sec-WebSocket-Accept` 是配套的，提供基本的防护，比如恶意的连接，或者无意的连接

服务端若支持 WebSocket 协议，并同意与客户端握手，**则应返回 101 的 HTTP 状态码，表示同意协议升级，同时应设置 Upgrade 字段并将值设置为 websocket, 并将 Connection 字段的值设置为 Upgrade**, 这些都是与标准 HTTP Upgrade 机制完全相同的，除了这些以外，服务端还应设置与 WebSocket 相关的头部字段:

- **| Sec-WebSocket-Accept |**, 必传，`Sec-WebSocket-Accept` 根据客户端请求首部的 `Sec-WebSocket-Key` 计算出来。
  - 将 `Sec-WebSocket-Key` 跟 `258EAFA5-E914-47DA-95CA-C5AB0DC85B11` 拼接。
  - 通过 SHA1 计算出摘要，并转成 base64 字符串。
- **| Sec-WebSocket-Protocol |,** 可选，若客户端在握手时传递了希望使用的 WebSocket 子协议，则服务端可在客户端传递的子协议列表中选择其中支持的一个，服务端也可以不设置该字段表示不希望或不支持客户端传递的任何一个 WebSocket 子协议
- **| Sec-WebSocket-Extensions |**, 可选，与 Sec-WebSocket-Protocol 字段类似，若客户端传递了拓展列表，可服务端可从中选择其中一个做为该字段的值，若服务端不支持或不希望使用这些扩展，则不设置该字段
- **| Sec-WebSocket-Version |**, 必传，服务端从客户端传递的支持的 WebSocket 协议版本中选择其中一个，若客户端传递的所有 WebSocket 协议版本对服务端来说都不支持，则服务端应立即终止握手，并返回 HTTP 426 状态码，同时在 Header 中设置 | Sec-WebSocket-Version | 字段向客户端指示自己所支持的 WebSocket 协议版本列表

#### 数据帧 (frame)

**WebSocket 以 frame 为单位传输数据，frame 是客户端和服务端数据传输的最小单元**，当一条消息过长时，通信方可以将该消息拆分成多个 frame 发送，接收方收到以后重新拼接、解码从而还原出完整的消息，在 WebSocket 中，frame 有多种类型，frame 的类型由 frame 头部的 Opcode 字段指示，WebSocket frame 的结构如下所示:

![img](https://pic2.zhimg.com/80/v2-4f09cf3daaa970c067f3e582d00b3fbd_720w.webp)

* FIN, 长度为 1 比特，该标志位用于指示当前的 frame 是消息的最后一个分段,除了最后一个 frame, 前面的 frame 的 FIN 字段都为 0, 最后一个 frame 的 FIN 字段为 1

* RSV1、2、3： 1 bit each

  除非一个扩展经过协商赋予了非零值以某种含义，否则必须为0
  如果没有定义非零值，并且收到了非零的RSV，则websocket链接会失败

* Opcode： 4 bit

  ```
  解释说明 “Payload data” 的用途/功能
  如果收到了未知的opcode，最后会断开链接
  定义了以下几个opcode值:
      %x0 : 代表连续的帧
      %x1 : text帧
      %x2 ： binary帧
      %x3-7 ： 为非控制帧而预留的
      %x8 ： 关闭握手帧
      %x9 ： ping帧
  %xA :  pong帧
  %xB-F ： 为非控制帧而预留的
  ```

* Mask： 1 bit

  ```
  表示是否要对数据载荷进行掩码操作。从客户端向服务端发送数据时，需要对数据进行掩码操作；从服务端向客户端发送数据时，不需要对数据进行掩码操作。
  如果服务端接收到的数据没有进行过掩码操作，服务端需要断开连接。
  如果 Mask 是 1，那么在 Masking-key 中会定义一个掩码键（masking key），并用这个掩码键来对数据载荷进行反掩码。所有客户端发送到服务端的数据帧，Mask 都是 1。
  ```

* Payload length： 7 bit | 7+16 bit | 7+64 bit

  ```
  “payload data” 的长度如果在0~125 bytes范围内，它就是“payload length”，
  如果是126 bytes， 紧随其后的被表示为16 bits的2 bytes无符号整型就是“payload length”，
  如果是127 bytes， 紧随其后的被表示为64 bits的8 bytes无符号整型就是“payload length”
  ```

* Masking-key： 0 or 4 bytes

  ```
  所有从客户端发送到服务器的帧都包含一个32 bits的掩码（如果“mask bit”被设置成1），否则为0 bit。一旦掩码被设置，所有接收到的payload data都必须与该值以一种算法做异或运算来获取真实值。（见下文）
  ```

* Payload data: (x+y) bytes

  ```
  它是"Extension data"和"Application data"的总和，一般扩展数据为空。
  ```

* Extension data: x bytes

  ```
  除非扩展被定义，否则就是0
  任何扩展必须指定其Extension data的长度
  ```

* Application data: y bytes

  ```
  占据"Extension data"之后的剩余帧的空间
  ```

**注意：这些数据都是以二进制形式表示的，而非ascii编码字符串**

#### 数据传递

一旦 WebSocket 客户端、服务端建立连接后，后续的操作都是基于数据帧的传递。

WebSocket 根据 `opcode` 来区分操作的类型。比如 `0x8` 表示断开连接，`0x0`-`0x2` 表示数据交互。

**数据分片**

WebSocket 的每条消息可能被切分成多个数据帧。当 WebSocket 的接收方收到一个数据帧时，会根据 `FIN` 的值来判断，是否已经收到消息的最后一个数据帧。

FIN=1 表示当前数据帧为消息的最后一个数据帧，此时接收方已经收到完整的消息，可以对消息进行处理。FIN=0，则接收方还需要继续监听接收其余的数据帧。

#### 连接保持 + 心跳

WebSocket 为了保持客户端、服务端的实时双向通信，需要确保客户端、服务端之间的 TCP 通道保持连接没有断开。然而，对于长时间没有数据往来的连接，如果依旧长时间保持着，可能会浪费包括的连接资源。

ping、pong 的操作，对应的是 WebSocket 的两个控制帧，`opcode` 分别是 `0x9`、`0xA`。

#### Sec-WebSocket-Key/Accept 的作用

1. 避免服务端收到非法的 websocket 连接
2. 确保服务端理解 websocket 连接。因为 ws 握手阶段采用的是 http 协议
3. 用浏览器里发起 ajax 请求，设置 header 时，Sec-WebSocket-Key 以及其他相关的 header 是被禁止的。这样可以避免客户端发送 ajax 请求时，意外请求协议升级（websocket upgrade）
4. 可以防止反向代理（不理解 ws 协议）返回错误的数据
5. Sec-WebSocket-Key 主要目的并不是确保数据的安全性，最主要的作用是预防一些常见的意外情况（非故意的）。

强调：Sec-WebSocket-Key/Sec-WebSocket-Accept 的换算，只能带来基本的保障，但连接是否安全、数据是否安全、客户端 / 服务端是否合法的 ws 客户端、ws 服务端，其实并没有实际性的保证。

#### 数据掩码的作用

WebSocket 协议中，数据掩码的作用是增强协议的安全性。但数据掩码并不是为了保护数据本身。

**为了防止早期版本的协议中存在的代理缓存污染攻击（proxy cache poisoning attacks）等问题。**

代理缓存污染攻击

在正式描述攻击步骤之前，我们假设有如下参与者：

- 攻击者、攻击者自己控制的服务器（简称 “**邪恶服务器**”）、攻击者伪造的资源（简称 “**邪恶资源**”）
- 受害者、受害者想要访问的资源（简称 “**正义资源**”）
- 受害者实际想要访问的服务器（简称 “**正义服务器**”）
- 中间代理服务器

攻击步骤一：

1. **攻击者**浏览器 向 **邪恶服务器** 发起 WebSocket 连接。根据前文，首先是一个协议升级请求。协议升级请求 实际到达 **代理服务器**。
2. **代理服务器** 将协议升级请求转发到 **邪恶服务器**。
3. **邪恶服务器** 同意连接，**代理服务器** 将响应转发给 **攻击者**。

由于 upgrade 的实现上有缺陷，**代理服务器** 以为之前转发的是普通的 HTTP 消息。因此，当**协议服务器** 同意连接，**代理服务器** 以为本次会话已经结束。

攻击步骤二：

1. **攻击者** 在之前建立的连接上，通过 WebSocket 的接口向 **邪恶服务器** 发送数据，且数据是精心构造的 HTTP 格式的文本。其中包含了 **正义资源** 的地址，以及一个伪造的 host（指向**正义服务器**）。（见后面报文）
2. 请求到达 **代理服务器** 。虽然复用了之前的 TCP 连接，但 **代理服务器** 以为是新的 HTTP 请求。
3. **代理服务器** 向 **邪恶服务器** 请求 **邪恶资源**。
4. **邪恶服务器** 返回 **邪恶资源**。**代理服务器** 缓存住 **邪恶资源**（url 是对的，但 host 是 **正义服务器** 的地址）。

受害者：

1. **受害者** 通过 **代理服务器** 访问 **正义服务器** 的 **正义资源**。
2. **代理服务器** 检查该资源的 url、host，发现本地有一份缓存（伪造的）。
3. **代理服务器** 将 **邪恶资源** 返回给 **受害者**。
4. **受害者** 卒。

最初的提案是对数据进行加密处理。基于安全、效率的考虑，最终采用了折中的方案：对数据载荷进行掩码处理。

## 传输层协议

### TCP

#### TCP基础认识

![image-20220110103518827](https://raw.githubusercontent.com/0RAJA/img/main/20230426000554-766-image-20220110103518827.png)

1. 序列号

   在建⽴连接时由计算机⽣成的随机数作为其初始值，通过 SYN 包传给接收端主机，每发送⼀次数据，就「累加」⼀次该「数据字节数」的⼤⼩。⽤来解决⽹络包乱序问题。

   **序列号是一个 32 位的无符号数，因此在到达 4G 之后再循环回到 0**。

2. 确认应答号

   指下⼀次「期望」收到的数据的序列号，发送端收到这个确认应答以后可以认为在这个序号以前的数据都已经被正常接收。⽤来解决不丢包的问题

   **序列号为当前端成功发送的数据位数，确认号为当前端成功接收的数据位数，SYN标志位和FIN标志位也要占1位**

3. 标志位

   ACK：该位为 1 时，「确认应答」的字段变为有效，TCP 规定除了最初建⽴连接时的 SYN 包之外该位必须设置为 1 。 

   RST：该位为 1 时，表示 TCP 连接中出现异常必须强制断开连接。 

   SYN：该位为 1 时，表示希望建⽴连接，并在其「序列号」的字段进⾏序列号初始值的设定。 

   FIN：该位为 1 时，表示今后不会再有数据发送，希望断开连接。当通信结束希望断开连接时，通信双⽅的主机之间就可以相互交换 FIN 位为 1 的 TCP 段
   
4. 选项

   ![TCP option 字段 - TFO](https://raw.githubusercontent.com/0RAJA/img/main/20230426000555-475-TCP%20option%E5%AD%97%E6%AE%B5%20-%20TFO.png)

> 为什么需要TCP协议?TCP工作在那一层?

`IP` 层是「不可靠」的，它不保证网络包的交付、不保证网络包的按序交付、也不保证网络包中的数据的完整性。

> 什么是TCP?
>

TCP是**面向连接,可靠的,基于字节流的传输层通信协议**.

1. 面向连接: 1对1

   不像UDP可以1对多

2. 可靠的：无论网络链路如何改变,TCP可以保证一个报文一定可以到达接收端.

3. 字节流：

   1.   分组：接收方需要规定消息边界
   2.   有序：在前一个TCP报文没到达之前不会把之后的数据交给应用层
   3.   去重：通过序列号去重

> TCP可靠性传输的实现.

1. 以字节为单位的滑动窗口

   TCP连接双方都有一个缓冲空间,TCP只允许另一端发送可接受的数据.

2. 超时重传

   当TCP发出一个段后会定时,如果不能及时收到目的端的确认将重发这个报文段.

3. 选择确定SACK

   当TCP收到数据后会发送确认(先进行校验,不成功就不回应)

4. TCP会将收到的数据进行排序和去重,然后交给应用层.

> 有一个 IP 的服务器监听了一个端口，它的 TCP 的最大连接数是多少？

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000555-535-format%252Cpng-20230426000551776.png)

- 文件描述符限制

  ，每个 TCP 连接都是一个文件，如果文件描述符被占满了，会发生 too many open files。Linux 对可打开的文件描述符的数量分别作了三个方面的限制：

  - **系统级**：当前系统可打开的最大数量，通过 cat /proc/sys/fs/file-max 查看；
  - **用户级**：指定用户可打开的最大数量，通过 cat /etc/security/limits.conf 查看；
  - **进程级**：单个进程可打开的最大数量，通过 cat /proc/sys/fs/nr_open 查看；

- **内存限制**，每个 TCP 连接都要占用一定内存，操作系统的内存是有限的，如果内存资源被占满后，会发生 OOM。


#### TCP三次握手,四次挥手


##### 三次握手连接建立

![TCP 三次握手](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4/网络/TCP三次握手.drawio.png)

初始状态：客户端和服务端都处于`close`状态，服务器监听端口，处于`listen`状态

###### 第一次

客户端随机初始化序列号`client_isn`，同时将`SYN=1`，发送`SYN`，之后处于`SYN_SENT`

> 第一次握手丢失怎么办？

1. 客户端

   迟迟接收不到服务端的`SYN-ACK`触发**超时重传**，重传`SYN`。每次重传时间间隔×2。

   `cat /proc/sys/net/ipv4/tcp_syn_retries # 查看重传次数`

###### 第二次

服务端接收后，初始化序列号`listen_isn`,初始化确认应答号`client_isn+1`，同时将`SYN`和`ACK`置1，发送`SYN-ACK`，之后处于`SYN_RCVD`

> 第二次握手丢失怎么办？

1. 客户端

   客户端以为自己的`SYN`丢失了，触发**超时重传**，重传`SYN`

2. 服务端

   触发**超时重传**,重传`SYN-ACK`，

   `cat /proc/sys/net/ipv4/tcp_synack_retries # 查看重传次数`

###### 第三次

客户端接收到报文后进行回应，初始化确认应答号`listen_isn+1`,最后把报文发送给服务端，之后处于`ESTABLISHED`**（可以携带数据）**；服务端收到应答报文后处于`ESTABLISHED`

> 第三次握手丢失了，会发生什么？

1. 服务端

   服务端会触发**超时重传**,重传`SYN-ACK`

   如果一直丢失直到重传上限，于是再等待一段时间（时间为上一次超时时间的 2 倍），之后便断开连接。

> 查看tcp状态

`netstat -napt`或`ss -napt`

![image-20221004165313666](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20221004165313666.png)

##### 三次握手细节

> 为什么是三次？

1. 防止旧连接的初始化

   如果两次握手则容易回应旧的请求来建立新的连接，而加入第三次握手则可以告知此请求有效。

2. 同步双方的序列号

   确保己方的序列号已经被对方准确接收

   1. 去重
   2. 排序
   3. 获知哪些数据包已经被接收（重传）

3. 避免资源浪费

   客户端的重复的SYN会导致服务端建立多个连接。

   **当然服务端可以通过上下文判断ACK是否有效**

> 每次初始化的序列号为啥不同呢？

1. 防止历史数据被下一个连接接收

   上一次连接发送的数据可能会被当前服务端接收。

   但如果初始值不同则大概率会避免历史报文被正常接收（当然也需要使用时间戳机制进一步确保）。

   eg：客户端和服务端建立一个 TCP 连接，在客户端发送数据包被网络阻塞了，然后超时重传了这个数据包，而此时服务端设备断电重启了，之前与客户端建立的连接就消失了，于是在收到客户端的数据包的时候就会发送 RST 报文。然后服务端和客户端建立新的连接，结果上一次阻塞的数据包到达服务端导致服务端正常接收。

2. 为了安全性：防止黑客伪造相同序列号的TCP报文

> 如何初始化序列号？

ISN随机数是会基于时钟计时器递增的

 ISN 随机生成算法：ISN = M + F (localhost, localport, remotehost, remoteport)。

- `M` 是一个计时器，这个计时器每隔 4 微秒加 1。
- `F` 是一个 Hash 算法，根据源 IP、目的 IP、源端口、目的端口生成一个随机数值。要保证 Hash 算法不能被外部轻易推算得出，用 MD5 算法是一个比较好的选择。

##### MSS和MTU

![MTU 与 MSS](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzIzLmpwZw?x-oss-process=image/format,png)

- `MTU`：一个网络包的最大长度，以太网中一般为 `1500` 字节；
- `MSS`：除去 IP 和 TCP 头部之后，一个网络包所能容纳的 TCP 数据的最大长度；

如果有超过**MTU**的数据包交给**IP**层，则IP层会进行分片然后交给目标方主机进行拼装再给TCP层。

但是如果一个IP分片丢失，则整个IP报文都需要重传。**而且需要TCP来进行重传**。

接收方TCP没收到数据也就不会响应ACK，于是发送方会超时重传**整个TCP头部和数据（以MTU为单位）**，且还需要IP进行分层。

但是如果TCP层就预先分层，则可以只发送**以MSS为单位的数据包**。

##### SYN 攻击

在 TCP 三次握手的时候，Linux 内核会维护两个队列，分别是：

* 半连接队列，也称 SYN 队列；
* 全连接队列，也称 accept 队列；

![正常流程](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzI2LmpwZw?x-oss-process=image/format,png)

1. 服务器接收到`SYN`请求，创建`半连接对象`放入`SYN队列`，然后发送`SYN-ACK`，之后等待
2. 服务端接收到`ACK`后从`SYN队列`取一个`半连接对象`创建为`全连接对象`放入`Accept队列`，应用通过`accept`取出全连接对象。

**如果两个队列满了，都会丢弃后续的报文。**

SYN攻击：一直发送不同`IP+端口`的`SYN`请求来打满`SYN`队列。

避免方式：

- 调大 netdev_max_backlog；

  可以增加网卡的接收队列，缓冲后续请求。

- 增大 TCP 半连接队列；

- 开启 tcp_syncookies；

  开启 syncookies 功能就相当于绕过了 SYN 半连接来建立连接。

  当`SYN队列`满了，服务器接收到后续报文会计算一个`Cookie`然后在第二次握手时传回去。当客户端发送第三次握手ACK时服务端只需要校验合法就可以直接放入`accept`队列。

  `net.ipv4.tcp_syncookies` 参数主要有以下三个值：

  - 0 值，表示关闭该功能；
  - 1 值，表示仅当 SYN 半连接队列放不下时，再启用它；
  - 2 值，表示无条件开启功能；

  `echo 1 > /proc/sys/net/ipv4/tcp_syncookies`

- 减少 SYN+ACK 重传次数

  `SYN攻击`时会有很多`SYN-ACK`的连接，可以减少重传次数。

##### 四次挥手连接断开

![客户端主动关闭连接 —— TCP 四次挥手](https://raw.githubusercontent.com/0RAJA/img/main/20230426000556-306-format%252Cpng-20230426000552079.png)

###### 第一次

客户端打算断开连接，发送`FIN=1`的报文，之后处于`FIN_WAIT_1`状态**（客户端不发送消息但仍然可以接收数据。）**

> 第一次挥手丢失怎么办？

触发**超时重传**，重传 FIN 报文，重发次数由 `tcp_orphan_retries` 参数控制。间隔主键×2。

达到上限就`close`

###### 第二次

服务端收到`FIN`，向客户端回复`ACK`报文，然后进入`CLOSE_WAIT`状态**（服务端仍可以发送数据）**

客户端接收到`ACK`，进入`FIN_WAIT_2`状态。

> 第二次挥手丢失怎么办？

1. 客户端

   客户端就会触发超时重传机制，重传 FIN 报文，直到收到服务端的第二次挥手，或者达到最大的重传次数就`close`。

   

   提醒：对于调用 close 关闭的连接（**无法发送和接收**），如果在 tcp_fin_timeout 秒后还没有收到 FIN 报文，客户端（主动关闭方）的连接就会直接关闭。
   
   但是如果 `shutdown` 则只关闭了发送方向，客户端在没有等待到服务端的`FIN`则会一直等待。

###### 第三次

服务端将数据处理完（中间可能发送数据），然后发送`FIN`，进入`LAST_ACK`状态

（**服务端在接收`FIN`后内核响应`ACK`**，之后进程需要主动`close`来发送`FIN`）

> 第三次挥手丢失怎么办？

1. 服务端

   服务端发送`FIN`后如果一直等不到`ACK`，则触发**超时重传**，

###### 第四次

客户端接收到服务端的`FIN`后，回复`ACK`，然后进入到`TIME_WAIT`状态。

服务端接收到`ACK`后进入`close`断开连接。

客户端等待`2MSL`后进入`close`断开连接。

> 第四次挥手丢失怎么办？

在 Linux 系统，TIME_WAIT 状态会持续 2MSL 后才会进入关闭状态。

如果第四次挥手的 ACK 报文没有到达服务端，服务端就会重发 FIN 报文，重发次数仍然由的 `tcp_orphan_retries` 参数控制。

> MSL 是报文最长生存时间，超过这个时间报文就会被丢弃。
>
> MSL 与 TTL 的区别： MSL 的单位是时间，而 TTL 是经过路由跳数。所以 **MSL 应该要大于等于 TTL 消耗为 0 的时间**。
>
> **TTL 的值一般是 64**；**MSL 一般为 30 秒**

**2MSL**则表明一来一回需要2倍时间。可以允许报文至少丢失一次。

###### TIME_WAIT

主动关闭方出现`TIME_WAIT`说明不发送数据，但保留接收数据的能力

> 为什么需要？

原因：

1、防止被动关闭方的延迟数据被之后的接收方错乱接收

为了防止历史连接中的数据，被后面相同四元组的连接错误的接收

因此 TCP 设计了 TIME_WAIT 状态，状态会持续 `2MSL` 时长，这个时间**足以让两个方向上的数据包都被丢弃，使得原来连接的数据包在网络中都自然消失，再出现的数据包一定都是新建立连接所产生的。**

2、防止被动关闭方没有收到最后的ACK

防止主动关闭方的最后的ACK丢失，对后续连接造成影响。

所以，我们在默认情况下，如果客户端等待足够长的时间就会遇到以下两种情况：

1. 服务端正常收到了 `ACK` 消息并关闭当前 TCP 连接；
2. 服务端没有收到 `ACK` 消息，重新发送 `FIN` 关闭连接并等待新的 `ACK` 消息；

`2MSL` 的时间是从**客户端接收到 FIN 后发送 ACK 开始计时的**。如果在 TIME-WAIT 时间内，因为客户端的 ACK 没有传输到服务端，客户端又接收到了服务端重发的 FIN 报文，那么 **2MSL 时间将重新计时**。

> TIME_WAIT过多有什么危害？

- 第一是占用系统资源，比如文件描述符、内存资源、CPU 资源、线程资源等；
- 第二是占用端口资源，端口资源也是有限的，一般可以开启的端口为 `32768～61000`，也可以通过 `net.ipv4.ip_local_port_range` 参数指定范围。

> 如何优化TIME_WAIT

*方式一：net.ipv4.tcp_tw_reuse 和 tcp_timestamps*

如下的 Linux 内核参数开启后，则可以**复用处于 TIME_WAIT 的 socket 为新的连接所用**。

有一点需要注意的是，**tcp_tw_reuse 功能只能用客户端（连接发起方），因为开启了该功能，在调用 connect () 函数时，内核会随机找一个 time_wait 状态超过 1 秒的连接给新的连接复用。**

使用这个选项，还有一个前提，**需要打开对 TCP 时间戳的支持**，由于引入了时间戳，我们在前面提到的 `2MSL` 问题就不复存在了，因为重复的数据包会因为时间戳过期被自然丢

*方式二：net.ipv4.tcp_max_tw_buckets*

这个值默认为 18000，**当系统中处于 TIME_WAIT 的连接一旦超过这个值时，系统就会将后面的 TIME_WAIT 连接状态重置**，这个方法比较暴力。

*方式三：程序中使用 SO_LINGER*

我们可以通过设置 socket 选项，来设置调用 close 关闭连接行为。

##### 客户端close

![客户端调用 close 过程](https://raw.githubusercontent.com/0RAJA/img/main/20230426000556-486-format%252Cpng-20230426000552136.png)

- 客户端调用 `close`，表明客户端没有数据需要发送了，则此时会向服务端发送 FIN 报文，进入 FIN_WAIT_1 状态；
- 服务端接收到了 FIN 报文，TCP 协议栈会为 FIN 包插入一个文件结束符 `EOF` 到接收缓冲区中，应用程序可以通过 `read` 调用来感知这个 FIN 包。这个 `EOF` 会被**放在已排队等候的其他已接收的数据之后**，这就意味着服务端需要处理这种异常情况，因为 EOF 表示在该连接上再无额外数据到达。此时，服务端进入 CLOSE_WAIT 状态；
- 接着，当处理完数据后，自然就会读到 `EOF`，于是也调用 `close` 关闭它的套接字，这会使得服务端发出一个 FIN 包，之后处于 LAST_ACK 状态；
- 客户端接收到服务端的 FIN 包，并发送 ACK 确认包给服务端，此时客户端将进入 TIME_WAIT 状态；
- 服务端收到 ACK 确认包后，就进入了最后的 CLOSE 状态；
- 客户端经过 `2MSL` 时间之后，也进入 CLOSE 状态；

#### 客户端崩溃

![web 服务的 心跳机制](https://img-blog.csdnimg.cn/img_convert/2d872f947dedd24800a1867dc4f8b9ce.png)

TCP存在心跳来监听

#### 服务器进程崩溃

TCP 的连接信息是由内核维护的，所以当服务端的进程崩溃后，内核需要回收该进程的所有 TCP 连接资源，于是内核会发送第一次挥手 FIN 报文，后续的挥手过程也都是在内核完成，并不需要进程的参与，所以即使服务端的进程退出了，还是能与客户端完成 TCP 四次挥手的过程。

#### TCP重传，滑动窗口，拥塞控制

##### 重传机制

TCP实现可靠传输的方式之一,是通过序列号进行确认应答.

ACK表示在这个序号以前的数据包都已经被正常接收。

SEQ没发送一个数据包就+对应长度,用来解决乱序和丢包。

###### 超时重传

1. 数据包丢失

2. 确认应答丢失

![image-20220111145808709](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220111145808709.png)

   > 超时时间应该设置为多少呢?

   **RTT** 是数据从网络一端传到另一端需要的时间.(包的往返时延)

   **RTO**是超时重传时间

   所以**RTO**应该略大于**RTT**

###### 快速重传(重传一个包)

TCP 还有另外一种**快速重传（Fast Retransmit）机制**，它**不以时间为驱动，而是以数据驱动重传**。

![快速重传机制](https://raw.githubusercontent.com/0RAJA/img/main/20230426000557-121-10.jpg)

接收方连续发送三次相同的ACK触发快速重传

但是发送端一次只能获知一个包丢失，在多个包丢失的场景下效率低

###### SACK(告知丢包区间)

还有一种实现重传机制的方式叫：`SACK`（ Selective Acknowledgment）， **选择性确认**。

这种方式需要在 TCP 头部「选项」字段里加一个 `SACK` 的东西，它**可以将已收到的数据的信息发送给「发送方」**，这样发送方就可以知道哪些数据收到了，哪些数据没收到，知道了这些信息，就可以**只重传丢失的数据**。

![选择性确认](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/11.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0)

###### D-SACK(告知重复接收)

Duplicate SACK 又称 `D-SACK`，其主要**使用了 SACK 来告诉「发送方」有哪些数据被重复接收了。**

在收到重复的包时可以告知发送方

1. 可以让「发送方」知道，是发出去的包丢了，还是接收方回应的 ACK 包丢了；
2. 可以知道是不是「发送方」的数据包被网络延迟了；
3. 可以知道网络中是不是把「发送方」的数据包给复制了；

##### 滑动窗口

那么有了窗⼝，就可以指定窗⼝⼤⼩，窗⼝⼤⼩就是指⽆需等待确认应答，⽽可以继续发送数据的最⼤值

窗⼝的实现实际上是操作系统开辟的⼀个**缓存空间**，**发送⽅主机在等到确认应答返回之前，必须在缓冲区中保留已发送的数据。如果按期收到确认应答，此时数据就可以从缓存区清除**

> 窗口大小由哪一方决定?

TCP 头⾥有⼀个字段叫 Window ，也就是窗⼝⼤⼩。 这个字段是**接收端告诉发送端⾃⼰还有多少缓冲区可以接收数据**。于是发送端就可以根据这个接收端的处理能⼒来 发送数据，⽽不会导致接收端处理不过来。 所以，**通常窗⼝的⼤⼩是由接收⽅的窗⼝⼤⼩来决定的**

**发送方发送的数据大小不能超过接收方的窗口大小，否则接收方就无法正常接收到数据。**

> 发送方窗口

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000557-380-16.jpg)

> 接收方的滑动窗口

![接收窗口](https://raw.githubusercontent.com/0RAJA/img/main/20230426000557-719-20.jpg)

##### 流量控制

**TCP 通过滑动窗口让「发送方」根据「接收方」的实际接收能力控制发送的数据量，这就是所谓的流量控制。**

发送方发送数据后会将数据缓存等待ACK，接收方接收数据后也会等待应用程序读取，之后把可用缓冲区大小通过响应报文告知发送方，发送方捅过接收方的窗口大小来调节自身窗口从而控制发送数据的大小。

问题：

1. 接收方反馈窗口为0（窗口关闭），发送方就不会再发送数据，但之后接收方的ACK丢失，则会造成双方死锁。

   TCP 为每个连接设有一个持续定时器，**只要 TCP 连接一方收到对方的零窗口通知，就启动持续计时器。**

   如果持续计时器超时，就会发送**窗口探测 ( Window probe ) 报文**，而对方在确认这个探测报文时，给出自己现在的接收窗口大小。

   窗口探测的次数一般为 3 次，每次大约 30-60 秒（不同的实现可能会不一样）。如果 3 次过后接收窗口还是 0 的话，有的 TCP 实现就会发 `RST` 报文来中断连接。

2. 发送方在窗口较小的时候仍然发送数据

   1. 接收方在小窗口时告知窗口关闭

      窗口小于MSS(一个TCP报文最大长度)或缓存空间一半

   2. 发送方避免发送小数据

      使用 Nagle 算法，该算法的思路是延时处理，只有满足下面两个条件中的任意一个条件，才可以发送数据：

      - 条件一：要等到窗口大小 >= `MSS` 并且 数据大小 >= `MSS`；
      - 条件二：收到之前发送数据的 `ack` 回包；

##### 拥塞控制

**拥塞窗口 cwnd** 是发送方维护的一个的状态变量，它会根据 **网络的拥塞程度动态变化的**。

**发送窗口的值是 swnd = min (cwnd, rwnd)，也就是拥塞窗口和接收窗口中的最小值。**

拥塞窗口 `cwnd` 变化的规则：

- 只要网络中没有出现拥塞，`cwnd` 就会增大；
- 但网络中出现了拥塞，`cwnd` 就减少；

> 那么怎么知道当前网络是否出现了拥塞呢？

其实只要「发送方」没有在规定时间内接收到 ACK 应答报文，也就是**发生了超时重传，就会认为网络出现了拥塞。**

###### 慢启动

慢启动的算法记住一个规则就行：**当发送方每收到一个 ACK，拥塞窗口 cwnd 的大小就会加 1。**

![慢启动算法](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/27.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0)

有一个叫慢启动门限 `ssthresh` （slow start threshold）状态变量。

- 当 `cwnd` < `ssthresh` 时，使用慢启动算法。
- 当 `cwnd` >= `ssthresh` 时，就会使用「拥塞避免算法」

一般来说 `ssthresh` 的大小是 `65535` 字节

###### 拥塞避免算法

那么进入拥塞避免算法后，它的规则是：**每当收到一个 ACK 时，cwnd 增加 1/cwnd。**

![拥塞避免](https://raw.githubusercontent.com/0RAJA/img/main/20230426000558-416-28.jpg)

就这么一直增长着后，网络就会慢慢进入了拥塞的状况了，于是就会出现丢包现象，这时就需要对丢失的数据包进行重传。

当触发了重传机制，也就进入了「拥塞发生算法」

######  拥塞发生

当网络出现拥塞，也就是会发生数据包重传，重传机制主要有两种：

- 超时重传

  这个时候，ssthresh 和 cwnd 的值会发生变化：

  - `ssthresh` 设为 `cwnd/2`，
  - `cwnd` 重置为 `1` （是恢复为 cwnd 初始化值，我这里假定 cwnd 初始化值 1）

  ![拥塞发送 —— 超时重传](https://raw.githubusercontent.com/0RAJA/img/main/20230426000558-196-29.jpg)

- 快速重传

   `ssthresh` 和 `cwnd` 变化如下：

  - `cwnd = cwnd/2` ，也就是设置为原来的一半；
  - `ssthresh = cwnd`;
  - 进入快速恢复算法

###### 快速恢复

进入快速恢复算法如下：

- 拥塞窗口 `cwnd = ssthresh + 3` （ 3 的意思是确认有 3 个数据包被收到了）；
- 重传丢失的数据包；
- 如果再收到重复的 ACK，那么 cwnd 增加 1；
- 如果收到新数据的 ACK 后，把 cwnd 设置为第一步中的 ssthresh 的值，原因是该 ACK 确认了新的数据，说明从 duplicated ACK 时的数据都已收到，该恢复过程已经结束，可以回到恢复之前的状态了，也即再次进入拥塞避免状态；

![快速重传和快速恢复](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/拥塞发生-快速重传.drawio.png?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0)

**首先，快速恢复是拥塞发生后慢启动的优化，其首要目的仍然是降低 cwnd 来减缓拥塞，所以必然会出现 cwnd 从大到小的改变。**

**其次，过程 2（cwnd 逐渐加 1）的存在是为了尽快将丢失的数据包发给目标，从而解决拥塞的根本问题（三次相同的 ACK 导致的快速重传），所以这一过程中 cwnd 反而是逐渐增大的。**

#### TCP 优化

##### TCP 握手优化

![TCP 三次握手的状态变迁](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/TCP-参数/5.jpg)

###### 客户端优化

三次握手的主要目的时为了**同步序列号**

客户端在SYN后进入SYN_SEND等待服务端SYN_ACK，如果在网络情况较好时可以减少SYN重传次数，减少等待时间。

###### 服务端优化

在收到客户端SYN后，服务端需要响应SYN_ACK并进入SYN_RCVD。同时内核建立半连接队列维护未完成的握手信息。

1. SYN攻击时增加接收能力

   * 可以增加网卡的接收队列，缓冲后续请求。
   * 扩大半连接队列
   * 启用`tcp_syncookies`来绕过半连接队列

2. 减少`SYN_RCVD`重传次数

3. 全连接队列满时告知客户端

   tcp_abort_on_overflow 共有两个值分别是 0 和 1，其分别表示：

   - 0 ：如果 accept 队列满了，那么 server 扔掉 client 发过来的 ack ；
     - 适合短期accept队列满时采用
   - 1 ：如果 accept 队列满了，server 发送一个 `RST` 包给 client，表示废掉这个握手过程和这个连接；
     - 有你非常肯定 TCP 全连接队列会长期溢出时，才能设置为 1 以尽快通知客户端。

###### 跳过TCP握手

在 Linux 3.7 内核版本之后，提供了 TCP Fast Open 功能，这个功能可以减少 TCP 连接建立的时延。

![开启 TCP Fast Open 功能](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/TCP-参数/22.jpg)

在客户端首次建立连接时的过程：

1. 客户端发送 SYN 报文，该报文包含 Fast Open 选项，且该选项的 Cookie 为空，这表明客户端请求 Fast Open Cookie；
2. 支持 TCP Fast Open 的服务器生成 Cookie，并将其置于 SYN-ACK 数据包中的 Fast Open 选项以发回客户端；
3. 客户端收到 SYN-ACK 后，本地缓存 Fast Open 选项中的 Cookie。

之后再次建立连接时，客户端只需要在SYN时**携带数据和cookie**，服务端检测Cookie是否有效，有效则直接建立连接。否则抛弃数据，返回SYN_ACK继续三次握手。

##### TCP 挥手优化

客户端和服务端双方都可以主动断开连接，**通常先关闭连接的一方称为主动方，后关闭连接的一方称为被动方。**

![客户端主动关闭](https://raw.githubusercontent.com/0RAJA/img/main/20230426000558-989-25.jpg)

###### 主动方的优化

RST 报文：暴力关闭连接

1. FIN_WAIT1 

   客户端在发送`FIN`后会进入`FIN_WAIT1`(孤儿状态)，等待服务端ACK然后进入`FIN_WAIT2`

   **可以调整 tcp_max_orphans 参数，它定义了「孤儿连接」的最大数量**：

   使得之后的连接调用close后直接RST强制断开。

2. FIN_WAIT2

   当主动方收到 ACK 报文后，会处于 FIN_WAIT2 状态，就表示主动方的发送通道已经关闭，接下来将等待对方发送 FIN 报文，关闭对方的发送通道。

   **如果连接是用 shutdown 函数关闭的，连接可以一直处于 FIN_WAIT2 状态，因为它可能还可以发送或接收数据。但对于 close 函数关闭的孤儿连接，由于无法再发送和接收数据，所以这个状态不可以持续太久，而 tcp_fin_timeout 控制了这个状态下连接的持续时长 2MSL**：**至少允许报文丢失一次**

3. TIME_WAIT

   - 防止历史连接中的数据，被后面相同四元组的连接错误的接收；
   - 保证「被动关闭连接」的一方，能被正确的关闭；

   1. **可以开启时间戳并复用处于TIME_WAIT的连接**
   2. **设置调用 close ，立即发送一个 RST 标志给对端，该 TCP 连接将跳过四次挥手，也就跳过了 TIME_WAIT 状态，直接关闭。**

###### 被动方优化

寻找当TCP连接返回EOF后为啥程序还不close的问题

##### 传输数据优化

TCP 可靠性是通过 ACK 确认报文实现的，又依赖滑动窗口提升了发送速度也兼顾了接收方的处理能力。

可以参考带宽提高滑动窗口的大小。

Linux 会对缓冲区动态调节，我们应该把缓冲区的上限设置为带宽时延积。发送缓冲区的调节功能是自动打开的，而接收缓冲区需要把 tcp_moderate_rcvbuf 设置为 1 来开启。其中，调节的依据是 TCP 内存范围 tcp_mem。

#### TCP缺陷

##### 升级 TCP 的工作很困难

但是 TCP 协议是在内核中实现的，应用程序只能使用不能修改，如果要想升级 TCP 协议，那么只能升级内核。

##### TCP 建立连接的延迟

三次握手完了才能四次TLS握手

##### TCP 存在队头阻塞问题

TCP 是字节流协议，**TCP 层必须保证收到的字节数据是完整且有序的**，如果序列号较低的 TCP 段在网络传输中丢失了，即使序列号较高的 TCP 段已经被接收了，应用层也无法从内核中读取到这部分数据。

##### 网络迁移需要重新建立 TCP 连接

**当移动设备的网络从 4G 切换到 WIFI 时，意味着 IP 地址变化了，那么就必须要断开连接，然后重新建立 TCP 连接**。

#### 断电和崩溃

如果「**客户端进程崩溃**」，客户端的进程在发生崩溃的时候，内核会发送 FIN 报文，与服务端进行四次挥手。

但是，「**客户端主机宕机**」，那么是不会发生四次挥手的，具体后续会发生什么？还要看服务端会不会发送数据？

- 如果服务端会发送数据，由于客户端已经不存在，收不到数据报文的响应报文，服务端的数据报文会超时重传，当重传总间隔时长达到一定阈值（内核会根据 tcp_retries2 设置的值计算出一个阈值）后，会断开 TCP 连接；
- 如果服务端一直不会发送数据，再看服务端有没有开启 TCP keepalive 机制？
  - 如果有开启，服务端在一段时间没有进行数据交互时，会触发 TCP keepalive 机制，探测对方是否存在，如果探测到对方已经消亡，则会断开自身的 TCP 连接；
  - 如果没有开启，服务端的 TCP 连接会一直存在，并且一直保持在 ESTABLISHED 状态。

### UDP

UDP 不提供复杂的控制机制，利用 IP 提供面向「无连接」的通信服务。

![UDP 头部格式](https://raw.githubusercontent.com/0RAJA/img/main/20230426000559-064-format%252Cpng-20230426000553379.png)

- 目标和源端口：主要是告诉 UDP 协议应该把报文发给哪个进程。
- 包长度：该字段保存了 UDP 首部的长度跟数据的长度之和。
- 校验和：校验和是为了提供可靠的 UDP 首部和数据而设计，防止收到在网络传输中受损的 UDP 包。

注：

1. 无首部长度，因为其首部固定8字节
2. 包长度可以通过IP-IP首部-UDP首部计算，但可能为了凑4的倍数而故意设计



### TCP和UDP区别

*1. 连接*

- TCP 是面向连接的传输层协议，传输数据前先要建立连接。
- UDP 是不需要连接，即刻传输数据。

*2. 服务对象*

- TCP 是一对一的两点服务，即一条连接只有两个端点。
- UDP 支持一对一、一对多、多对多的交互通信

*3. 可靠性*

- TCP 是可靠交付数据的，数据可以无差错、不丢失、不重复、按序到达。
- UDP 是尽最大努力交付，不保证可靠交付数据。

*4. 拥塞控制、流量控制*

- TCP 有拥塞控制和流量控制机制，保证数据传输的安全性。
- UDP 则没有，即使网络非常拥堵了，也不会影响 UDP 的发送速率。

*5. 首部开销*

- TCP 首部长度较长，会有一定的开销，首部在没有使用「选项」字段时是 `20` 个字节，如果使用了「选项」字段则会变长的。
- UDP 首部只有 8 个字节，并且是固定不变的，开销较小。

*6. 传输方式*

- TCP 是流式传输，没有边界，但保证顺序和可靠。
- UDP 是一个包一个包的发送，是有边界的，但可能会丢包和乱序。

*7. 分片不同*

- TCP 的数据大小如果大于 MSS 大小，则会在传输层进行分片，目标主机收到后，也同样在传输层组装 TCP 数据包，如果中途丢失了一个分片，只需要传输丢失的这个分片。
- UDP 的数据大小如果大于 MTU 大小，则会在 IP 层进行分片，目标主机收到后，在 IP 层组装完数据，接着再传给传输层。

### 应用场景区别

TCP稳定可靠，常用于

- `FTP` 文件传输；
- HTTP / HTTPS

UDP无连接，可以随时发送数据

- 包总量较少的通信，如 `DNS` 、`SNMP` 等；
- 视频、音频等多媒体通信；
- 广播通信；

## 网络层

### IP协议

#### 基础知识

IP 地址分类成了 5 种类型，分别是 A 类、B 类、C 类、D 类、E 类。

![IP 地址分类](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/IP/7.jpg)

其中对于 A、B、C 类主要分为两个部分，分别是**网络号和主机号**。

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/IP/8.jpg)

主机号中有两个比较特殊的

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/IP/10.jpg)

- 主机号全为 1 指定某个网络下的所有主机，用于广播
- 主机号全为 0 指定某个网络

而 D 类和 E 类地址是没有主机号的，所以不可用于主机 IP，D 类常被用于**多播**，E 类是预留的分类，暂时未使用。

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000559-410-12.jpg)

![单播、广播、多播通信](https://raw.githubusercontent.com/0RAJA/img/main/20230426000559-551-13.jpg)

**无分类地址 CIDR

表示形式 `a.b.c.d/x`，其中 `/x` 表示前 x 位属于**网络号**， x 的范围是 `0 ~ 32`，后面是**主机号**。

比如 10.100.122.2/24，这种地址表示形式就是 CIDR，/24 表示前 24 位是网络号，剩余的 8 位是主机号。

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/IP/15.jpg)

还有另一种划分网络号与主机号形式，那就是**子网掩码**，掩码的意思就是掩盖掉主机号，剩余的就是网络号。

**将子网掩码和 IP 地址按位计算 AND，就可得到网络号。**

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/IP/16.jpg)

在上面我们知道可以通过子网掩码划分出网络号和主机号，那实际上子网掩码还有一个作用，那就是**划分子网**

**子网划分实际上是将主机地址分为两个部分：子网网络地址和子网主机地址**。形式如下：

![img](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/IP/18.jpg)

假设对 C 类地址进行子网划分，网络地址 192.168.1.0，使用子网掩码 255.255.255.192 对其进行子网划分。

C 类地址中前 24 位是网络号，最后 8 位是主机号，根据子网掩码可知**从 8 位主机号中借用 2 位作为子网号**。

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000600-055-19.jpg)

由于子网网络地址被划分成 2 位，那么子网地址就有 4 个，分别是 00、01、10、11，具体划分如下图：

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000600-355-21.jpg)

在 A、B、C 分类地址，实际上有分公有 IP 地址和私有 IP 地址。

![img](https://raw.githubusercontent.com/0RAJA/img/main/20230426000600-385-22-20230426000554609.jpg)

**IPV6**

IPv4 的地址是 32 位的,IPv6 的地址是 `128` 位的，

IPv6 不仅仅只是可分配的地址变多了，它还有非常多的亮点。

- IPv6 可自动配置，即使没有 DHCP 服务器也可以实现自动分配 IP 地址
- IPv6 包头包首部长度采用固定的值 `40` 字节，去掉了包头校验和，简化了首部结构，减轻了路由器负荷，大大**提高了传输的性能**。
- IPv6 有应对伪造 IP 地址的网络安全功能以及防止线路窃听的功能，大大**提升了安全性**。

IPv4 地址长度共 32 位，是以每 8 位作为一组，并用点分十进制的表示方式。

IPv6 地址长度是 128 位，是以每 16 位作为一组，每组用冒号 「:」 隔开。

![IPv6 地址表示方法](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/IP/27.jpg)

如果出现连续的 0 时还可以将这些 0 省略，并用两个冒号 「::」隔开。但是，一个 IP 地址中只允许出现一次两个连续的冒号。

![Pv6 地址缺省表示方](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%BD%91%E7%BB%9C/IP/28.jpg)

IPv6 类似 IPv4，也是通过 IP 地址的前几位标识 IP 地址的种类。

IPv6 的地址主要有以下类型地址：

- 单播地址，用于一对一的通信
- 组播地址，用于一对多的通信
- 任播地址，用于通信最近的节点，最近的节点是由路由协议决定
- 没有广播地址

![IPv6地址结构](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%BD%91%E7%BB%9C/IP/29.jpg)

 **IPv4 首部与 IPv6 首部**

IPv4 首部与 IPv6 首部的差异如下图：

![IPv4 首部与 IPv6 首部的差异](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%BD%91%E7%BB%9C/IP/31.jpg)

IPv6 相比 IPv4 的首部改进：

- **取消了首部校验和字段。** 因为在数据链路层和传输层都会校验，因此 IPv6 直接取消了 IP 的校验。
- **取消了分片 / 重新组装相关字段。** 分片与重组是耗时的过程，IPv6 不允许在中间路由器进行分片与重组，这种操作只能在源与目标主机，这将大大提高了路由器转发的速度。
- **取消选项字段。** 选项字段不再是标准 IP 首部的一部分了，但它并没有消失，而是可能出现在 IPv6 首部中的「下一个首部」指出的位置上。删除该选项字段使的 IPv6 的首部成为固定长度的 `40` 字节。

**DHCP**

![DHCP 工作流程](https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%BD%91%E7%BB%9C/IP/36.jpg)**

- 客户端首先发起 **DHCP 发现报文（DHCP DISCOVER）** 的 IP 数据报，由于客户端没有 IP 地址，也不知道 DHCP 服务器的地址，所以使用的是 UDP **广播**通信，其使用的广播目的地址是 255.255.255.255（端口 67） 并且使用 0.0.0.0（端口 68） 作为源 IP 地址。DHCP 客户端将该 IP 数据报传递给链路层，链路层然后将帧广播到所有的网络中设备。
- DHCP 服务器收到 DHCP 发现报文时，用 **DHCP 提供报文（DHCP OFFER）** 向客户端做出响应。该报文仍然使用 IP 广播地址 255.255.255.255，该报文信息携带服务器提供可租约的 IP 地址、子网掩码、默认网关、DNS 服务器以及 **IP 地址租用期**。
- 客户端收到一个或多个服务器的 DHCP 提供报文后，从中选择一个服务器，并向选中的服务器发送 **DHCP 请求报文（DHCP REQUEST** 进行响应，回显配置的参数。
- 最后，服务端用 **DHCP ACK 报文**对 DHCP 请求报文进行响应，应答所要求的参数。

一旦客户端收到 DHCP ACK 后，交互便完成了，并且客户端能够在租用期内使用 DHCP 服务器分配的 IP 地址。

**NAT**

### IP协议相关知识

#### DNS

DNS 域名解析将域名转换为ip地址

>   域名的层级关系

1.   域名以`.`分隔

2.   越靠右层次越高(树形)

     ![image-20220113221431490](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220113221431490.png)

3.   客户端只用找到任意一台DNS服务器就可以通过它找到根域服务器,然后顺着层次找到权威服务器返回对应ip地址

#### ARP

在传输一个IP数据包时确定了源IP和目标IP后通过路由表确定IP数据包的下一跳,

但需要知道下一跳的MAC地址.才可以进行转发.

>   ARP如何获取目标MAC地址?

1.   主机会广播ARP请求,其中包含目标IP地址
2.   当同一个链路的所有设备都接收到ARP请求时,会拆包查看IP,如果和自己IP一致就想自己的MAC放到ARP响应包给主机.
3.   操作系统通常会把第一次通过ARP获取的MAC地址缓存起来,

>   RARP 通过MAC求IP

#### DHCP

通过DHCP动态获取IP地址

1.   客户端发送**DHCP发现报文**的IP数据报,因为客户端无IP也不知道DHCP服务器IP,所以使用UDP广播.使用的目的地址为255.255.255.255并且使用0.0.0.0作为原地址.
2.   DHCP服务器收到**DHCP发现报文**时,使用255.255.255.255向客户端回应**可租约的IP,子网掩码,默认网关,DNS服务器,和IP地址租用期**
3.   客户端收到多个服务器的DHCP提供报文后从中选择一个服务器然后发送**DHCP请求报文**
4.   最后服务器用DHCP ACK 报文进行响应相关信息.

>   如果租期快过了,客户端会想服务器发送DHCP请求报文.

1.   服务器同意继续租用,则用`DHCP ACK`进行回应
2.   服务器拒绝租用,使用`DHCP NACK`进行回应

>   DHCP交互中使用的是UDP广播通信

为了解决局域网才能进行广播问题，就出现了 DHCP 中继代理。有了 DHCP 中继代理以后，对不同⽹段的 IP 地址分配也可以由⼀个 DHCP 服务器统⼀进⾏管理

![image-20220113223754640](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220113223754640.png)

1.   DHCP 客户端会向 DHCP 中继代理发送 DHCP 请求包，⽽ DHCP 中继代理在收到这个⼴播包以后，再以单播 的形式发给 DHCP 服务器。 
2.   服务器端收到该包以后再向 DHCP 中继代理返回应答，并由 DHCP 中继代理将此包⼴播给 DHCP 客户端

因此，DHCP 服务器即使不在同⼀个链路上也可以实现统⼀分配和管理IP地址。

#### NAT

NAT 就是同个公司、家庭、教室内的主机对外部通信时，把私有 IP 地址转换成公有 IP 地址

1.   静态:1对1实现外部网络对内部网络某些特殊设备的访问.
2.   动态:随机分配.
3.   端口多路复用(PAT):不同IP相同端口转换为相同IP不同端口,内部存储对应的转换表.

![image-20220113224007917](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220113224007917.png)

**⽹络地址与端⼝转换 NAPT(PAT)**

![image-20220113224113047](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220113224113047.png)

存在的问题:

1.   外部无法主动和NAT内部服务器建立连接,
2.   转换表的生成与转换操作会产生开销
3.   通信过程中,如果NAT路由器重启了,所有TCP连接都将被重置

解决方法:

1. 使用IPV6 直接使用私有IP

2. NAT穿透技术

   说人话，就是客户端主动从 NAT 设备获取公有 IP 地址，然后自己建立端口映射条目，然后用这个条目对外通信，就不需要 NAT 设备来进行转换了

#### IGMP

在前⾯我们知道了组播地址，也就是 D 类地址，既然是组播，那就说明是只有⼀组的主机能收到数据包，不在⼀组 的主机不能收到数组包，怎么管理是否是在⼀组呢？那么，就需要 IGMP 协议了。

![image-20220114000804276](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220114000804276.png)

IGMP 是因特⽹组管理协议，⼯作在主机（组播成员）和最后⼀跳路由之间

1.   GMP 报⽂向路由器申请加⼊和退出组播组，默认情况下路由器是不会转发组播包到连接中的主机，除⾮主机 通过 IGMP 加⼊到组播组，主机申请加⼊到组播组时，路由器就会记录 IGMP 路由器表，路由器后续就会转发 组播包到对应的主机了。
2.   IGMP 报⽂采⽤ IP 封装，IP 头部的协议号为 2，⽽且 TTL 字段值通常为 1，因为 IGMP 是⼯作在主机与连接 的路由器之间。

>   工作机制

IGMP 分为了三个版本分别是，IGMPv1、IGMPv2、IGMPv3。

1.   常规查询和响应

     ![image-20220115145259417](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115145259417.png)

     1.   路由器会周期性发送⽬的地址为 224.0.0.1 （表示同⼀⽹段内所有主机和路由器） IGMP 常规查询报⽂。
     2.   主机1 和 主机 3 收到这个查询，随后会启动「报告延迟计时器」，计时器的时间是随机的，通常是 0~10 秒， 计时器超时后主机就会发送 IGMP 成员关系报告报⽂（源 IP 地址为⾃⼰主机的 IP 地址，⽬的 IP 地址为组播地址）。如果在定时器超时之前，收到同⼀个组内的其他主机发送的成员关系报告报⽂，则⾃⼰不再发送，这 样可以减少⽹络中多余的 IGMP 报⽂数ᰁ。
     3.   路由器收到主机的成员关系报⽂后，就会在 IGMP 路由表中加⼊该组播组，后续⽹络中⼀旦该组播地址的数据 到达路由器，它会把数据包转发出去

2.   离开组播组机制

     1.   网络中仍有该组播组

          ![image-20220115145513400](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115145513400.png)

          1.   主机 1 要离开组 224.1.1.1，发送 IGMPv2 离组报⽂，报⽂的⽬的地址是 224.0.0.2（表示发向⽹段内的所有路 由器）
          2.   路由器 收到该报⽂后，以 1 秒为间隔连续发送 IGMP 特定组查询报⽂（共计发送 2 个），以便确认该⽹络是 否还有 224.1.1.1 组的其他成员
          3.   否还有 224.1.1.1 组的其他成员。 3. 主机 3 仍然是组 224.1.1.1 的成员，因此它⽴即响应这个特定组查询。路由器知道该⽹络中仍然存在该组播组 的成员，于是继续向该⽹络转发 224.1.1.1 的组播数据包

     2.   网络中没有该组播组

          ![image-20220115145623433](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115145623433.png)

          1.    主机 1 要离开组播组 224.1.1.1，发送 IGMP 离组报⽂
          2.   路由器收到该报⽂后，以 1 秒为间隔连续发送 IGMP 特定组查询报⽂（共计发送 2 个）。此时在该⽹段内，组 224.1.1.1 已经没有其他成员了，因此没有主机响应这个查询
          3.    ⼀定时间后，路由器认为该⽹段中已经没有 224.1.1.1 组播组成员了，将不会再向这个⽹段转发该组播地址 数据包

### ping的工作原理

#### ICMP

**互联⽹控制报⽂协议**

功能：

1.   确认IP包能否成功送到目标地址
2.   报告发送过程中IP包被丢弃的原因
3.   改善网络设置

![image-20220113235216254](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220113235216254.png)

ICMP消息会原路返回到主机A,主机A对这个IP消息进行解析得到原因.

>   ICMP 包头格式

ICMP 报⽂是封装在 IP 包⾥⾯，它⼯作在⽹络层，是 IP 协议的助⼿

![image-20220115150419802](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115150419802.png)

根据ICMP包的类别对ICMP进行分类.

>   ICMP类型

![image-20220113235438152](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220113235438152.png)

#### 查询报文类型

用于诊断的查询消息

>   回送消息 -- 类型 0 和 8

**回送消息**⽤于进⾏通信的主机或路由器之间,判断所发送的数据包是否已经成功到达对端的⼀种消息，

![image-20220115151130577](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115151130577.png)

可以向对端主机发送**回送请求**的消息（ ICMP Echo Request Message ，类型 8 ），也可以接收对端主机发回来的**回送应答**消息（ ICMP Echo Reply Message ，类型 0 ）

![image-20220115151450651](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115151450651.png)

在**选项数据**中， ping 还会存放发送请求的时间值，来计算往返时间，说明路程的⻓短。

#### 差错报文类型

通知出错原因的错误消息,

举几个常见的例子

##### 目标不可达 - 3

IP 路由器⽆法将 IP 数据包发送给⽬标地址时，会给发送端主机返回⼀个**⽬标不可达**的 ICMP 消息，并在这个消息中显示不可达的具体原因，原因记录在 ICMP 包头的**代码字段**。

![image-20220115152256195](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115152256195.png)

1.   网络不可达 - 0 

     IP 地址是分为⽹络号和主机号的，所以当路由器中的路由器表匹配不到接收⽅ IP 的⽹络号，就通过 ICMP 协议以**⽹络不可达**的原因告知主机

2.   主机不可达 - 1

     当路由表中没有该主机的信息，或者该主机没有连接到⽹络，那么会通过 ICMP 协议以主机不可达的原因告知主机。

3.   协议不可达 - 2

     当主机使⽤ TCP 协议访问对端主机时，能找到对端的主机了，可是对端主机的防⽕墙已经禁⽌ TCP 协议访问，那 么会通过 ICMP 协议以协议不可达的原因告知主机

4.   端⼝不可达 - 3

     当主机访问对端主机 8080 端⼝时，这次能找到对端主机了，防⽕墙也没有限制，可是发现对端主机没有进程监听 8080 端⼝，那么会通过 ICMP 协议以端⼝不可达的原因告知主机。

5.   需要进⾏分⽚但设置了不分⽚位 - 4

     发送端主机发送 IP 数据报时，将 **IP ⾸部的分⽚禁⽌标志位设置为 1** 。根据这个标志位，途中的**路由器遇到超过 MTU ⼤⼩的数据包时，不会进⾏分⽚，⽽是直接抛弃。**

##### 原点抑制消息 - 4

在使⽤低速⼴域线路的情况下，连接 WAN 的路由器可能会遇到⽹络拥堵的问题

**ICMP 原点抑制消息的⽬的就是为了缓和这种拥堵情况。**

当路由器向低速线路发送数据时，**其发送队列的缓存变为零⽽⽆法发送出去时**，可以向 IP 包的源地址发送⼀个 ICMP 原点抑制消息

收到消息的主机可以了解到整个线路的某一处发生了拥堵,从而**加大IP包传输间隔**,减少网络拥堵.

##### 重定向消息 - 5

如果**路由器发现发送端主机使⽤了「不是最优」的路径发送数据**，那么它会返回⼀个 ICMP 重定向消息给这个主 机。

##### 超时消息 - 11

**IP包中的TTL声明周期,每过一个路由器就减1,最后到0就被丢弃了**

此时,路由器会发送一个ICMP超时给发送端主机.

设置声明周期是为了防止在路由转发出现问题而导致报文被无限转发.

#### ping 查询报文类型的使用

![image-20220115160424124](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115160424124.png)

ping先创建一个ICMP回送请求消息数据包

ICMP数据包内多个字段,核心是两个

1.   ⼀个是类型，对于回送请求消息⽽⾔该字段为 8 ； 
2.   另外⼀个是序号，主要⽤于区分连续 ping 的时候发出的多个数据包。

每发出⼀个请求数据包，序号会⾃动加 1 。为了能够计算往返时间 RTT ，它会在报⽂的数据部分插⼊发送时间

然后，**由 ICMP 协议将这个数据包连同地址 192.168.1.2 ⼀起交给 IP 层。IP 层将以 192.168.1.2 作为⽬的地址， 本机 IP 地址作为源地址，协议字段设置为 1 表示是 ICMP 协议，再加上⼀些其他控制信息，构建⼀个 IP 数据包**

![image-20220115161446506](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115161446506.png)

之后加入MAC头,再在本地ARP映射表中查找MAC地址,没有就ARP查询MAC地址,获取MAC后由数据链路层构建一个帧,目的IP是由IP层传过来的MAC地址,原地址是本地MAC,然后依据以太网介质规则传输出去.

![image-20220115162035389](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115162035389.png)

主机B收到消息后先检查MAC地址是否是自己,然后拆开数据帧,检查IP层,然后将信息给ICMP协议.

主机B构建一个ICMP回送响应消息,**类型是0,序号是请求数据包中的序号**,然后再发送给主机A.

![image-20220115162308826](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220115162308826.png)

如果一定时间内主机A没收到应答包就说明目标主机不可达.

 **ping 这个程序是使⽤了 ICMP ⾥⾯的 ECHO REQUEST（类型为 8 ） 和 ECHO REPLY （类型为 0）**

#### traceroute 差错报文类型的使用

有⼀款充分利⽤ ICMP 差错报⽂类型的应⽤叫做 traceroute （在UNIX、MacOS中是这个命令，⽽在Windows中 对等的命令叫做 tracert ）。

1.   利用IP包的生存周期

     先设置TTL为1发送UDP包,遇到第一个路由器就gg,然后返回超时,之后设置为2,然后第二个返回超时,直到到达目标主机.**拿到此过程的所有路由器IP**,但对于部分不返回ICMP的路由器是看不到中间路由的.

2.   如何确定UDP到达目标主机?

     发送的UDP设置一个不可能的端口号,当目标主机接受到UDP后返回端口不可达.

3.   通过故意设置不分片来确定路径的MTU

     为了路径MTU发现.

     1.   ⾸先在发送端主机发送 IP 数据报时，将 IP 包⾸部的分⽚禁⽌标志位设置为 1。
     2.   根据这个标志位，途中的路由器不会对⼤数据包进⾏分⽚，⽽是将包丢弃。 随后，通过⼀个 ICMP 的不可达消息将数据链路上 MTU 的值⼀起给发送主机，不可达消息的类型为「需要进⾏分 ⽚但设置了不分⽚位」
     3.   发送主机端每次收到 ICMP 差错报⽂时就减少包的⼤⼩，以此来定位⼀个合适的 MTU 值，以便能到达⽬标主机。