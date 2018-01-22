FROM lsiobase/mono

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	wget && \
 echo "**** install jackett ****" && \
 mkdir -p \
	/app/Jackett && \
 jack_tag=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
 /tmp/jacket.tar.gz -L \
	https://github.com/Jackett/Jackett/releases/download/$jack_tag/Jackett.Binaries.Mono.tar.gz && \
 tar xf \
 /tmp/jacket.tar.gz -C \
	/app/Jackett --strip-components=1 && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

RUN \
  apt-get install -y \
    gcc && \
    make && \
    bash && \
    openssl && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*
 
ADD http://www.harding.motd.ca/autossh/autossh-1.4e.tgz /autossh-1.4e.tgz

RUN tar -xf autossh-1.4e.tgz && \
    cd autossh-1.4e
    ./configure
    make
    make install
    
# add local files
COPY root/ /

# ports and volumes
VOLUME /config /downloads
EXPOSE 9117
