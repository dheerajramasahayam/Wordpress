#!/bin/bash

# Install the basic updates
sudo apt update

# Install the necessary dependencies
sudo apt install apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip


# Let's start setting up wordpress

sudo mkdir -p /srv/www

sudo chown www-data: /srv/www

curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

sudo cp wordpress.conf /etc/apache2/sites-available/

sudo a2ensite wordpress

sudo a2enmod rewrite

sudo a2dissite 000-default

sudo service apache2 reload

#Setting up database for wordpress

sudo mysql -u root <<EOF

CREATE DATABASE wordpress;
CREATE USER wordpress@localhost IDENTIFIED BY 'hasherbro';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER
ON wordpress.*
TO wordpress@localhost;
FLUSH PRIVILEGES;
quit

EOF

sudo service mysql start

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/hasherbro/' /srv/www/wordpress/wp-config.php

FILE="/srv/www/wordpress/wp-config.php"

# Generate new keys with 64-character length and similar complexity
NEW_AUTH_KEY=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/~`' < /dev/urandom | fold -w64 | head -n1)
NEW_SECURE_AUTH_KEY=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/~`' < /dev/urandom | fold -w64 | head -n1)
NEW_LOGGED_IN_KEY=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/~`' < /dev/urandom | fold -w64 | head -n1)
NEW_NONCE_KEY=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/~`' < /dev/urandom | fold -w64 | head -n1)
NEW_AUTH_SALT=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/~`' < /dev/urandom | fold -w64 | head -n1)
NEW_SECURE_AUTH_SALT=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/~`' < /dev/urandom | fold -w64 | head -n1)
NEW_LOGGED_IN_SALT=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/~`' < /dev/urandom | fold -w64 | head -n1)
NEW_NONCE_SALT=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/~`' < /dev/urandom | fold -w64 | head -n1)


# Backup original file before editing
sudo -u www-data cp "$FILE" "${FILE}.bak"

# Delete old keys
sudo -u www-data sed -i '/AUTH_KEY/d' "$FILE"
sudo -u www-data sed -i '/SECURE_AUTH_KEY/d' "$FILE"
sudo -u www-data sed -i '/LOGGED_IN_KEY/d' "$FILE"
sudo -u www-data sed -i '/NONCE_KEY/d' "$FILE"
sudo -u www-data sed -i '/AUTH_SALT/d' "$FILE"
sudo -u www-data sed -i '/SECURE_AUTH_SALT/d' "$FILE"
sudo -u www-data sed -i '/LOGGED_IN_SALT/d' "$FILE"
sudo -u www-data sed -i '/NONCE_SALT/d' "$FILE"

#Add new keys to the file
cat <<EOF | sudo -u www-data tee -a "$FILE"
define( 'AUTH_KEY',         '$NEW_AUTH_KEY');
define( 'SECURE_AUTH_KEY',  '$NEW_SECURE_AUTH_KEY');
define( 'LOGGED_IN_KEY',    '$NEW_LOGGED_IN_KEY');
define( 'NONCE_KEY',        '$NEW_NONCE_KEY');
define( 'AUTH_SALT',        '$NEW_AUTH_SALT');
define( 'SECURE_AUTH_SALT', '$NEW_SECURE_AUTH_SALT');
define( 'LOGGED_IN_SALT',   '$NEW_LOGGED_IN_SALT');
define( 'NONCE_SALT',       '$NEW_NONCE_SALT');
EOF