FROM swift:latest

RUN apt-get update && apt-get install -y libxml2 libxml2-dev

RUN mkdir /swiftsax

ADD Sources /swiftsax/Sources
ADD Modules /swiftsax/Modules
ADD Tests /swiftsax/Tests
ADD Package.swift /swiftsax
ADD Package.resolved /swiftsax

RUN cd /swiftsax && swift test --enable-test-discovery
