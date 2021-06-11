FROM ruby:2.6.3

RUN apt-get update && apt-get install -y npm && npm install -g yarn

RUN mkdir -p /var/app
COPY . /var/app
WORKDIR /var/app

ARG DB_PASSWORD

ENV DB_PASSWORD=$DB_PASSWORD
ENV RAILS_ENV=production

RUN bundle install
RUN rake compile_md

CMD rails s -b 0.0.0.0