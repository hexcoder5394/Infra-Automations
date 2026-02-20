#!/bin/bash

apt-get update

#install nginx

apt-get install -y nginx

#custom webpage to display the VMs name

echo "<html><body><h1 style='color:blue;'>Welcome to the Web Tier!</h1>" > /var/www/html/index.html\
echo "<h2>Served by VM: $(hostname)</h2></body></html>" >> /var/www/html/index.html

#start nginx

systemctl enable nginx
systemctl start nginx

