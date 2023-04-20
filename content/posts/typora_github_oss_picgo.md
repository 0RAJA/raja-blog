---
title: "picgo-core + typora + github或oss 图床" # 标题
subtitle: "picgo-core + typora + github或oss 图床" # 副标题
description: "" # 文章内容描述
date: 2023-04-20T10:03:54+08:00 # 时间
lastmod: 2023-04-20T10:03:54+08:00 # 上次修改时间
tags: ["oss","typora","图床","github"] # 标签
categories: ["typora"] # 分类
featuredImagePreview: "https://raw.githubusercontent.com/0RAJA/img/main/20230420100652-981-image-20230420100651902.png" # 封面链接
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人
---
<!--more-->

# picgo-core + typora + github或oss 图床

>  [【Typora】typora+picgo+阿里云oss搭建图床 - sakuraxx - 博客园 (cnblogs.com)](https://www.cnblogs.com/myworld7/p/13132549.html#_label3)
>
>  [Typora + PicGo-Core + Github 实现图片上传到Github - jxiaow - 博客园 (cnblogs.com)](https://www.cnblogs.com/xiaowj/p/13934555.html)

# 安装`picgo-core`

默认拥有`npm`,没有先用`brew`安装,没有`brew`在[镜像快速安装Homebrew教程](https://brew.idayer.com/)安装

```shell
npm install picgo -g
```

# 安装插件

```shell
picgo install github-plus rename-file # github上传插件,文件改名插件
```

# 创建oss仓库或者github仓库

此过程略去可以参考上面的文章

# 配置文件

一般路径在`~/.picgo/config.json`这里,但是windows下如果用typora安装则应该是在typora安装路径下进行查找

```json
{
  "picBed": {
    "uploader": "github", // 选择上传的服务
    "aliyun": {
      "accessKeyId": "", // id
      "accessKeySecret": "", // secret
      "bucket": "raja-img", // bucket
      "area": "oss-cn-hangzhou", // area
      "path": "img/", // 目录
      "customUrl": "https://xxx.oss-cn-hangzhou.aliyuncs.com", // 自定义域名,需要在oss配置
      "options": ""
    },
    "github": {
      "repo": "0RAJA/img", // repo 名，格式為 username/<repo name>
      "token": "", // github token
      "path": "", // 自定義存儲路徑，比如 img/
      "customUrl": "", // 自定義域名，注意要加 http://或者 https://
      "branch": "main" // 分支名，默認是 main
    }
  },
  "picgoPlugins": {
    "picgo-plugin-rename-file": true,
    "picgo-plugin-github-plus": true
  },
  "picgo-plugin-rename-file": {
    "format": "{y}{m}{d}{h}{i}{s}-{ms}-{origin}" // 重命名
  }
}
```

# 测试

1. 终端测试

    `picgo upload xxx.img`
2. typora 测试

    ![image](https://raw.githubusercontent.com/0RAJA/img/main/20230420100411-520-20230420100236-918-image-20230420003654-2d8s524.png)

    需要注意的地方是

    1. 这里需要填写picgo的路径,不然可能找不到命令
    2. 如果出现`env node ......`将`node`的位置写前面,参考[typora 配置picgo-core出现env: node: No such file or directory的解决方法 - vpslala.com](https://www.vpslala.com/t/774)
