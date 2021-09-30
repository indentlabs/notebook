# HEADS UP!
# This Dockerfile is for DEVELOPMENT use only;
# it's in no way optimized for production and is largely maintained by
# the open source community for convenience. Installing the full stack
# manually is the preferred setup for Notebook.ai instances.

# The image to build from.
FROM ruby:2.7.4

# Properties/labels for the image.
LABEL maintainer="Notebook.ai Contributors"

# Copy the current folder into the notebookai user's home directory.
COPY . /home/notebookai

# Set the notebookai user's home directory as the working directory.
WORKDIR /home/notebookai

# Prep the image for runtime, this should all be done in one command
# to minimize image layers.
# See: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#minimize-the-number-of-layers
RUN groupadd --system --gid 1000 notebookai && \
    useradd --system --home-dir /home/notebookai --gid notebookai --uid 1000 --shell /bin/bash notebookai && \
    apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs imagemagick libmagickwand-dev && \
    rm --recursive --force /var/lib/apt/lists/* && \
    bundle install && \
    rails db:setup

# This image should expose the port 3000.
# This does not actually expose the port, you'll have to expose it yourself by
# using `-p 3000:3000/tcp` in Docker's CLI or `- "3000:3000"` in the in docker-compose.yml service's ports[].
# https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 3000/tcp
