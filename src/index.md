---
layout: default
---

<div class="py-4 bg-grenadier-50">
  <div class="container max-w-screen-lg">
    <h2 class="text-4xl py-4 font-medium">
      Articles
    </h2>

    <ul class="divide-y divide-zinc-400">
      {% for post in collections.posts.resources %}
      <li class="py-3">
        <a class="text-lg leading-tight hover:underline" href="{{ post.relative_url }}">{{ post.data.title }}</a>
        <p class="pt-2 text-sm">
        <time class="text-grenadier-800" datetime="{{post.data.date}}">{{post.data.date | date: "%B %e, %Y" }}</time>
        </p>
      </li>
      {% endfor %}
    </ul>

   </div>
</div>
