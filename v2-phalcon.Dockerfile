FROM php:{{PHP_IMAGE_TAG}}
LABEL maintainer Danil Agafonov <mail@live-notes.ru>

ARG PHALCON_VERSION=2.0.13

ENV PHALCON_VERSION=${PHALCON_VERSION}

RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install imagick && docker-php-ext-enable imagick \
    && docker-php-ext-install mbstring iconv mcrypt pdo_mysql zip mysqli exif \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen

# Compile Phalcon
RUN set -xe \
    && curl -LO https://github.com/phalcon/cphalcon/archive/phalcon-v${PHALCON_VERSION}.tar.gz \
    && tar xzf phalcon-v${PHALCON_VERSION}.tar.gz && cd cphalcon-phalcon-v${PHALCON_VERSION}/build/64bits && phpize && ./configure CFLAGS="-O2 -g" --enable-phalcon && make -B && make install \
    && docker-php-ext-enable phalcon \
    && cd ../.. && rm -rf phalcon-v${PHALCON_VERSION}.tar.gz cphalcon-phalcon-v${PHALCON_VERSION} \
    # Insall Phalcon Devtools, see https://github.com/phalcon/phalcon-devtools/
    && curl -LO https://github.com/phalcon/phalcon-devtools/archive/v${PHALCON_VERSION}.tar.gz \
    && tar xzf v${PHALCON_VERSION}.tar.gz \
    && mv phalcon-devtools-${PHALCON_VERSION} /usr/local/phalcon-devtools \
    && ln -s /usr/local/phalcon-devtools/phalcon.php /usr/local/bin/phalcon
