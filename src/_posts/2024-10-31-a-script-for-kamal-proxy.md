---
layout: post
title:  A Script for Kamal Proxy
date:   2024-10-31
tags:
  - kamal
  - shell
---

Here's a simple shell for interacting with [kamal-proxy](https://github.com/basecamp/kamal-proxy) on your host. It wraps a call to docker-exec, passing the arguments you provide to the kamal-proxy executable in your kamal-proxy container.

{% code shell caption="kp.sh" %}
#!/bin/bash

#Run the docker exec command with the provided arguments
docker exec kamal-proxy kamal-proxy "$@"
{% endcode %}

You can now do:

{% code shell %}
chmod u+x kp.sh

./kp.sh list
Service                   Host                  Target             State    TLS
cbennell_com-web-main     cbennell.com          6db082a60a7f:8043  running  no
cbennell_com-web-staging  staging.cbennell.com  478d9119f70a:8043  running  no

./kp.sh stop cbennell_com-web-staging --message "Offline for maintenance"
./kp.sh resume cbennell_com-web-staging"
{% endcode %}

When the service is stopped, we get kamal's nice error page:

<figure class="mx-auto max-w-xl">
  <img src="/images/content/kamal-maintenance.webp" alt="Screenshot of kamal error screen showing custom error message">
</figure>
