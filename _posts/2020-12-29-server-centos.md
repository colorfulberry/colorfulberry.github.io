---
layout: post
title: centos server config
categories: [server]
tags: [centos]
comments: true
description: ''
---

# install postgres 13
### step 1
```
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```
### step 2
```
sudo yum search postgresql13
```

### step 3
```
sudo yum -y install postgresql13 postgresql13-server
```

### step 4 initial db
```
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
```

### step 5 create user
```
create user deploy with encrypted password 'StrongDBPassword';
alter role deploy login;
alter role deploy CreateDb;
```


### step 6 Enabling remote Database connections

sudo vi /var/lib/pgsql/13/data/postgresql.conf
```
listen_addresses = '*'
```

sudo vi /var/lib/pgsql/13/data/pg_hba.conf

```
#Accept from anywhere (not recommended)
host all deploy 0.0.0.0/0 md5

# Accept from trusted subnet (Recommended setting)
host all deploy 172.20.11.0/24 md5
```
sudo systemctl restart postgresql-13


# config firewall
### start/stop firewall
```
sudo systemctl start firewalld
sudo systemctl enable firewalld

sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

### add rule to filewall
```
sudo firewall-cmd --state
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=http
sudo firewall-cmd --reload
```

### selinux
```
semanage port -a -t http_port_t -p tcp 80
setsebool -P httpd_can_network_connect 1
sudo cat /var/log/audit/audit.log | grep nginx | grep denied | audit2allow -M mynginx
sudo semodule -i mynginx.pp
```