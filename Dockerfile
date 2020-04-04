FROM ruby:2.6.5-alpine3.10
MAINTAINER Ministry of Justice, Apply service <apply@digital.justice.gov.uk>

# fail early and print all commands
RUN set -ex

# build dependencies:
# -virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
# - ruby-dev/libc-dev for compiling raindrops, at least
# - libxml2-dev/libxslt-dev for nokogiri, at least
# - git for installing gems referred to use as git:// uri
#
# runtime dependencies:
# - file: for paperclip file type spoofing check
# - nodejs: for ExecJS and asset compilation
# - runit for process management (because we have multiple services)
# - libreoffice: for pdf conversion
# - ttf-ubuntu-font-family: needed by wkhtmltopdf/wicked_pdf & libreoffice
# - wkhtmltopdf: for pdf generation from html
# - redis: for backend key-value store
#
RUN apk --no-cache add --virtual build-dependencies \
                    build-base \
                    libxml2-dev \
                    libxslt-dev \
                    git \
&& apk --no-cache add \
                  redis

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

# create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
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
&& bundle config build.nokogiri --use-system-libraries \
&& bundle install

####################
# DEPENDENCIES END #
####################
COPY . .

# tidy up installation
RUN apk update && apk del build-dependencies

## non-root/appuser should own only what they need to
#RUN chown -R appuser:appgroup log tmp db

# expect ping environment variables
ARG SLACK_API_TOKEN
ENV SLACK_API_TOKEN=${SLACK_API_TOKEN}

USER 1000
