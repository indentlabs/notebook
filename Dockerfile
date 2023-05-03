# HEADS UP!
# This Dockerfile is for DEVELOPMENT use only;
# it's in no way optimized for production and is largely maintained by
# the open source community for convenience. Installing the full stack
# manually is the preferred setup for Notebook.ai instances.

# The image to build from.
FROM ruby:3.2.1

# Properties/labels for the image.
LABEL maintainer="Notebook.ai Contributors"

# Development ENV by default, but overridable with RAILS_ENV
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

# Copy the current folder into the notebookai user's home directory.
COPY . /home/notebookai

# Set the notebookai user's home directory as the working directory.
WORKDIR /home/notebookai

# Create the notebookai user and group
RUN groupadd --system --gid 1000 notebookai && \
    useradd --system --home-dir /home/notebookai --gid notebookai --uid 1000 --shell /bin/bash notebookai

# Install system dependencies
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs imagemagick libmagickwand-dev curl && \
    rm --recursive --force /var/lib/apt/lists/*

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn

# Install app dependencies, compile assets, and set up the database
RUN bundle install && \
    yarn install && \
    if [ "$RAILS_ENV" = "development" ] ; then \
        echo "Starting webpack-dev-server..." && \
        bin/webpack-dev-server & \
    else \
        echo "Compiling webpack assets..." && \
        rails webpacker:compile ; \
    fi && \
    rails db:setup && \
    rake db:migrate && \
    rm -f tmp/pids/server.pid

# This image should expose the port 3000.
# This does not actually expose the port, you'll have to expose it yourself by
# using `-p 3000:3000/tcp` in Docker's CLI or `- "3000:3000"` in the in docker-compose.yml service's ports[].
# https://docs.docker.com/engine/reference/builder/#expose
#EXPOSE 3000/tcp

# Finally, start the server!
#CMD rails server -b 0.0.0.0



# This image should expose port 80.
EXPOSE 80/tcp

# Finally, start the server using Puma!
CMD bundle exec puma -C config/puma.rb -e ${RAILS_ENV} -b tcp://0.0.0.0:80



# And run it with
# docker run --name nb-webserver -p 80:3000 -d notebookai