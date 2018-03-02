---
layout: post
title: rails production server ubuntu 设置
categories: [rails, ubuntu]
tags: [rails, ubuntu]
comments: true
description: ''
---


### 部署可用服务

system is ubuntu 14.00

`sudo su - root`

#### 初始化服务
  * 添加公钥

  `vim ~/.ssh/authorized_keys`

  * 更新升级安装基本服务

  ~~~
  apt-get update
  apt-get upgrade
  apt-get install make gcc openssl libssl-dev git tig monit unzip
  ~~~

  * 修改时区(重起系统生效) 和 自动同步时间

  ~~~
  cp /usr/share/zoneinfo/Australia/Sydney /etc/localtime
  apt-get install ntp
  ~~~


  * 设置dns

  ~~~
    vi /etc/resolv.conf
    nameserver 8.8.8.8
  ~~~



  * 安装rails 环境

    * rvm

    ~~~
    curl -L https://get.rvm.io | bash -s stable
    ~~~
    退出登录后重新ssh进来

  * 安装 ruby 和 安装 bundle

    ~~~
    rvm requirements
    rvm install 2.3.2
    rvm --default use 2.3.2
    echo gem: --no-ri --no-rdoc > ~/.gemrc  #后面创建的deploy用户需要也做相同设置
    gem i bundler --pre

    rvm gemset create project_production
    ~~~

### 发布用户配置

  * 创建用户 deploy

  ~~~
  vim /etc/ssh/sshd_config
  PasswordAuthentication no

  adduser deploy
  usermod -aG www-data,rvm deploy
  ~~~

  * 配置ssh

  ~~~
  sudo su - deploy

  mkdir ~/.ssh
  touch /home/deploy/.ssh/authorized_keys
  vim /home/deploy/.ssh/authorized_keys
  chmod 700 /home/deploy/.ssh
  chmod 600 /home/deploy/.ssh/authorized_keys
  ~~~
  测试是否可以 ssh 到 deploy 用户


  * 创建rails app目录

  ~~~
  mkdir -p /var/apps/project_production/shared/log
  chown -R deploy:deploy /var/apps/project_production

  ssh deploy@xxxx
  echo gem: --no-ri --no-rdoc > ~/.gemrc
  exit
  ~~~

  * create the deploy link file.

  `database.yml,.env,version.conf ..... `

#### 安装配置nginx

  * 安装

  ~~~
  apt-get install nginx
  ~~~

  * 创建临时rails app目录

  ~~~
  mkdir -p /var/apps/project_production/shared/log
  ~~~

  * 配置nginx配置

  ~~~
  vim /etc/nginx/sites-available/project_production

  upstream puma-project-name-staging {
    server unix:/var/apps/project_name_staging/shared/tmp/sockets/puma.sock fail_timeout=0;
  }

  server {
    listen  80;
    server_name  btbrecruit.jp;
    error_log   /var/apps/project_name_staging/shared/log/nginx_error.log;
    access_log  /var/apps/project_name_staging/shared/log/nginx_access.log;
    root /var/apps/project_name_staging/current/public;
    client_max_body_size 20M;

    location / {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_redirect off;
      proxy_pass http://puma-project-name-staging;

      proxy_connect_timeout       600;
      proxy_send_timeout          600;
      proxy_read_timeout          600;
      send_timeout                600;

      #auth_basic "nginx basic auth";
      #auth_basic_user_file /var/apps/basic_auth_file;

      #auth_digest_user_file /var/apps/digest_auth_file;
      #auth_digest "nginx digest auth";
    }

   location ~* ^/(assets|static|uploads)/(.+)$ {
      expires 24h;
    }

    location ~* ^/(favicon.ico|robots.txt|apple-touch-icon.png|logo.png)$ {
      expires 24h;
    }

  }

  ln -s /etc/nginx/sites-available/project_production /etc/nginx/sites-enabled/project_production
  rm /etc/nginx/sites-enabled/default
  /etc/init.d/nginx restart
  ~~~

  * 配置ssl

    参考 https://ruby-china.org/topics/31983

  * postgres安装

  ~~~
  apt-get install  libpq-dev postgresql postgresql-contrib
  sudo -u postgres psql
  create role deploy;
  alter role deploy login;
  alter role deploy CreateDb;
  \du
  ~~~

#### monit
  所有的配置都放/etc/monit/cong-available 中，使用的是/etc/monit/cong-enabled中
  * postgreslq 监控

  ~~~
    vim  /etc/monit/conf-available/pg
    check process postgres with pidfile /var/postgres/postmaster.pid
      group database
      start program = "/etc/init.d/postgresql start"
      stop  program = "/etc/init.d/postgresql stop"
      if failed unixsocket /var/run/postgresql/.s.PGSQL.5432 protocol pgsql
         then restart
      if failed host 192.168.1.1 port 5432 protocol pgsql then restart
  ~~~

  * nginx 监控

  ~~~
  vim  /etc/monit/conf-available/nginx
  check process nginx with pidfile /var/run/nginx.pid
    group www
    group nginx
    start program = "/etc/init.d/nginx start"
    stop program = "/etc/init.d/nginx stop"
    if failed port 80 protocol http request "/" then restart
    if 5 restarts with 5 cycles then timeout
    depend nginx_bin
    depend nginx_rc

  check file nginx_bin with path /usr/sbin/nginx
    group nginx
    include /etc/monit/templates/rootbin

  check file nginx_rc with path /etc/init.d/nginx
    group nginx
    include /etc/monit/templates/rootbin
  ~~~

  * puma监控

  ~~~
  check process puma with pidfile /var/apps/project_production/tmp/pids/puma.pid
  start program = "/bin/su - root -c '/etc/init.d/puma start'" with timeout 50 seconds
  stop program = "/etc/init.d/puma stop"
  ~~~


#### logrotate

  ~~~
  vim /etc/logrotate.d/project_production
  /var/apps/project_production/shared/log/var/rails_apps/wcs_production/shared/log/*.log {
  daily
  missingok
  rotate 14
  compress
  delaycompress
  notifempty
  copytruncate
  }
  /etc/init.d/rsyslog restart
  ~~~
