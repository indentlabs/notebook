# The image to build from.
FROM ruby:3.2.1-slim

# Properties/labels for the image.
LABEL maintainer="Notebook.ai Contributors"

# Development ENV by default, but overridable with RAILS_ENV
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

# Create the notebookai user and group
RUN groupadd --system --gid 1000 notebookai && \
    useradd --system --home-dir /home/notebookai --gid notebookai --uid 1000 --shell /bin/bash notebookai

# Install system dependencies
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs imagemagick libmagickwand-dev curl && \
    rm --recursive --force /var/lib/apt/lists/*

# Install yarn via npm (avoids the deprecated apt-key approach)
RUN npm install -g yarn

# Set the notebookai user's home directory as the working directory.
WORKDIR /home/notebookai

# Copy dependencies first to maximize Docker layer caching
COPY Gemfile Gemfile.lock package.json yarn.lock ./

# Install app dependencies
RUN bundle install && \
    yarn install

# Copy the remaining application files
COPY . .

# Adjust permissions on all copied files to match the system user
RUN chown -R notebookai:notebookai /home/notebookai

# This image should expose port 3000.
EXPOSE 3000/tcp

# Run unprivileged
USER notebookai

# Configure the main process to run when running the image
ENTRYPOINT ["./docker-entrypoint.sh"]

# Start the server using Puma!
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-e", "development", "-b", "tcp://0.0.0.0:3000"]