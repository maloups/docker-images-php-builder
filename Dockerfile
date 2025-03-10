# Dockerfile

#Image intiialement basé sur le docker file https://github.com/silarhi/docker-php/tree/main/7.4-symfony/
#Détail de l'image 7.4-apache : https://hub.docker.com/layers/php/library/php/7.4-apache/images/sha256-3f04eaed6449ebe2f2969c5f6176f745ae9bcef659f67b6c7fcbe54d8a15a2db?context=explore
FROM php:8.3.13-apache-bookworm


ENV COMPOSER_VERSION=2.2.4
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV APACHE_DOCUMENT_ROOT=/var/www/html/api/public

COPY ./apache/000-default.conf /etc/apache2/sites-available/
COPY ./php/config/php.ini $PHP_INI_DIR/php.ini
COPY ./php/config/php-cli.ini $PHP_INI_DIR/php-cli.ini
COPY ./php/config/xdebug.ini $PHP_INI_DIR/conf.d/xxx-xdebug.ini

# Prepare Node setup
RUN apt-get update -qq && apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

ENV NODE_MAJOR=20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.

#Les dependances fontconfig, libfreetype6 libjpeg62-turbo libpng16-16 libxrender1 xfonts-75dpi xfonts-base sont utiles pour wkhtmltox
RUN apt-get update -qq && \
    apt-get install -qy \
    vim=2:9.* \
    git=1:2.* \
    gnupg=2.* \
    libicu-dev=72.* \
    libzip-dev=1.* \
    libpq-dev=15.* \
    libxml2-dev=2.* \
    unzip=6.* \
    zip=3.* \
    zlib1g-dev=1:1.* \
    xvfb=2:21.* \
    libapache2-mod-security2=2.* \
    curl=7.* \
    nodejs \
    linux-libc-dev=6.1.128-1\
    expat=2.5.0-1+deb12u1 \
    yarn


RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION}

#PHP Extensions
#Add this line because of pdo_psql error : https://github.com/docker-library/php/issues/221
#Install Postgre PDO
RUN docker-php-ext-configure zip && \
    docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
    docker-php-ext-install -j$(nproc) intl pgsql pdo pdo_pgsql opcache zip

RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN a2enmod headers
RUN a2enmod rewrite remoteip security2

#Changement du fuseau horaire de la machine linux pour l'aligner avec le fuseau de Paris
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

RUN npm install -g commitizen

RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt install symfony-cli

