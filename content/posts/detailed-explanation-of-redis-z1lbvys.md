---
title: redis 详解
slug: detailed-explanation-of-redis-z1lbvys
date: '2026-05-10 15:51:20+08:00'
lastmod: '2026-06-24 00:10:55+08:00'
tags:
  - redis
keywords: redis
description: >-
  Redis的List类型是一种双向链表，支持从左侧插入元素，命令`lpush`用于将一个或多个值插入到列表头部，插入顺序与参数顺序相反。List适用于消息队列、最新消息列表等场景，具有高效的头尾操作性能，但索引查询较慢。Redis底层使用压缩列表或快速链表实现，以平衡内存与性能。
toc: true
isCJKLanguage: true
---



# redis 详解

‍

# REDIS

[redis 视频链接](https://www.bilibili.com/video/BV1S54y1R7SB)

## 概述

> Redis 是什么

**Redis** 是一个使用 [ANSI C](https://zh.wikipedia.org/wiki/ANSI_C) 编写的[开源](https://zh.wikipedia.org/wiki/开源)、支持[网络](https://zh.wikipedia.org/wiki/电脑网络)、基于[内存](https://zh.wikipedia.org/wiki/内存)、[分布式](https://zh.wikipedia.org/wiki/分布式缓存)、可选[持久性](https://zh.wikipedia.org/w/index.php?title=持久性_(数据库)&action=edit&redlink=1)的[键值对存储数据库](https://zh.wikipedia.org/wiki/键值-值数据库)。

> Redis 能做什么

1. 内存存储,持久化(rdb,aof)
2. 效率高,可以用于高速缓存
3. 订阅系统
4. 地图信息分析
5. 计时器,浏览量

## 安装

```
1. 下载压缩包
    wget 软件链接
2. 解压gz压缩包
     tar -zxvf redis-6.2.6.tar.gz 
3. 安装gcc-c++环境
    yum install gcc-c++
4. 进入解压后的文件夹,make命令
    make    //第一次会下载很多环境
    make install //测试是否安装好了
5. redis默认安装路径/usr/local/bin
    复制原生的redis.config到bin下进行配置
6. redis默认不是后台启动,需要设置配置文件
    daemonize=yes
7. 启动redis服务,进入/usr/local/bin,运行redis-server
    redis-server 配置文件(redis.conf)
    //redis-server redisconfig/redis.conf
8. 测试连接
    redis-cli -p 6379//启动服务之后才行
9. shutdown//关闭服务
```

## 性能测试

```
压测命令：redis-benchmark -h 127.0.0.1 -p 6379 -c 50 -n 10000
```

```
压测需要一段时间，因为它需要依次压测多个命令的结果，如：get、set、incr、lpush等等，所以我们需要耐心等待，如果只需要压测某个命令，如：get，那么可以在以上的命令后加一个参数-t
//比如
redis-benchmark -h 127.0.0.1 -p 6379 -c 100 -n 10000
```

## 基础知识

1. redis 有 16 个数据库,默认使用第 0 个
2. `select 数据库序号` 切换使用的数据库
3. `DBSIZE` 查询数据库大小
4. `set` `get`
5. `keys *` 查看数据库所有的 key
6. `flushdb` 清空当前数据库  `flushall` 清空所有数据库
7. Redis 是单线程的

   Redis 是基于内存操作的,Redis 的瓶颈是带宽和内存

   1. 为什么单线程还这么快?

      1. 高性能服务器不一定是多线程的
      2. 多线程会有上下文切换不一定比单线程效率高

      Redis 将数据全部放到内存中,使用单线程效率非常高

## 五大数据类型

### Redis-key

```
set key value   //设置key value
get key         //获取key对应的value
keys *          //显示所有键值对
exists key      //是否存在key
move key db     //移动key到db数据库
expire key time //设置key过期时间(秒)
ttk key         //查询key的剩余时间
type key        //查看key类型
```

### String

1. 动态字符串,可以进行修改.
2. 当字符串长度小于 1MB 时,拓容是加倍内存,大于 MB 时每次只会加 1MB,字符串长度最大为 512MB.
3. 如果 value 是一个整数,可以对其进行自增,但其范围为 `signed long` 的最大最小值之间

```
append key v     //给key追加v
strlen key       //获取key对应value长度
incr key         //是key对应value自增
decr key         //使key对应value自减
incrby key count //使key对应value+=count
decrby key count //减少count
getrange key st et      //截取key对应字符串value st到et 闭区间
setrange key start str  //从start起替换key对应value(可以变长)
SETEX key time value    //设置key-value 过期时间为time
SETNX key value         //不存在key时创建key-value
mset k1 v1 k2 v2        //一次性设置多值
mget k1 k2 k3           //一次性获取多值
msetnx k1 v1 k2 v2      //不存在才能创建,原子性必须全部成功才行
getset key newvalue     //获取key值并设置newvalue
实例:
    set user:1 {name:raja,age:18}
```

### List (列表)

注:命令均以 `l` 开头

1. `list` 是链表(不严谨),一些操作需要遍历链表,效率低,如:`lindex`
2. index 可以为负数,表示倒数第 index 个数
3. redis 底层快速链表.

   1. 在元素较少的情况下,redis 会使用一片连续的内存存储(ziplist 压缩列表),
   2. 在元素较多的情况下,redis 会改用 quicklist:多个 ziplist 通过双向指针连接

      1. 满足了快速插入删除.
      2. 不会有太大的空间冗余-> 普通链表有指针空间,还会加重内存碎片化.

```
lpush list v1 v2    //从list左边插入v1 v2
lrange list st et   //从list左边起遍历st到et
rpush list v1 v2    //从list右边插入v1 v2
lpop list [cnt]     //弹出list左边1或[cnt]个元素
rpop list [cnt]     //弹出list右边1或[cnt]个元素
lindex list index   //获取下标从左起为index的元素
llen list           //查看list大小
lrem list cnt value //移除list从左起cnt个值为value的元素
ltrim list st et    //保留list从左起下标st到et的元素
rpoplpush list1 list2   //移动
lset list index value   //将list中下标为index的值改为value(不存在就报错)
linsert list before value1 value2 //在value1前插入value2
linsert list after value1 value2  //在value1后插入value2
```

### Set (集合)

注:命令均以 `s` 开头,集合元素不重复

1. 可以用来保存中奖的人,以确保不会二次中奖

```
sadd myset v1 v2        //向集合中插入v1 v2
smembers myset          //查看myset中的所有元素
sismember myset value   //判断value是不是myset的元素(1,0)
scard myset             //获取set的中的元素个数
srem myset v1 v2        //删除myset中的元素v1 v2
srandmember myset [cnt] //随机抽选出1或[cnt]个元素
spop myset [cnt]        //随机删除1或[cnt]个元素
smove myset1 myset2 value //将myset1中value移动至myset2
sdiff set1 set2         //返回set1-set2的差集
sinter set1 set2        //交集
sunion set1 set2        //并集
```

### Hash (map 集合)

key-map

1. 类似 java 的 hashmap,使用一维数组 + 二维链表的形式存储
2. 拓容使用渐进式 rehash,使用新旧两个 hash 结构.

注:以 `h` 开头

```
hset myhash k1 v1           //设置myhash中k1 v1元素
hget myhash key             //获取..key元素的值
hmset myhash k1 v1 k2 v2    //设置多个值 可以分段进行保存,获取数据比较高效
hmget myhash k1 k2          //获取多个值
hgetall myhash              //获取myhash中所有键值对
hdel myhash k1 k2           //删除myhash中指定的k1 k2
hlen myhash                 //获取myhash元素个数
hincrby myhash key num      //增加num
hsetnx myhash key value     //不存在才创建
```

和 String 差不多

### Zset (有序集合)

1. 使用跳表进行存储 O(logn)

   1. 先在顶层定位,然后一层一层潜入下去,最后插入即可
2. inf 表示无穷大

```
zadd myset score1 v1 score2 v2  //插入数据
zrange myset st et              //遍历
zrangebyscore myset (minscore (maxscore [withscores] //返回递增minscore<= x <=maxscore [带score]的所有x 不加括号表示没等号
zrangebyscore myset (maxscore (minscore [withscores]//降序
zrem myset v1           //移除myset中的v1元素
zcard myset             //获取myset的元素个数
zcount myset min max    //获取myset score min到max中共多少元素
```

### 拓展

1. 容器型数据结构的通用规则:

   `list`,`set`,`hash`,`zset` 是容器型数据结构,共享以下两种规则

   1. 如果容器不存在就创建一个,在进行操作
   2. 如果容器里没有元素就立即删除容器.
2. 过期时间

   1. redis 的过期时间是以对象为单位进行设置的,如一个 hash 的过期是整个 hash 对象的过期,而不是其中一个子 key 的过期.
   2. 如果一个字符串设置了过期时间,然后使用 set 方法修改了它,则它的过期时间会消失.
3. 分布式锁:

   其利用 redis 处理指令是单线程.在 redis 内占一个坑,告诉别人我已经上锁了

   使用 `setnx`(不存在才设置),为了防止因为各种原因导致无法解锁导致死锁,给锁设置一个过期时间.

   使用 `set 锁名 锁值 ex 过期时间 nx` 进行上锁

   1. 锁冲突:

      1. 直接抛出异常,提示用户稍后重试
      2. sleep 一会再试
      3. 将请求转移到延时队列
4. 延时队列

   1. 异步消息队列:

      使用 `list`,读取使用阻塞读:`blpop/brpop`-> 在队列没有数据时会立刻休眠等待指定时间.

      `BRPOP 队列名1 队列名2 时间`

      1. 注意:如果一直阻塞,redis 客户端可能会主动断开连接!!!
   2. 延时消息队列

      1. 使用 `zset`,将消息序列化为一个字符串作为 `value`,到期处理时间作为 `score`,然后多线程轮询到期任务进行处理,

         `ZADD 队列名 过期时间 值`

         `ZRANGEBYSCORE 队列名 0 time.Now()`

         `zrem 队列名 value` 通过这个的返回结果判断是否获取到数据,处理并发问题
5. 布隆过滤器

   使用:

   ```shell
   bf.add k v # 添加
   bf.madd k v1 v2 # 添加多个
   bf.exists k v # 判断有没有...
   bf.reserve # 自定义过滤器
       -key #key
       -error\_rate # 错误率越高,占用空间越高
       -initial\_size # 预计放入的元素个数
   ```

   原理:一个大型位数组和几个不一样的无偏 hash(把 key 算的比较均匀)函数,每次 add 一个 key,通过多个 hash 函数算出多个位,将其都置为 1,在 exists 时查询那几个位是否都为 1.
6. 限流

   1. 简单限流:滑动窗口

      使用 `zset`,每次请求使用 zset 记录下来,value 保证唯一,score 保存当前时间戳,每次查询时先删除过期时间,再查询记录数进行判断.
   2. 漏斗限流

      漏斗的剩余空间代表着当前行为可以持续进行的数量,流水速率代表系统允许该行为的最大频率.

      结构:

      ```c
      type funnel struct {
          cap       float64   //容量
          rate      float64   //速率 额度/s
          freeSpace float64   //剩余空间
          lastTime  time.Time //上一次漏水时间->用于加剩余空间
      }
      ```

      使用:

      每次计算与上次漏水的时间间隔,加空间,然后判断所需额度(每次请求消耗额度)与剩余空间大小.

      `redis-cell` 提供了实现,可以了解一下.
7. `scan`

   常规的 `keys` 可能会阻塞线程,不能控制最大条数.

   `scan` 特点

   1. 通过游标分布进行,不会阻塞线程
   2. 提供 `limit` 参数,可以控制每次遍历的最大槽数
   3. 服务器不需要为游标保存状态,需要客户端进行保存.

   注意:

   1. 返回的结果可能重复
   2. 遍历过程中如果有数据修改,可能会无法遍历到
   3. 遍历结束的标志是返回的游标为 0

   使用:

   三个参数:`cursor` 游标位置,`match` 正则表达式,`count` 单次遍历的最大槽数

   ```shell
   \$ scan 0 match \* count 100
   1) "0"
   2) 1) "codehole"
      2) "list"
      3) "list2"
      4) "delay-queue"
      5) "k1"
   ```

   `scan` 遍历顺序:采用高位进位加法进行遍历避免因为字典的扩容缩容导致槽位遍历重复和遗漏

## 三大特殊数据类型

### geospatial 地理位置

```
geoadd key 纬度 经度 名称 //将指定的地理空间位置（经度,纬度、名称）添加到指定的key中
getpos key 名称   //获取指定名称的经度和纬度
geodist key city1 city2 [unit]//获取city1和city2之间的距离[m米/km千米/mi英里/ft英尺]
GEORADIUS key 经度 纬度 radius m|km|ft|mi [WITHCOORD] [WITHDIST] [WITHHASH] [COUNT count] [ASC|DESC] [STORE key] [STOREDIST key] //查找指定经纬度的点周围的点
//WITHDIST：还要返回指定中心返回物品的距离。距离以与指定为命令的半径参数的单位相同的单位返回。
//WITHCOORD：还返回匹配项目的经度，纬度坐标。
//ASC:由近到远 DESC:相反
//COUNT:查询数量
GEORADIUSBYMEMBER key 城市 radius//通过存在的城市进行查询,和上面差不多
geohash key city1 city2 ... //返回一个或者多个值的经纬度哈希
zrange  //可以遍历
zrem myset v1   //可以删除
```

底层使用 zset 实现,可以使用 zset 操作

### Hyperloglog (基数统计)

基数:不重复的元素

1. 提供不精确的去重统计
2. 数据较少时,使用稀疏矩阵,较多时使用稠密矩阵(1 个 key 固定 12kb 内存)

```
pfadd key v1 v2 v3     //添加元素
pfcount key            //统计个数
pfmerge key3 key1 key2 //将key1和key2合并到key3,不是覆盖
```

### Bitmaps (位存储)

1. 位图:普通字符串 byte 数组

   位图的最小单位是 bit.
2. 位图的位数组是自动拓展的

```
setbit key offset value //设置key中第offset位值为value(0或1)
getbit key offset       //查看key中第offset位的值
bitpos key bit [start,end] //查看key中第一个bit出现的位置,指定区间可以看数量
bitcount key            //统计key的value总和
# 整存
set k1 v1
# 整取
get k1
# 一次性操作多个位,有三个子命令,但每个子命令最多操作64个连续位
BITFIELD
    -get
        BITFIELD k1 get u4 0 //从第一个位开始获取4位,结果是uint型
        BITFIELD k1 get i4 0 //从第一个位开始获取4位,第一位是符号,结果是int型
    -set
        BITFIELD k1 set u8 8 97 //从第9位起8位用无符号数97替换
    -incrby
        BITFIELD k1 incrby u4 2 1 //从第3位起对接下来的4位无符号数+1,溢出则折返(默认).
            -overflow //溢出策略
                -sat  //饱和截断
                -fail //失败不执行
        BITFIELD k1 overflow sat incrby u4 2 1 //饱和截断
应用场景:
统计用户信息,活跃不活跃,登录未登录,打卡,只要两个状态都可以使用
```

### 拓展

xstream-消息队列-自己看书...

## 事务

```
事务:  一组命令的集合,所有的命令会按顺序执行
    一次性,顺序性,排他性
//Redis 单条命令是保证原子性的,但Redis的事务是不保证原子性的

//Redis的事务没有隔离级别的概念,不会出现幻读,脏读,重复读等概念->所有命令在事务中没有直接被执行,而是在发起执行命令时才会被执行
Redis 事务
    开启事务(multi)
    命令入队(...)
    执行事务(exec)
    取消事务(discard)
监控
    watch k1 k2 ... //开启监控
    unwatch         //取消监控
```

```
事务出错
    1. 编译型异常(命令的使用有误,如命令写错或参数不对)
       所有命令都不会执行
    2. 运行时异常(执行命令时发现问题,比如字符串增加)
       除了异常命令外,其余命令都会执行
```

> 监控: Watch 乐观锁

```
悲观锁:
    认为什么时候都会出问题,无论做什么都会加锁
乐观锁:
    不会加锁.在更新数据时判断一下,看此期间是否有人修改过这个数据
    1. 获取version
    2. 更新时比较version
```

正常情况下

监控开启之后进行事务,多线程修改监控的值导致事务提交失败

事务执行失败解决措施:

1. 重新监控
2. 再次执行

## REDIS.CONF 详解

> 配置文件大小写不敏感
>
> 可以包含多配置文件
>
> 网络
>
> ip `bind 127.0.0.1 -::1`
>
> 保护模式 `protected-mode yes`
>
> 端口号 `7963`

> 通用配置
>
> 是否以守护进程形式开启: `daemonize yes`
>
> 如果不以守护进程形式启动,需要指定对应 pid 文件 `pidfile /var/run/redis_6379.pid`
>
> 日志
>
> ```
> Specify the server verbosity level.
> debug (a lot of information, useful for development/testing) verbose (many rarely useful info, but not a mess like the debug level)
> ```
>
> `notice (moderately verbose, what you want in production probably)` 生产环境
>
> ```
> warning (only very important / critical messages are logged) loglevel notice
> ```
>
> 日志位置: `logfile ""`
>
> 数据库数量:  `databases 16`
>
> 是否显示 log `always-show-logo no`

> 快照 `SNAPSHOTTING`
>
> 持久化: 在规定的时间内,执行了多少次操作,则会持久化到文件 `.rdb` `.aof`
>
> ```
> save 3600 1 # 3600秒内,如果至少有1个key进行了修改,则持久化
> save 300 100
> save 60 10000
> ```
>
> 持久化出错后是否继续工作 : `stop-writes-on-bgsave-error yes`
>
> 是否压缩 rdb 文件 : `rdbcompression yes`
>
> 保存 rdb 文件时,进行错误的检查校验: `rdbchecksum yes`
>
> rdb 文件保存目录: `dir ./`

> 主从复制 `REPLICATION`

> 安全 `SECURITY`
>
> 密码: `requirepass xxxx`
>
> 设置(获取)密码: `set(get) requirepass XXXX`

> 客户端 `CLIENTS`
>
> 最大客户端连接数 `maxclients 10000`
>
> redis 配置最大内存数 `maxmemory <bytes>`
>
> 内存满了采取什么策略 `maxmemory-policy noeviction`
>
> ```
> 1、volatile-1ru:只对设置了过期时间的key进行LRU (默认值)
> 2、al1keys-1ru :删除1ru算法的key 
> 3、volatile-random: 随机删除即将过期key
> 4、al1keys-random: 随机删除
> 5、volatile-tt1:删除即将过期的
> 6、noeviction :永不过期，返回错误
> ```

> AOF 设置 `APPEND ONLY`
>
> 默认关闭 `appendonly no` 一般都是用 rdb
>
> 默认文件名 `appendfilename "appendonly.aof"`
>
> ```
> 记录的频率
> # appendfsync always
> appendfsync everysec # 每秒执行一次,但可能会丢失1秒内的数据
> # appendfsync no
> ```

## REDIS 持久化

内存型数据库在退出时会丢失数据,所以需要持久化操作

### RDB

快照原理:

redis 使用 COW 实现快照持久化

> fork(多线程)
>
> redis 在持久化时会创建一个子进程来遍历内存进行持久化.当父进程修改数据时会复制一份页然后对复制的页进行修改,而子进程数据不会有改变,等到持久化快结束了替换上次的持久化文件.

> 在指定时间间隔内将数据快照写入磁盘,恢复是将快照直接读入内存

rdb 默认保存文件为 `dbfilename dump.rdb`

> 触发机制:
>
> 1. `save` 规则满足的条件下
> 2. 执行 `flushall` 后,也会触发 rdb 规则
> 3. 退出 redis 关机,也会触发

> 如何恢复 rdb 文件?
>
> 只需要 `.rdb` 文件放到 redis 的启动目录下.

> 优点:
>
> 1. 适合大规模的数据恢复
> 2. 对数据的完整性要求不高(玩意 gg 了最后一次修改的数据就无了)
>
> 缺点:
>
> 1. 需要一定时间间隔进程操作.
> 2. fork 进程会占用内存

### AOF

> 以日志的形式记录每个写操作,将 redis 执行的指令记录下来,只允许追加文件.
>
> redis 启动会根据此文件重新构建数据(很慢)

> 默认是不开启的,开启后重启即可
>
> 如果 aof 文件损坏,redis 是无法开启的,需要修复
>
> `redis-check-aof --fix` 但是会清空一部分异常数据

> 优点 :
>
> 1. 每一次修改都会保存,数据完整性很好
>
> 缺点:
>
> 1. aof 文件非常大,修复速度慢,效率低

> 重写机制
>
> 如果 aof 文件太大,redis 会 fork 一个新的进程对文件进行重写

### 拓展

1. RDB 持久化方式能够在指定的时间间隔内对你的数据进行快照存储
2. AOF 持久化方式记录每次对服务器写的操作,当服务器重启的时候会重新执行这些命令来恢复原始的数据, AOF 命令以 Redis 协议追加保存每次写的操作到文件末尾, Redis 还能对 AOF 文件进行后台重写,使得 AOF 文件的体积不至于过大。
3. 只做缓存,如果你只希望你的数据在服务器运行的时候存在,你也可以不使用任何持久化
4. 同时开启两种持久化方式

   1. 在这种情况下,当 redis 重启的时候会优先载入 AOF 文件来恢复原始的数据,因为在通常情况下 AOF 文件保存的数据集要比 RDB 文件保存的数据集要完整。
   2. RDB 的数据不实时,同时使用两者时服务器重启也只会找 AOF 文件，那要不要只使用 AOF 呢?作者建议不要，因为 RDB 更适合用于备份数据库( AOF 在不断变化不好备份) , 快速重启,而且不会有 AOF 可能潜在的 Bug ,留着作为一个万一的手段。
5. 性能建议

   1. 因为 RDB 文件只用作后备用途,建议只在从机上持久化 RDB 文件,而且只要 15 分钟备份一次就够了,只保留 save 900 1 这条规则。
   2. 如果 Enable AOF ,好处是在最恶劣情况下也只会丢失不超过两秒数据,启动脚本较简单只 load 自己的 AOF 文件就可以了,代价一是带来了持续的 I0 ,二是 AOF rewrite 的最后将 rewrite 过程中产生的新数据写到新文件造成的阻塞几乎是不可避免的。只要硬盘许可,应该尽量减少 AOF rewrite 的频率, AOF 重写的基础大小默认值 64M 太小了,可以设到 5G 以上,默认超过原大小 100% 大小重写可以改到适当的数值。
   3. 如果不 Enable AOF , 仅靠 Master-Slave Repllcation 实现高可用性也可以,能省掉一大笔 I0 ,也减少了 rewrite 时带来的系统波动。代价是如果 Master/Slave 同时倒掉,会丢失十几分钟的数据,启动脚本也要比较两个 Master/Slave 中的 RDB 文件,载入较新的那个,微博就是这种架构。

## REDIS 发布订阅

redis 发布订阅是一种 `消息通信模式` : 发送者(pub)发布消息,订阅者(sub)接收消息.

```
PSUBSCRIBE pattern [pattern ...] # 订阅一个或多个符合给定模式的频道。
PUBSUB subcommand [argument [argument ...]] # 查看订阅与发布系统状态。
PUBLISH channel message # 将信息发送到指定的频道。
PUNSUBSCRIBE [pattern [pattern ...]] # 退订所有给定模式的频道。
SUBSCRIBE channel [channel ...] # 订阅给定的一个或多个频道的信息。
UNSUBSCRIBE [channel [channel ...]] # 指退订给定的频道。
监听订阅:`SUBSCRIBE raja`
发布消息:`PUBLISH raja test`

```

使用场景:

1. 实时消息系统
2. 实时消息
3. 订阅,关注

## Redis 架构主从、哨兵、集群

### 一、 主从复制 (Master-Slave Replication)

**核心定位**：解决数据备份和读并发瓶颈（读写分离）。

#### 1. 工作机制

- **1 主 N 从**：Master 节点负责处理读写请求（通常只做写），Slave 节点只负责处理读请求。
- 数据单向流动：只能由 Master 同步到 Slave。

#### 2. 设计原理 (同步机制)

- **全量同步 (Full Resynchronization)** ：

  - 发生在 Slave 初始化连接或断开过久时。
  - Master 执行 `bgsave` 生成 RDB 快照文件发送给 Slave，Slave 清空旧数据并加载 RDB。
  - 在生成和发送 RDB 期间，Master 接收到的新写请求会存入缓冲区（`repl_backlog_buffer`），随后增量发给 Slave。
- **增量同步 (Partial Resynchronization)** ：

  - 发生在网络闪断重连后。
  - 基于 `offset`​（偏移量）。Master 和 Slave 各自维护一个 offset。重连后，Slave 告诉 Master 自己的 offset，Master 从 `repl_backlog_buffer` 中提取这部分差异命令发送，避免昂贵的全量同步。

#### 3. 致命缺陷

- **不具备高可用**：Master 宕机后，系统失去写能力，必须**人工干预**将 Slave 提升为 Master。

---

### 二、 哨兵模式 (Sentinel)

**核心定位**：解决主从复制的单点故障问题，实现**自动故障转移（Failover）** 。

#### 1. 工作机制

引入独立的“哨兵”集群（本身也是 Redis 进程，但不存储数据），负责监控原有主从节点的状态，并在 Master 挂掉时自动换帅。

#### 2. 设计原理 (故障转移逻辑)

- **心跳监控**：Sentinel 每秒向所有 Master 和 Slave 发送 PING 命令，检测存活状态。
- **主观下线 (SDOWN)** ：如果一个 Sentinel 发现 Master 没按时回 PONG，它单方面认为 Master 挂了。
- **客观下线 (ODOWN)** ：为了防止网络抖动导致的误判，需要多个 Sentinel（达到配置的 `quorum` 数量）互相通信，达成“Master 确实挂了”的共识，才会正式触发 Failover。
- **Leader 选举**：Sentinel 集群内部使用类似于 Raft 的一致性算法，选举出一个 Leader Sentinel 来主导这次故障转移。
- **选主策略**：Leader 会从现有的 Slave 中挑一个最好的（优先级最高 -> 数据偏移量最大/数据最全 -> Run ID 最小）发送 `slaveof no one` 命令，将其晋升为新 Master，并修改其他 Slave 的配置指向新 Master。

#### 3. 致命缺陷

- **容量和写并发受限**：虽然解决了高可用，但本质上依然是单点写，集群的总内存容量和单节点写吞吐量依然受限于单台机器的物理极限。

---

### 三、 Redis 集群 (Redis Cluster)

**核心定位**：解决海量数据存储和单节点写并发瓶颈，实现**去中心化的水平扩容**。

#### 1. 工作机制

- **多主多从**：将数据分片（Sharding）存储在多个 Master 节点上，每个 Master 配备自己的 Slave 用于高可用。
- **无中心架构**：没有统一的代理层，节点之间对等。

#### 2. 设计原理 (分片与路由)

- **哈希槽 (Hash Slots)** ：

  - Redis Cluster 预设了 **16384** 个哈希槽。
  - 集群启动时，这 16384 个槽被分配给所有的 Master 节点。
  - **路由算法**：当客户端写入或读取 key 时，Redis 执行 `CRC16(key) % 16384` 算出一个槽位编号，然后根据槽位找到对应的 Master 节点。
- **Gossip 协议**：

  - 节点之间通过 PING/PONG 消息（Gossip 协议）持续交换状态信息（谁负责哪些槽，谁挂了，谁加入了）。
- **MOVED 重定向**：

  - 如果客户端把请求发给了错误的节点（该节点不负责这个 key 所在的槽），节点不会代理请求，而是返回一个 `MOVED` 错误，并附带目标节点的 IP 和端口。客户端收到后需要自己重新向正确的节点发起请求（通常由 Smart Client SDK 自动缓存槽位映射并在本地完成计算）。
- **内建高可用**：

  - 集群自带哨兵功能。如果某个 Master 节点失联，集群内其他在线的 Master 会通过 Gossip 协议达成共识，自动将其麾下的某个 Slave 提升为新 Master。

---

### 总结与技术选型

|维度|主从复制 (Master-Slave)|哨兵模式 (Sentinel)|Redis 集群 (Cluster)|
| --------| ----------------------------| ------------------------------| --------------------------------|
|解决痛点|数据备份、读写分离|自动故障转移（高可用）|海量数据、写并发、高可用|
|写节点数|单个 (SPOF 风险)|单个|多个 (水平扩展)|
|数据分片|否（全量复制）|否（全量复制）|是（哈希槽拆分）|
|适用场景|数据量小，并发极低，容忍停机|数据量小于单机内存，要求高可用|互联网大厂标配，数据量大，高并发|

---

## REDIS 集群

> [原文链接](https://cloud.tencent.com/developer/article/1592432)
>
> [Redis Cluster 命令]([Redis%20Cluster日常操作命令梳理%20-%20散尽浮华%20-%20博客园%20(cnblogs.com)](https://www.cnblogs.com/kevingrace/p/7910692.html))

### Redis 集群介绍

Redis 集群是 Redis 提供的分布式数据库方案，集群通过分片( sharding )来实现数据共享，并提供复制和故障转移。

> 为什么需要 Redis 集群呢?
>
>     主从复制和哨兵模式只会有一个主服务器( master )。主从复制，只会有一个 master ，可以有多个 slave。而哨兵模式是在主从复制的基础上，发现 master 挂掉，会自动的将其中一个 salve 升级成 master 。但是最终结果还是只有一个 master。所以如果系统很大，对 Redis 写操作的压力就会很大，所以才出现的集群的模式。集群模式可以有多个 master 。

集群模式图:

![image-20211211192314909](https://gitee.com/ORaja/picture/raw/master/img/image-20211211192314909.png)

> 总结: 集群就是多个 master 之间数据同步,单个 master 存在主从复制的哨兵模式

### 使用集群的好处

> 在没有 Redis 集群的时候，人们使用哨兵模式，所有的数据都存在 master 上面，master 的压力越来越大，垂直扩容再多的 salve 已经不能分担 master 的压力的，因为所有的写操作集中都集中在 master 上。所以人们就想到了水平扩容，就是搭建多个 master 节点。客户端进行分片，手动的控制访问其中某个节点。但是这几个节点之间的数据是不共享的。并且如果增加一个节点，需要手动的将数据进行迁移，维护起来很麻烦。所以才产生了 Redis 集群。
>
> Redis 集群有什么好处，就是进一步提升 Redis 性能，分布式部署实现高可用性，更加的稳定。当然还包含主从复制的数据热备份以及哨兵模式的故障转移等优点。

> 在哪使用集群呢?
>
> 一般较大的项目使用了 redis 的话，都会使用 redis 集群.
>
> 1. 利于拓展
> 2. Redis 的轻量级的,不会占用过多的性能

### 集群的主从复制和故障转移

> 集群的主从复制和单机的差不多
>
> 1. slave 会同步所属的 master 的数据
> 2. master 之间的数据会同步
>
> 故障转移也差不多,但是可以不用哨兵了(使用 master 充当哨兵的作用了)
>
> 1. 哨兵的作用,定期给监视的 master 发送 ping,如果认为其主观下线,就和其他哨兵一起判断,当数量达到一定数量后就认为其客观下线,然后选举出一个新的 master.
> 2. 而集群的 master 以同样的方式进行,master 之间会定时 ping,如果没有 ping 通就认为其主观下线,再结合半数以上的 master 都认为如此,就认定其为客观下线,再选举出一个新的 master 接替.

### 搭建一个 Redis 集群

1. 修改配置文件

   ```
   port 8000 # 端口
   daemonize yes # 后台
   cluster-enabled yes # 开启集群
   cluster-config-file nodes.conf # 用来存放当前节点信息。
   cluster-node-timeout 5000 # 超时
   ```
2. 启动服务

   ```
   [root@raja clusters]# ps -elf|grep redis
   5 S root     10276     1  0  80   0 - 42805 ep_pol 20:08 ?        00:00:00 /usr/local/bin/redis-server *:7963 [cluster]
   5 S root     10306     1  0  80   0 - 41269 ep_pol 20:08 ?        00:00:00 /usr/local/bin/redis-server *:7964 [cluster]
   5 S root     10329     1  0  80   0 - 41269 ep_pol 20:09 ?        00:00:00 /usr/local/bin/redis-server *:7965 [cluster]
   5 S root     10341     1  0  80   0 - 41269 ep_pol 20:09 ?        00:00:00 /usr/local/bin/redis-server *:7966 [cluster]
   5 S root     10356     1  0  80   0 - 41269 ep_pol 20:09 ?        00:00:00 /usr/local/bin/redis-server *:7967 [cluster]
   5 S root     10369     1  0  80   0 - 41269 ep_pol 20:09 ?        00:00:00 /usr/local/bin/redis-server *:7968 [cluster]
   0 S root     10384  8781  0  80   0 - 28203 pipe_w 20:09 pts/0    00:00:00 grep --color=auto redis
   ```
3. 节点互通

   ```
   cluster nodes # 查看当前连通的节点信息(包含自己)
   cluster meet  ip  port # 连接其他节点
   ```

   连接后的状态如下:

   ![image-20211211202254403](https://gitee.com/ORaja/picture/raw/master/img/image-20211211202254403.png)
4. 卡槽分配

   Redis 集群是通过分片的方式来保存数据库中的键值对的，集群整个数据库被分成 16384 个槽（slot）。也就是说所有数据的 key 都会映射到对应的 slot 中。只有当数据库中 16384 个槽都在节点上有分派，集群才会上线，否则集群的状态就是 fail。

   ```
   cluster addslots  slots[slots]
   样例：
   cluster addslots 0 1 2
   ```

   ```
   start=$1
   end=$2
   port=$3
   for slot in `seq ${start} ${end}`
   do
              echo "slot:${slot}"
                 redis-cli -p ${port} cluster addslots ${slot}
         done
   ```

   > 注: `cluster forget id` 用于节点下线时，将待下线节点从集群其他节点保存的节点列表中删除。由于 redis cluster 采用 gossip 协议交互节点信息及集群状态，所以只要集群中有一个节点知道待下线节点，随着 gossip 信息交换，集群中的其他节点最终也都知道该节点，正因为此，向集群添加一个节点时，只需要向集群任意一个节点执行 cluster meet 命令即可，也因此，为了将一个节点完全的从集群中删除，**必须对集群中其他所有节点都发送 cluster forget 命令。**
   >

   ```
   # 分配完后发现ok了
   ```

   ```
   127.0.0.1:7963> cluster info
   ```

   ```
   cluster_state:ok
   ```

   ```
   cluster_slots_assigned:16384
   ```

   ```
   cluster_slots_ok:16384
   ```

   ```
   cluster_slots_pfail:0
   ```

   ```
   cluster_slots_fail:0
   ```

   ```
   cluster_known_nodes:3
   ```

   ```
   cluster_size:3
   ```

   ```
   cluster_current_epoch:5
   ```

   ```
   cluster_my_epoch:1
   ```

   ```
   cluster_stats_messages_ping_sent:5577
   ```

   ```
   cluster_stats_messages_pong_sent:5596
   ```

   ```
   cluster_stats_messages_meet_sent:7
   ```

   ```
   cluster_stats_messages_fail_sent:2
   ```

   ```
   cluster_stats_messages_sent:11182
   ```

   ```
   cluster_stats_messages_ping_received:5596
   ```

   ```
   cluster_stats_messages_pong_received:5578
   ```

   ```
   cluster_stats_messages_fail_received:6
   ```

   ```
   cluster_stats_messages_received:11180
   ```

   ### 集群操作

   ![image-20211211212101731](https://gitee.com/ORaja/picture/raw/master/img/image-20211211212101731.png)

   可以看到，进行槽指派之后是可以进行正常的操作的，这里的 `set k1 v1` 提示我移动到 `7965` 端口执行。因为 `k1` 对应的卡槽为 `12706`.

   > 更方便的方法: `redis-cli -c -p 端口`
   >
   > 这样启动后进行操作会自动切换到对应端口后,再保存数据
   >
   > ![image-20211211212615039](https://gitee.com/ORaja/picture/raw/master/img/image-20211211212615039.png)
   >

   ### 配置主从

   前面为止，集群模式已经搭建好了，但是呢前文说的还有点瑕疵，现在就来说说，我们现在搭建的集群只有三个主节点，任何一个主节点挂掉了，就会导致集群不可用，因为集群可用的标志是 16384 个卡槽全部都分配到可用的节点上。所以我们现在搭建的集群还是不稳定的。所以为了解决这个问题，我们需要为每一个主节点配置一个从节点。 从节点的作用是数据热备份和当主节点出现故障时可以替代主节点进行工作

   1. 先将子节点加入到集群中

      ```
      CLUSTER MEET 127.0.0.1 7966
      ```

      ```
      CLUSTER MEET 127.0.0.1 7967
      ```

      ```
      CLUSTER MEET 127.0.0.1 7968
      ```
   2. 查找主节点的 nodesId

      ![image-20211211213812855](https://gitee.com/ORaja/picture/raw/master/img/image-20211211213812855.png)
   3. 将从节点和主节点关联起来。

      ```
      [root@raja 68]# redis-cli -p 7966 cluster replicate 1b560f8faa02976508ecd7fdfe408eb4ca28da8c
      ```

      ```
      OK
      ```

      ```
      [root@raja 68]# redis-cli -p 7967 cluster replicate dfcea0b4564a6ba484260dbe132793c0a9325a2e
      ```

      ```
      OK
      ```

      ```
      [root@raja 68]# redis-cli -p 7968 cluster replicate e4f037c9ca53f8da087d923e20c621b2a9f8e495
      ```

      ```
      OK
      ```

   再次查看节点信息

   ![image-20211211214843623](https://gitee.com/ORaja/picture/raw/master/img/image-20211211214843623.png)

   > 测试(断开节点)
   >
   > ```
   > # 断开连接
   > 127.0.0.1:7965> SHUTDOWN
   > not connected>
   > # 查看节点 信息
   > e4f037c9ca53f8da087d923e20c621b2a9f8e495 127.0.0.1:7965@17965 master,fail - 1639230607395 1639230604885 0 disconnected
   > # 其子节点编程master节点
   > 205be367c485aa2712ddb09cb2b86bdd3531f44e 127.0.0.1:7968@17968 master - 0 1639230788029 6 connected 10001-16383
   > 127.0.0.1:7963> set k1 v1
   > -> Redirected to slot [12706] located at 127.0.0.1:7968
   > OK
   > 127.0.0.1:7968> 
   > # 重连节点,发现其称为slave节点
   > e4f037c9ca53f8da087d923e20c621b2a9f8e495 127.0.0.1:7965@17965 slave 205be367c485aa2712ddb09cb2b86bdd3531f44e 0 1639230895000 6 connected
   > ```
   >
   > 方法二:
   >
   > 第二种方法搭建集群就简单讲啦，准备工作和启动都是一样的，只是不用我们自己进行节点互通和分配卡槽啦
   >
   > 1. 启动几个 redis
   > 2. 安装软件
   >
   >    ```
   >    yum install ruby
   >    ```
   >
   >    ```
   >    yum install rubygems
   >    ```
   >
   >    ```
   >    gem install redis
   >    ```
   > 3. 配置
   >
   >    执行以下命令，就会自动的帮我们进行节点互通，分配卡槽以及设置从节点。
   >
   >    ```
   >    ./redis-trib.rb create --replicas 1 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005
   >    ```
   >
   >    特别提醒，这里的 IP 用主机的 IP，如果使用 127.0.0.1 的话，在我们代码中访问会出错，我也是在项目中使用的时候碰到的
   >
   >    ![image-20211211220339766](https://gitee.com/ORaja/picture/raw/master/img/image-20211211220339766.png)
   >
   > 上面就已经搭建好集群了
   >

## REDIS 主从复制

**概念** 主从复制,是指将一台 Redis 服务器的数据,复制到其他的 Redis 服务器。前者称为主节点(master/leader) ,后者称为从节点(slave/follower) ;数据的复制是**单向**的,**只能由主节点到从节点**。Master 以写为主 , Slave 以读为主。 **默认情况下,每台 Redis 服务器都是主节点;且一个主节点可以有多个从节点(或没有从节点) ,但一个从节点只能有一个主节点。**

**主从复制的作用主要包括:**

1. 数据冗余:主从复制实现了数据的热备份,是持久化之外的一种数据冗余方式。
2. 故障恢复:当主节点出现问题时,可以由从节点提供服务,实现快速的故障恢复;实际上是一种服务的冗余。
3. 负载均衡:在主从复制的基础上,配合读写分离,可以由主节点提供写服务,由从节点提供读服务(即写 Redis 数据时应用连接主节点,读 Redis 数据时应用连接从节点) , 分担服务器负载;尤其是在写少读多的场景下,通过多个从节点分担读负载,可以大大提高 Redis 服务器的并发量。
4. 高可用(集群)基石:除了上述作用以外,主从复制还是哨兵和集群能够实施的基础,因此说主从复制是 Redis 高可用的基础。 一般来说，要将 Redis 运用于工程项目中,只使用一台 Redis 是万万不能的,原因如下:

   1. 从结构上,单个 Redis 服务器会发生单点故障,并且- 台服务器需要处理所有的请求负载,压力较大;
   2. 从容量上,单个 Redis 服务器内存容量有限,就算一台 Redis 服务器内存容 量为 256G ,也不能将所有内存用作 Redis 存储内存,一般来说， 单台 Redis 最大使用内存不应该超过 **20G**。电商网站.上的商品, 一般都是一次上传,无数次浏览的,说专业点也就是"多读少写"。对于这种场景,我们可以使如下这种架构:

> 增量同步:
>
> redis 同步的是指令流,主节点会将修改性指令保存到本地 buffer(定长的环形数组),然后异步将 buffer 同步到从节点,从节点将偏移量返回,如果因为网络或者同步的指令被覆盖了,就要使用快照同步.
>
> 快照同步:
>
> 先进行 bgsive,然后将 rdb 文件传输给从节点,然后通知从节点增量同步,

```
# 查看当前库的信息
127.0.0.1:7963> info replication
# Replication
role:master # 角色
connected_slaves:0 # 从机数
master_failover_state:no-failover
master_replid:825140e4ce53c71b03609f34d4f2ac16c56f30ac
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

### 主从复制部署

> 配置文件
>
> 1. `port` 端口
> 2. `pidfile` 后台运行 pid
> 3. `logfile` 日志文件
> 4. `dbfilename` 备份文件名

对于 Redis 集群，如果设置了 requirepass，则一定要设置 masterauth，否则从节点无法正常工作!!!

> 主从配置(命令行配置在断开后失效)

```
默认下每一台redis都是主机.
需要配置从机来连接主机
`SLAVEOF host port`
# SLAVEOF localhost 7963
# 从机
127.0.0.1:7964> info replication
# Replication
role:slave
master_host:localhost
master_port:7963
master_link_status:down
master_last_io_seconds_ago:-1
master_sync_in_progress:0
slave_read_repl_offset:1
slave_repl_offset:1
master_link_down_since_seconds:-1
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:08c57dc6f5e45b074aac4f23d4ff861a7dfd29e7
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
# 主机
127.0.0.1:7963> INFO replication
# Replication
role:master
connected_slaves:1
slave0:ip=127.0.0.1,port=7964,state=online,offset=98,lag=0
master_failover_state:no-failover
master_replid:69f449a8cd8f14b80e7ed4eb6b1da2cf516b5629
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:98
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:98
```

> 注意:
>
> 1. 主机可以写,从机只能读
> 2. 主机中的数据会被从机保存
> 3. 主机断掉,从机仍可读,主机重连,从机仍保持连接

**复制原理**

1. Slave 启动成功连接到 master 后会发送一个 sync 同步命令,Master 接到命令,启动后台的存盘进程,同时收集所有接收到的用于修改数据集命令,在后台进程执行完毕之后, master 将传送整个数据文件到 slave ,并完成一次完全同步。
2. 全量复制:而 slave 服务在接收到数据库文件数据后,将其存盘并加载到内存中。
3. 增量复制: Master 继续将新的所有收集到的修改命令依次传给 slave ,完成同步
4. 但是只要是重新连接 master , 一次完全同步(全量复制)将被自动执行

#### 主从复制原理

[原文链接](https://cloud.tencent.com/developer/article/1594111)

```
# 当启动一个一主两从的主从复制样例后 查看master
127.0.0.1:7963> info server
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:65d970af095d0295
redis_mode:standalone
os:Linux 3.10.0-957.21.3.el7.x86_64 x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:atomic-builtin
gcc_version:4.8.5
process_id:9794
process_supervised:no
run_id:3a7496f7372de18e4b9f31dc827e0c96f60268d2 # redis服务的唯一标志
tcp_port:7963
server_time_usec:1639148964386103
uptime_in_seconds:3347
uptime_in_days:0
hz:10
configured_hz:10
lru_clock:11759012
executable:/usr/local/bin/redis-server
config_file:/root/redisconfigs/redis7963.conf
io_threads_active:0
# 这个run_id 就是redis服务的唯一标识，重启redis服务号，这个run_id 会改变，多个redis客户端连接到同一个服务端，其run_id 是一样的，也就是说run_id 指的是服务端的id

# 查看master
127.0.0.1:7963> info replication
# Replication
role:master
connected_slaves:2
slave0:ip=127.0.0.1,port=7965,state=online,offset=4718,lag=0
slave1:ip=127.0.0.1,port=7964,state=online,offset=4718,lag=0
master_failover_state:no-failover
master_replid:19396025e773f6a214de67159207cda5af5a3742
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:4718
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576 # 复制缓存区大小
repl_backlog_first_byte_offset:1
repl_backlog_histlen:4718
# 其中repl_backlog_size 复制缓存区大小，默认大小为1M，如果mater_repl_offset在这个范围内，就看是部分复制，否则就开始全量复制。
```

> 全量复制:
>
> 1. 首先 slave 向 master 发送一个 psync 命令,因为是第一次,所以不知道 run_id 和 offset.
>
>    所以传过来-1 表示全量复制.
> 2. master 在接受到 psync 后,将 run_id 和 offset 发送给 slave
>
>    1. master 进行 bgsave 生成 rdb,并将 rdb 发送给 slave
>    2. 在 bgsave 时可能会有 write 数据,将数据存到 repl_back_buffer 中 并将 buffer 发送给 slave
> 3. slave 清空数据,然后加载 rdb 和 buffer 将数据存储起来。

> 部分复制
>
> 既然是部分复制，那就是 slave 已经知道了 master 的 run_id 和 offset ,所以发送 psync 命令带上这两个参数，master 就知道这是部分复制，然后通过偏移量将需要复制的数据发送给 slave。

> 总结:
>
> 主从复制的过程中既用到了全量复制也用到了部分复制，二者是相互配合使用的。看下面的流程图：

**层层链路**

**我想当老大**

```
SLAVEOF no one # 自己成为主机
```

### 哨兵模式

> 介绍:
>
> 下面是 Redis 官方文档对于哨兵功能的描述：
>
> 1. 监控（Monitoring）：哨兵会不断地检查主节点和从节点是否运作正常。
> 2. 自动故障转移（Automatic failover）：当主节点不能正常工作时，哨兵会开始自动故障转移操作，它会将失效主节点的其中一个从节点升级为新的主节点，并让其他从节点改为复制新的主节点。
> 3. 配置提供者（Configuration provider）：客户端在初始化时，通过连接哨兵来获得当前 Redis 服务的主节点地址。
> 4. 通知（Notification）：哨兵可以将故障转移的结果发送给客户端。
>
> 哨兵模式的结构拓扑图
>
> 大意就是
>
> 1. 每一个哨兵节点会监听其他的哨兵节点以及 master 和所有的 slave
> 2. 所有哨兵节点会定期的 ping 主节点，监控是否正常
> 3. 如果认为主节点出现故障的哨兵数量达到阙值，就判定主节点死掉，主节点就会客观下线
> 4. 主节点客观下线后，哨兵节点通过选举模式在 slave 中选择出一个升级为主节点
> 5. 其他的 salve 指向新的主节点
> 6. 原来的 master 变成 slave ，并且指向新的主节点
>
> **引用官方哨兵模式处理流程**
>
> 每个 Sentinel（哨兵）进程以 `每秒钟一次` 的频率向整个集群中的 Master 主服务器，Slave 从服务器以及其他 Sentinel（哨兵）进程发送一个 PING 命令。
>
> ● 如果一个实例（instance）距离最后一次有效回复 PING 命令的时间超过 `down-after-milliseconds` 选项所指定的值， 则这个实例会被 Sentinel（哨兵）进程标记为主观下线（`SDOWN`）。
>
> ● 如果一个 Master 主服务器被标记为主观下线（`SDOWN`），则正在监视这个 Master 主服务器的所有 Sentinel（哨兵）进程要以每秒一次的频率确认 Master 主服务器的确进入了主观下线状态。
>
> ● 当有足够数量的 Sentinel（哨兵）进程（大于等于配置文件指定的值）在指定的时间范围内确认 Master 主服务器进入了主观下线状态（`SDOWN`）， 则 Master 主服务器会被标记为客观下线（`ODOWN`）。
>
> ● 在一般情况下， 每个 Sentinel（哨兵）进程会以每 10 秒一次的频率向集群中的所有 Master 主服务器、Slave 从服务器发送 INFO 命令。
>
> ● 当 Master 主服务器被 Sentinel（哨兵）进程标记为客观下线（`ODOWN`）时，Sentinel（哨兵）进程向下线的 Master 主服务器的所有 Slave 从服务器发送 INFO 命令的频率会从 10 秒一次改为每秒一次。
>
> ● 若没有足够数量的 Sentinel（哨兵）进程同意 Master 主服务器下线， Master 主服务器的客观下线状态就会被移除。若 Master 主服务器重新向 Sentinel（哨兵）进程发送 PING 命令返回有效回复，Master 主服务器的主观下线状态就会被移除。

自动选老大

> 部署哨兵模式
>
> 1. 创建并修改哨兵配置文件 `sentinel.conf`
>
>    首先到我们 redis 安装目录下，发现有 sentinel.conf ，我们把它移到我们自己定义的文件夹中，和 redis.conf 放在一起。
>
>    ```
>    mv sentinel.conf /usr/local/redis/etc/
>    ```
>
>    ```
>    port 26379
>    dir /usr/local/redis/etc  
>    # 这里默认的是“/tmp”，如果你没有这个目录的权限就需要换啦，换一个你有权限的目录
>    sentinel monitor mymaster 192.168.252.53 6379 2
>    sentinel auth-pass mymaster 123456
>    # 设置监控的主节点，2是一个阈值，代表有两台或两台以上哨兵判断主节点redis不通的话就认定这个节点有问题，实行故障转移。
>
>    daemonize yes #后台启动
>    logfile "/usr/local/redis/logs/redis_sentinel-26379.log" #加上日志 ，不加也无所谓
>    ```
> 2. `sentinel monitor myredis 127.0.0.1 7963 1`
>
>    ```
>    sentinel monitor <masterName> <ip> <port> <quorum>
>    ```
>
>    1. `masterName` 这个是对某个 `master+slave` 组合的一个区分标识（一套 sentinel 是可以监听多套 master+slave 这样的组合的）。
>    2. `ip` 和 `port` 就是 master 节点的 ip 和 端口号
>    3. `quorum` 这个参数是进行**客观下线的一个依据**，意思是至少有 `quorum` 个 sentinel `主观` 的认为这个 master 有故障，才会对这个 master 进行下线以及故障转移。因为有的时候，某个 sentinel 节点可能因为自身网络原因，导致无法连接 master，而此时 master 并没有出现故障，所以这就需要多个 sentinel 都一致认为该 master 有问题，才可以进行下一步操作，这就保证了公平性和高可用。
> 3. `sentinel down-after-milliseconds <masterName> <timeout>`
>
>    1. 这个配置其实就是进行**主观下线的一个依据**
>    2. `timeout` 是一个毫秒值，表示：如果这台 sentinel 超过 `timeout` 这个时间都无法连通 master 包括 slave（slave 不需要客观下线，因为不需要故障转移）的话，就会主观认为该 master 已经下线（实际下线需要客观下线的判断通过才会下线）
> 4. 一些参数说明:
>
>    ![image-20211211155803177](https://gitee.com/ORaja/picture/raw/master/img/image-20211211155803177.png)
> 5. 启动哨兵
>
>    ```
>    redis-sentinel sentinel.conf
>    ```
>
>    监听一主二从
>
>    ![image-20211211174140026](https://gitee.com/ORaja/picture/raw/master/img/image-20211211174140026.png)
>
>    当主节点断开,通过选举出一个新节点座位主节点.之前的主节点也会称为子节点.
>
>    ![image-20211211174431837](https://gitee.com/ORaja/picture/raw/master/img/image-20211211174431837.png)

> 总结: 哨兵模式是主从复制的升级,但配置文件很难配

## REDIS 缓存穿透和雪崩

[原文链接](https://blog.csdn.net/qq_39794062/article/details/120434626)

### 缓存穿透

当缓存中没有数据的话,会直接去查数据库,当查询过多就会导致数据库挂了.**多 key 请求**

> 解决方式:
>
> 1. 接口校验
>
>    在调用接口时，可以在最外层先做一层校验，比如用户鉴权、数据合法性校验等等，提前过滤掉一些非法的接口请求。例如商品查询中，商品的 ID 是正整数，则可以直接对非正整数 ID 的请求直接过滤掉。
> 2. 缓存空值
>
>    当访问缓存和数据库都没有的数据时，可以将一个空值写入缓存，并给这个空值设置较短的过期时间，防止这个无效值一直占有内存。
> 3. 布隆过滤器
>
>    可以使用布隆过滤器存储所有可能访问的 key，当用户请求过来，先判断用户发来的请求的 key 是否存在于布隆过滤器中，不存在的 key 直接被过滤掉，存在的 key 则进一步查询缓存和数据库。布隆过滤器相当于在 Redis 缓存前面又进行了一次拦截校验。
>
>    1. 原理:
>
>       **说一个值存在时,此值可能不存在,说一个值不存在时,此值一定不存在.**
>
>       实际上布隆过滤器在 Redis 中的数据结构就是一个**大型的位数组 + 多个随机映射的哈希函数**
>
>       向布隆过滤器中添加 key 时，会使用多个 hash 函数计算这个 key 的 hash 值，并转换为数组中对应的索引值，然后对数组长度进行取模运算得到具体的存放位置，每一个 hash 函数都会计算出不同的位置，然后把数组中对应的位置置为 1，就相当于完成添加操作
>
>       当一个请求向布隆过滤器查询一个 key 是否存在时，跟添加操作一样，会把这个要查询的 key 通过 hash 函数计算出数组中对应的索引位置，看看数组中这个位置是否都为 1，只要有一个位置为 0，则说明布隆过滤器中不存在这个 key。如果这几个位置都为 1，并不能说明这个 key 一定存在，只是有非常大概率存在，因为这些位置为 1 很有可能是因为其它 key 存在所导致的。如果这个数组比较稀疏，那么布隆过滤器判断正确的概率还是很大的，如果说这个位数组比较密集，那么判断正确的概率就会降低。
>
>       **布隆过滤器空间占用的大小，可能会影响到判断元素是否存在的精准度。**
>
>       布隆过滤器有两个参数：
>
>       - 第一个参数是**预计元素的数量 n**(超过数量使错误率上升)
>       - 第二个参数是**错误率 f**。(错误率越低,空间越大)
>
>       布隆过滤器的**空间占用计算公式**根据这两个参数输入得到两个输出：
>
>       - 第一个输出是**位数组的长度 l**，也就是需要的存储空间大小(bit)
>       - 第二个输出是 **hash 函数的最佳数量 k。** hash 函数的数量也会直接影响到错误率，最佳的数量会有最低的错误率。
>
>       k=0.7∗(l/n)
>
>       f=0.6185(l/n)

### 缓存击穿

某热点 key 在过期的一瞬间被大量请求访问,导致全部直接访问数据库.**对同 key 请求**

> 解决方法:
>
> 1. 加互斥锁(同一时刻只有一个请求去访问数据库)
>
>    在并发的多个请求中，只有第一个请求线程能拿到锁并执行数据库查询操作，其他的线程拿不到锁就阻塞等着，等到第一个线程将数据写入缓存后，其它请求直接走缓存查询数据。
> 2. 热点数据设置不过期
>
>    直接将缓存设置为不过期，然后由定时任务去异步加载数据，更新缓存。这种方式适用于比较极端的场景，例如流量特别特别大的场景。很有可能发生异常，缓存无法更新

### 缓存雪崩

**大量的**热点 key 设置了相同的过期时间，导致缓存在**同一时刻**全部失效，造成瞬时数据库请求量大、压力骤增，引起雪崩，甚至导致数据库被打挂。缓存雪崩其实有点像“升级版的缓存击穿”，缓存击穿是一个热点 key，缓存雪崩是一组热点 key。**一组 key 击穿**

> 解决方法:
>
> 1. 分散过期时间
>
>    可以给缓存的过期时间时加上一个随机值时间，使得每个 key 的过期时间分布开来，不会集中在同一时刻失效。
> 2. 热点数据不过期
>
>    该方式和缓存击穿一样，也是要着重考虑刷新的时间间隔和数据异常如何处理的情况。
> 3. 加互斥锁
>
>    该方式和缓存击穿一样，按 key 维度加锁，对于同一个 key，只允许一个线程去计算，其他线程原地阻塞等待第一个线程的计算结果，然后直接走缓存即可

## 原理

### 线程 IO

1. 指令队列

   redis 为每个客户端关联一个指令队列,客户端指令通过队列按顺序处理.
2. 定时任务

   redis 的定时任务保存在一个小根堆中,最快要执行的任务在根顶,在每个循环周期内 redis 对已经到点的任务进行处理,记录下下一个要执行的任务的时间作为 select 中的 timeout 参数的值.

### 通信协议

redis 使用 `RESP` 通信协议(redis 序列化协议)

redis 数据被分为 5 种最小单元类型.单元结束统一加上回车换行 `\r\n`

1. 单行字符串使用 `+` 开头

   ```
   +hello world\r\n
   ```
2. 多行字符串以 `$` 开头,后跟字符串长度

   ```
   $11\r\nhello world\r\n
   ```
3. 整数以 `:` 开头,后跟整数字符串形式

   ```
   :1024\r\n
   ```
4. 错误信息以 `-` 开头
5. 数组以 `*` 开头,后跟数组长度.

   ```
   # 数组[1,2,3]
   ```

   ```
   *3\r\n:1\r\n:2\r\n:3\r\n
   ```

   1. `NULL` 使用多行字符串表示,不过长度为-1

      ```
      $-1\r\n
      ```
   2. 空串使用多行字符串表示,长度为 0

      ```
      $0\r\n\r\n # 两个\r\n中间是空串
      ```

### 内存回收机制

redis 并不是立刻将空闲内存归还给操作系统,而是等操作系统分配给它的页上的所有内存空闲时才归还,但是 redis 会利用那些空闲的内存.

### 过期策略

redis 会将所有设置了过期的 key 存到一个字典里,定时进行遍历这个字典进行删除,当访问某个 key 时也会进行判断.

1. 定期扫描策略

   redis 每秒进行 10 次过期扫描,每次从过期字典中选出 20 个 key,删除 20 个 key 中已经过期的 key,如果过期的 key 比例超过 1/4,就重复扫描.
