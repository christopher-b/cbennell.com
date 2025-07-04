# cbennell.com

This is the static content generator for [cbennell.com](https://cbennell.com), my personal website and blog.

This site is powered by [Bridgetown](https://www.bridgetownrb.com/) and [Tailwind CSS](https://tailwindcss.com/), deployed with [Kamal](https://kamal-deploy.org/).

It's mostly a vanilla Bridgetown site, but one point of interest is the custom [code block formatter](https://github.com/christopher-b/cbennell.com/blob/main/plugins/builders/code.rb).

## To Do

 - [X] Deploy on push
 - [X] Convert templates / components to ERB or Phelx
 - [ ] Add commenting: https://cactus.chat/docs/getting-started/quick-start/

## Commands

```sh
# running locally
bin/bridgetown start

# build & deploy to production
bin/kamal deploy

# load the site up within a Ruby console (IRB)
bin/bridgetown console
```

## License

This site is released under the [MIT License](https://github.com/christopher-b/cbennell.com/blob/main/LICENSE.txt)
