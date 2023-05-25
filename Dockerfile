# Make sure it matches the Ruby version in .ruby-version and Gemfile
# ARG RUBY_VERSION=3.1.1
# FROM ruby:$RUBY_VERSION as builder
FROM ruby:3.1.1-slim-bullseye as builder

# Install libvips for Active Storage preview support
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev libvips bash bash-completion libffi-dev tzdata postgresql nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# Rails app lives here
WORKDIR /rails


# Set production environment
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_PATH='vendor/bundle'

ENV BUNDLER_VERSION='2.4.10'

# Install application gems
COPY Gemfile Gemfile.lock ./

RUN npm install --global yarn
RUN yarn config set ignore-engines true

RUN gem install bundler -v 2.4.10
RUN bundle config set --local path 'vendor'
RUN bundle install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile --gemfile app/ lib/


# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# precomiles assets and then deletes the dummy key

RUN SECRET_KEY_BASE=1 /rails/bin/bundle exec rails assets:precompile

# Run stage
# FROM ruby:3.1.1-alpine3.14
# ARG RAILS_ROOT=/rails
# ARG PACKAGES="tzdata postgresql-client libpq nodejs bash"


# ENV RAILS_ENV="production" \
#    BUNDLE_PATH='vendor/bundle' \
#    RAILS_LOG_TO_STDOUT=true \
# WORKDIR $RAILS_ROOT

# # install packages
# RUN apk update \
#     && apk upgrade \
#     && apk add --update --no-cache $PACKAGES

# # RUN bundle config set --local path 'vendor'

# COPY --from=builder $RAILS_ROOT $RAILS_ROOT
# COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
# CMD ["./bin/rails", "server"]