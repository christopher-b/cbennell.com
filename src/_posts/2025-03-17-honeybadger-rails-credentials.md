---
layout: post
title:  Honeybadger with Kamal and GitLab CI
date:   2025-03-17
tags:
  - kamal
  - honeybadger
  - rails
coverImage: stars.webp
---

I recenlty migrated a Rails app to deploy with [Kamal](https://kamal-deploy.org/) on GitLab CI. I wanted to share a few quirks related to [Honeybadger](https://www.honeybadger.io/) integration. This was mostly an out-of-the-box Kamal configuration, using a Dockerfile similar to what ships with Rails 8.

## Rails Crendentials & Honeybadger

The first issue I encountered was the use of Rails credentials in my Honeybadger config, which included this line:

{% code erb caption="config/honeybadger.yml" %}
api_key: <%= Rails.application.credentials.honeybadger.api_key %>
{% endcode %}

This caused an error during the application image build, specifically on this line, asset precompilation:

{% code dockerfile caption="Dockerfile" %}
SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
{% endcode %}

Since we aren't setting a valid `SECRET_KEY_BASE`, Rails can't decrypt our credentials, leading to an error when it fails to find our Honeybadger API key.

### Solution: Safe Navigation
One approach is to use Ruby's safe navigation operator (&.) to prevent the error. This will set the API key to `nil`, which the Honeybadger gem will not complain about:

{% code erb caption="config/honeybadger.yml" %}
api_key: <%= Rails.application&.credentials&.honeybadger&.api_key %>
{% endcode %}

## Reporting Deploys

The other issue involved reporing deploys to Honeybadger. There are alot of ways one might go about setting this up, but I had a few requirements in mind that narrowed down the options:

- I wanted to use a Kamal [post-deploy hook](https://kamal-deploy.org/docs/hooks/post-deploy/), rather than extra steps to my CI job. This ensures deploys are reported even if the CI process changes (well, to an extent. I'm using GitLab-specific env vars, see below).
- I wanted to use the Honeybadger API key stored in Rails credentials rather than duplicating the key in my CI configuration. This meant running the command in the context of a Rails environment.

A key constraint here is the execution context of the Kamal hooks in the CI environment. When the hook runs, it's running on the CI build host rather than within the application container. It also doesn't have a gem bundle installed unless specifically told to install one, which would increase the excecution time of the deploy job.

### Solution: Kamal Alias

To address these requirements, I put the actual reporting command into a Kamal alias and call that alias from the post-deploy hook. This runs the task on one of the just-deployed production containers (the jobs container, in this case) which has access to the Rails credentials to load the API key. It also introduces a bit of abstraction around the parameters supplied to the deploy command.


{% code yaml caption="config/deploy.yml" %}
...
aliases:
  record-deploy: >
    app exec --reuse --roles=job 'bundle exec honeybadger deploy
    --user "<%= ENV["DEPLOY_USER"] %>"
    --repository "<%= ENV["DEPLOY_REPO"] %>"
    --revision "<%= ENV["DEPLOY_REVISION"] %>"'
{% endcode %}

{% code bash caption=".kamal/hooks/post-deploy" %}
#!/bin/sh
DEPLOY_USER=$CI_COMMIT_AUTHOR \
  DEPLOY_REPO=$CI_PROJECT_URL \
  DEPLOY_REVISION=$CI_COMMIT_SHA \
  kamal record-deploy
{% endcode %}

Since Kamal configuration doesn’t support direct environment variable expansion, we use ERB interpolation to extract the values from environment variables. These variables are then populated using values supplied by GitLab CI.

This setup ensures that deploys are properly reported to Honeybadger with minimal modifications to the deployment process.
