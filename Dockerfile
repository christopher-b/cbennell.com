# Build frontend JS and CSS assets using ESbuild
FROM node:alpine AS asset_builder
ENV BRIDGETOWN_ENV=production
WORKDIR /assets
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run esbuild

# Generate your site content as HTML
FROM ruby:alpine AS bridgetown_builder
ENV BRIDGETOWN_ENV=production
WORKDIR /app
RUN apk add --no-cache build-base
# RUN gem install bundler -N
# RUN gem install bridgetown -N
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
COPY --from=asset_builder /assets/output output/
COPY --from=asset_builder /assets/.bridgetown-cache .bridgetown-cache/
RUN ./bin/bridgetown build

# Serve your site in a tiny production container, which serves on port 8043.
FROM pierrezemb/gostatic
COPY --from=bridgetown_builder /app/output /srv/http/

CMD ["-enable-health", "-log-level", "info", "-fallback", "404.html"]

# FROM ruby:3.3.4 AS build
# WORKDIR /app
# COPY Gemfile Gemfile.lock ./
# RUN bundle install
#
# COPY package.json package-lock.json ./
# RUN apt update && apt install nodejs npm -y
# RUN npm install
#
# COPY . .
# RUN BRIDGETOWN_ENV=production bundle exec bridgetown deploy --trace
#
# FROM pierrezemb/gostatic
# COPY --from=build /app/output/. /srv/http/
# CMD ["-enable-health", "-log-level", "info", "-fallback", "404.html", "-append-header"," "Access-Control-Allow-Origin:https://static.cloudflareinsights.com"]
