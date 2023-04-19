---
title: "Learn ElasticSearch" # 标题
subtitle: "Learn ElasticSearch" # 副标题
description: "学习ElasticSearch总结" # 文章内容描述
date: 2023-04-20T01:22:16+08:00 # 时间
lastmod: 2023-04-20T01:22:16+08:00 # 上次修改时间
tags: ["Elasticsearch","总结"] # 标签
categories: ["Elasticsearch"] # 分类
featuredImagePreview: "https://raw.githubusercontent.com/0RAJA/img/main/20230420012456-285-1024px-Elasticsearch_logo.svg.png" # 封面链接
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人
---
<!--more-->

# Elasticsearch

> [Elastic 开源社区](https://www.elastic.org.cn/archives/chapter1)

# 环境选择与安装

## 安装

> [docker 安装 es8.0 及 kibana 步骤_docker 安装 es 8 详细教程](https://blog.csdn.net/mcfeng007/article/details/124840268)
>
> [你必须会的 Docker 安装 ElasticSearch 教程 - 掘金 (juejin.cn)](https://juejin.cn/post/7074115690340286472)

```shell
# 拉取镜像
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.0.0
docker pull docker.elastic.co/kibana/kibana:8.0.0

# 创建网络
docker network create elastic

# 启动 Elastic Search 8.0.0
docker run -it \
-e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
--name elasticsearch \
--net elastic \
--restart=always \
-p 9200:9200 \
-p 9300:9300 \
-e "discovery.type=single-node" \
docker.elastic.co/elasticsearch/elasticsearch:8.0.0
# 第一次的日志中会打印出默认用户elastic的初始密码，以及用于Kibana启动的enrollment token（半小时有效）注意保存

# 启动 Kibana 8.0.0
docker run \
--name kibana \
--net elastic \
-p 5601:5601 \
docker.elastic.co/kibana/kibana:8.0.0
# 第一次的日志中会打印出启动配置网址，在浏览器打开并输入enrollment token，等待完成配置
# 使用用户名elastic和之前保存的密码登录

# 安装ik分词器
# 下载 https://github.com/medcl/elasticsearch-analysis-ik/releases
docker cp elasticsearch-analysis-ik-8.0.0.zip elasticsearch:/usr/share/elasticsearch/plugins

# 进入elasticsearch命令行
cd plugins/
mkdir ik
mv elasticsearch-analysis-ik-8.0.0.zip ik/
cd ik/
unzip elasticsearch-analysis-ik-8.0.0.zip
rm elasticsearch-analysis-ik-8.0.0.zip
 
# 重启es和kibana
docker restart elasticsearch
docker restart kibana
 
# 在kibana中测试ik分词器
GET _analyze
{
  "text" : "中华人民共和国国歌",
  "analyzer": "ik_max_word"
}
```

![image-20230406212436450](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-324-image-20230406212436450-20230411101225-w1d7yvs.png)

## Elasticsearch 目录结构

|**目录名称**|**描述**|
| :----------| :-------------------------------------------------------------------------------|
|bin|可执行脚本文件，包括启动 elasticsearch 服务、插件管理、函数命令等。|
|config|配置文件目录，如 elasticsearch 配置、角色配置、jvm 配置等。|
|lib|elasticsearch 所依赖的 java 库。|
|data|默认的数据存放目录，包含节点、分片、索引、文档的所有数据，生产环境要求必须修改。|
|logs|默认的日志文件存储路径，生产环境务必修改。|
|modules|包含所有的 Elasticsearch 模块，如 Cluster、Discovery、Indices 等。|
|plugins|已经安装的插件的目录。|
|jdk/jdk.app|7.x 以后特有，自带的 java 环境，8.x 版本自带 jdk 17|

## 基础配置

- [cluster.name](http://cluster.name/)：集群名称，节点根据集群名称确定是否是同一个集群。默认名称为 elasticsearch，但应将其更改为描述集群用途的适当名称。不要在不同的环境中重用相同的集群名称。否则，节点可能会加入错误的集群
- [node.name](http://node.name/)：节点名称，集群内唯一，默认为主机名。，但可以在配置文件中显式配置
- network.host： 节点对外提供服务的地址以及集群内通信的 ip 地址，例如 127.0.0.1 和 [::1]。
- http.port：对外提供服务的端口号，默认 9200
- transport.port：节点通信端口号，默认 9300

# Elasticsearch 简介

1. 天生支持分布式的搜索,聚合分析和存储引擎
2. OLAP 系统

   ![img](https://raw.githubusercontent.com/0RAJA/img/main/20230420015049-914-d8ced3196edd57413caa2d6e5d5dfbb1.png)
3. 特点

   ![image-20230410205931932](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-324-image-20230410205931932-20230411101227-7afjwai.png)
4. 常见指标速记

   1. ES 支持的搜索类型

      * 结构化搜索:可预先确定数据结构的数据
      * 非结构化搜索:例如博客,html 等
      * 文本搜索
      * 地理位置搜索
   2. 擅长从海量数据中查询少量相关数据,但不擅长一次查询大量数据
   3. 写入实时性不高
   4. 不支持事务
5. 选型

   ||Elasticsearch|Solr|MongoDB|MySQL|
   | :---------------| :-----------------------------| :--------------------------------------------------------| :-------------------------| :-------------------|
   |DB 类型|搜索引擎|搜索引擎|文档数据库|关系型数据库|
   |基于何种框架开发|Lucene|Lucene|||
   |基于何种开发语言|Java|Java|C++|C、C++|
   |数据结构|FST、Hash 等|||B+ Trees|
   |数据格式|Json|Json/XML/CSV|Json|Row|
   |分布式支持|原生支持|支持|原生支持|不支持|
   |数据分区方案|分片|分片|分片|分库分表|
   |业务系统类型|OLAP|OLAP|OLTP|OLTP|
   |事务支持|不支持|不支持|多文档 ACID 事务|支持|
   |数据量级|PB 级|TB 级~PB 级|PB 级|单库 3000 万|
   |一致性策略|最终一致性|最终一致性|最终一致性即时一致性|即时一致性|
   |擅长领域|海量数据全文检索大数据聚合分析|大数据全文检索|海量数据 CRUD|强一致性 ACID 事务|
   |劣势|不支持事务写入实时性低|海量数据的性能不如 ES 随着数据量的不断增大，稳定性低于 ES|弱事务支持不支持 join 查询|大数据全文搜索性能低|
   |查询性能|★★★★★|★★★★|★★★★★|★★★|
   |写入性能|★★|★★|★★★★|★★★|

# 核心概念

推荐阅读:[ES 节点角色深层解读，及高可用集群架构角色设计 - 墨天轮 (modb.pro)](https://www.modb.pro/db/523837)

## 节点 Node

一个节点为一个 ES 实例,一个 ES 进程.

正式环境下通常一个服务器一个节点.

## 角色 Roles

角色可以用来规定节点职责.

1. 常见角色

   * **主节点（active master）**：一般指活跃的主节点，一个集群中只能有一个，主要作用是对集群的管理。
   * **候选节点（master-eligible）**：当主节点发生故障时，参与选举，也就是主节点的替代节点。可以参与选举,也可以投票.
   * **数据节点（data node）**：数据节点保存包含已编入索引的文档的分片。数据节点处理数据相关操作，如 CRUD、搜索和聚合。这些操作是 I/O 密集型、内存密集型和 CPU 密集型的。监控这些资源并在它们过载时添加更多数据节点非常重要。
   * **预处理节点（ingest node）**：预处理节点有点类似于 logstash 的消息管道，所以也叫ingest pipeline，常用于一些数据写入之前的预处理操作。
2. 使用和配置方法

   准确的说，应该叫节点角色，是区分不同功能节点的一项服务配置，配置方法为

   ```json
   node.roles: [ 角色1, 角色2, xxx ]
   ```

   **注意：**

   > 如果 node.roles 为缺省配置，那么当前节点具备所有角色
   >

## 索引 Index

1. 索引是什么

   索引表述的含义等价于 MySQL 中的表（仅针对 ES 7.x 以后版本），注意这里只是类比去理解，索引并不等于表。
2. 索引的组成部分

   - alias：即 索引别名,戳：**[ES 中索引别名（alias）的到底有什么用](http://www.elastic.org.cn/archives/alias)**
   - settings：索引设置，常见设置如分片和副本的数量等。
   - mapping：即映射，定义了索引中包含哪些字段，以及字段的类型、长度、分词器等。
3. 拓展知识

   - **表示源文件数据**：当做数据的载体，即类比为数据表，通常称作 index 。例如：通常说 集群中有 product 索引，即表述当前 ES 的服务中存储了 product 这样一张“表”。
   - **表示索引文件**：以加速查询检索为目的而设计和创建的数据文件，通常承载于某些特定的数据结构，如哈希、FST 等。例如：通常所说的 正排索引 和 倒排索引（也叫正向索引和反向索引）。就是当前这个表述，索引文件和源数据是完全独立的，索引文件存在的目的仅仅是为了加快数据的检索，不会对源数据造成任何影响.
   - **表示创建数据的动作**：通常说创建或添加一条数据，在 ES 的表述为索引一条数据或索引一条文档，或者 index 一个 doc 进去。此时索引一条文档的含义为向索引中添加数据。

## 类型：Type（ES 7.x 之后版本已删除此概念）

### 4.1 类型的基本概念

从 Elasticsearch 的第一个版本开始，每个文档都存储在一个索引中并分配一个映射类型。映射类型用于表示被索引的文档或实体的类型，例如 product 索引可能具有 user 类型和 order 类型。

每个映射类型都可以有自己的字段，因此该 user 类型可能有一个 user_name 字段、一个 title 字段和一个 email 字段，而该 order 类型可以有一个 content 字段、一个 title 字段，并且和 user 类型一样，也有一个 user_name 字段。

每个文档都有一个_type 包含类型名称的元数据字段，通过在 URL 中指定类型名称，可以将搜索限制为一种或多种类型：

```json
GET product/user,order/_search
{
  "query": {
    "match": {
      "user_name": "吕小布"
    }
  }
}
```

### 4.2 为什么要删除 type 的概念

最初，“索引”类似于 SQL 数据库中的“数据库”，“类型”相当于“表”。即

|元字段|ES 6.x 及早期版本|ES 7.x 及之后版本|
| :-----| :----------------| :----------------|
|_index|DataBase|Table|
|_type|Table|固定为：“_doc”|
|_doc|Row|Row|

- **逻辑不合理**：然而这是错误的类比，官方后来也意识到了这是个错误。在 SQL 数据库中，表是相互独立的。一个表中的列与另一个表中的同名列无关。对于映射类型中的字段，情况并非如此。
- **数据结构混乱**：在 Elasticsearch 索引中，不同映射类型中具有相同名称的字段在内部由相同的 Lucene 字段支持。换句话说，使用上面的示例，类型中的 user_name 字段与 user 和 order 类型中的字段存储在完全相同的 user_name 字段中 ，并且两个 user_name 字段在两种类型中必须具有相同的映射（定义）。
- **影响性能**：最重要的是，在同一索引中存储具有很少或没有共同字段的不同实体会导致数据稀疏并干扰 Lucene 有效压缩文档的能力。

基于以上原因，官方决定从 Elasticsearch 中删除映射类型的概念。

### 4.3 替代方案

#### 每个文档类型的索引

第一种选择是为每个文档类型设置一个索引，而不是把 user 和 order 存储在单个索引中。这样索引彼此完全独立，因此索引之间不会存在字段类型冲突。

这种方法有以下好处：

- 避免了稀疏字段，数据更密集，有利于 Lucene 中对索引的压缩效率。
- 在全文搜索中用于评分的术语统计信息更可能准确，因为同一索引中的所有文档都表示单个实体。
- 索引粒度更小，方便动态优化每个索引的性能。比如可以分别为两个索引单独设置不同的分片数量

### 4.4 不同版本中的变化

**ES 5.6.0**

- 在索引上设置 index.mapping.single_type: true 将启用将在 6.0 中强制执行的单类型每索引行为。
- parent-child 的 [join 字段](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/parent-join.html)替换可用于 5.6 中创建的索引。

**ES 6.x**

- 在 5.x 中创建的索引将在 6.x 中继续发挥作用，就像在 5.x 中一样。
- 在 6.x 中创建的索引仅允许每个索引使用单一类型。该类型可以使用任何名称，但只能有一个。首选类型名称是_doc，以便索引 API 具有与 7.0 中相同的路径：

```json
PUT {index}/_doc/{id}和POST {index}/_doc
```

- _type 名称不能再与 组合 形成_id 字段_uid 。该_uid 字段已成为该_id 字段的别名。
- 新索引不再支持旧式的父/子，而应使用该 [join 字段](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/parent-join.html)。
- 不推荐使用_default_映射类型。
- 在 6.8 中，索引创建、索引模板和映射 API 支持查询字符串参数 ( include_type_name)，该参数指示请求和响应是否应包含类型名称。它默认为 true，并且应该设置为一个明确的值以准备升级到 7.0。不设置 include_type_name 将导致弃用警告。没有显式类型的索引将使用虚拟类型名称_doc。

**ES 7.x**

- **不推荐**在请求中指定类型。例如，索引文档不再需要文档 type。新的索引 API 适用 PUT {index}/_doc/{id}于显式 ID 和 POST {index}/_doc 自动生成的 ID。请注意，在 7.0 中，_doc 是路径的永久部分，表示端点名称而不是文档类型。
- 索引创建、索引模板和映射 API 中的 include_type_name 参数将默认为 false. 完全设置参数将导致弃用警告。
- _default_映射类型被删除 。

**ES 8.x**

- **不再支持**​在请求中指定类型。
- 该 `include_type_name` ​参数被删除。

## 文档

### 元数据 mata data

所有的元字段均已下划线开头，为系统字段。

- _index：索引名称
- _id：文档 id
- _version：版本号:索引每次修改都会 +1
- _seq_no：索引级别的版本号，索引中所有文档共享一个 _seq_no
- _primary_term：_primary_term 是一个整数，每当 Primary Shard 发生重新分配时，比如节点重启，Primary 选举或重新分配等，_primary_term 会递增 1。主要作用是用来恢复数据时处理当多个文档的_seq_no 一样时的冲突，避免 Primary Shard 上的数据写入被覆盖。

### 源数据 source data

指业务数据，即最终写入的用户数据。

## 集群：Cluster

### 自动发现

ES 是自动发现的，即零配置，开箱即用，无需任何网络配置，Elasticsearch 将绑定到可用的环回地址并扫描本地端口 9300 到 9305 连接同一服务器上运行的其他节点，自动形成集群。此行为无需进行任何配置即可提供自动集群服务。

### 核心配置

- **network.host**：即提供服务的 ip 地址，**一般配置为本节点所在服务器的内网地址**，此配置会导致节点由开发模 式转为生产模式，从而触发引导检查。**用于部署内网集群**.
- **network.publish_host**：即提供服务的 ip 地址，一般配置为本节点所在服务器的公网地址.**用于部署外网集群**
- **http.port**：调用服务端口号，默认 9200，通常范围为 9200~9299
- **transport.port**：节点通信端口，默认 9300，通常范围为 9300~9399
- **discovery.seed_hosts**：此设置提供集群中**其他候选节点的列表**，并且可能处于活动状态且可联系以播种[发现过程](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-hosts-providers.html)。每个地址可以是 IP 地址，也可以是通过 DNS 解析为一个或多个 IP 地址的主机名。
- **cluster.initial_master_nodes**：指定集群**初次选举**中用到的**候选节点**，称为集群引导，只在第一次形成集群时需要，如过配置了 network.host，则此配置项必须配置。重新启动节点或将新节点添加到现有集群时不要使用此设置。

### 集群的​健康​值检查

#### 健康状态

* 绿色：所有分片都可用
* 黄色：至少有一个副本不可用，但是所有主分片都可用，此时集群能提供完整的读写服务，但是可用性较低。
* 红色：至少有一个主分片不可用，数据不完整。此时集群无法提供完整的读写服务。集群不可用。

每个索引中的数据存在多个分片,每个分片存在对应副本.

> **新手误区：对不同健康状态下的可用性描述，集群不可用指的是集群状态为红色，无法提供完整读写服务，而不代表无法通过客户端远程连接和调用服务。**

![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230411131731-gs9hqmi.png)​

#### 健康值检查

1. `_cat API`​

   `GET _cat/health?v`​

   返回结果

   ![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230411132411-1ihk48o.png)​​
2. `_cluster API`​

   `GET _cluster/health`​

   返回结果

   ![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230411132726-n9aj3sn.png)​

### 集群的故障诊断

检查集群的健康状态,是否有节点未加入或者脱离集群,以及是否有异常状态的分片.

#### Cat APIs：

**常用 APIs：**

* `_cat/indices?health=yellow&v=true`​：查看当前集群中的所有索引
* `_cat/health?v=true`​：查看健康状态
* `_cat/nodeattrs`​：查看节点属性
* `_cat/nodes?v`​：查看集群中的节点
* `_cat/shards`​：查看集群中所有分片的分配情况

#### Cluster APIs

* `_cluster/allocation/explain`​：可用于诊断分片未分配原因

  ```json
  GET _cluster/allocation/explain
  {
    "index": "test_index", # 索引
    "shard": 0, # 分片序号
    "primary": false # 是否为主节点
  }
  ```

* `_cluster/health/ ​`​​：检查集群状态

#### 索引未分配的原因

* ALLOCATION_FAILED: 由于分片分配失败而未分配
* CLUSTER_RECOVERED: 由于完整群集恢复而未分配.
* DANGLING_INDEX_IMPORTED: 由于导入悬空索引而未分配.
* EXISTING_INDEX_RESTORED: 由于还原到闭合索引而未分配.
* INDEX_CREATED: 由于 API 创建索引而未分配.
* INDEX_REOPENED: 由于打开闭合索引而未分配.
* NEW_INDEX_RESTORED: 由于还原到新索引而未分配.
* NODE_LEFT: 由于承载它的节点离开集群而取消分配.
* REALLOCATED_REPLICA: 确定更好的副本位置并取消现有副本分配.
* REINITIALIZED: 当碎片从“开始”移回“初始化”时.
* REPLICA_ADDED: 由于显式添加了复制副本而未分配.
* REROUTE_CANCELLED: 由于显式取消重新路由命令而取消分配.

## 分片 Shard

可以理解为索引的碎片,可以无限复制

#### 分片种类

1. 主分片:可读可写
2. 副本分片:只读

作用:容灾,副本提高效应能力,分片提高写能力

#### 分片的基本策略

* 一个索引包含一个或多个分片，在 7.0 之前默认五个主分片，每个主分片一个副本；在 7.0 之后默认一个主分片。副本可以在索引创建之后修改数量，但是主分片的数量一旦确定不可修改，只能创建索引
* 每个分片都是一个 Lucene 实例，有完整的创建索引和处理请求的能力
* ES 会自动再 nodes 上做分片均衡 shard reblance (**节点离开和加入时延时触发**)
* 一个 doc 不可能同时存在于多个主分片中，但是当每个主分片的副本数量不为一时，可以同时存在于多个副本中。
* `主分片和其副本分片` ​不能同时存在于同一个节点上。
* `完全相同的副本` ​不能同时存在于同一个节点上。

#### 分片的作用和意义

* 高可用性：提高分布式服务的高可用性。
* 提高性能：提供系统服务的吞吐量和并发响应的能力
* 易扩展：当集群的性能不满足业务要求时，可以方便快速的扩容集群，而无需停止服务。

# 索引和文档的基本操作

### Search API

基本语法

```json
GET /<index_name>/_search 
GET /_search 
```

可选参数

* size：单次查询多少条文档，默认为 10
* from：起始文档偏移量。需要为非负数，默认为 0
* **timeout：**指定等待每个分片响应的时间段。如果在超时到期之前未收到响应，则请求失败并返回错误。默认为无超时。

### Index API

#### Settings：索引设置（见：第四章 3.2 小节）

基本语法

1. 创建索引时指定 `settings`​

   `PUT <index_name>`​

   eg:**创建主分片为 1,备份为 1 的索引**

   ```json
   PUT test_setting
   {
     "settings": {
       "number_of_shards": 1,  // 主分片数量为 1
       "number_of_replicas": 1 // 为每个主分片分配一个副本
     }
   }
   ```
2. 修改 `settngs`​

   使用 `_setting` ​只能修改允许动态修改的配置项

   `PUT /<index_name>/_settings`​

   eg:**修改主分片备份节点**

   ```json
   PUT index_test/_settings
   {
     "number_of_replicas": 1
   }
   ```
3. 静态索引 `settings`​

   只能在创建索引时或在关闭状态的索引上设置。

   **重要的静态配置**

   * **index.number_of_shards**：索引的主分片的个数，默认为 1，此设置只能在创建索引时设置

   每个索引的分片的数量上限为 1024，这是一个安全限制，以防止意外创建索引，这些索引可能因资源分配而破坏集群的稳定性。export ES_JAVA_OPTS=“-Des.index.max_number_of_shards=128” 可以通过在属于集群的每个节点上指定系统属性来修改限制
4. 动态索引 `settings`​
   即可以使用 `_setting API` ​在实时修改的配置项。

   **重要的动态配置**

   * **index.number_of_replicas：**每个主分片的副本数。默认为 1，允许配置为 0。
   * **index.refresh_interval：**执行刷新操作的频率，默认为 1s. 可以设置 -1 为禁用刷新。
   * **index.max_result_window： ​**​`from + size` ​搜索此索引 的最大值。默认为 **10000**.

     搜索请求占用堆内存和时间 from + size，这限制了内存。请参阅 Scroll 或 Search After 以获得更有效的替代方法。

     **推荐阅读**：[增大 max_result_window 是错的，ES 只能查询前 10000 条数据的正确解决方案](http://www.elastic.org.cn/archives/maxresultwindow)

#### 创建索引

1. 基本语法

   `PUT <index_name>`​

   * `index_name` ​索引名
2. 索引明明规范

   * 必须全部小写
   * 索引名称中不能包含以下符号：`\`​、`/`​、`*`​、`?`​、`"`​、`<`​、`>`​、`|`​、`<span> </span>` ​空白符号、`,`​、`#`​
   * 7.0 之前的索引可以包含冒号英文冒号 : ，但在 7.x 及之后版本中不再受支持。
   * 不使用中文命名索引
   * 可以使用 `-`​、`_` ​或者 `+` ​三种符号，但是不能以这三种符号开头。
   * 不能是 `.` ​或者 `..`​
   * 不能超过 255 个字节长度
   * 业务索引不能以 `.` ​开头，因为这些索引是给 `内部索引（如数据流中的后备索引）` ​和 `隐藏索引` ​使用的

   **总结：如过记不住这些规则，请牢记以下几点**

   * 以小写英文字母命名索引
   * 不要使用 `驼峰` ​或者 `帕斯卡` ​命名法则
   * 如过出现多个单词的索引名称，以全小写 + 下划线分隔的方式：如 `test_index`​​。

#### 删除索引

1. 基本语法

   ```json
   DELETE /<index_name>
   ```

   * index_name：索引名称

#### 判断索引是否存在

1. 基本语法

   `HEAD <index_name>`​

#### 索引的不可变性

ES 索引创建成功之后，以下属性将不可修改

* **索引名称**
* **主分片数量**
* **字段类型**

#### Reindex 重新创建文档

1. 基本语法

   ```json
   POST _reindex
   {
     "dest": {
       "index": "新索引"
     },
     "source": {
       "index": "源索引"
     }
   }
   ```

**注意:如果索引中没有文档则不会创建新的索引**

### Document API

#### 文档的操作类型

```json
enum OpType {
   INDEX(0),
   CREATE(1)
}
```

* **index**：索引（动词）， 不存在时创建，存在时**全量替换**
* **create**：不存在则创建，存在则报错

**注意：**

* 以上操作均为**写操作。**
* ES 中的数据写入均发生在 **Primary Shard**
* 当操作对象为数据流时，op_type 必须为 create

##### Create 创建

如果在 PUT 数据的时候当前数据已经存在，则数据会被覆盖，**如果在 PUT 的时候指定操作类型 ​**​`create`​，**此时如果数据已存在则会返回失败**，因为已经强制指定了操作类型为 create，ES 就不会再去执行 update 操作。

1. 基本语法

   `PUT /<index_name>/_doc/<_id>?op_type=create`​

   **案例**

   在 `test_index` ​索引下使用 `create` ​方式创建一个文档

   ```json
   PUT test_create/_doc/1?op_type=create
   {
     "name":"傻妞手机",
     "content":"华人牌2060款手机傻妞"
   }
   ```

   或者可以简化为:

   ```json
   PUT test_create/_create/1
   {
     "name":"傻妞手机",
     "content":"华人牌2060款手机傻妞"
   }
   ```
2. 自动生成 ID

   `POST /<target>/_doc/`​

   **案例**

   创建一个文档，并随机生成文档 id

   ```json
   POST test_index/_doc
   {
     "test_field":"test",
     "test_title":"title"
   }
   ```

#### 文档的 CRUD

##### Document Index API：索引 API

将 JSON 文档添加到指定的数据流或索引并使其可被检索。

如果目标是索引并且文档已经存在，则请求更新文档并增加其版本号。

1. 基本语法

   ```json
   # 创建或更新文档
   PUT /<target>/_doc/<_id>
   # 使用create方式创建文档
   PUT /<target>/_create/<_id>
   # 可以不指定id来自动生成
   POST /<target>/_create/<_id>
   ```

##### GET API

1. **查询指定 id 的文档**

   `GET <index>/_doc/<_id>`​
2. **判断指定 id 的文档是否存在**

   `HEAD  <index>/_doc/<_id>`​

   > 通过 HEAD 判断文档是否存在的使用场景很局限，因为其完全可以被 GET 所取代，比如下列查询，当 id 为 1 的文档不存在的时候，返回 `found：false`​
   >

   ```json
   GET test_create/_doc/3
   
   {
     "_index" : "test_create",
     "_type" : "_doc",
     "_id" : "3",
     "found" : false
   }
   ```
3. **_source API**

   使用 _source API 可以打开或者关闭源数据字段，true 为打开，false 为关闭，默认为 true。

   `GET <index>/_doc/<_id>?_source=false`​

   也可以只查询 `source` ​字段

   `GET <index>/_source/<_id>?`​

##### DELETE API

删除索引中指定 id 的文档，Document Delete API 必须指定 id

`DELETE /<index>/_doc/<_id>`​

##### UPDATE API

修改局部字段或者数据

```json
POST /<index>/_update/<_id>
{
  "doc": {
    "<field_name>": "<field_value>"
  }
}
```

#### Multi get (mget) API 批量查询

1. 语法

   ```json
   GET /_mget
   {
     "docs": [
       {
         "_index": "<index_name>",
         "_id": "<_id>"
       },
       {
         "_index": "<index_name>",
         "_id": "<_id>"
       }
     ]
   }
   
   ```

   **支持查询同一个索引的不同 id，也可以查询不同索引的不同 id。**
2. 简化语法: 同一个索引下

   ```json
   GET <index_name>/_mget
   {
     "docs": [
       {
         "_id": "<_id>"
       },
       {
         "_id": "<_id>"
       }
     ]
   }
   ```
3. 进一步简化: 使用列表

   ```json
   GET /<index_name>/_mget
   {
     "ids" : ["<_id_1>", "<_id_2>"]
   }
   ```
4. **意义**

   可以根据不同文档,指定不同查询策略

   ```json
   GET <>/_mget
   {
     "docs": [
       {
         "_id": "1",
         "_source": false
       },
       {
         "_id": "2",
         "_source": true
       }
     ]
   }
   ```

#### Bulk API 批量写入

1. 语法

   ```json
   POST /_bulk
   POST /<index>/_bulk
   {"action": {"mata data"}} # 行为(upda,delete,index...),元数据
   {"data"} # 数据
   ```

2. 创建文档

   ```json
   POST /_bulk
   {"create":{"_index":"test_create"}}
   {"name":"raja","age":21}
   {"create":{"_index":"test_create"}}
   {"name":"aologei","age":22}
   {"create":{"_index":"test_create"}}
   {"name":"bing","age":23}
   ```

3. 覆写文档

   ```json
   POST /_bulk
   {"index":{"_index":"test_create","_id":"-KWHeocBr-sH4YsOQrTk"}}
   {"age":22}
   ```
4. 更新文档

   ```json
   POST /_bulk
   {"update":{"_index":"test_create","_id":"-KWHeocBr-sH4YsOQrTk"}}
   {"doc":{"age":22,"name":"raja"}}
   ```
5. 删除文档

   ```json
   POST /_bulk
   {"delete":{"_index":"test_create","_id":"-KWHeocBr-sH4YsOQrTk"}}
   ```

使用场景

大数据量的批量操作.

> * bulk api 对 json 的语法有严格的要求，除了 delete 外，每一个操作都要两个 json 串（mata data 和 source field data），且每个 json 串内不能换行，非同一个 json 串必须换行，否则会报错；
> * bulk 操作中，任意一个操作失败，是不会影响其他的操作的，但是在返回结果里，会告诉你异常日志

#### DeleteByQuery

1. 语法

   ```json
   POST /<index_name>/_delete_by_query
   {
     "query": {
       ...
     }
   }
   ```

2. 使用 `term` ​过滤器匹配 `test_field` ​字段值为 `test` ​的文档

   ```json
   POST /test_create/_delete_by_query
   {
     "query":{
       "term":{
         "test_field":"test"
       }
     }
   }
   ```

**需要注意的是，  DeleteByQuery   删除文档是一个耗时的操作，如果待删除的文档数量比较大，可能会消耗较长的时间，并且会对 Elasticsearch 的性能产生影响。因此，在使用   DeleteByQuery   操作时，需要慎重考虑并评估其影响**

# Mapping 映射

## 简介

1. ### 介绍

   类似关系型数据库中 `表结构` ​的概念,在 `Mapping` ​里包含了一些属性，比如**字段名称**、**类型**、**字段使用的分词器**、**是否评分**、**是否创建索引等属性**，并且在 ES 中**一个字段可以有对个类型。**

   ![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230413204350-e5ea3mi.png)​
2. ### 查看索引映射

   1. 查看完整映射

      `GET /<index_name>/_mappings`​
   2. 查看索引中指定字段的映射

      `GET /<index_name>/_mappings/field/<field_name>`​

      举例

      `GET test_create/_mapping/field/content`​

      ![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230413204922-f5tjnxu.png)​

## 自动映射 dynamic mapping

自动映射是 ES 在索引文档写入时自动创建 `Mapping` ​的一种机制.

### 自动类型推断规则

**自动映射器会尽可能的把字段映射为宽字段类型。**

![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230413205510-j2968vk.png)​

### mapping 的使用禁忌

* ES 没有隐式类型转换:

  在 Elasticsearch 中，不会自动进行数据类型的转换。比如，在建立索引时，如果某个字段的类型为 integer  ，那么如果尝试向该字段中插入一个字符串类型的值，Elasticsearch 会直接报错，而不是试图将字符串转换为整数并存储。这也意味着，如果想要存储的数据类型与已有的 Mapping 定义不一致，开发者必须显式地将数据类型进行转换。
* ES 不支持类型修改

  这里指的是 Elasticsearch 不允许直接修改现有 `Mapping`​ 的属性。比如，如果想将一个已经建好的索引中某个字段的数据类型由   string   修改为   integer  ，需要重建该索引。**目前，Elasticsearch 只允许在新增字段时添加类型约束**。
* 生产环境尽可能的避免使用 dynamic mapping

  在 Elasticsearch 中，一个开关  dynamic  决定是否开启动态 mapping，即是否允许 Elasticsearch 自动创建 Mapping。

  如果开启，当向索引中添加一个新字段时，Elasticsearch 会自动判断该字段的类型，并尝试建立对应的 Mapping。这个功能是非常实用的，但也存在一些隐患。因为 Elasticsearch 的动态 mapping 是基于扫描文档内容自动推断字段类型的，因此会存在一些问题。比如，如果字段的内容没有很好地覆盖了所有的数据类型，那么 Elasticsearch 会将该字段的数据类型设置为   string  ，这可能不符合实际情况。同时，如果在无意中出现了错误映射，可能会导致数据的查询和分析错误。因此，在生产环境中尽可能禁用动态映射，手动创建并维护 Mapping，可以更加精确地控制索引中的数据。

## 手动映射

也成为显式映射,即在索引文档写入之前手动制定每个字段类型,分词器等.

### 创建索引的 mapping

1. 规范

   ```json
   PUT /<index_name>
   {
     "mappings": {
       "properties": { // 属性
         "field_a": { // 字段A
           "<parameter_name>": "<parameter_value>" // 字段属性
         },
         ...
       }
     }
   }
   ```
2. 样例

   创建 `goods` ​索引的 `mapping`​

   ```json
   PUT goods
   {
     "mappings": {
       "properties": {
         "brand": {
           "type": "keyword"
         },
         "createtime": {
           "type": "date"
         },
         "desc": {
           "type":"text",
           "analyzer":"standard"
         },
         "lv": {
           "type": "keyword"
         },
         "name": {
           "type": "keyword"
         },
         "price": {
           "type": "long"
         },
         "tags": {
           "type": "keyword"
         },
         "type": {
           "type": "keyword"
         }
       }
     }
   }
   ```

### 修改索引的 mapping 属性

1. 语法

   ```json
   PUT <index_name>/_mapping
   {
     "properties": {
       "<field_name>": {
         "type": "text",	// 必须和原字段类型相同，切不许显式声明
         "analyzer":"ik_max_word",	// 必须和元原词器类型相同，切必须显式声明
         "fielddata": false
       }
     }
   }
   ```

   **注意：**并非所有字段参数都可以修改。

   * **字段类型**不可修改

     ```json
     PUT goods/_mapping
     {
       "properties": {
         "brand": {
           "type": "text",
         }
       }
     }
     ```
   * **字段分词器**不可修改

     例如: 需要携带之前的类型

     ```json
     PUT goods/_mapping
     {
       "properties": {
         "brand": {
           "type": "keyword",
           "analyzer": "standard"
         }
       }
     }
     ```
   * **字段名称**不可修改

## ES 数据类型

### 概述

每个字段都有字段数据类型或字段类型,分为两种

* 会被分词的数据类型

  text、match_only_text 等
* 不会被分词的数据类型

  keyword、数值类型等

当然数据类型的划分可以分为很多种，比如按照 `基本数据类型和复杂数据类型` ​来划分

### ES 支持的数据类型

#### 基本数据类型

* **Numbers**：数字类型，包含很多具体的基本数据类型
  ​![在这里插入图片描述](https://raw.githubusercontent.com/0RAJA/img/main/20230420013736-396-25b608a44a154723adf9260fa5c2fa6d.jpeg)​
* **binary**：编码为 Base64 字符串的二进制值。
* **boolean**：即布尔类型，接受 true 和 false。
* **alias**：字段别名。
* **Keywords**：包含 **keyword** ★、constant_keyword 和 wildcard。
* **Dates**：日期类型，包括 **data** ★ 和 data_nanos，两种类型

#### 对象数据类型(复杂类型)

* **object**：非基本数据类型之外，默认的 json 对象为 object 类型。
* **flattened**：单映射对象类型，其值为 json 对象。
* **nested** ★：嵌套类型。
* **join**：父子级关系类型。

#### 结构化类型

* **Range**：范围类型，比如 long_range，double_range，data_range 等
* **ip**：ipv4 或 ipv6 地址
* **version**：版本号
* **murmur3**：计算和存储值的散列

#### 聚合数据类型

* **aggregate_metric_double**：
* **histogram**：

#### 文本搜索字段

* **text** ★：文本数据类型，用于全文检索。
* **annotated-text：**
* **completion** ★**：**自动补全
* **search_as_you_type：**
* **token_count：**

#### 文档排名类型

* dense_vector：记录浮点值的密集向量。
* rank_feature：记录数字特征以提高查询时的命中率。
* rank_features：记录数字特征以提高查询时的命中率。

#### 空间数据类型 ★

* **geo_point**：纬度和经度点。
* **geo_shape**：复杂的形状，例如多边形。
* **point**：任意笛卡尔点。
* **shape**：任意笛卡尔几何。

#### 其他类型

* **percolator**：用 Query DSL 编写的索引查询。

## 映射参数

|**参数名称**|**释义**|
| ----------------------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|**analyzer** ★|**指定分析器，只有 text 类型字段支持。**|
|coerce|是否允许强制类型转换，支持对字段段度 设置或者对整个索引设置。<br />true： “1” => 1<br />false： “1” =< 1<br />索引级设置<br />![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230417202425-9djxgwi.png)<br />字段级设置<br />![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230417202210-g2ujfjs.png)<br />|
|||
|copy_to|该参数允许将多个字段的值复制到组字段中，然后可以将其作为单个字段进行查询<br /><br />|
|**doc_values** ★|为了提升排序和聚合效率，默认 true，如果确定不需要对字段进行排序或聚合，也不需要通过脚本访问字段值，则可以禁用 doc 值以节省磁盘空间（不支持 text 和 annotated_text）在 `开源社区 ES 8.x:进阶篇 - 深入聚合原理` ​章节中会深入讲解|
|dynamic ★|控制是否可以动态添加新字段<br />支持以下四个选项：<br />**true**：（默认）允许动态映射<br />**false**：忽略新字段。这些字段不会被索引或搜索，但仍会出现在_source 返回的命中字段中。这些字段不会添加到映射中，必须显式添加新字段。<br />**runtime**：新字段作为运行时字段添加到索引中，这些字段没有索引，是_source 在查询时加载的。<br />**strict**：如果检测到新字段，则会抛出异常并拒绝文档。必须将新字段显式添加到映射中。<br />|
|eager_global_ordinals|(ES8)用于聚合的字段上，优化聚合性能。例如：<br />![在这里插入图片描述](https://img-blog.csdnimg.cn/f1ba4244066048759a9293b461ec3fc0.jpeg#pic_center)<br />|
||<br />|
|enabled|是否创建倒排索引，可以对字段操作，也可以对索引操作，如果不创建索引，让然可以检索并在_source 元数据中展示，谨慎使用，该状态无法修改。<br />![在这里插入图片描述](https://img-blog.csdnimg.cn/dc4f2cf9631d41458fe5f2548597c4de.jpeg#pic_center)<br />如果是对某个字段指定,则字段类型必须为 object<br />![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230417203619-inkcebg.png)<br />|
|**fielddata** ★|**查询时内存数据结构，在首次用当前字段聚合、排序或者在脚本中使用时，需要字段为 fielddata 数据结构，并且创建倒排索引保存到堆中**|
|**fields** ★|**给 field 创建多字段，用于不同目的（全文检索或者聚合分析排序）**|
|**format** ★|用于格式化代码，日期类型,时间类型<br />![在这里插入图片描述](https://img-blog.csdnimg.cn/804ce8c65e0547248551068579b6d803.jpeg#pic_center)[在这里插入图片描述](https://img-blog.csdnimg.cn/804ce8c65e0547248551068579b6d803.jpeg#pic_center)<br />|
|**ignore_above** ★|超过长度将被忽略,不存储<br />![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420012033-325-image-20230417210521-og0grvr.png) <br />|
|ignore_malformed|忽略类型错误|
|index_options|控制将哪些信息添加到反向索引中以进行搜索和突出显示。仅用于 text 字段|
|index_phrases|提升 exact_value 查询速度，但是要消耗更多磁盘空间|
|index_prefixes|前缀搜索：min_chars：前缀最小长度，>0，默认 2（包含）max_chars：前缀最大长度，<20，默认 5（包含）|
|**index** ★|是否对创建对当前字段创建倒排索引，默认 true，如果不创建索引，该字段不会通过索引被搜索到,<br />但是仍然会在 source 元数据中展示 true 新检测到的字段将添加到映射中。（默认）false 新检测到的字段将被忽略。这些字段将不会被索引，因此将无法搜索，但仍会出现在_source 返回的匹配项中。这些字段不会添加到映射中，必须显式添加新字段。strict 如果检测到新字段，则会引发异常并拒绝文档。必须将新字段显式添加到映射中<br />|
|**meta**|附加到元字段,可以用于处理相同索引的多个应用区分时使用,ES 查询数据时不可见|
|normalizer|文档归一化器(分词器的一部分)|
|**norms** ★|**是否禁用评分（在 filter 和聚合字段上应该禁用）。不用做排序就可以禁用**|
|**null_value** ★|**为 null 值设置默认值**|
|position_increment_gap|用于数组中相邻搜索中的搜索间隙，slop 默认 100 `见：代码块 1`​|
|properties ★|除了 mapping 还可用于 object 的属性设置|
|**search_analyzer** ★|**设置单独的查询时分析器**|
|**similarity**|为字段设置相关度算法，支持：<br />BM25<br />boolean<br />注意：**classic（TF-IDF）在 ES 8.x 中已不再支持！**<br />|
|subobjects|ES 8 新增，subobjects 设置为 false 的字段的值，其子字段的值不被扩展为对象。|
|store|**开辟一块独立的字段存储区**|
|**term_vector**|运维参数，在运维篇会详细讲解。|

## Text 类型

* 主要用于长文本的全文检索,不常用于排序,聚合等场景
* 基本声明

  ```json
  "message_full" : {
              "match" : "message_full",
              "mapping" : {
                "fields" : {
                  "keyword" : {
                    "ignore_above" : 2048,
                    "type" : "keyword"
                  }
                },
                "type" : "text"
              }
            }
  ```
* Text 类型的字段默认会被分词(`term`​)
* ES 默认情况下会为 Text 类型创建倒排索引

## keyword 类型

`keyword` ​使用序号映射存储它们的文档值以获得更紧凑的表示

> 注意 `ignore_above` ​属性代表**忽略**而不是**截断**
>
> 例如:
>
> ```json
> "keyword" : {
> 	"type" : "keyword",
> 	"ignore_above" : 10
> }
> ```
>
> 当你插入的数据超过 `ignore_above` ​时,数据会被保存下来,但是无法通过 `query` ​查询.

1. `keyword` ​类型不会被分词: 精准查询
2. 查询参数

   ```json
   GET keyword_text/_search
   {
     "query": {
       "term": {
         "keyword": {
           "value": "1234"
         }
       }
     }
   ```

   * `term` ​精准查询和聚合字段: ID、电子邮件地址、主机名、状态代码、邮政编码或标签,包括范围查询
   * `match` ​全文检索
3. `keyword` ​类型超过阈值长度会直接被丢弃

## Date 类型

由于 Es 存在自动映射机制,所以在对于 Date 类型时十分容易踩坑

### 案例

假如我们有如下索引 tax ，保存了一些公司的纳税或资产信息，单位为“万元”。当然这里面的数据是随意填写的。多少为数据统计的时间.

我们看到 date 字段其中包含了多种日期的格式：“yyyy-MM-dd”，“yyyy-MM-dd”还有时间戳。如果按照 dynamic mapping，采取自动映射器来映射索引。我们自然而然的都会感觉字段应该是一个 date 类型。

```json
POST tax/_bulk
{"index":{}}
{"date": "2021-01-25 10:01:12", "company": "中国烟草", "ratal": 5700000}
{"index":{}}
{"date": "2021-01-25 10:01:13", "company": "华为", "ratal": 4034113.182}
{"index":{}}
{"date": "2021-01-26 10:02:11", "company": "苹果", "ratal": 7784.7252}
{"index":{}}
{"date": "2021-01-26 10:02:15", "company": "小米", "ratal": 185000}
{"index":{}}
{"date": "2021-01-26 10:01:23", "company": "阿里", "ratal": 1072526}
{"index":{}}
{"date": "2021-01-27 10:01:54", "company": "腾讯", "ratal": 6500}
{"index":{}}
{"date": "2021-01-28 10:01:32", "company": "蚂蚁金服", "ratal": 5000}
{"index":{}}
{"date": "2021-01-29 10:01:21", "company": "字节跳动", "ratal": 10000}
{"index":{}}
{"date": "2021-01-30 10:02:07", "company": "中国石油", "ratal": 18302097}
{"index":{}}
{"date": "1648100904", "company": "中国石化", "ratal": 32654722}
{"index":{}}
{"date": "2021-11-1 12:20:00", "company": "国家电网", "ratal": 82950000}
```

但是可以查看 `mapping` ​发现其类型并非 `Date`​

```json
"properties" : {
        "company" : {
          "type" : "keyword"
        },
        "date" : {
          "type" : "keyword"
        },
        "ratal" : {
          "type" : "long"
	}
}
```

### 原理

原因就在于对时间类型的格式的要求是绝对严格的。要求必须是一个标准的 UTC 时间类型。上述字段的数据格式如果想要使用，就必须使用 `yyyy-MM-ddTHH:mm:ssZ` ​或 `yyyy-MM-dd` ​格式（其中 T 个间隔符，Z 代表 0 时区），以下均为错误的时间格式（均无法被自动映射器识别为日期时间类型）：

* yyyy-MM-dd HH:mm:ss
* 时间戳

注意：需要注意的是时间说是必须的时间格式，但是需要通过手工映射方式在索引创建之前指定为日期类型，使用自动映射器无法映射为日期类型。

```json
// 插入数据
POST tax2/_bulk
{"index":{}}
{"date":"2021-01-25T10:01:12Z","company":"中国烟草","ratal":5700000}

// 查看mapping
"properties" : {
        "company" : {
          "type" : "keyword"
        },
        "date" : {
          "type" : "date"
        },
        "ratal" : {
          "type" : "long"
        }
}
```

### 手动指定映射类型

```json
// 手动建立映射类型
PUT tax
{
  "mappings": {
    "properties": {
      "date":{
        "type":"date"
      }
    }
  }
}
// 插入数据
POST tax/_bulk
{"index":{}}
{"date":"2021-01-30 10:02:07","company":"中国石油","ratal":18302097} // 插入失败
{"index":{}}
{"date":"1648100904","company":"中国石化","ratal":32654722} // 插入成功 -- 指定Date类型后可以被识别
{"index":{}}
{"date":"2021-11-1T12:20:00Z","company":"国家电网","ratal":82950000} // 格式失败 11-01
{"index":{}}
{"date":"2021-01-30T10:02:07Z","company":"中国石油","ratal":18302097} // 写入成功 -- 标准格式
{"index":{}}
{"date":"2021-01-25","company":"中国烟草","ratal":5700000} // 写入成功 -- 日期类型
```

### 解决方法

在字段属性中添加一个参数`"format":"yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"`​可以避免因为数据给是不统一导致无法写入

```json
PUT tax
{
  "mappings": {
    "properties": {
      "date": {
        "type": "date",
        "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
      }
    }
  }
}
```

> 还有需要注意的是不同时区下的问题

## Nested 嵌套类型

‍

>  [ES中 Nested 类型的原理和使用 - Elastic开源社区](https://www.elastic.org.cn/archives/nested)

### 基本认知

1. 概念

    **官方定义: ​**这个nested类型是object一种数据类型，允许对象数组以相互独立的方式进行索引

    Es中用于复杂类型对象数组的索引操作,Es中没有内部对象的概念,因此Es在存储复杂类型的时候会把对象的复杂层次结果扁平化为为一个k-v键值对列表
2. 适用场景

    字段值为复杂类型

### 不使用Nested复杂数据结构时的问题

1. 插入数据,其中`goods_list`​的类型是数组的第一个元素的类型,即`object`​复杂数据类型

    ```json
    PUT /order/_doc/1
    {
      "order_name": "xiaomi order",
      "desc": "shouji zhong de zhandouji",
      "goods_count": 3,
      "total_price": 12699,
      "goods_list": [
        {
          "name": "xiaomi PRO MAX 5G",
          "price": 4999
        },
        {
          "name": "ganghuamo",
          "price": 19
        },
        {
          "name": "shoujike",
          "price": 1999
        }
      ]
    }
    
    PUT /order/_doc/2
    {
      "order_name": "Cleaning robot order",
      "desc": "shouji zhong de zhandouji",
      "goods_count": 2,
      "total_price": 12699,
      "goods_list": [
        {
          "name": "xiaomi cleaning robot order",
          "price": 1999
        },
        {
          "name": "dishwasher",
          "price": 4999
        }
      ]
    }
    ```
2. 查看`mapping`

    ```json
    "properties" : {
            "desc" : {
              "type" : "keyword"
            },
            "goods_count" : {
              "type" : "long"
            },
            "goods_list" : {
              "properties" : {
                "name" : {
                  "type" : "keyword"
                },
                "price" : {
                  "type" : "long"
                }
              }
            },
            "order_name" : {
              "type" : "keyword"
            },
            "total_price" : {
              "type" : "long"
            }
    }
    ```
3. 尝试搜索不存在结果的条件: 同时满足`name`​和`price`​的数据并不存在

    ```json
    GET order/_search
    {
      "query": {
        "bool": {
          "must": [
            {
              "match": {
                "goods_list.name": "dishwasher"
              }
            },
            {
              "match": {
                "goods_list.price": 1999
              }
            }
          ]
        }
      }
    }
    ```

    **结果: 查询出了数据**

    ```json
    {
      "took" : 8,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : {
          "value" : 1,
          "relation" : "eq"
        },
        "max_score" : 1.9186288,
        "hits" : [
          {
            "_index" : "order",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : 1.9186288,
            "_source" : {
              "order_name" : "Cleaning robot order",
              "desc" : "shouji zhong de zhandouji",
              "goods_count" : 2,
              "total_price" : 12699,
              "goods_list" : [
                {
                  "name" : "xiaomi cleaning robot order",
                  "price" : 1999
                },
                {
                  "name" : "dishwasher",
                  "price" : 4999
                }
              ]
            }
          }
        ]
      }
    }
    ```
4. 原因分析

    当字段值为复杂数据类型时,Es内部实际是将对象字段的属性值采用扁平化的形式存储在数组中,相互之间失去了对应关系

    ```json
    {
      "order_name": "Cleaning robot order",
      "desc": "shouji zhong de zhandouji",
      "goods_count": 2,
      "total_price": 12699,
      "goods_list.name":[ "alice", "cleaning", "robot", "order", "dishwasher" ],
      "goods_list.price":[ 1999, 4999 ]
    }
    ```

### 使用Nested类型

上述问题解决办法即对复杂类型使用Nested类型(嵌套类型不仅为`Nested`​一种)

1. 手动指定Mapping中Nested类型

    ```json
    PUT order
    {
      "mappings": {
        "properties": {
          "goods_list": {
            "type": "nested",
            "properties": {
              "name": {
                "type": "text"
              },
              "price": {
                "type": "long"
              }
            }
          }
        }
      }
    }
    ```
2. 写入数据
3. 查询数据: 相比于之间多了一层嵌套 -> 结果正确.

    ```json
    GET order/_search
    {
      "query": {
        "nested": {
          "path": "goods_list",
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "goods_list.name": "dishwasher"
                  }
                },
                {
                  "match": {
                    "goods_list.price": 1999
                  }
                }
              ]
            }
          }
        }
      }
    }
    ```

## 自动映射模板 Dynamic Templates