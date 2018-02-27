FROM php:5.6-apache

# Set Phalcon Version
ENV PHALCON_VERSION=2.0.13

RUN a2enmod rewrite expires headers

# Download Node 6.x & Yarn & Install
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    apt-get install -y nodejs \
    zlib1g-dev \
    yarn \
    libpcre3-dev \
    libicu-dev \
    gcc \
    make \
    git \
    g++ \
    wget

RUN npm install -g grunt-cli

# Enable Php Extensions
RUN docker-php-ext-install pdo \
    pdo_mysql \
    zip \
    intl \
    && docker-php-ext-configure intl
    
# Enable Memcache
RUN pecl install memcache && \
    echo extension=memcache.so >> /usr/local/etc/php/conf.d/memcache.ini

# Compile Phalcon
RUN set -xe && \
        curl -LO https://github.com/phalcon/cphalcon/archive/phalcon-v${PHALCON_VERSION}.tar.gz && \
        tar xvzf phalcon-v${PHALCON_VERSION}.tar.gz && cd cphalcon-phalcon-v${PHALCON_VERSION}/build && ./install && \
        docker-php-ext-enable phalcon && \
        cd ../.. && rm -rf phalcon-v${PHALCON_VERSION}.tar.gz cphalcon-phalcon-v${PHALCON_VERSION}


RUN apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
