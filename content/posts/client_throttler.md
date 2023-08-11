---
title: "主动限流" # 标题
subtitle: "Client_throttler" # 副标题
description: "一种基于redis的主动限流算法" # 文章内容描述
date: 2023-08-11T20:34:15+08:00 # 时间
lastmod: 2023-08-11T20:34:15+08:00 # 上次修改时间
tags: ["redis","python"] # 标签
categories: ["算法"] # 分类
featuredImagePreview: "https://raw.githubusercontent.com/0RAJA/img/main/20230811204200-153-v2-64256851792c5b160a83c6ea0a216c8f_720w.jpg" # 封面链接
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人
---
<!--more-->

# 主动限流 throttler

# 背景介绍:

　　访问第三方API由于客观因素无法提高限制速率,需要主动限制请求频率,可以延迟请求,但不能丢弃请求,且能够在多副本情况下进行主动限流

　　![image](https://raw.githubusercontent.com/0RAJA/img/main/20230811203451-422-image-20230811102453-1bval4d.png)

# 如何限流？

## 均匀请求

　　目标：每个请求之间相隔`interval`

　　需要：全局变量(存储最近访问时间)

```python
last_time = get_last_time()                    # 获取最近请求时间
    if last_time + interval < now :            # 判断是否限流
        sleep(last_time + interval - now)
    else:
        update_time()                          # 更新请求时间
        func()
```

　　问题：效率低，无法并发请求，任意两个请求之间都需要等待一定周期

## 时间片限流

　　目标：每个时间片`interval`最多请求`MAX_COUNT`次，例如每秒10次

　　需要：start_time（时间片的开始时间），request_count(当前时间片内的请求数量)

```python
start_time = 时间片的开始时间
request_count = 当前时间片内的请求数量

if start_time + internal < now: # 判断是否需要更新时间戳
    start_time = now       
else:
    if incr(request_count) > MAX_COUNT:           # 判断是否达到该区间最大请求次数
        sleep(start_time + interval - now)        # 限流
    else:                                       
        func()
```

　　问题：时间片的限制条件，如果是1秒25次，可能出现0s请求1次,0.5s-1s请求24次,1s-1.5s请求25次，相当于1s请求了49次

　　如果缩小时间片限制，例如100毫秒2次，首先会损失精度，且同样可能出现跨区间请求造成超出限制的情况，除非缩小至`x`毫秒`1`次，但这样就退化为`均匀请求`方式

## 滑动窗口限流

　　目标：每个时间周期`interval`内最多请求`MAX_COUNT`次

　　需要：用请求时间戳构建时间窗口，维护时间窗口的请求数量

```python
start_time = now_time - internal    # 获取窗口开始时间
remranmger(0,start_time)            # 删除窗口外的数据
count = card(start_time, now)       # 获取窗口中的请求数
if count < MAX_COUNT:               # 如果数量<最大数则插入当前时间戳
    add(now_time)
    func()         
else:                           
    last_time = get_last_time()     # 根据窗口中第一个请求时间来计算等待时间
    sleep_time(last_time + internal - now_time)
```

# 如何在多副本下限流？

　　基于 redis 来实现，可以采用 `zset key -> {tag:value}`

## 采用zset+lua脚本来实现

　　确保 **计数，判断，插入** 的原子性

```lua
local key = KEYS[1]
local now = tonumber(ARGV[1])
local interval = tonumber(ARGV[2])
local max_count = tonumber(ARGV[3])
local tag = ARGV[4]
local start_time = now - interval

redis.call('zremrangebyscore', key, '-inf', start_time)
local count = redis.call('zcount', key, start_time, now)
if count < max_count then
    return redis.call('zadd', KEYS[1], now, tag)
else
    return 0
end
```

　　但是，由于lua脚本嵌套调用很不优雅，且不易于维护，腰斩！

　　![image](https://raw.githubusercontent.com/0RAJA/img/main/20230811203530-661-image-20230810180451-p6mvrp4.png)

## 利用区间来确保操作正确

```python
tag = 当前请求标识
now = time.now()
start_time = now - interval          # 获取窗口开始时间
remrange(0, start_time-1)            # 删除区间外的数据
set(tag, now+MAX_VALUE)              # 将当前记录作为极大值插入(极大值是为了防止指令执行过长导致该记录被删除)
count = card(start_time,+inf)        # 获取当前区间内的请求数来判断是否超频        
if count > MAX_COUNT:              
    rem(tag)                         # 限流则删除该记录
    first_time = get_first_time_by_range(start_time,now) # 根据当前区间内第一个请求的时间来计算下次请求时间
    sleep(first_time + interval - now)
else:
    set(tag, time.now()+buffer_time) # 恢复记录为当前时间+缓冲时间(缓冲时间是为了模拟解锁到请求的间隔时间)
    func()
```

# 模拟测试

|周期(s)|限制次数|进程数|单进程并发数|请求时延(ms)|缓冲时延(ms)|成功数|失败数|平均请求时间(s)|平均间隔时间(s)|
| :----------------: | :------------------: | :----------------: | :-------------------: | :--------------------: | :-----------------: | :-------------------: | :----------------: | :-----------------: | :-------------------: |
|1|200|3|2000|10-30|60|9000|0|71|1.61|
|1|50|3|1000|10-30|50|3000|0|64|1.11|
|5|100|3|500|10-30|50|1500|0|70|5.05|
|1|1|3|10|10-30|50|30|0|27|1.06|

# 具体实现

```python
# -*- coding: utf-8 -*-

import time
import uuid
from functools import wraps

from django_redis import get_redis_connection
from redis.client import Redis
from redis.exceptions import RedisError

from core.exceptions import RateLimitException

class TimeDurationUnit:
    """
    时间单位
    """

    NANOSECOND = 1
    MICROSECOND = 1000 * NANOSECOND
    MILLISECOND = 1000 * MICROSECOND
    SECOND = 1000 * MILLISECOND
    MINUTE = 60 * SECOND
    HOUR = 60 * MINUTE
    DAY = 24 * HOUR
    YEAR = 365 * DAY


# 采用一年作为极大值(以秒为单位)
TIME_DURATION_MAX_VALUE = TimeDurationUnit.YEAR / TimeDurationUnit.SECOND


redis_client: Redis = get_redis_connection()


class Throttler:
    """
    限流器(线程和进程)
    利用滑动窗口限制方法在指定时间区间内的被请求次数
    """

    prefix = "Throttler_"

    def __init__(
        self,
        func: callable,
        *,
        key: str,
        interval: int,
        max_count: int,
        enable_sleep_wait: bool = True,
        buffer_time: float = 0.05,
    ):
        """
        :param func: 被限流的方法
        :param key: 用于区分被限流的对象
        :param interval: 时间周期(秒)
        :param max_count: 该周期内的最大请求次数
        :param enable_sleep_wait: 被限流后是否睡眠并等待重试
        :param buffer_time: 请求从发出到到达的缓冲时间(秒)
        """

        self.func = func
        self.key = self.prefix + key
        self.interval = interval
        self.max_count = max_count
        self.enable_sleep_wait = enable_sleep_wait
        self.buffer_time = buffer_time

    def try_limit(self, tag: str) -> float:
        """
        尝试限流,采用redis zset中的key -> {tag:value}
        :param tag: 标签(区分不同的请求)
        :return: 需要等待的时间(秒),0表示不需要限流
        """

        """
        1. 删除区间外的数据
        2. 插入当前记录(极大值是为了防止指令执行过长导致该记录被删除)
        3. 获取当前区间内的请求数来判断是否超频
        4. 设置大key过期时间防止冷数据占用空间
        """
        now = time.time()
        start_time = now - self.interval
        with redis_client.pipeline(transaction=False) as pipe:
            pipe.zremrangebyscore(self.key, 0, start_time - TimeDurationUnit.MILLISECOND / TimeDurationUnit.SECOND)
            pipe.zadd(self.key, {tag: now + TIME_DURATION_MAX_VALUE})
            pipe.zcard(self.key)
            pipe.expire(self.key, 2 * self.interval)
            _, _, count, _ = pipe.execute(False)
        """
        1. 如果被限流了,则去除插入的记录并根据当前区间内第一个请求的时间来计算下次请求时间
        2. 没有限流则更新记录为当前时间戳+缓冲时间(缓冲时间是为了模拟解锁到请求的间隔时间)
        """
        if count > self.max_count:
            with redis_client.pipeline(transaction=False) as pipe:
                pipe.zrem(self.key, tag)
                pipe.zrangebyscore(self.key, start_time, now, start=0, num=1, withscores=True)
                _, result = pipe.execute()
            if not result:
                # 获取不到兜底休眠一个周期
                return self.interval
            _, last_time = result[0]
            return (last_time + self.interval - now) or self.interval
        else:
            redis_client.zadd(self.key, {tag: time.time() + self.buffer_time})
            return 0

    def get_delay_time(self, tag: str) -> float:
        """
        获取需要等待的时间
        """

        try:
            return self.try_limit(tag)
        except RedisError as e:
            logger.error(f"[Cache Lock Failed]Redis Err: key => {self.key},err => {e}")
            return 0

    def __call__(self, *args, **kwargs):
        tag = str(uuid.uuid1())
        while True:
            delay_time = self.get_delay_time(tag)
            if not delay_time:
                break
            if self.enable_sleep_wait:
                time.sleep(delay_time)
                continue
            raise RateLimitException(message="API Limit", data=f"func => {delay_time}; delay_time => {delay_time}")
        return self.func(*args, **kwargs)


def throttler(key: str, interval: int, max_count: int, enable_sleep_wait: bool = True, buffer_time: float = 0.05):
    """
    :param key: 用于区分被限流的对象
    :param interval: 时间周期(秒)
    :param max_count: 该周期内的最大请求次数
    :param enable_sleep_wait: 被限流后是否睡眠并等待重试
    :param buffer_time: 请求从发出到到达的缓冲时间(秒)
    """

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            return Throttler(
                func,
                key=key,
                interval=interval,
                max_count=max_count,
                enable_sleep_wait=enable_sleep_wait,
                buffer_time=buffer_time,
            )(*args, **kwargs)

        return wrapper

    return decorator

```

# 使用

```python
class TestAPI(Resource):
    @throttler(key="TestAPI", interval=1, max_count=200, buffer_time=0.60)
    def request(self, request_data=None, **kwargs):
        return super().request(request_data, **kwargs)

    def perform_request(self, validated_request_data):
        time.sleep(round(random.uniform(0.01, 0.03), 2))
        logger.info(f"[pass]key => TestAPI; tag => ; now => {time.time()}")
        return validated_request_data

@throttler(key="test_func", interval=1, max_count=200, buffer_time=0.60)
def test_func():
    logger.info(f"[pass]key => TestAPI; tag => ; now => {time.time()}")
```
