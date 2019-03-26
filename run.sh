#!/bin/sh
apt-get install apache2 -y
echo "Apache Server" > /var/www/html/index.html
systemctl restart apache2
