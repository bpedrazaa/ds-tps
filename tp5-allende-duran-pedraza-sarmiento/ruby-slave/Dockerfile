FROM ruby

WORKDIR /usr/src/ruby-slave
COPY . .
RUN gem install grpc
RUN gem install grpc-tools
RUN gem install bundler
RUN bundle install
ENTRYPOINT ["ruby", "server.rb"]
