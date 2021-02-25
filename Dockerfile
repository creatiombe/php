FROM php:8-fpm-alpine


ENV PATH="~/.composer/vendor/bin:./vendor/bin:${PATH}" \
    APP_ENV='prod' \
    APP_DEBUG=0 \
    DATABASE_URL='' \
    WKHTMLTOPDF_PATH=/usr/bin/wkhtmltopdf \
    WKHTMLTOIMAGE_PATH=/usr/bin/wkhtmltoimage \
    MEMCACHED_HOST='127.0.0.1' \
    MEMCACHED_PORT=11211

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk add --no-cache \
    $PHPIZE_DEPS \
    git zip \
    imap-dev \
    openssl-dev \
    krb5-dev \
    icu-dev \
    libpng-dev \
    libxml2-dev \
    libqrencode \
    libzip-dev \
    rabbitmq-c \
    rabbitmq-c-dev \
    libmemcached-dev \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family \
    wkhtmltopdf

RUN docker-php-ext-install gd && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pcntl && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install sockets && \
    docker-php-ext-install opcache && \
    docker-php-ext-install soap && \
    docker-php-ext-install zip && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    pecl install https://github.com/0x450x6c/php-amqp/raw/7323b3c9cc2bcb8343de9bb3c2f31f6efbc8894b/amqp-1.10.3.tgz && \
    docker-php-ext-enable amqp && \
    pecl install mailparse && \
    docker-php-ext-enable mailparse && \
    pecl install memcached && \
    docker-php-ext-enable memcached && \
    pecl install -o -f redis && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis && \
    CPPFLAGS="-DHAVE_SYS_FILE_H" pecl install dbase && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable dbase && \
    pecl install apcu && \
    docker-php-ext-enable apcu

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --quiet --install-dir=/usr/bin --filename=composer && \
    rm composer-setup.php