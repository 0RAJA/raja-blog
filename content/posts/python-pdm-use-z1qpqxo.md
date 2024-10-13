
# python pdm 使用

[简介 - PDM](https://pdm-project.org/zh-cn/latest/)

1. 初始化项目：`pdm init`​

   1. 选择当前项目下的 python 虚拟环境
   2. 不选择作为一个库 -- [库或应用程序 - PDM](https://pdm-project.org/zh-cn/latest/usage/project/#_3)
   3. 删除敏感信息：`authors`​
2. 【从 pip requirements 迁移至 pdm 执行】导入依赖包：`pdm import requirements.txt && pdm import --dev requirements_dev.txt`​
3. 安装生产依赖项、开发依赖项：`pdm install -G:all`​
4. 修改依赖项：`pdm add xxx`​,`pdm remove xxx`​,`pdm update`​ -- [管理依赖项 - PDM](https://pdm-project.org/zh-cn/latest/usage/dependency/#_7)
5. 导出依赖项：`pdm export --pyproject --no-hashes --prod -o requirements.txt && pdm export --pyproject --no-hashes -G dev --no-default -o requirements_dev.txt`​

> 我应该添加到 `pdm.lock`​ 版本控制吗？
>
> 这要视情况而定。如果目标是使 CI 使用与本地开发相同的依赖项版本并避免意外失败，则应将该 `pdm.lock`​ 文件添加到版本控制中。否则，如果你的项目是一个库，并且你希望 CI 模拟用户站点上的安装，以确保 PyPI 上的当前版本不会破坏任何内容，则不要提交该 `pdm.lock`​ 文件。

‍
