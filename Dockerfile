FROM ubuntu:14.04.5
MAINTAINER Jeff Lindsay <progrium@gmail.com>

RUN apt-get update && apt-get install -y curl jq git

ADD https://get.docker.io/builds/Linux/x86_64/docker-1.3.0 /bin/docker
RUN chmod +x /bin/docker

ADD https://github.com/progrium/dockerhook/releases/download/v0.1.0/dockerhook_0.1.0_linux_x86_64.tgz /tmp/dockerhook.tgz
RUN cd /bin && tar -zxf /tmp/dockerhook.tgz && rm /tmp/dockerhook.tgz

ADD https://github.com/dokku/plugn/releases/download/v0.3.0/plugn_0.3.0_linux_x86_64.tgz /tmp/plugn.tgz
RUN cd /bin && tar -zxf /tmp/plugn.tgz && rm /tmp/plugn.tgz

ADD ./plugins /plugins
ENV PLUGIN_PATH /plugins

ADD ./start /start
CMD ["/start"]
