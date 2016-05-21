---
layout: post
title: shadowsocks server and client build
categories: [cross fire wall]
tags: [cross fire wall]
comments: true
description: ''
---


### server setting
* build a ubuntu server at AWS
* open the port 8388 in AWS console
* install shadowsocks

  ~~~
  $ apt-get install python-gevent python-pip python-m2crypto monit
  $ pip install shadowsocks
  ~~~
* setting shadowsocks
  vim  `/etc/shadowsocks/config.json` with follow content

  ~~~
  {
    "server":"127.0.0.1",
    "server_port":8388,
    "local_port":1080,
    "password":"yourpassword!",
    "timeout":600,
    "method":"aes-256-cfb"
  }
  ~~~

* setting monitor
  vim `/etc/monit/conf.d/shadowsocks` with follow content

  ~~~
  check host ssh_socks5 with address 127.0.0.1
    start program "/usr/bin/ssserver -c /etc/shadowsocks/config.json"
    if failed port 8388 then start
  ~~~

### client setting
* [download client](https://shadowsocks.org/en/download/clients.html)
* setting the address with `your server ip`
* setting the password `yourpassword`
* encryption `aes-256-cfb`

Now is ok, if you will setting the chrome you can user [SwitchyOmega](https://chrome.google.com/webstore/detail/krotor-access-internet-vi/dfdhngcahhplaibahkkjhdklhihbaikl?hl=en)
