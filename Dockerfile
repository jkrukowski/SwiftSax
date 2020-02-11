FROM swiftlang/swift:nightly-5.2

RUN apt-get update && apt-get install -y libxml2 libxml2-dev
