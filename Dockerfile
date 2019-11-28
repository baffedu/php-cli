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
    apk del -f .build-deps freetype-dev libpng-dev libjpeg-turbo-dev && \
    rm -rf /tmp/* /var/cache/apk/*


ENV PHPREDIS_VERSION 3.0.0

RUN mkdir -p /usr/src/php/ext/redis && \
curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 && \
echo 'redis' >> /usr/src/php-available-exts && \
docker-php-ext-install redis && \
docker-php-source delete

RUN apk add -U tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
echo "Asia/Chongqing" > /etc/timezone

ADD ./conf.d/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
# ADD ./conf.d/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# 运行计划任务
RUN echo '* * * * * php /var/www/html/artisan schedule:run >> /dev/null 2>&1' > /var/spool/cron/crontabs/root
CMD [ "crond","-f","-d","6","-L","/dev/stdout"]
