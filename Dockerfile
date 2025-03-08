# Usa la imagen oficial de PHP con Apache
FROM php:8.4-apache

# Habilitar mod_rewrite para Laravel y establecer DocumentRoot en /public
RUN a2enmod rewrite \
    && sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Instalar extensiones necesarias para Laravel (sin MySQL)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mbstring

# Instalar Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copiar los archivos del proyecto Laravel
COPY . /var/www/html

# Definir el directorio de trabajo
WORKDIR /var/www/html

# Instalar las dependencias de Composer
RUN composer install --no-dev --optimize-autoloader

# Asignar permisos correctos a Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Exponer el puerto 80
EXPOSE 80

# Iniciar el servidor Apache
CMD ["apache2-foreground"]
