# Use an official PHP runtime as a parent image
FROM php:7.4-apache

# Set environment variables for Moodle
ENV MOODLE_HOME /var/www/html/moodle

# Install dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libxml2-dev \
    zlib1g-dev \
    libicu-dev \
    libldap2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    ghostscript \
    unoconv \
    aspell \
    aspell-en \
    cron \
    git \
    unzip \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        opcache \
        intl \
        soap \
        xmlrpc \
        ldap \
        curl \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Moodle
WORKDIR /tmp
RUN git clone --branch MOODLE_39_STABLE --depth 1 https://github.com/moodle/moodle.git $MOODLE_HOME

# Set up Moodle data directory
RUN mkdir $MOODLE_HOME/data \
    && chown -R www-data:www-data $MOODLE_HOME \
    && chmod -R 777 $MOODLE_HOME

# Install PostgreSQL support for PHP
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Expose port 80 and start Apache
EXPOSE 80
CMD ["apache2-foreground"]
