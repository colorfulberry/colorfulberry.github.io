---
layout: post
title: 002 rails common gems(rails 常见插件)
categories: [rails, gems]
tags: [rails, gems]
comments: true
description: ''
---

## rails version is 4.2.5.1

### [enumerize](https://github.com/brainspec/enumerize)
支持国际化的enum，提供了scope......(enum through hash, let we can use scope, i18n for enum without redefine)

### [paranoia](https://github.com/rubysherpas/paranoia)
用deleted_at字段soft destroy(through add deleted_at column and cover the destroy method achieve soft destroy)

### [active_model_serializers](https://github.com/rails-api/active_model_serializers)
方便自定义model中的字段组合成json数据（api中的利器）(helpful during the api return json with customize column from model)

### [exception_notification](https://github.com/rails/exception_notification)
当系统出现错误的时候发送邮件(send email to you when occur web system error)


### [prawn](https://github.com/prawnpdf/prawn), [prwan-table](https://github.com/prawnpdf/prawn-table)
通过prawn`语法代码`生成pdf，精确度高(generate pdf through code, very accurate)

### [pdfkit](https://github.com/devongovett/pdfkit)
通过已有的html页面生成pdf,精确度不是很高(generate pdf through exist html page but not accurate )

### [sidekiq](https://github.com/mperham/sidekiq)
多线程的后台任务处理器(multithreading background processing)

### [redis](https://github.com/antirez/redis)
内存数据库(Memory Database)

### [simple_form](https://github.com/plataformatec/simple_form)
简化rails form 表单的代码量(Rails forms made easy.)

### [pundit](https://github.com/elabs/pundit)
一个简单可扩展的强大的权限插件(a simple, robust and scaleable authorization gem)

### [rails-api](https://github.com/rails-api/rails-api)
快速简单的提供api，（Rails5已经集成）不需要加载所有的rails组件(has integrated at Rails5, quick walk-through to help you get up and running with Rails::API to create API-only Apps,)

### [ransack](https://github.com/activerecord-hackery/ransack)
一个的搜索插件(a simple and flexible gem for search with conditions)

### [kaminari](https://github.com/amatsuda/kaminari)
一个的分页插件(a simple and flexible gem for pagination)

### [carrierwave](https://github.com/carrierwaveuploader/carrierwave)
一个上传插件(a simple and flexible gem for upload things)

### [factory_girl_rails](https://github.com/thoughtbot/factory_girl_rails), [ffaker](https://github.com/ffaker/ffaker)
造假数据(provide function for faker data)

### [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner)
数据库清除插件(is a set of strategies for cleaning your database)

### [rspec-rails](https://github.com/rspec/rspec-rails), [rspec](https://github.com/rspec/rspec), [webmock](https://github.com/bblimke/webmock)
测试用插件(gem for spec)

### [capistrano](https://github.com/capistrano/capistrano), capistrano-rails, capistrano3-puma, capistrano-rvm, capistrano-sidekiq
发布脚本(gem for cap)
