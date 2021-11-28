FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential pkg-config libssl-dev libexpat1-dev libavcodec-dev qtbase5-dev zlib1g-dev ffmpeg

# Build makemkv (install additional packages for the script)
RUN apt-get install -y --no-install-recommends \
    ca-certificates gnupg wget
COPY install.sh /install.sh
RUN chmod +x install.sh && ./install.sh && rm install.sh

RUN apt-get autoremove -y
