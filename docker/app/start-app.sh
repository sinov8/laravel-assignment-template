#!/bin/sh

# Run migrations if any
cd /var/www/html

# Maintenance Mode
# php artisan down --secret=1630542a-246b-4b66-afa1-dd72a4c43515 --render=errors.503

# Set cache
php artisan route:cache
php artisan config:cache
php artisan event:cache
php artisan view:cache

mv /tmp/supervisord-app.conf /etc/supervisor/conf.d/supervisord.conf

# Start supervisor
/usr/bin/supervisord
