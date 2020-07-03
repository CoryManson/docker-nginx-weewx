FROM centos:latest

ARG HOME=/home/weewx
ARG WEEWX_VERSION="4.1.1"
ENV TZ=Australia/Sydney

RUN sed -i -e '/override_install_langs/s/^/#/g' /etc/yum.conf;\    
	yum clean metadata;\
	yum -y reinstall glibc-common glibc-headers;\
	mkdir -p /tmp/extensions;\
	mkdir -p /etc/init.d
ENV LANG="hu_HU.UTF-8"

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm;\
	yum -y update;\
	yum -y install python3 python3-pillow python3-configobj python-setuptools pyephem wget git php-cli php-fpm php-json php-sqlite3 php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath;\
	yum -y groupinstall "Fonts";\
	easy_install pyserial pyusb;\ 
	rpm --import http://weewx.com/keys.html;\
	wget -O /tmp/weewx-${WEEWX_VERSION}.tar.gz http://weewx.com/downloads/weewx-${WEEWX_VERSION}.tar.gz;\
	wget -O /tmp/extensions/weewx-interceptor.tar.gz https://github.com/matthewwall/weewx-interceptor/archive/master.zip;\
	git clone https://github.com/steepleian/weewx-Weather34.git /tmp/weather34;\
	python3 /tmp/weewx/setup.py build;\
	python3 /tmp/weewx/setup.py install;\
	yum clean all;\
	rm -rf /var/cache/yum;\
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone;\
	find /tmp/extensions/ -name '*.*' -exec wee_extension --install={} \; ;\
	cd /home/weewx;\
	sudo cp util/init.d/weewx.redhat /etc/rc.d/init.d/weewx;\
	sudo chmod +x /etc/rc.d/init.d/weewx;\
	sudo chkconfig weewx on;

VOLUME [ "/etc/weewx" ]
VOLUME [ "/var/www/weewx" ]
VOLUME [ "/var/lib/weewx/" ]

CMD [ "/etc/init.d/weewx start" ]