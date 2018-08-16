FROM ruby:2.5.1
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs imagemagick libmagickwand-dev && \
    mkdir /notebook-ai
COPY . /notebook-ai
WORKDIR /notebook-ai
RUN bundle install
RUN rake db:create
RUN rake db:migrate
