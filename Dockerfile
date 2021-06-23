FROM ruby:2.6.3

RUN apt-get update && apt-get install -y npm && npm install -g yarn

RUN mkdir -p /var/app
COPY . /var/app
WORKDIR /var/app

ARG RAILS_MASTER_KEY

ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

RUN bundle install
RUN rake compile_md

CMD rails server -b 0.0.0.0