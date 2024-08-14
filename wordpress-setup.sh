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

cp wordpress.conf /etc/apache2/sites-available/

sudo a2ensite wordpress

sudo a2enmod rewrite

sudo a2dissite 000-default

sudo service apache2 reload

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

# Temporary placeholder for new values
NEW_AUTH_KEY=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w32 | head -n1)
NEW_SECURE_AUTH_KEY=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w32 | head -n1)
NEW_LOGGED_IN_KEY=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w32 | head -n1)
NEW_NONCE_KEY=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w32 | head -n1)
NEW_AUTH_SALT=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w16 | head -n1)
NEW_SECURE_AUTH_SALT=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w16 | head -n1)
NEW_LOGGED_IN_SALT=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w16 | head -n1)
NEW_NONCE_SALT=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w16 | head -n1)

# Backup original file before editing
sudo -u www-data cp "$FILE" "${FILE}.bak"

# Edit the file by deleting old keys and adding new ones
sed -i '/define\( 'AUTH_KEY',/d' "$FILE"
echo "define( 'AUTH_KEY',         '$NEW_AUTH_KEY');" >> "$FILE"
sed -i '/define\( 'SECURE_AUTH_KEY',/d' "$FILE"
echo "define( 'SECURE_AUTH_KEY',  '$NEW_SECURE_AUTH_KEY');" >> "$FILE"
sed -i '/define\( 'LOGGED_IN_KEY',/d' "$FILE"
echo "define( 'LOGGED_IN_KEY',    '$NEW_LOGGED_IN_KEY');" >> "$FILE"
sed -i '/define\( 'NONCE_KEY',/d' "$FILE"
echo "define( 'NONCE_KEY',        '$NEW_NONCE_KEY');" >> "$FILE"
sed -i '/define\( 'AUTH_SALT',/d' "$FILE"
echo "define( 'AUTH_SALT',        '$NEW_AUTH_SALT');" >> "$FILE"
sed -i '/define\( 'SECURE_AUTH_SALT',/d' "$FILE"
echo "define( 'SECURE_AUTH_SALT', '$NEW_SECURE_AUTH_SALT');" >> "$FILE"
sed -i '/define\( 'LOGGED_IN_SALT',/d' "$FILE"
echo "define( 'LOGGED_IN_SALT',   '$NEW_LOGGED_IN_SALT');" >> "$FILE"
sed -i '/define\( 'NONCE_SALT',/d' "$FILE"
echo "define( 'NONCE_SALT',       '$NEW_NONCE_SALT');" >> "$FILE"


