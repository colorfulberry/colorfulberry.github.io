---
layout: post
title: Active model serializers for rails json
categories: [rails]
tags: [rails]
comments: true
description: 'rails gems for json'
---

### 运用背景
随着rails－api的引入，为了更好的支持api的编写，自带的as_json又很不放方便

### 原理
`active_model_serializers`通过继承`ActiveModel::Serializer`，根据每个model来生自定义不同的json数据方式，方便返回给用户

以下面结构关系为例
 ![relations](https://dab1nmslvvntp.cloudfront.net/wp-content/uploads/2015/10/1444739329models-large.png)
### 用法
* scaffold

  `$ rails g serializer --help`

* 单表

  ~~~
  class UserSerializer < ActiveModel::Serializer
    attribute :id, :name
  end
  ~~~
  controller use
  ~~~
  ...
    render json: @user
    or
    render json: @users
  ...
  ~~~

* 同model定义不同json以及自定方法

  ~~~
  class UserAuthSerializer < ActiveModel::Serializer
    attribute :id, :name, :auth_token

    def auth_token
      ...
    end
  end
  ~~~

  controller use
  ~~~
  ...
    render json: @user, serializer: UserAuthSerializer
  ...
  ~~~

* 多表关联
  ~~~
  class UserVideoSerializer < ActiveModel::Serializer
    attribute :id, :name
    has_many :videos, serializer: VideoSerializer #default is       ModelNameSerializer
  end

  class VideoSerializer < ActiveModel::Serializer
    attribute :id, :name
  end
  ~~~
  controller use
  ~~~
  ...
    render json :@user,  serializer: UserVideoSerializer
  ...
  ~~~

* 分页

  ~~~
  class PaginatedSerializer < ActiveModel::Serializer::ArraySerializer
    def initialize(object, options={})
      meta_key = options[:meta_key] || :meta
      options[meta_key] ||= {}
      options[meta_key] = {
        current_page: object.current_page,
        next_page: object.next_page,
        prev_page: object.prev_page,
        total_pages: object.total_pages,
        total_count: object.total_count
      }
      super(object, options)
    end
  end
  ~~~

  ~~~
  class CommentSerializer < ActiveModel::Serializer
    attribute :id, :content
    has_one :user
  end
  ~~~

  controller use
  ~~~
  ...
    @comments = @comments.page(params[:page]).per(params[:per_page] || 10)
    render json: @comments, serializer: PaginatedSerializer, each_serlizer: CommentSerializer
  ...
  ~~~

* 嵌入式数据

  ~~~
  class VideoSerializer < VideoSerializer
    embed :ids, include: true
    has_one :user
  end
  ~~~
  ~~~
  ...
    render json: @videos
  ...

  it will return the user_id at the video same level
  ~~~
