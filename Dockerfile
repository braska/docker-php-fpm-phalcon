FROM centos:centos7
MAINTAINER Danil Agafonov <mail@live-notes.ru>

RUN \
  rpm --rebuilddb && yum update -y && \
  `# Install yum-utils (provides yum-config-manager) + some basic web-related tools...` \
  yum install -y yum-utils wget patch mysql tar bzip2 unzip openssh-clients rsync make gcc libtool epel-release git && \

  `# Install PHP 5.6` \
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum-config-manager -q --enable remi && \
  yum-config-manager -q --enable remi-php56 && \
  yum install -y php-fpm php-bcmath php-cli php-gd php-intl php-mbstring \
                  php-pecl-imagick php-mcrypt php-devel php-mysql php-opcache php-pdo && \

  `# Install libs required to build some gem/npm packages (e.g. PhantomJS requires zlib-devel, libpng-devel)` \
  yum install -y ImageMagick GraphicsMagick gcc gcc-c++ libffi-devel libpng-devel zlib-devel

RUN git clone --depth=1 git://github.com/phalcon/cphalcon.git /usr/local/src/cphalcon && cd /usr/local/src/cphalcon/build && ./install && \
  echo "extension=phalcon.so" > /etc/php.d/60-phalcon.ini

ADD etc /etc/

EXPOSE 9000
ENTRYPOINT ["php-fpm"]
CMD ["-RF"]
