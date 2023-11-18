---
title: Mac从Intel迁移到Apple芯片
date: '2023-11-17 22:46:23'
lastmod: '2023-11-18 17:08:11'
toc: true
tags:
  - mac
  - 迁移
  - Intel
categories:
  - 总结
keywords: mac,迁移,Intel
description: Mac从Intel迁移到Apple芯片后的软件变更
isCJKLanguage: true
slug: move-from-intel-to-apple-chip-1q4are
---

# Mac从Intel迁移到Apple芯片

1. 使用 MAC 的 `迁移助理`​​ ​将旧电脑的数据导入新电脑
2. <span style="font-weight: bold;" data-type="strong">重新安装</span>各种软件的 Apple 版本(不需要卸载再重装)
3. 替换​ `brew`​​​​

   > [Homebrew 在 M1 上的迁移工作 | 蹲墙角的猫 (lstec.org)](https://blog.lstec.org/2022/08/18/Homebrew-%E5%9C%A8-M1-%E4%B8%8A%E7%9A%84%E8%BF%81%E7%A7%BB%E5%B7%A5%E4%BD%9C/)
   >
   > [快速安装 Homebrew 教程 - Homebrew 中文网 (idayer.com)](https://brew.idayer.com/)
   >

   记得最后要把新的 `brew`​​ ​加入到环境变量中

   1. 部分未通过苹果授权的软件无法打开，例如 `Marktext`​​​

      官方解答：`xattr -cr /Applications/MarkText.app`​​​

      > [Cannot install MarkText 0.17.0rc2-arm64 on M1 MacBook Air · Issue #2983 · marktext/marktext (github.com)](https://github.com/marktext/marktext/issues/2983)
      >

      更推荐的教程：

      > [最新 ｜ 解决 Mac 安装软件的“已损坏，无法打开。 您应该将它移到废纸篓”问题 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/135948430)
      >

      但是似乎 `xattr`​​ ​还是 x64 的版本，需要更换。`arch -arm64 python3.11 -m pip install xattr --no-cache`​​​

      > [python - (mach-o file, but is an incompatible architecture (have &apos;x86_64&apos;, need &apos;arm64e&apos;)) - Stack Overflow](https://stackoverflow.com/questions/72308682/mach-o-file-but-is-an-incompatible-architecture-have-x86-64-need-arm64e)
      >

      最后使用 `sudo xattr -d com.apple.quarantine /Applications/MarkText.app`​​​ 成功

      ps: 类似的软件都可以这样解决。
4. 安装 `python3.6.*`​

   > [在 Mac M1 上安装 python 3.6.* - Stack Overflow](https://stackoverflow.com/questions/71862398/install-python-3-6-on-mac-m1)
   >

   ```shell
   brew install pyenv
   pyenv install 3.6.15
   ```

   通过 `pyenv virtualenvs` ​查看当前所拥有的环境并且将其添加到环境变量中

   后续在项目中创建虚拟环境就只需要 `python3.6 -m venv ./venv` ​即可

‍
