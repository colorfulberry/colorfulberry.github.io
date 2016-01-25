---
layout: post
title: 001省市级连查询
categories: [rails, jquery]
tags: [rails, jquery]
comments: true
description: 级连查询jquery.
---

cascade select from new app
===========================

~~~
建表Provinces, Cities, Users
原理：利用js去监听然后利用ajax去请求然后填充数据
拿到provience.id 然后去查city
利用ajax去请求
~~~

### prepare

* rails new select
* gem "therubyracer" gem "less-rails" gem "twitter-bootstrap-rails"
* bundle install
* rails g model province name
* rails g model city province:belongs_to name
* rails g scaffold user name province:belongs_to city:belongs_to location:string

* write

`rake db:migrate` # 更新 db 解构

`rails generate bootstrap:install` # 安装 bootstrap 文件

`rails g bootstrap:layout` # 创建一个 layout

`rails g bootstrap:themed users` # 创建资源模板

### start cascade

`rails g controller cities index`

####cities_controller.rb

~~~
  def index
    @proviences = Provience.find(params[:provience_id])
    @cities = @proviences.cities
    render json: @cities
  end
~~~

####index.json.jbuilder

~~~
json.array!(@cities) do |city|
  json.id city[1]
  json.name city[0]
end
~~~

####users/_form.html.erb

~~~
 <div class="form-group">
    <%= f.label :provience %><br>
    <%= f.collection_select :provience_id, provience.all, :id, :name, {prompt: "請選擇" }, { class: "form-control provience_select" } %>
  </div>
  <div class="form-group">
    <%= f.label :city %><br>
    <%= f.select :city_id, City.get_select_options_by_provience(f.object.provience_id), {}, { class: "form-control city_code_select" } %>
  </div>
~~~

####city_cascade.js

~~~
$(document).ready(function(){
  // input provience code return city information 
  $(".provience_select").on('change', function(event){
    $(".city_code_select").html('')
    var provience_id = $(event.target).val();
    $.ajax({
      type: "get",
      dataType: "json",
      url: "/cities",
      data: { provience_id: provience_id },
      success: function(data) {
        $.each(data,function(i){
          city = data[i]
          $(".city_code_select").append($("<option value='" + city.id + "'>" + city.name + "</option>"))
        });
      }
			error: function() {
			}
    });
  }) 
})
~~~
