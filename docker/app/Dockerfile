FROM php:8.2.3-fpm as php-main-build

MAINTAINER Werner Hanekom

RUN apt-get update \
    && apt-get install -y \
        supervisor cron git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zip unzip libzip-dev \
        libxml2-dev \
    && docker-php-source extract \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install exif \
    && docker-php-ext-install opcache \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install soap \
    && docker-php-ext-install zip \
    && docker-php-ext-install bcmath \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-source delete \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && rm -rf /var/lib/apt/lists/*

# Install puppeteer dependencies
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash
RUN apt-get update && apt-get install -f -y nodejs gconf-service libasound2 libgbm-dev libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libnss3 lsb-release xdg-utils wget

# Install puppeteer
RUN npm install --global --unsafe-perm puppeteer@18.0.5
RUN chmod -R o+rx /usr/lib/node_modules/puppeteer/.local-chromium

# Copy OpCache config
ADD /docker/app/custom.ini "$PHP_INI_DIR/conf.d/z_custom.ini"
ADD /docker/app/opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

# Copy PHP Config
COPY /docker/app/www.conf /usr/local/etc/php-fpm.d/www.conf


#################################################
# DEV BUILD
#################################################
FROM php-main-build as dev-build

# PHP-FPM defaults
ENV PHP_FPM_PM="dynamic" \
    PHP_FPM_MAX_CHILDREN="100" \
    PHP_FPM_START_SERVERS="12" \
    PHP_FPM_MIN_SPARE_SERVERS="8" \
    PHP_FPM_MAX_SPARE_SERVERS="16" \
    PHP_FPM_MAX_REQUESTS="300"

# OPcache defaults
ENV PHP_OPCACHE_ENABLE="1" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="256" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="20000" \
    PHP_OPCACHE_REVALIDATE_FREQUENCY="0" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="20"

RUN apt-get update && apt-get install -y default-mysql-client \
    && docker-php-ext-install pdo_mysql
# Copy Supervisor Config
COPY /docker/app/supervisord-dev.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]


#################################################
# PRODUCTION BUILD STAGE
#################################################
FROM php-main-build as prod-build

ARG ENLIGHTN_USERNAME
ARG ENLIGHTN_API_TOKEN
ARG NOVA_USERNAME
ARG NOVA_LICENSE_KEY_VALUE
ARG GIT_OAUTH

# PHP-FPM defaults
ENV PHP_FPM_PM="dynamic" \
    PHP_FPM_MAX_CHILDREN="100" \
    PHP_FPM_START_SERVERS="12" \
    PHP_FPM_MIN_SPARE_SERVERS="8" \
    PHP_FPM_MAX_SPARE_SERVERS="16" \
    PHP_FPM_MAX_REQUESTS="300"

# OPcache defaults
ENV PHP_OPCACHE_ENABLE="1" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="256" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_REVALIDATE_FREQUENCY="0" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

ENV NOVA_LICENSE_KEY=$NOVA_LICENSE_KEY_VALUE

# Copy Supervisor Config
#COPY /docker/app/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY /docker/app/supervisord-app.conf /tmp/supervisord-app.conf
COPY /docker/app/supervisord-worker.conf /tmp/supervisord-worker.conf

# Copy App
COPY . /var/www/html/

# Install Composer Dependencies
RUN cd /var/www/html \
&& composer config http-basic.satis.laravel-enlightn.com "$ENLIGHTN_USERNAME" "$ENLIGHTN_API_TOKEN" \
&& composer config http-basic.nova.laravel.com "$NOVA_USERNAME" "$NOVA_LICENSE_KEY_VALUE" \
&& composer config github-oauth.github.com "$GIT_OAUTH" \
&& composer install --no-dev

# Laravel writing rights
RUN chown -R www-data:www-data /var/www/html /var/www/html/storage /var/www/html/public/css && chmod -R 755 /var/www/html /var/www/html/storage/ /var/www/html/public/css

COPY /docker/app/start-app.sh /tmp/start-app.sh
COPY /docker/app/start-worker.sh /tmp/start-worker.sh

RUN chown -R www-data:www-data /tmp && chmod -R 755 /tmp

CMD ["/tmp/start-app.sh"]
