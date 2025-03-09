# Usa la imagen oficial de PHP con Apache
FROM php:8.4-apache

# Establecer ServerName para suprimir la advertencia
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

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

# Copiar el archivo .env si lo tienes
# (Descomenta la siguiente línea si tienes un archivo .env que quieras copiar al contenedor)
COPY .env /var/www/html/.env

# Definir el directorio de trabajo
WORKDIR /var/www/html

# Instalar las dependencias de Composer
RUN composer install --no-dev --optimize-autoloader --prefer-dist

# Asegurarse de que Apache sirva desde la carpeta 'public' y que .htaccess esté funcionando
RUN cp /var/www/html/public/.htaccess /var/www/html/.htaccess

# Asignar permisos correctos a Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Verificar las rutas en `web.php` y registrar en los logs si hay problemas
RUN php -r "if (!file_exists('/var/www/html/routes/web.php')) { file_put_contents('/var/www/html/storage/logs/error.log', 'Routes file web.php is missing.\n', FILE_APPEND); exit(1); }"

# Exponer el puerto 80
EXPOSE 80

# Comando para iniciar Apache y manejar el proceso
CMD ["sh", "-c", "apache2-foreground || echo 'Apache failed to start' >> /var/www/html/storage/logs/error.log && exit 1"]
