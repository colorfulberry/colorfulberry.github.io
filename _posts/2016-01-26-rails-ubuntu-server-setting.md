---
layout: post
title: rails production server ubuntu 设置
categories: [rails, ubuntu]
tags: [rails, ubuntu]
comments: true
description: ''
---


### cap

* system is ubuntu 14.00
  ~~~
  sudo su - root
  ~~~

* apt-get

  更新 apt-get 和 安装基础包

  ~~~
  apt-get update
  apt-get upgrade
  apt-get install make gcc openssl libssl-dev git tig monit unzip
  apt-get install libxslt-dev libxml2-dev libgmp-dev
  ~~~

* 修改时区(重起系统生效) 和 自动同步时间 和 设置dns

  ~~~
  cp /usr/share/zoneinfo/Australia/Sydney /etc/localtime
  apt-get install ntp

  vi /etc/resolv.conf

  nameserver 8.8.8.8
  ~~~

* RVM安装

  ~~~
  curl -L https://get.rvm.io | bash -s stable
  ~~~

  退出登录后重新ssh进来

  安装 ruby 和 安装 bundle

  ~~~
  rvm requirements
  rvm install 2.0.0-p247
  rvm --default use 2.0.0-p247
  echo gem: --no-ri --no-rdoc > ~/.gemrc  #后面创建的deploy用户需要也做相同设置
  gem i bundler --pre

  rvm gemset create project_production
  ~~~

* nginx安装

  ~~~
  apt-get install nginx
  ~~~

  创建临时rails app目录

  ~~~
  mkdir -p /var/apps/project_production/shared/log
  ~~~
  配置nginx

  ~~~
  vi /etc/nginx/nginx.conf

  worker_processes 1

  vi /etc/nginx/sites-available/project_production

  upstream project-priducton-unicorn {
    server unix:/tmp/unicorn_project_production.sock fail_timeout=0;
  }

  server {
    listen      80;
    access_log  /var/apps/project_production/shared/log/nginx_access.log;

    client_max_body_size 20M;

    location / {
      root /var/apps/project_production/current/public;
      if (-f $request_filename) { break; }
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_redirect off;
      proxy_pass http://project-priducton-unicorn;

      proxy_connect_timeout       600;
      proxy_send_timeout          600;
      proxy_read_timeout          600;
      send_timeout                600;
    }

    location ~* ^/(assets|uploads|favicon.ico|robots.txt|apple-touch-icon.png) {
      root /var/apps/project_production/current/public;
      expires 24h;
    }
  }

  ln -s /etc/nginx/sites-available/project_production /etc/nginx/sites-enabled/project_production
  rm /etc/nginx/sites-enabled/default
  /etc/init.d/nginx restart
  ~~~

* postgres安装

  ~~~
  apt-get install ibpq-dev postgresql-client postgresql postgresql-contrib
  sudo -u postgres
  psql postgres
  createuser -P -s -e project_production
  sudo -u project_production
  createdb project_production
  ~~~

* 发布用户配置
创建组 dev 和 用户 deploy

  ~~~
  groupadd dev
  useradd -m -g dev -s /bin/bash deploy
  passwd deploy #密码：hello4dsafetypa123456 这个地方复杂点，我们不会用这个用户登录
  usermod -aG dev,www-data,rvm deploy
  mkdir /home/deploy/.ssh
  touch /home/deploy/.ssh/authorized_keys
  vi /home/deploy/.ssh/authorized_keys
  chown -R deploy:dev /home/deploy/.ssh/
  chmod 700 /home/deploy/.ssh/
  chmod 600 /home/deploy/.ssh/authorized_keys
  创建rails app目录

  mkdir -p /var/apps/project_production
  chown -R deploy:dev /var/apps/project_production
  rm -rf /var/apps/project_production/current
  测试是否可以 ssh 到 deploy 用户

  ssh deploy@xxxx
  echo gem: --no-ri --no-rdoc > ~/.gemrc
  echo export EDITOR="vim" >> ~/.bashrc
  exit
  ~~~


* deploy服务器

  ~~~
  sudo su - deploy
  mkdir -p /var/apps/project_production/shared/config

  vi /var/apps/project_production/shared/.versions.conf
  ruby=ruby-2.2.3
  ruby-gemset=4dsafety

  vi /var/apps/project_production/shared/config/database.yml
  default: &default
    adapter: postgresql
    encoding: unicode
    pool: 5

  development:
    <<: *default
    database: project_development

  test:
    <<: *default
    database: project_test

  staging:
    <<: *default
    database: project_staging
    username: project_staging
    password: <%= ENV['PROJECT_DATABASE_PASSWORD_STG'] %>

  production:
    <<: *default
    database: project_production
    username: project
    password: <%= ENV['PROJECT_DATABASE_PASSWORD_PROD'] %>

  vi /var/apps/project_production/shared/.evn
  PROJECT_DATABASE_PASSWORD_STG=PROJECT_DATABASE_PASSWORD_STG
  PROJECT_DATABASE_PASSWORD_PROD=PROJECT_DATABASE_PASSWORD_PROD
  STG_SECRET_KEY_BASE=STG_SECRET_KEY_BASE
  PROD_SECRET_KEY_BASE=PROD_SECRET_KEY_BASE
  ~~~

* logrotate

  ~~~
  vim /etc/logrotate.d/4d_safety_web
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
