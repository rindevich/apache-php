FROM php:7-apache

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libcurl4-openssl-dev \
        software-properties-common  \
        libcurl3 curl \
        zip \
        unzip \
        libzip-dev \
        inotify-tools \
        build-essential \
        libxml2-dev libxslt1-dev zlib1g-dev \
        git \
        mc \
        htop \
        mysql-client \
        sshpass \
        gnupg \
        nano \
        sudo \
        graphviz \
        netcat-openbsd \
        libmagickwand-dev \
        imagemagick \
        libicu-dev \
        mysql-client

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs build-essential

RUN docker-php-ext-install opcache \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install -j$(nproc) intl

RUN pecl install mcrypt-1.0.2

RUN pecl install apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini

#RUN pecl install memcached
#RUN echo "extension=memcached.so" > /usr/local/etc/php/conf.d/memcached.ini

RUN pecl install imagick
RUN echo "extension=imagick.so" > /usr/local/etc/php/conf.d/imagick.ini

RUN pecl install xdebug docker-php-ext-enable xdebug

RUN pecl install redis docker-php-ext-enable redis

RUN echo "date.timezone=Europe/Berlin" >> /usr/local/etc/php/conf.d/timezone.ini

RUN set -eux; \
	{ \
		echo 'xdebug.remote_enable=1'; \
		echo 'xdebug.remote_handler=dbgp'; \
		echo 'xdebug.remote_host=172.18.0.1'; \
		echo 'xdebug.remote_port=9000'; \
		echo 'xdebug.remote_autostart=0'; \
		echo 'xdebug.remote_connect_back=1'; \
		echo 'xdebug.profiler_output_dir="/var/www/html/vendor/shopware/shopware/build/artifacts"'; \
	} > /usr/local/etc/php/conf.d/xdebug.ini

# Apache + PHP requires preforking Apache for best results
RUN a2enmod rewrite && a2dismod mpm_event && a2enmod mpm_prefork
RUN service apache2 restart

RUN echo "alias ll='ls -ahl'" >> /etc/bash.bashrc

WORKDIR /var/www/html

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer
RUN php -r "unlink('composer-setup.php');"
