Bridgetown.configure do |config|
  # You can also modify options on the configuration object directly, like so:
  # config.autoload_paths << "models"

  # Add new inflection rules using the following format. Inflections
  # are locale specific, and you may define rules for as many different
  # locales as you wish. All of these examples are active by default:
  # ActiveSupport::Inflector.inflections(:en) do |inflect|
  #   inflect.plural /^(ox)$/i, "\\1en"
  #   inflect.singular /^(ox)en/i, "\\1"
  #   inflect.irregular "person", "people"
  #   inflect.uncountable %w( fish sheep )
  # end
  #
  # These inflection rules are supported but not enabled by default:
  # ActiveSupport::Inflector.inflections(:en) do |inflect|
  #   inflect.acronym "RESTful"
  # end

  # You can use `init` to initialize various Bridgetown features or plugin gems.
  # For example, you can use the Dotenv gem to load environment variables from
  # `.env`. Just `bundle add dotenv` and then uncomment this:
  #
  # init :dotenv
  #

  # Uncomment to use Bridgetown SSR (aka dynamic rendering of content via Roda):
  #
  # init :ssr
  #

  # Uncomment to use file-based dynamic template routing via Roda (make sure you
  # uncomment the gem dependency in your `Gemfile` as well):
  #
  # init :"bridgetown-routes"
  #

  # We also recommend that if you're using Roda routes you include this plugin
  # so you can get a generated routes list in `.routes.json`. You can then run
  # `bin/bridgetown roda:routes` to print the routes. (This will require you to
  # comment your route blocks. See example in `server/routes/hello.rb.sample`.)
  #
  # only :server do
  #   init :parse_routes
  # end
  #

  # For more documentation on how to configure your site using this initializers file,
  # visit: https://edge.bridgetownrb.com/docs/configuration/initializers/

  url "https://cbennell.com"
  permalink "pretty"
  template_engine "liquid" # for posts
  timezone "America/Toronto"

  config.pagination = {enabled: true}

  config.collections = {
    posts: {
      permalink: "/posts/:slug/"
    },
    redirects: {output: true}
  }

  init :"bridgetown-sitemap"
  init :"bridgetown-seo-tag"
  init :"bridgetown-svg-inliner"
end
