FROM openjdk:11

ENV LANG C.UTF-8

RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install -y wget unzip sudo

RUN mkdir /workdir && cd /workdir

WORKDIR /workdir

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf awscliv2.zip \
  && rm -rf aws

RUN wget -q https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.7.6/gatling-charts-highcharts-bundle-3.7.6-bundle.zip \
  && unzip gatling-charts-highcharts-bundle-3.7.6-bundle.zip

ENV GATLING_HOME=/workdir/gatling-charts-highcharts-bundle-3.7.6

ENV PATH=$PATH:$GATLING_HOME/bin

RUN chmod +x ${GATLING_HOME}/bin/gatling.sh

RUN echo "root soft nproc 64000" >> /etc/security/limits.conf \
  && echo "root hard nproc 64000" >> /etc/security/limits.conf \
  && echo "root soft nofile 64000" >> /etc/security/limits.conf \
  && echo "root hard nofile 64000" >> /etc/security/limits.conf \
  && echo "session required pam_limits.so" >> /etc/pam.d/common-session \
  && echo "fs.file-max = 2097152" >> /etc/sysctl.conf \
  && ulimit -n 64000

COPY ./senario/simulations /${GATLING_HOME}/user-files/simulations

COPY ./function.sh /workdir/

RUN chmod +x ./function.sh

CMD ["./function.sh"]
