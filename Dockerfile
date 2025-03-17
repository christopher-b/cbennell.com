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
RUN apk add --no-cache build-base libyaml
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
COPY --from=asset_builder /assets/output output/
COPY --from=asset_builder /assets/.bridgetown-cache .bridgetown-cache/
RUN ./bin/bridgetown build

FROM pierrezemb/gostatic
COPY --from=bridgetown_builder /app/output /srv/http/

CMD ["-enable-health", "-log-level", "info", "-fallback", "404.html"]
