FROM php:7-apache

RUN apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends --no-install-suggests -q -y gnupg2 dirmngr wget apt-transport-https lsb-release ca-certificates \
    && apt-get install -y \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libcurl4-openssl-dev \
        software-properties-common  \
        libcurl3 curl \
        zip \
        wget \
        unzip \
        libzip-dev \
        inotify-tools \
        build-essential \
        libxml2-dev libxslt1-dev zlib1g-dev \
        git \
        mc \
        htop \
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

RUN mkdir -p /usr/share/man/man1 \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs build-essential

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install \
    opcache \
    bcmath \
    gd \
    zip \
    intl \
    mysqli \
    bz2 \
    pdo_mysql \
    soap \
    sockets \
    tokenizer \
    xmlrpc \
    xsl \
    exif \
    calendar

RUN pecl install mcrypt-1.0.2

RUN pecl install imagick \
        apcu \
        imagick \
        xdebug \
        pcov \
        redis

RUN docker-php-ext-enable imagick\
        apcu \
        imagick \
        xdebug \
        pcov \
        redis

#RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini
#RUN echo "extension=imagick.so" > /usr/local/etc/php/conf.d/imagick.ini

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

RUN set -eux; \
	{ \
		echo 'memory_limit=1024M'; \
		echo 'max_input_time=-1'; \
		echo 'max_execution_time=0'; \
		echo 'post_max_size=256M'; \
		echo 'upload_max_filesize=256M'; \
		echo 'max_input_vars=2000'; \
	} > /usr/local/etc/php/conf.d/memlimit.ini

# Apache + PHP requires preforking Apache for best results
RUN a2enmod rewrite && a2dismod mpm_event && a2enmod mpm_prefork
RUN service apache2 restart

RUN echo "alias ll='ls -ahl'" >> /etc/bash.bashrc

RUN pecl clear-cache

WORKDIR /var/www/html

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
