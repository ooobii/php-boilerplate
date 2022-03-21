#!/bin/bash

export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
export DEBIAN_FRONTEND=noninteractive

ROOT_DIR="/vagrant"

if [ ! -f "${ROOT_DIR}/.env" ]; then
    >&2 echo "File ${ROOT_DIR}/.env must exist to provision this box!"
    exit 1
fi
export $(egrep -v '^#' ${ROOT_DIR}/.env | xargs)

echo "******************* Adding PHP repository... ******************"
add-apt-repository -y --no-update ppa:ondrej/php

echo "**************** Adding Postgres repository... ****************"
curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

echo "***************** Refreshing apt sources... *******************"
apt-get update

echo "********* Update and upgrade base system packages... **********"
apt-get upgrade -y

echo "*********** Perge unused packages after upgrade... ************"
apt-get autoremove --purge

echo "**************** Installing basic packages... *****************"
apt-get install -y \
    nano \
    vim \
    bash-completion \
    wget \
    curl \
    zip \
    unzip \
    tree \
    mlocate \
    net-tools \
    wget \
    cifs-utils \
    nfs-kernel-server \
    software-properties-common \
    git

#configure git
echo "********************* Configuring Git... *********************"
git config --global user.name "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"

echo "***************** Installing PHP & Apache... *****************"
apt-get install -y \
    apache2 \
    openssl \
    php${PHP_VERSION}\
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-odbc \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-xdebug \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip

echo "******************* Installing Composer... *******************"
curl https://getcomposer.org/installer --output composer-install.php
chmod +x composer-install.php
php composer-install.php --install-dir="/bin" --filename=composer


echo "******************* Installing Postgres... *******************"
apt-get install -y postgresql-10 postgresql-client-10

#stop postgres
echo "********** Updating Postgres connection settings... **********"
{
PGSQL_CONF=$(find /etc/postgresql -name "postgresql.conf")
PGSQL_HBA=$(find /etc/postgresql -name "pg_hba.conf")
echo "listen_addresses = '*'			# what IP address(es) to listen on;"        | tee -a $PGSQL_CONF
echo "host    all             all              0.0.0.0/0                       md5" | tee -a $PGSQL_HBA
echo "host    all             all              ::/0                            md5" | tee -a $PGSQL_HBA
} &> /dev/null

echo "******************* Restarting Postgres... *******************"
systemctl restart postgresql

echo "************ Creating Database User & Catalogs... ************"
sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH SUPERUSER PASSWORD '${DB_PASS}';"
sudo -u postgres psql -c "CREATE DATABASE \"${DB_NAME}\";"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"${DB_NAME}\" TO ${DB_USER};"


echo "************ Copying Apache site configuration... ************"
cp ${ROOT_DIR}/build/site.conf /etc/apache2/sites-available/

echo "******* Injecting URL into Apache site configuration... ******"
cat <<< "Define URL_SITE $SITE_URL
$(cat /etc/apache2/sites-available/site.conf)
" > /etc/apache2/sites-available/site.conf

echo "******** Enable Apache modules & site configuration... *******"
a2enmod rewrite
a2enmod headers 
a2ensite site
a2dissite 000-default
sudo chmod -R 0777 /var/www/code

echo "******************** Restarting Apache... ********************"
systemctl restart apache2
systemctl enable apache2


