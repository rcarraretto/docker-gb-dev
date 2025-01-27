FROM debian:latest

# these are to stop debian in docker from complaining
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV SDCCDIR=/opt/sdcc

# apt-get dependencies
RUN dpkg --add-architecture i386 \
  && apt-get update && apt-get -y install \
  gnupg2 \
  wget \
  libboost-dev \
  && wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
  && echo 'deb https://dl.winehq.org/wine-builds/ubuntu/ xenial main' |tee /etc/apt/sources.list.d/winehq.list \
  && apt-get update && apt-get -y install \
  winehq-stable \
  zenity \
  libncurses5 \
  unzip \
  git \
  build-essential \
  byacc \
  bison \
  flex \
  pkg-config \
  gawk \
  libpng-dev \
  xvfb \
  x11vnc \
  xdotool \
  tar \
  supervisor \
  net-tools \
  fluxbox \
  python \
  && apt-get -y full-upgrade

# noVNC (VNC client web application)
# https://github.com/novnc/noVNC
RUN wget -O - https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzv -C /opt/ && mv /opt/noVNC-1.1.0 /opt/novnc \
  && wget -O - https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar -xzv -C /opt/ && mv /opt/websockify-0.9.0 /opt/novnc/utils/websockify

# Wine
RUN mkdir /opt/wine-stable/share/wine/mono && wget -O - https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-bin-4.9.4.tar.gz |tar -xzv -C /opt/wine-stable/share/wine/mono \
  && mkdir /opt/wine-stable/share/wine/gecko && wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi \
  && wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86_64.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86_64.msi

# RGBDS (assembler/linker)
# https://github.com/gbdev/rgbds
RUN git clone https://github.com/rednex/rgbds.git /opt/rgbds \
  && cd /opt/rgbds \
  && make && make install

# SDCC (GBDK dependency)
# https://github.com/gbdk-2020/gbdk-2020#current-status
RUN cd /opt \
  && wget -O sdcc.tar.gz "https://github.com/gbdk-2020/gbdk-2020-sdcc/releases/download/sdcc-12539-patched/sdcc-amd64-linux2.5-20210711-12539--sms-gg-patched.tar.bz2" \
  && tar xf sdcc.tar.gz \
  && rm sdcc.tar.gz
# GBDK
# https://github.com/gbdk-2020/gbdk-2020
RUN cd /opt \
  && wget -O gbdk.tar.gz "https://github.com/gbdk-2020/gbdk-2020/releases/download/4.0.6/gbdk-linux64.tar.gz" \
  && tar xf gbdk.tar.gz \
  && rm gbdk.tar.gz

# BGB (emulator/debugger)
# http://bgb.bircd.org/
RUN mkdir /opt/bgb \
  && cd /opt/bgb \
  && wget http://bgb.bircd.org/bgb.zip \
  && unzip bgb.zip \
  && rm bgb.zip

ADD novnc.html /opt/novnc/index.html
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD help.html /opt/help.html
ADD menu /etc/X11/fluxbox/fluxbox-menu

RUN useradd -ms /bin/bash gbdev

# set these in your .bashrc on a local install
ENV WINEPREFIX /home/gbdev/wine
ENV WINEARCH win32
ENV WINEDEBUG -all
ENV GBDK_DIR /opt/gbdk
ENV RGBDS_DIR /opt/rgbds

# Docker-stuff to make everything run correctly as gbdev user through VNC
ENV DISPLAY :0
EXPOSE 8080
ENV HOME /home/gbdev
WORKDIR /home/gbdev
VOLUME /home/gbdev

CMD ["/usr/bin/supervisord"]
