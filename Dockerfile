FROM php:7.2-cli-alpine
MAINTAINER wish@baffedu.net

RUN set x=1 && \
    apk update && \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS zlib-dev imagemagick-dev libtool && \
    apk add --no-cache --virtual .tools rsync && \
    apk add --no-cache --virtual .imagick-runtime-deps imagemagick && \
    apk add --no-cache --virtual .gd freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
    curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && chmod a+x /usr/local/bin/composer && \
    docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    pecl install imagick && \
    docker-php-ext-install -j$(nproc) gd pcntl pdo_mysql bcmath zip opcache && \
    docker-php-ext-enable imagick && \
    docker-php-source delete && \
    wget https://getcomposer.org/installer && \
    php installer && \
    mv composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer && \
    apk del -f .build-deps freetype-dev libpng-dev libjpeg-turbo-dev && \
    rm -rf /tmp/* /var/cache/apk/*

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh

WORKDIR /var/www/html/
ENTRYPOINT [ "/bin/sh","/entrypoint.sh"]