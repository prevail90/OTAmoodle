# Use an official PHP runtime as a parent image
FROM php:7.4-apache

# Set environment variables for Moodle
ENV MOODLE_HOME /var/www/html/moodle
ARG MOODLE_VERSION

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
        pdo \
        pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Moodle
WORKDIR /tmp
RUN if [ "$MOODLE_VERSION" = "latest" ]; then \
        MOODLE_VERSION=$(curl -L https://download.moodle.org/api/1.0/ /latest/ | grep -oP '(?<=filename=")[^"]*(?=")') \
    fi && \
    curl -o moodle.zip -L https://download.moodle.org/download.php/direct/stable$MOODLE_VERSION && \
    unzip moodle.zip -d $MOODLE_HOME && \
    mv $MOODLE_HOME/moodle/* $MOODLE_HOME && \
    rm moodle.zip && \
    chown -R www-data:www-data $MOODLE_HOME && \
    chmod -R 777 $MOODLE_HOME

# Set up Moodle data directory
RUN mkdir $MOODLE_HOME/data \
    && chown -R www-data:www-data $MOODLE_HOME \
    && chmod -R 777 $MOODLE_HOME

# Expose port 80 and start Apache
EXPOSE 80
CMD ["apache2-foreground"]
