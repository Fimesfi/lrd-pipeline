#!/bin/bash

# Aja tietokantamigraatiot pakotetusti
php artisan migrate --force

# Tyhjennä välimuistit ja päivitä ne
php artisan cache:clear
php artisan auth:clear-resets
php artisan route:cache
php artisan config:cache
php artisan view:cache

# Käynnistä jonotyöntekijät uudelleen
php artisan queue:restart

# Tyhjennä aikataulut ja käynnistä ne uudelleen
php artisan schedule:clear-cache

# Käynnistä Nginx ja PHP-FPM, jos niitä käytetään
supervisorctl restart queue-worker:*
service restart apache2

# Suorita Apache foreground-moodissa
exec apache2-foreground