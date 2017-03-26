FROM ubuntu:14.04.5
MAINTAINER Jeff Lindsay <progrium@gmail.com>

RUN apt-get update && apt-get install -y curl jq git

ADD https://get.docker.com/builds/Linux/x86_64/docker-17.03.0-ce.tgz                                  /tmp/docker.tgz
ADD https://github.com/progrium/dockerhook/releases/download/v0.1.0/dockerhook_0.1.0_linux_x86_64.tgz /tmp/dockerhook.tgz
ADD https://github.com/dokku/plugn/releases/download/v0.3.0/plugn_0.3.0_linux_x86_64.tgz              /tmp/plugn.tgz

RUN    cd /tmp && tar -zxf /tmp/docker.tgz     && rm /tmp/docker.tgz && mv /tmp/docker/* /bin \
    && cd /bin && tar -zxf /tmp/dockerhook.tgz && rm /tmp/dockerhook.tgz \
    && cd /bin && tar -zxf /tmp/plugn.tgz      && rm /tmp/plugn.tgz \
    && chmod +x /bin/docker* /bin/plugn \
    && chown root:root /bin/docker* /bin/plugn

ADD ./plugins /plugins
ENV PLUGIN_PATH /plugins

ADD ./start /start
CMD ["/start"]
