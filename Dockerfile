FROM ruby:2.5.3

RUN mkdir /src

ENV APP_ROOT /src

WORKDIR $APP_ROOT

# 必要なものをインストール
RUN apt-get update
RUN apt-get install -y nodejs mysql-client
RUN rm -rf /var/lib/apt/lists/*
## nodejsとyarnはwebpackをインストールする際に必要
# Node.js
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
apt-get install nodejs
# yarnパッケージ管理ツール
RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn

# ホスト側のGemfileをコピー
ADD Gemfile $APP_ROOT
ADD Gemfile.lock $APP_ROOT

# bundle install
RUN bundle config --global build.nokogiri --use-system-libraries
RUN bundle config --global jobs 4
RUN gem install bundler
RUN bundle install

ADD . $APP_ROOT

# docker runした時に起動するコマンドを設定、ポートは3000を設定
EXPOSE  3000
CMD ["rails", "server", "-b", "0.0.0.0"]