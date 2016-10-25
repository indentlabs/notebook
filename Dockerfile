FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs imagemagick libmagickwand-dev
RUN mkdir /notebook-ai
RUN gem install rails -v 4.2.5
WORKDIR /notebook-ai
ADD . /notebook-ai
RUN bundle install
RUN rake db:create
RUN rake db:migrate
