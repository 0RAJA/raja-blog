---
title: "Python工具开源" # 标题
subtitle: "Python工具开源" # 副标题
description: "" # 文章内容描述
date: 2023-08-25T17:31:27+08:00 # 时间
lastmod: 2023-08-25T17:31:27+08:00 # 上次修改时间
tags: ["python","开源"] # 标签
categories: ["开源"] # 分类
featuredImagePreview: "" # 封面链接
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人
---
<!--more-->

# Python工具开源

# 项目

[OVINC-CN/ClientThrottler: A proactive rate-limiting tool utilizing Redis](https://github.com/OVINC-CN/ClientThrottler)

# 步骤

项目结构

```shell
.
├── .github                # 自动化流程
├── LICENSE                # 开源协议
├── MANIFEST.in            # 说明在源发行版中包含哪些文件
├── Makefile               # 相关构建指令
├── README.md              # 项目介绍文档
├── SECURITY.md            # 安全信息和指导文档
├── client_throttler       # 源码
├── pyproject.toml         # 项目描述信息
├── requirements.txt       # 依赖包
├── requirements_dev.txt   # 开发依赖包
├── setup.py               # 传统打包配置
├── tests                  # 测试代码
```

1. 确定开源协议 [Licenses – Open Source Initiative](https://opensource.org/licenses/)

   我这里选择 [The MIT License](https://opensource.org/license/mit/)，将其放置于所有代码文件头，以及项目根路径下

2. 打包发布

   > [Python - 包( 模块)分发](https://www.cnblogs.com/Neeo/articles/10272780.html)
   >
   > [构建与发布 - Python 项目工程化开发指南](https://pyloong.github.io/pythonic-project-guidelines/guidelines/project_management/distribution/)
   >

   1. **pyproject.toml**

      ```toml
      [build-system]
      requires = ["setuptools", "wheel"]
      build-backend = "setuptools.build_meta"
      ```

      这是一个关于 Python 项目构建系统的配置信息，它定义了构建所需的工具和后端。

      * `[build-system]`​：这是一个配置文件的节，表示这部分内容与构建系统相关。
      * `requires`​：这是一个列表，包含了构建该项目所需的工具。在这个例子中，它需要两个工具：`setuptools`​ 和 `wheel`​。

        * `setuptools`​：一个用于构建和分发 Python 项目的工具。它提供了很多实用功能，如包管理、依赖管理等。
        * `wheel`​：一个用于构建 Python 分发包的工具。它生成的是 `.whl` ​文件，这是一种二进制分发格式，可以更快地安装和分发 Python 包。
      * `build-backend`​：这指定了构建过程中使用的后端。在这个例子中，使用的是 `setuptools.build_meta`​。这意味着在构建过程中，将使用 `setuptools` ​提供的构建元数据（build metadata）来生成项目的构建信息。
   2. **setup.py**

      ```python
      from setuptools import find_packages, setup
      
      with open("README.md") as f:
          readme = f.read()
      
      with open("requirements.txt") as f:
          requires = f.readlines()
      
      setup(
          name="client_throttler",    # 项目的名称
          version="1.1.0",            # 项目的版本号
          author="Raja",              # 项目的作者
          url="https://github.com/OVINC-CN/ClientThrottler",     # 项目的GitHub仓库地址
          author_email="contact@ovinc.cn",                       # 作者的联系邮箱
          description="A client throttle tool based on redis.",  # 项目的简短描述
          long_description=readme,    # 项目的详细描述（在这里使用 README.md 文件的内容）
          long_description_content_type="text/markdown",    # ​long_description​的内容类型（在这里是Markdown文本）
          packages=find_packages(include=["client_throttler"]), # 项目中要包含的包（使用`find_packages()`函数指定client_throttler包）
          classifiers=[    # 项目的分类信息，用于帮助其他人了解项目的类型、支持的Python版本等
              "Programming Language :: Python :: 3.6",
              "Programming Language :: Python :: 3.7",
              "Programming Language :: Python :: 3.8",
              "Programming Language :: Python :: 3.9",
              "Programming Language :: Python :: 3.10",
              "Operating System :: OS Independent",
              "License :: OSI Approved :: MIT License",
          ],
          python_requires=">=3.6, <4", # 项目支持的Python版本范围
          install_requires=requires, # 项目的依赖列表（从requirements.txt​文件中获取）
          license="MIT",    # 项目的许可证（在这里是MIT许可证）
      )
      ```

   3. 安装依赖

      `pip install setuptool twine build`​
   4. 生成源码包和 wsl 文件

      `python -m build`​
   5. 检查打包是否正确

      `twine check dist/*`​
   6. 发布到 [pypi](https://pypi.org/) 上(需要注册账号)

      `twine upload dist/*`​
   7. 清理打包时生成的文件

      `rm -r client_throttler.egg-info dist`​
3. Github Actions

   1. 在 `main` ​分支 `pull` ​和 `pr` ​时触发测试

      ```yml
      name: unittest  # 定义 GitHub Actions 工作流程的名称
   
      on:  # 触发工作流程的事件
        push:  # 当推送到 main 分支时触发
          branches: [ main ]
        pull_request:  # 当向 main 分支发起拉取请求时触发
          branches: [ main ]
   
      jobs:  # 工作流程中的任务
        unittest:  # 任务名称
          runs-on: ubuntu-20.04  # 运行任务的操作系统
          strategy:  # 任务执行策略
            fail-fast: false  # 如果一个版本的测试失败，不会立即停止其他版本的测试
            matrix:  # 构建矩阵，用于测试多个版本
              python-version: [ "3.10" ]  # 测试的 Python 版本
          steps:  # 任务的步骤
            - uses: actions/checkout@v3  # 使用 GitHub Action 从仓库检出代码
            - name: Setup redis  # 设置 Redis
              uses: supercharge/redis-github-action@1.6.0  # 使用 Redis GitHub Action
              with:
                redis-version: 6  # 指定 Redis 版本
            - name: Set up Python ${{ matrix.python-version }}  # 设置 Python 环境
              uses: actions/setup-python@v3  # 使用 setup-python GitHub Action
              with:
                python-version: ${{ matrix.python-version }}  # 指定 Python 版本
            - name: Install dependencies  # 安装依赖
              run: make dev  # 执行 make dev 命令
            - name: Test  # 运行测试
              run: pytest --cov=client_throttler  # 使用 pytest 运行测试并生成覆盖率报告
            - name: Upload coverage to Codecov  # 上传覆盖率报告到 Codecov
              uses: codecov/codecov-action@v3  # 使用 codecov GitHub Action
      ```

   2. 发布时自动打包并分发至 `pypi`​

      ```yml
      name: Release Python Package  # 定义 GitHub Actions 工作流程的名称
   
      on:  # 触发工作流程的事件
        release:  # 当发布新版本时触发
          types: [published]  # 发布类型：已发布
   
      permissions:  # GitHub Actions 权限设置
        contents: read  # 允许读取仓库内容
   
      jobs:  # 工作流程中的任务
        deploy:  # 任务名称
          runs-on: ubuntu-latest  # 运行任务的操作系统
          steps:  # 任务的步骤
          - uses: actions/checkout@v3  # 使用 GitHub Action 从仓库检出代码
          - name: Set up Python  # 设置 Python 环境
            uses: actions/setup-python@v3  # 使用 setup-python GitHub Action
            with:
              python-version: '3.10'  # 指定 Python 版本
          - name: Install dependencies  # 安装依赖
            run: |
              python -m pip install --upgrade pip  # 升级 pip
              pip install build  # 安装 build 工具
          - name: Build package  # 构建 Python 包
            run: python -m build  # 使用 build 工具构建包
          - name: Publish package  # 发布 Python 包
            uses: pypa/gh-action-pypi-publish@27b31702a0e7fc50959f5ad993c78deac1bdfc29  # 使用 PyPA 提供的 GitHub Action 发布包到 PyPI
            with:
              user: __token__  # 使用 PyPI API token 作为用户名
              password: ${{ secrets.PYPI_API_TOKEN }}  # 使用 GitHub 仓库中存储的 PyPI API token 作为密码
      ```

   3. 代码分析

      ```yml
      name: "CodeQL"  # 定义 GitHub Actions 工作流程的名称
   
      on:  # 触发工作流程的事件
        push:  # 当推送到任意分支时触发
          branches: [ "*" ]
        pull_request:  # 当向任意分支发起拉取请求时触发
          branches: [ "*" ]
   
      jobs:  # 工作流程中的任务
        analyze:  # 任务名称
          name: Analyze  # 任务显示名称
          runs-on: ubuntu-latest  # 运行任务的操作系统
          timeout-minutes: 360  # 任务超时时间（分钟）
          permissions:  # GitHub Actions 权限设置
            actions: read
            contents: read
            security-events: write
   
          strategy:  # 任务执行策略
            fail-fast: false  # 如果一个版本的分析失败，不会立即停止其他版本的分析
            matrix:  # 构建矩阵，用于分析多个版本
              language: [ "python" ]  # 分析的编程语言
   
          steps:  # 任务的步骤
          - name: Checkout repository  # 从仓库检出代码
            uses: actions/checkout@v3
          - name: Initialize CodeQL  # 初始化 CodeQL 分析
            uses: github/codeql-action/init@v2
            with:
              languages: ${{ matrix.language }}  # 指定分析的编程语言
          - name: Autobuild  # 自动构建代码
            uses: github/codeql-action/autobuild@v2
          - name: Perform CodeQL Analysis  # 执行 CodeQL 分析
            uses: github/codeql-action/analyze@v2
            with:
              category: "/language:${{matrix.language}}"  # 分析的编程语言类别
      ```

4. 比较推荐的 `Commit` ​规范

   ```shell
   feat: A new feature
   fix: A bug fix
   docs: Documentation only changes
   style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.)
   refactor: A code change that neither fixes a bug nor adds a feature
   perf: A code change that improves performance
   test: Adding missing or correcting existing tests
   chore: Changes to the build process or auxiliary tools and libraries such as documentation generation
   ```

5. 使用 GPG 对提交签名验证

   > [关于提交签名验证](https://docs.github.com/zh/authentication/managing-commit-signature-verification/about-commit-signature-verification)
   >

# 参考

　　[Why you shouldn&apos;t invoke setup.py directly](https://blog.ganssle.io/articles/2021/10/setup-py-deprecated.html)

　　[python - How to make PyPi description Markdown work? - Stack Overflow](https://stackoverflow.com/questions/26737222/how-to-make-pypi-description-markdown-work/26737672#26737672)

　　[Packaging Python Projects — Python Packaging User Guide](https://packaging.python.org/en/latest/tutorials/packaging-projects/#description)

　　[redis-py/setup.py at master · redis/redis-py](https://github.com/redis/redis-py/blob/master/setup.py)

　　[Python - 包( 模块)分发](https://www.cnblogs.com/Neeo/articles/10272780.html)

　　[构建与发布 - Python 项目工程化开发指南](https://pyloong.github.io/pythonic-project-guidelines/guidelines/project_management/distribution/#2111)

　　[python-redis-rate-limit/setup.py](https://github.com/EvoluxBR/python-redis-rate-limit/blob/master/setup.py)

　　[bk-audit-python-sdk/setup.py](https://github.com/TencentBlueKing/bk-audit-python-sdk/blob/master/setup.py)

　　[An Overview of Packaging for Python](https://packaging.python.org/en/latest/overview/)

　　[MIT License | Choose a License](https://choosealicense.com/licenses/mit/)
