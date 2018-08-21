FROM ruby:2.5.1-slim

COPY drone-mail.rb /bin/drone-mail

RUN gem install aws-sdk-ses

CMD ["/bin/drone-mail"]
