As part of my recent migration from WordPress to Bridgetown, I investigated three CSS frameworks to build my frontend. I spent some time with each, building out parts of my design. As I investigated, I noticed an interesting pattern emerge: these frameworks can be assessed based on their reliance on utility classes vs CSS rules. The three frameworks I assessed formed a nice range on this continuum.

## Open Props
On one end of the spectrum, [Open Props](https://open-props.style/) relies entirely on CSS custom properties, for use in your CSS files. There are no class name hooks provided, so you're using the framework entirely within your CSS files. You do, of course, need to add class names to your HTML elements so you have some hooks on which to hang the custom. An example:

```
.card {
  border-radius: var(--radius-2);
  padding: var(--size-fluid-3);
  box-shadow: var(--shadow-2);
}

<div class="card">...</div>
```

OpenProps can be used with no-build by just using the CDN, or you can use something like PostCSS to only import the props you're actually using.

I appreciate how using a pre-build set of thoughtful [design tokens](https://www.contentful.com/blog/design-token-system/)makes for consistent design and can be a great starting point. OpenProps is just CSS, so you're not mooring yourself to a specific tool chain. The defaults are quite nice, and include some [pretty gradients](https://www.contentful.com/blog/design-token-system/) and [masks](https://open-props.style/#masks).

The downside to this approach is that you're responsible for naming all your components, and there's a lot of back-and-forth between your markup and your CSS. There are no pre-build components here, so if you're looking for a UI library, this is not it. I did not love the documentation, and I had a hard time figuring out how I was supposed to be using it: the concept is simple, but it's not really laid out anywhere in their documentation. I think they could use a better "Getting Started" section.
## Bulma
[Bulma](https://bulma.io/) is a more fully-feature library, including a range of components, like dropdown menu. It's like a alternate take on Bootstrap. I think Bulma would be a bit easier to learn than Bootstrap, but I'm not sure that Bulma offers a huge amount of value over Bootstrap, considering that Bootstrap offers more features and better accessibility (according to Bulma's [own comparison](https://bulma.io/alternative-to-bootstrap/)).

I think Bulma is a good project and could be a good fit for people building UIs, and prefer its approach over Bootstrap. The documentation is great, and I can see the appeal of this library.

Bulma is in the middle of the "utility-vs-css" spectrum: it offers helper/utility classes, but you're still going to be adding class names as CSS hooks. This is perhaps the worst of both worlds: it's unclear where a particular CSS property might be defined: as a helper class, or in you own CSS. You're going to be mixing framework classes and your custom class names in the same HTML element.

## TailwindCSS
Finally, we have [TailwindCSS](https://tailwindcss.com/) coming in at the "all-utility" end of the spectrum. Much has been written about this approach, so I won't rehash it.

Like many people, I was sceptical about the idea of polluting my HTML with big handfuls of utility classes. This project was a blank slate, and I had a dream clean, unadulterated markup. I didn't want multi-line lists of classes marring that. But here's the thing: you're going to be adding classnames into your project anyways; maybe even extra HTML elements to make your layouts work. Your markup is always going to need concessions to your CSS.

For a project like mine, where I build the layout once and my day-to-day interactions don't really touch the HTML (Markdown, baby!), this approach makes sense. I can shove a bunch of classes into my markup and never have to open a CSS file. There's no need to name components, and there's no ambiguity about where the properties are defined.

I think this approach would also be great for component-based projects, like something making heavy use of [Phlex](https://www.phlex.fun/) or [ViewComponent](https://viewcomponent.org/). The more often you need to interact with the HTML, the less appealing this.

## Wrap Up
TailwindCSS was the framework that made the most sense for this project. It clicked very quickly, and I was able to build my design with good velocity. But I'm not sure it's a good fit for every project.

I was happy to dip my toe into these waters. As a primarily back-end guy, it was a good chance to learn more about these tools which I had been hearing so much about.
