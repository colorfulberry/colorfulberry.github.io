---
layout: post
title: schedule design
categories: [error]
tags: [centos ubuntu ]
comments: true
description: ''
---


# /bin/tar: Argument list too long
```
find . -name '*.txt' -print >/tmp/ficheiros
tar -cvzf textfiles.tar.gz --files-from /tmp/ficheiros
find . -name '*.txt' | xargs rm -v
```

# puma deploy can not restart some version
`remove the restart hack at puma.rb at the server`