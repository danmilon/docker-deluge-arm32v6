FROM arm32v6/alpine:3.6
LABEL maintainer="Dan Milon <i@danmilon.me>"

RUN \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	libffi-dev \
	openssl-dev \
	py2-pip \
	python2-dev && \

# install runtime packages
 apk add --no-cache \
     	s6 \
	gettext \
	ca-certificates \
	curl \
	openssl \
	p7zip \
	unrar \
	unzip && \
# deluge is in testing only
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	deluge && \

# install pip packages
 pip install --no-cache-dir -U \
	incremental \
	pip && \
 pip install --no-cache-dir -U \
	crypto \
	mako \
	markupsafe \
	pyopenssl \
	service_identity \
	six \
	twisted \
	zope.interface && \

# cleanup
 apk del --purge build-dependencies && \
 rm -rf /root/.cache

RUN adduser -Su 1000 deluge
RUN install -dD -o deluge \
    /data/downloaded \
    /data/incomplete \
    /data/torrent-files

COPY root/ /
RUN chown -R deluge /var/lib/deluge

VOLUME ["/data"]
VOLUME ["/var/lib/deluge"]

# incoming torrent connections
EXPOSE 6881/tcp

# DHT
EXPOSE 6881/tcp

# web UI
EXPOSE 8112/tcp

ENTRYPOINT ["/bin/s6-svscan", "/etc/services.d"]
