FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV HOME=/tmp

RUN apt-get update -y \
  && apt-get install -y curl tsung unzip

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf awscliv2.zip \
  && rm -rf aws

COPY ./exec /.tsung

WORKDIR /workdir

COPY ./function.sh /workdir/

RUN chmod +x ./function.sh

CMD ["./function.sh"]
