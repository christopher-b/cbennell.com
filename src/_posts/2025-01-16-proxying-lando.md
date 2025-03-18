---
layout: post
published: false
title:  Hosting Lando With a Reverse Proxy
date:   2025-01-16
tags:
  - lando
image: images/cover/spatter.webp
---

I'm a big fan of [Lando](https://lando.dev/), the dev tool for building replicatable development environments. I got started with Lando while working on a [Pantheon](https://pantheon.io/)-hosted project, but I've been using it for various projects, including Rails applications via the custom "[lando](https://docs.lando.dev/services/lando-3.html)" service type.

My workplace recently implemented the concept of Privileged Access Workstations (PAWs), which is essentially a remote server that I need to SSH into over VPN; all my work happens on the VPN. I wanted to continue to use Lando on my PAW, but this introduced some complications. Lando is designed to work local-only, so we need to jump through some hoops to get it to work over the network. There are a few ways this can be accomplished, each with pros and cons.

# Just Lando

By default, Lando wants to bind to localhost, so it's not available over the network.

# Lando + Nginx
