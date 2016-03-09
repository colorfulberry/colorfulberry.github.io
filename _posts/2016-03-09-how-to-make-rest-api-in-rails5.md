---
layout: post
title: how to make reset api in rails5
categories: [rails]
tags: [rails]
comments: true
description: ''
---

How to make rest api in Rails5
===============================

### initial project demo
~~~
$ rails new rails --version==5.0.0.beta3
$ rake db:migrate
$ rake db:create
$ rails g scaffold user name:string sex:integer address:string
~~~

### import 'active_model_serializers' to Gemfile
add gem 'active_model_serializers' to Gemfile.rb
~~~
$ bundle install
~~~

### add api
routes.rb
~~~
namespace :api, { format: :json } do
  namespace :v1 do
    resources :users
  end
end
~~~

~~~
$ rails g controller api/v1/users
$ rails g serializer user
~~~

application_controller.rb
~~~
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
end
~~~

users_controller.rb
~~~
class Api::V1::UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users
  end
end
~~~

user_serializer.rb
~~~
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :sex, :address
end
~~~

### look it
first https://127.0.0.1:3000/users create some users

then
https://127.0.0.1:3000/api/v1/users return json
