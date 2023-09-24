---
title: "Shell配置" # 标题
subtitle: "Shell配置" # 副标题
description: "" # 文章内容描述
date: 2023-09-24T12:55:09+08:00 # 时间
lastmod: 2023-09-24T12:55:09+08:00 # 上次修改时间
tags: ["shell","配置"] # 标签
categories: ["Shell"] # 分类
featuredImagePreview: "" # 封面链接
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人
---
<!--more-->

# Shell 配置

# Shell 框架

## 安装 zimfw

跟随 [README](https://github.com/zimfw/zimfw) 过一遍即可

## 插件加载

只需要在 `~/.zimrc` ​中编辑即可，例如：`zmodule xxx`​

插件仓库：[unixorn/awesome-zsh-plugins: A collection of ZSH frameworks, plugins, themes and tutorials](https://github.com/unixorn/awesome-zsh-plugins)

* `zimfw install` ​安装新插件
* `zimfw update`​ 更新插件
* `zimfw uninstall`​ 删除插件

## 主题

懒人推荐 [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k)

安装后通过 `p10k configure` ​配置即可

![](https://raw.githubusercontent.com/0RAJA/img/main/202309241306227.png)

## 配置

`~/.zimfw`​

```yml
# Start configuration added by Zim install {{{

#

# This is not sourced during shell startup, and it's only used to configure the

# zimfw plugin manager

#

#

# Modules

#

# Sets sane Zsh built-in environment options

zmodule environment

# Provides handy git aliases and functions

zmodule git

# Applies correct bindkeys for input events

zmodule input

# Sets a custom terminal title

zmodule termtitle

# Utility aliases and functions. Adds colour to ls, grep and less

zmodule utility

#

# Prompt

#

# Exposes to prompts how long the last command took to execute, used by asciiship

zmodule duration-info

# Exposes git repository status information to prompts, used by asciiship

zmodule git-info

# A heavily reduced, ASCII-only version of the Spaceship and Starship prompts

zmodule asciiship

#

# Completion

#

# Additional completion definitions for Zsh

zmodule zsh-users/zsh-completions --fpath src

# Enables and configures smart and extensive tab completion

# completion must be sourced after all modules that add completion definitions

zmodule completion

#

# Modules that must be initialized last

#

zmodule DarrinTisdale/zsh-aliases-exa # 添加多个 alias, 使用 exa 代替 ls，要求有安装 exa
zmodule romkatv/powerlevel10k --use degit # p10k themes
zmodule none9632/zsh-sudo # 双击ESC->sudo
zmodule ael-code/zsh-colored-man-pages # 对 man 的输出进行着色
zmodule wookayin/fzf-fasd # 集成 fzf 和 fasd --- tab 补全与 fzf 的模糊搜索
zmodule zsh-users/zaw
zmodule zsh-users/zsh-syntax-highlighting # 指令高亮

# Fish-like syntax highlighting for Zsh

# zsh-users/zsh-syntax-highlighting must be sourced after completion

zmodule zsh-users/zsh-syntax-highlighting

# Fish-like history search (up arrow) for Zsh

# zsh-users/zsh-history-substring-search must be sourced after zsh-users/zsh-syntax-highlighting

zmodule zsh-users/zsh-history-substring-search # 通过指令的一部分查询历史记录

# Fish-like autosuggestions for Zsh

zmodule zsh-users/zsh-autosuggestions

# }}} End configuration added by Zim install

```

## 参考

[使用 zimfw 作为 zsh 配置框架 :: HP goes FE (hikerpig.cn)](https://www.hikerpig.cn/2020-10-14-zsh-zimfw-setup/)

[zimfw/zimfw: Zim: Modular, customizable, and blazing fast Zsh framework (github.com)](https://github.com/zimfw/zimfw)

[07 - Zim - Zsh 配置框架與它的插件 - iT 邦幫忙::一起幫忙解決難題，拯救 IT 人的一天 (ithome.com.tw)](https://ithelp.ithome.com.tw/articles/10270581)

# Shell 工具

## 命令行翻译

[soimort/translate-shell: :speech_balloon: Command-line translatort](https://github.com/soimort/translate-shell)

推荐配置 `~/.zshrc`​

```yml
# trans
alias tzh="trans :zh -b"
alias ten="trans :en -show-languages=n -show-prompt-message=n -show-alternatives=n"
```

![](https://raw.githubusercontent.com/0RAJA/img/main/202309241305175.png)‍
