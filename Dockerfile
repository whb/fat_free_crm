# Usage:
# docker volume create gems
# docker-compose up -d
# docker-compose exec web bundle exec rake db:create db:schema:load ffcrm:demo:load

FROM ruby:2.7

LABEL author="Steve Kenworthy"

ENV HOME /home/app

# ruby 镜像预设的这个环境变量干扰了后面的操作，将它重置为默认值
ENV BUNDLE_APP_CONFIG=.bundle

# apt 使用阿里云的源
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb https://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >/etc/apt/sources.list && \
    echo "deb-src https://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian-security/ bullseye-security main" >>/etc/apt/sources.list && \
    echo "deb-src https://mirrors.aliyun.com/debian-security/ bullseye-security main" >>/etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >>/etc/apt/sources.list

RUN mkdir -p $HOME

WORKDIR $HOME

ADD . $HOME
RUN apt-get update && \
	apt-get install -y imagemagick tzdata sqlite3 && \
	apt-get autoremove -y 

# 设置 gem 中国镜像，并安装bundler
RUN cp config/database.sqlite.docker.yml config/database.yml && \
    gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ &&\
    bundle config mirror.https://rubygems.org https://gems.ruby-china.com &&\
	gem install bundler && \
	gem update --system && \
	bundle config set --local deployment 'true' && \
	bundle install --deployment && \
	bundle exec rails assets:precompile

CMD ["bundle","exec","rails","s"]

EXPOSE 3000

# # Usage:
# # docker volume create pgdata
# # docker volume create gems
# # docker-compose up
# # docker-compose exec web bundle exec rake db:create db:schema:load ffcrm:demo:load assets:precompile

# FROM phusion/passenger-ruby24
# MAINTAINER Steve Kenworthy

# ENV HOME /home/app

# ADD . /home/app
# WORKDIR /home/app

# RUN apt-get update \
#   && apt-get install -y imagemagick firefox tzdata \
#   && apt-get autoremove -y \
#   && cp config/database.postgres.docker.yml config/database.yml \
#   && chown -R app:app /home/app \
#   && rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default \
#   && cp .docker/nginx/sites-enabled/ffcrm.conf /etc/nginx/sites-enabled/ffcrm.conf \
#   && bundle install --deployment
