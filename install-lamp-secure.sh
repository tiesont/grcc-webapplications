#!/bin/bash
# Update the package list
echo "Updating the package list..."
sudo yum update -y

echo "Preparing to install Web Services (this may take a few minutes)..."
read -p "Press [Enter] to begin the installation process or Q to quit: " -n 1 -r choice
if [[ $choice =~ ^[Qq]$ ]]; then
    echo "Exiting..."
    exit 0
fi
sleep 3

# Install MariaDB server (MariaDB 10.5)
echo "Installing MariaDB server..."
sudo amazon-linux-extras install -y mariadb10.5
echo "MariaDB server installed."

# Install php (php 8.2)
echo "Installing php v8.2..."
sudo amazon-linux-extras install -y php8.2
echo "php installed."

# Install httpd (Apache) web server
echo "Installing httpd..."
sudo yum install -y httpd
echo "httpd installed."

# Start the httpd (Apache) service
echo "Starting httpd..."
sudo systemctl start httpd
echo "httpd started."

# Enable httpd (Apache) to start on boot
echo "Enabling httpd to start on boot..."
sudo systemctl enable httpd
echo "httpd enabled to start on boot."

# Test httpd (Apache) service
echo "Testing httpd..."
sudo systemctl is-enabled httpd

echo "LAMP server installed."

# Set file permissions
echo "Setting file permissions..."
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
find /var/www -type f -exec sudo chmod 0664 {} \;
echo "Permissions set."

# Encrypt the Connection with Certificate Automation: Let's Encrypt with Certbot on Amazon Linux 2
echo "Visit http://your_domain.tld to test your server. If your server is working, you can proceed to the next step. If not, please check your DNS entries. If you recently updated your DNS entries, you may need to wait a few minutes before you can test your server. You may need to test this on your phone's cell connection to ensure it's not a caching issue."
read -p "Press [Enter] to continue the installation process or Q to quit: " -n 1 -r choice
if [[ $choice =~ ^[Qq]$ ]]; then
    echo "You can re-run this script to continue without issues once your DNS entries have propogated."
    echo "It will try to reinstall the MariaDB, php, and Apache services, but this should be a harmless operation."
    exit 0
fi

echo -e "\nIn the next step, you will be asked to enter your domain name for the script to use during the installation process and creation of the virtual hosts files.\n"
echo -e "You will also be asked to enter your email address which will be used to create your SSL certificate, accept the Terms of Service, then optionally be added to the Electronic Frontier Foundation (EFF) mailing list.\n"
read -p "Press [Enter] to begin: "

# Install Certbot
echo "Installing Certbot..."
sudo amazon-linux-extras install epel -y
sudo yum install certbot-apache -y
echo "Certbot installed."

# Setup Domain host directories
echo "Creating the directories for your web server..."

echo "Be sure to include the top-level domain (TLD).
Example: google.com NOT google or www.google.com"
read -p "Enter the domain name you are using: " your_domain
echo -e "\n"$your_domain" will be used to create your web server."

sudo mkdir -p /var/www/$your_domain/html
echo "/var/www/"$your_domain"/html created."

sudo mkdir -p /var/www/$your_domain/log
echo "/var/www/"$your_domain"/log created"

echo "Creating new index.html file..."
sudo chown -R ec2-user:apache /var/www/$your_domain/
sudo chmod -R 755 /var/www/$your_domain/
touch /var/www/$your_domain/html/index.html
echo '<html>
  <head>
  <title>Welcome to your website!</title>
  </head>
  <body>
  <h1>Success! The '$your_domain' virtual host is working!</h1>
  </body>
</html>' >> /var/www/$your_domain/html/index.html
echo "index.html file created."

echo -e "\nYour HTML files will be located in /var/www/"$your_domain"/html"
echo "Copy this location for future reference."
read -p "Press [ENTER] to continue: "

echo "Creating folders for the virtual hosts..."
set -v
sudo mkdir /etc/httpd/sites-available
sudo mkdir /etc/httpd/sites-enabled
set +v
echo "Folders created."
sleep 1

echo "Updating httpd.conf..."
echo "IncludeOptional sites-enabled/*.conf" | sudo tee -a /etc/httpd/conf/httpd.conf
echo "httpd.conf has been updated."
sleep 1

echo "Creating /etc/httpd/sites-available/"$your_domain".conf..."
sudo touch /etc/httpd/sites-available/$your_domain.conf

echo '<VirtualHost *:80>
    ServerName www.'$your_domain'
    ServerAlias '$your_domain'
    DocumentRoot /var/www/'$your_domain'/html
    ErrorLog /var/www/'$your_domain'/log/error.log
    CustomLog /var/www/'$your_domain'/log/requests.log combined
</VirtualHost>' | sudo tee -a /etc/httpd/sites-available/$your_domain.conf

cat /etc/httpd/sites-available/$your_domain.conf

echo $your_domain".conf has been created."
sleep 1

echo "Creating symlink..."
sudo ln -s /etc/httpd/sites-available/$your_domain.conf /etc/httpd/sites-enabled/$your_domain.conf
echo "Symlink created."

sleep 3

# Complete Certbot Setup
sudo certbot --apache -d $your_domain

echo "Restarting Apache..."
sudo systemctl restart httpd
echo -e "Apache restarted.\n"

echo "Done. Visit https://www.ssllabs.com/ssltest/analyze.html?d="$your_domain" to test your SSL certificate."
read -p "Press [ENTER] to continue: "

# Secure the Database & Restart MariaDB
echo "Preparing the database for phpMyAdmin..."
sleep 3
echo "Securing the database..."
sudo systemctl start mariadb
sudo mysql_secure_installation
echo "MariaDB is now secure."
sleep 1

echo "Enabling MariaDB to start on boot..."
sudo systemctl enable mariadb
sudo systemctl is-enabled httpd

echo "Restarting MariaDB..."
sudo systemctl restart mariadb
echo "MariaDB restarted."
sleep 1

# Install phpMyAdmin
echo "Preparing to install phpMyAdmin..."
sleep 3
echo "Installing phpMyAdmin..."
sudo yum install php-mbstring php-xml -y
echo "phpMyAdmin installed."
sleep 1

echo "Restarting Services..."
sudo systemctl restart httpd
echo "Apache restarted."

sudo systemctl restart php-fpm
echo "php-FPM restarted."

echo "Preparing to download phpMyAdmin (this may take a few minutes)..."
sleep 3
echo "Downloading phpMyAdmin..."
cd /var/www/$your_domain/html

wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz

echo "Installing phpMyAdmin..."
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1

echo "phpMyAdmin installed."
echo "Cleaning up..."
rm phpMyAdmin-latest-all-languages.tar.gz

sudo systemctl start mariadb
cd ~

echo "Installation of your web server with php service is now complete."
echo "Visit https://"$your_domain"/phpMyAdmin to login."
