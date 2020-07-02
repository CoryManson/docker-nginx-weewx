FROM lsiobase/nginx:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

ARG WEEWX_VERSION=4.1.1

COPY weewx-input.txt weather34-input.txt requirements.txt /build/

# install packages
RUN \
	apk add --no-cache --upgrade \
	curl \
	memcached \
	nginx \
	nginx-mod-http-echo \
	nginx-mod-http-fancyindex \
	nginx-mod-http-geoip \
	nginx-mod-http-geoip2 \
	nginx-mod-http-headers-more \
	nginx-mod-http-image-filter \
	nginx-mod-http-lua \
	nginx-mod-http-lua-upstream \
	nginx-mod-http-nchan \
	nginx-mod-http-perl \
	nginx-mod-http-redis2 \
	nginx-mod-http-set-misc \
	nginx-mod-http-upload-progress \
	nginx-mod-http-xslt-filter \
	nginx-mod-mail \
	nginx-mod-rtmp \
	nginx-mod-stream \
	nginx-mod-stream-geoip \
	nginx-mod-stream-geoip2 \
	nginx-vim \
	php7-bcmath \
	php7-bz2 \
	php7-ctype \
	php7-curl \
	php7-dom \
	php7-exif \
	php7-ftp \
	php7-gd \
	php7-iconv \
	php7-imap \
	php7-intl \
	php7-ldap \
	php7-mcrypt \
	php7-memcached \
	php7-mysqli \
	php7-mysqlnd \
	php7-opcache \
	php7-pdo_mysql \
	php7-pdo_odbc \
	php7-pdo_pgsql \
	php7-pdo_sqlite \
	php7-pear \
	php7-pecl-apcu \
	php7-pecl-imagick \
	php7-pecl-redis \
	php7-pgsql \
	php7-phar \
	php7-posix \
	php7-soap \
	php7-sockets \
	php7-sodium \
	php7-sqlite3 \
	php7-tokenizer \
	php7-xml \
	php7-xmlreader \
	php7-xmlrpc \
	php7-zip \
	php7-cli \
	php7-fpm \
	php7-json \
	php7-sqlite3 \
	php7-zip \ 
	php7-gd \
	php7-mbstring \
	php7-curl \
	php7-xml \
	php7-pear \
	php7-bcmath \
	freetype \
	libjpeg \
	libstdc++ \
	openssh \
	openssl \
	python3 \
	py3-cheetah \
	py3-configobj \
	py3-mysqlclient \
	py3-pillow \
	py3-six \
	rsync \
	rsyslog && \
	apk add --no-cache --virtual .fetch-deps \
	file \
	freetype-dev \
	g++ \
	gawk \
	gcc \
	git \
	jpeg-dev \
	libpng-dev \
	make \
	musl-dev \
	py3-pip \
	py3-wheel \
	python3-dev \
	zlib-dev && \
	echo "**** configure nginx ****" && \
	rm -f /etc/nginx/conf.d/default.conf && \
	sed -i \
	's|include /config/nginx/site-confs/\*;|include /config/nginx/site-confs/\*;\n\tlua_load_resty_core off;|g' \
	/defaults/nginx.conf && \
	echo "**** install weewx ****" && \
	cd build && \
	curl -sLo weewx.tar.gz http://www.weewx.com/downloads/released_versions/weewx-$WEEWX_VERSION.tar.gz && \
	pip install -r /build/requirements.txt && \
	ln -s python3 /usr/bin/python && \
	tar xf weewx.tar.gz --strip-components=1 && \
	sed --in-place 's/\/home\/weewx/\/config\/weewx/g' /build/setup.cfg && \
	./setup.py build && ./setup.py install < /build/weewx-input.txt && \
	echo "**** install interceptor ****" && \
	mkdir /build/interceptor && \
	wget https://github.com/matthewwall/weewx-interceptor/archive/master.zip -O /build/interceptor/weewx-interceptor.zip && \
	/config/weewx/bin/wee_extension --install /build/interceptor/weewx-interceptor.zip && \
	/config/weewx/bin/wee_config --reconfigure --driver=user.interceptor --no-prompt && \
	echo "**** install weather34 ****" && \
	git clone -b master --depth 1 https://github.com/steepleian/weewx-Weather34.git /build/weather34 && \
	sed --in-place 's/\/home\/weewx/\/config\/weewx/g' /build/weather34/setup_py.conf && \ 
	sed --in-place 's/\/var\/www\/html\/weewx\/weather34/config\/www/g' /build/weather34/setup_py.conf && \
	sed --in-place 's/www-data/abc/g' /build/weather34/w34_installer.py && \
	find /home/weewx/bin -name '*.pyc' -exec rm '{}' +;

# add local files
COPY root/ /
