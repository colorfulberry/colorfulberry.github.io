---
layout: post
title: error handle
categories: [error]
tags: [centos ubuntu ]
comments: true
description: ''
---


# /bin/tar: Argument list too long
```
find . -maxdepth 1 -name '*.txt' -print >/tmp/ficheiros
tar -cvzf textfiles.tar.gz --files-from /tmp/ficheiros
find . -maxdepth 1 -name '*.txt' | xargs rm -v
```

# puma deploy can not restart some version
`remove the restart hack at puma.rb at the server`