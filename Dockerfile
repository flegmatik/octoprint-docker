FROM alpine:latest as builder
WORKDIR /tmp
RUN \
    apk update && \
    apk add \
      build-base \
      python3 \
      python3-dev \
      py3-virtualenv \
      py3-pip \
      py3-setuptools \
      yaml-dev \
      v4l-utils-dev \
      linux-headers \
      gcc \
      cmake \
      libjpeg-turbo-dev \
      g++ \
      imagemagick \
      ffmpeg \
      git && \
    cd /opt && git clone https://github.com/jacksonliam/mjpg-streamer.git && \
    cd /opt/mjpg-streamer/mjpg-streamer-experimental && \
    make && make install

FROM alpine:latest
LABEL maintainer="Robert Plestenjak"
LABEL version="latest"
LABEL description="Octoprint"
COPY --from=builder /usr/local/bin/mjpg_streamer /usr/local/bin/mjpg_streamer
COPY --from=builder /usr/local/share/mjpg-streamer /usr/local/share/mjpg-streamer/www
COPY --from=builder /usr/local/lib/mjpg-streamer /usr/local/lib/mjpg-streamer
RUN \
    apk add \
      build-base \
      linux-headers \
      python3 \
      python3-dev \
      py3-virtualenv \
      py3-pip \
      py3-setuptools \
      yaml-dev \
      ffmpeg \
      v4l-utils \
      haproxy \
      imagemagick \
      gcc
COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./octoserve /usr/local/bin/octoserve
COPY ./octoprint /etc/octoprint
COPY ./requirements.txt /tmp/
RUN \
    chmod +x /usr/local/bin/octoserve && \
    adduser octoprint -h /home/octoprint -s /bin/sh -D && \
    addgroup octoprint tty && \
    addgroup octoprint dialout && \
    mkdir -p /opt/octoprint && \
    chown -R octoprint:root /opt/octoprint && \
    chown octoprint:octoprint /home/octoprint && \
    pip3 install -r /tmp/requirements.txt
CMD /usr/local/bin/octoserve
