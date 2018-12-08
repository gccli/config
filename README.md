# 定制化Linux开发环境

在CentOS Linux系统自动化部署和配置定制化的开发环境，基本配置包括：

* Bash shell
   - 定义一些方便的别名和函数
   - 登录终端时，自运行一些脚本
   - 环境变量
* 编辑器(emacs)
* git
* ssh & ssh-agent
   - 配置RSA key, 用于ssh认证
* 配置一些开发工具 (python, gdb, ...)

## 安装配置

    curl -L git.io/cloudinit|bash

## 配置emacs

    curl -L https://git.io/emacsinit|bash -x

Generate shortutl by git.io

    curl -i https://git.io -F 'url=http://domain/path' -F 'code=shorturl'
