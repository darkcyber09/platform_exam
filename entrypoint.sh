#!/bin/bash
set -e

echo "Migrating..."
php bin/console doctrine:migrations:migrate --env=prod --no-interaction --allow-no-migration

echo "Starting PHP-FPM..."
php-fpm -F &

# A short sleep is fine to let FPM bind to its socket/port
sleep 2 

echo "Starting Nginx..."
nginx -g "daemon off;" &

# Wait for ANY of the background processes to exit
wait -n

# If we reach this point, either Nginx or PHP-FPM has crashed.
echo "A critical process crashed. Exiting..."
exit 1