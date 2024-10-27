---
title: Bridgetown, TailwindCSS and Kamal
date: Sunday, 27 Oct 2024 09:00:13 -0400
tags:
  - bridgetown
  - dev
  - kamal
  - tailwind
coverImage: bridge.webp
---

As part of my migration to Bridgetown, I needed a process to deploy my content. [Kamal](https://kamal-deploy.org/), the hot new Ruby deploy tool, was the obvious choice. But I ran into a tricky bug related to the TailwindCSS integration. I'm documenting that bug here for anyone who runs into the same problem.

Bridgetown has an official [TailwindCSS automation](https://github.com/bridgetownrb/tailwindcss-automation)  that adds Tailwind support to your project, although it's not updated or supported by the Bridgetown folks. The installation process creates a file, `frontend/styles/jit-refresh.css`, along with a hook to update it during the frameworks `:pre_reload` event. This file required in the main CSS file, and changes to it will trigger the Tailwind JIT compiler.
## The Problem

The issue is that `jit-refresh.css` is also `.gitignore`'ed. If you're working from a fresh checkout of the project, such as during a [Kamal](https://kamal-deploy.org/) deploy, the file won't exist. Did you know that when you deploy with Kamal, it clones your repo into `/var/folders/something`, so any uncommitted changes aren't present in the build?

The automation does add a line in Bridgetown's Rakefile to ensure the file is created. However, we don't always trigger our frontend build using Rake tasks. For example the [suggested Dockerfile](https://www.bridgetownrb.com/docs/deployment#docker) compiles frontend assets by calling esbuild directly, not through the Rake task. In this case, the `jit-refresh.css` file is not created.

If we run esbuild without that file, we might not even notice anything is wrong unless we're reading the output logs. The process still completes successful, and exits without throwing an error. We do, however, see an error in the logs:

{% code sh highlight=[5,6] caption="`esbuild` output" %}
> node esbuild.config.js --minify

esbuild: frontend bundling started...

error: "undefined" while processing CSS file:
undefined:undefined:undefined

esbuild: frontend bundling complete!
esbuild: entrypoints processed:
         - index.P6KJZRZR.js: 113B
         - index.DYSKJ26J.css: 3.9KB
{% endcode %}

As a result, the CSS doesn’t compile, and the output bundle lacks Tailwind styling.

## Solutions

One workaround is to touch the file before building. In the Kamal/Docker setup, this can be done in the Dockerfile:

{% code Dockerfile caption="Dockerfile" %}
...
RUN touch frontend/styles/jit-refresh.css
RUN npm run esbuild
...
{% endcode %}

Although it's simple, I don't love this solution. It's fixing the problem in the wrong place. We shouldn't be patching over weird quirks of the build process in our packaging layer. A better solution would be in the esbuild process, closer to the intricacies of why the `jit-refresh.css` file exists in the first place. Putting fix in the esbuild process also ensure that it's in place regardless of how we actually trigger esbuild–whether it's directly, via a rake task, or some other method.

Here's how we might do it. Create an esbuild plugin that will touch the file (actually, make a general purpose file-touching plugin, and pass the file name in):

{% code js caption="plugins/touch_file.js" %}
// We're using CommonJs requires to match Bridgetown defaults
const fs = require("fs");

const createTouchFilePlugin = (filePaths) => ({
  name: "touch-file",
  setup(build) {
    build.onStart(() => {
      if (!Array.isArray(filePaths) || filePaths.length === 0) {
        console.warn("No file paths provided to touch.");
        return;
      }

      const time = new Date();

      filePaths.forEach((filePath) => {
        try {
          fs.utimesSync(filePath, time, time);
        } catch (err) {
          fs.closeSync(fs.openSync(filePath, "w"));
        }
        console.log(`Touched file at ${filePath}`);
      });
    });
  }
});

module.exports = createTouchFilePlugin;
{% endcode %}

*All that just to touch a file...*

We then include that plugin in the esbuild config:

{% code js caption="esbuild.config.js" %}
const touchFilePlugin = require("./plugins/touch_file.js");

const esbuildOptions = {
  plugins: [
    touchFilePlugin(["frontend/styles/jit-refresh.css"])
  ],
  ...
}
{% endcode %}

This solution allows esbuild to run without errors, and all CSS renders correctly in the final output.
