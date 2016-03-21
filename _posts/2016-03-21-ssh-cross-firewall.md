---
layout: post
title: ssh cross firewall direct socks5
categories: [Linux]
tags: [Linux]
comments: true
description: 'Cross FireWall'
---

需求：通过ssh+socks5+monit+chrome 实现部分网址选择性的翻墙

[proxychains-ng](https://github.com/rofl0r/proxychains-ng) 安装配置

```
#安装
brew install proxychains-ng

#配置socks5
vim /usr/local/etc/proxychains.conf
socks5  127.0.0.1 1080
```

[monit](https://mmonit.com/monit/) 安装配置

```
#安装
brew install monit

#配置监控
check host ssh_socks5 with address 127.0.0.1
  start program "/usr/bin/ssh -qTfnN -D 127.0.0.1:1080 user@server"
  if failed port 1080 then start
```

chrome 安装配置[SwitchyOmega](https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif?hl=en)

```
#安装

#配置插件
根据guide 引导
注意 Protocol 是 SOCKS5
Server 127.0.0.1
Port 1080

部分防火墙规则链接
https://autoproxy-gfwlist.googlecode.com/svn/trunk/gfwlist.txt
```

使用: 遇到不能访问的网址时点击插件 右键走代理
备注: user@server 是墙外能访问的服务器帐号和地址，登录方式为密钥登陆

详细安装配置介绍[proxychains-ng](http://blog.zorro.im/posts/proxychians.html),[monit](http://www.stuartellis.eu/articles/monit/),SwitchyOmega安装后会有引导
