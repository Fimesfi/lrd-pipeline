FROM php:8.3-apache

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP-extensions ja Composer
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    supervisor \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy app
COPY . /var/www/html

COPY ./docker/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod u+x /usr/local/bin/entrypoint \
    && a2enmod rewrite

# Allow Laravel logs
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

RUN composer install --no-interaction --optimize-autoloader
RUN a2ensite 000-default.conf

RUN php artisan key:generate

EXPOSE 80

CMD ["/usr/local/bin/entrypoint"]