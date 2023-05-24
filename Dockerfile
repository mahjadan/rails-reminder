# Make sure it matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.1.1
FROM ruby:$RUBY_VERSION as builder

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
    BUNDLE_WITHOUT="development"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile --gemfile app/ lib/


# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# precomiles assets and then deletes the dummy key
# RUN SECRET_KEY_BASE_DUMMY=1 /rails/bin/bundle exec rails assets:precompile
# RUN node -v
RUN npm install --global yarn
RUN yarn config set ignore-engines true

RUN SECRET_KEY_BASE=1 /rails/bin/bundle exec rails assets:precompile

# Run stage
FROM ruby:3.1.1-alpine
ARG RAILS_ROOT=/rails
ARG PACKAGES="tzdata postgresql-client nodejs bash"

ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

WORKDIR $RAILS_ROOT

# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES

COPY --from=builder $RAILS_ROOT $RAILS_ROOT
# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
# CMD ["./bin/rails", "server"]