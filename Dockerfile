FROM ruby:2.6.6-alpine3.10
MAINTAINER Ministry of Justice, Apply service <apply@digital.justice.gov.uk>

# fail early and print all commands
RUN set -ex

# build dependencies:
# -virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
RUN apk --no-cache add --virtual build-dependencies build-base

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

## create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

######################
# DEPENDENCIES START #
######################
COPY Gemfile* ./

# only install production dependencies,
# build nokogiri using libxml2-dev, libxslt-dev
# note: installs bundler version used in Gemfile.lock
#
RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") \
&& bundle config --global without test development \
&& bundle install

####################
# DEPENDENCIES END #
####################
COPY . .

# tidy up installation
RUN apk update && apk del build-dependencies

# expect ping environment variables
ARG SLACK_API_TOKEN
ENV KUBE_CONFIG_FILE=./config/.kube_config
ENV SLACK_API_TOKEN=${SLACK_API_TOKEN}

USER 1000
