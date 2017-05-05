---
layout: post
title: elixir／Phoenix 简单聊天室2-显示用户名和在线人数
categories: [聊天室]
tags: [elixir, phoenix, jquery, pg, chatroom]
comments: true
description: 'exlir 在线聊天室，示用户名和在线人数'
---

### 显示用户名

* 设置用户的token
~~~
#router.ex
....
plug Coherence.Authentication.Session, protected: true  
plug :put_user_token #加入
....
#加入
defp put_user_token(conn, _) do
  current_user = Coherence.current_user(conn).id
  user_id_token = Phoenix.Token.sign(conn, "user_id",   
                  Coherence.current_user(conn).id)
  conn
  |> assign(:user_id, user_id_token)
end
~~~


* 把userToken 放到 window中
~~~
#web/templates/layout/app.html.eex
....
<script>window.userToken = "<%= assigns[:user_id] %>"</script>
<script src="<%= static_path(@conn, "/js/app.js") %>"></script>
~~~

* 在sockes中捕获userToken并获取用户名
~~~
# web/channels/user_socket.ex
......
  def connect(%{"token" => user_id_token}, socket) do
    case Phoenix.Token.verify(socket,
                              "user_id",
                              user_id_token,
                              max_age: 1000000) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _reason} ->
        :error
    end
  end
......
~~~

* 从channel连接中接受token，验证后存入socket
~~~
# web/channels/room_channel.ex
defmodule Chatroom.RoomChannel do
  use Phoenix.Channel
  alias Chatroom.Repo
  alias Chatroom.User
  ....
  def handle_in("message:new", payload, socket) do
   user = Repo.get(User, socket.assigns.user_id)
   broadcast! socket, "message:new", %{user: user.name,
                                       message: payload["message"]}
   {:noreply, socket}
 end
end
~~~

#### 显示在线人数

* 初始化[Phoenix.Presence](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
~~~
mix phoenix.gen.presence

#lib/Chatroom.ex:
children = [
...
supervisor(Chatroom.Presence, []),
]
~~~

* 在chatroom channel中使用presence
~~~
# web/channels/room_channel.ex
...
alias Chatroom.Presence
...
def join("room", _payload, socket) do
  send(self, :after_join)
  {:ok, socket}
end

def handle_info(:after_join, socket) do
  user = Repo.get(User, socket.assigns.user_id)
  {:ok, _} = Presence.track(socket, user.name, %{
    online_at: inspect(System.system_time(:seconds))
   })
  push socket, "presence_state", Presence.list(socket)
  {:noreply, socket}
end
.....
~~~

* 从服务端获取在线用户数量

~~~
#socket.js
import {Socket, Presence} from "phoenix"
....

// 加入
let presences = {}
let onlineUsers = document.getElementById("online-users")

//加入
let listUsers = (user) => {
  return {
    user: user
  }
}
//加入
let renderUsers = (presences) => {
  onlineUsers.innerHTML = Presence.list(presences, listUsers)
  .map(presence => `
    <li>${presence.user}</li>`).join("")
}
....
//加入
channel.on('presence_state', state => {
  presences = Presence.syncState(presences, state)
  renderUsers(presences)
});
//加入
channel.on('presence_diff', diff => {
  presences = Presence.syncDiff(presences, diff)
  renderUsers(presences)
});
~~~
