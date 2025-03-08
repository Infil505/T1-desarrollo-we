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
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar los archivos del proyecto Laravel
COPY . /var/www/html

# Definir el directorio de trabajo
WORKDIR /var/www/html

# Asignar permisos correctos a Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Exponer el puerto 80
EXPOSE 80

# Iniciar el servidor Apache
CMD ["apache2-foreground"]
