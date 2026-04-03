# The image to build from.
FROM ruby:3.2.3-slim

# Properties/labels for the image.
LABEL maintainer="Notebook.ai Contributors"

# Development ENV by default, but overridable with RAILS_ENV
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}

# Create the notebookai user and group
RUN groupadd --system --gid 1000 notebookai && \
    useradd --system --home-dir /home/notebookai --gid notebookai --uid 1000 --shell /bin/bash notebookai

# Install system dependencies (including curl which is needed for Node download, and git for Bundler)
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev imagemagick libmagickwand-dev curl git libjemalloc2 && \
    rm --recursive --force /var/lib/apt/lists/*

# Install Node.js 16.x explicitly and support both ARM and x64 architectures
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" && \
    case "${dpkgArch##*-}" in \
      amd64) ARCH='x64';; \
      arm64) ARCH='arm64';; \
      *) echo "unsupported architecture"; exit 1 ;; \
    esac && \
    curl -fsSLO "https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-$ARCH.tar.gz" && \
    tar -xzf "node-v16.20.2-linux-$ARCH.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v16.20.2-linux-$ARCH.tar.gz"

# Install yarn via npm (matches local tools specification)
RUN npm install -g yarn@1.22.22

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

# Drop down to the unprivileged user before running Rake, so any files it generates (like logs) are owned correctly
USER notebookai

# Precompile assets during docker build to prevent OOM memory spikes at runtime
# We strictly limit Node.js memory to 1GB to prevent Railway's Builder container from OOMing
RUN NODE_OPTIONS="--max_old_space_size=1024" SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# This image should expose port 3000.
EXPOSE 3000/tcp

# Enable jemalloc to drastically reduce memory fragmentation and usage
ENV LD_PRELOAD="libjemalloc.so.2"

# Configure the main process to run when running the image
ENTRYPOINT ["./docker-entrypoint.sh"]

# Start the server using Puma!
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-e", "development", "-b", "tcp://0.0.0.0:3000"]