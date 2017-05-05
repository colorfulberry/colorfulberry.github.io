---
layout: post
title: elixir／Phoenix 简单聊天室1-实现聊天
categories: [聊天室]
tags: [elixir, phoenix, jquery, pg, chatroom]
comments: true
description: 'exlir 在线聊天室'
---

### elixir简单聊天室

默认用Elixir 1.4.0, pg

#### 初始化项目
  * 新建项目并初始化数据库
  ~~~
  mix phoenix.new  chatroom #创建项目
  mix ecto.create #创建数据库
  ~~~

#### [Coherence](https://github.com/smpallen99/coherence) 进行用户管理
这个是phoenix的用户管理系统，和rails中的devise功能类似

 * 引入coherence
 ~~~
 #mix.exs
  ......
  def application do
   [mod: {Chatourius, []},
   applications: [:phoenix, :phoenix_pubsub,
   ...
   :phoenix_ecto, :postgrex, :coherence]] #加入
   end
  ......
  defp deps do
   [{:phoenix, "~> 1.2.1"},
   ...
   {:cowboy, "~> 1.0"},
   {:coherence, "~> 0.3"}] #加入
   end
 ~~~

* 初始化coherence, 会给我们创建一些views和model
~~~
mix deps.get
mix coherence.install --full-invitable
mix ecto.setup
~~~

* 重写路由
~~~
#router.ex
defmodule Chatroom.Router do
  use Chatroom.Web, :router
  use Coherence.Router #加入

  pipeline :browser do
    ...
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session #加入
  end

  #加入
  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end
  ...

  #加入
  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  #加入
  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", Chatroom do
    pipe_through :browser # Use the default browser stack
  end

  scope "/", Chatroom do
    pipe_through :protected  #加入
    get "/", PageController, :index
  end
end
~~~

#### 聊天室
用web sockets 来创建聊天室

* 添加聊天室页面
~~~
#web/templates/page/index.html.eex
<div class="chat container">
  <div class="col-md-9">
    <div class="panel panel-default chat-room">
      <div class="panel-heading">
        Hello <%= Coherence.current_user(@conn).name %>
        <%= link "Sign out", to: session_path(@conn, :delete),
                                 method: :delete %>
      </div>
      <div id="chat-messages" class="panel-body panel-messages">    
      </div>
      <input type="text" id="message-input" class="form-control"
                         placeholder="Type a message…">
    </div>
  </div>
  <div class="col-md-3">
    <div class="panel panel-default chat-room">
      <div class="panel-heading">
        Online Users
      </div>
      <div class="panel-body panel-users" id="online-users">
      </div>
    </div>
  </div>
</div>
~~~

* 添加聊天室样式
~~~
#phoenix.css
....
@media (min-width: 768px) {
  .container {
    max-width: 730px;
  }
}
.....

#app.css
.chat {
 margin-top: 0em;
}
.chat-room {
 margin-top: 1em;
}
.panel-messages, .panel-users {
 height: 400px;
}
#chat-messages {
 min-height: 400px;
 overflow-y: scroll;
}
~~~

* 连接到我们的聊天室

引入jquery

~~~
#web/templates/layout/app.html.eex
...
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>
<script src="<%= static_path(@conn, "/js/app.js") %>"></script>
...
~~~

将会创建一个聊天室然后让用户加入

~~~
web/channels/room_channel.ex
defmodule Chatroom.RoomChannel do
  use Phoenix.Channel
  def join("room", _payload, socket) do
    {:ok, socket}
  end
end

# web/channels/user_socket.ex
...
channel "room", Chatroom.RoomChannel
...
# web/static/js/app.js
import "phoenix_html"
import socket from "./socket"
~~~

我们通过捕获页面的enter事件，当用户输入回车后就会出发事件。
通过channel监听是不是有新信息发送过来，如果收到新的消息执行appened

~~~
# web/static/js/socket.js
let channel = socket.channel("room", {}) #编辑成room
# added
let message = $('#message-input')
let nickName = "Nickname"
let chatMessages = document.getElementById("chat-messages")
message.focus();
message.on('keypress', event => {
  if(event.keyCode == 13) {
    channel.push('message:new', {message: message.val(),
                                 user: nickName})
    message.val("")
  }
});
channel.on('message:new', payload => {
  let template = document.createElement("div");
  template.innerHTML = `<b>${payload.user}</b>:
                           ${payload.message}<br>`
chatMessages.appendChild(template);
  chatMessages.scrollTop = chatMessages.scrollHeight;
})
~~~

server 短执行处理发送新消息
~~~
# web/channels/room_channel.ex
def handle_in("message:new", payload, socket) do
  broadcast! socket, "message:new", %{user: payload["user"],  
                                      message: payload["message"]}
  {:noreply, socket}
end
~~~
