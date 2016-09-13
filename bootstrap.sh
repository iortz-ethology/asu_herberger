#!/usr/bin/env bash

# sync pantheon files: http://helpdesk.getpantheon.com/customer/portal/articles/1341538-local-development-setup-and-operation
# Bring Files Down:
# drush @pantheon.forward-air-dev.dev cc all --strict=0
# drush -r . rsync @pantheon.forward-air-dev.dev:%files @self:sites/default/
# Get Database
# drush sql-sync-pipe @pantheon.forward-air-dev.dev @self --progress
# Get Code
#
# UPLOAD:
# drush cc all
# drush sql-dump --gzip --result-file=/assets/environ/dbbackup/db_forward_air_dev.sql
# # Upload db file to site using ui
# # Files:
# drush -r . rsync @self:sites/default/files/ @pantheon.forward-air.dev:%files
#
# Permissions
# sudo chown -R www-data:www-data /www/$WWW_DIR
# sudo chmod -R 777 /www/$WWW_DIR
#
# Note: good testing of events import at 14,200 items


# TERMINUS
#	terminus site backup create --element=database --site=forward-air --env=dev
#	terminus site backup get --element=database --site=forward-air --env=dev --to-directory=$HOME/dbbackup --latest
#	gunzip < database.sql.gz | mysql -uroot -pForwardair4u forward_air_drupal_web
#
#	Speed up the db: Add the following settings to /etc/mysql/my.cnf below [mysqld]
# 	innodb_buffer_pool_size=2M
#	innodb_additional_mem_pool_size=500K
#	innodb_log_buffer_size=500K
#	innodb_thread_concurrency=2
#	innodb_flush_log_at_trx_commit=0
#
#temp:
# $image_link = parse_url($image_link, PHP_URL_PATH);
#
# command line debug
# export XDEBUG_CONFIG="idekey=sonosdebug"

# url pattern skip words:
# a, an, as, at, before, but, by, for, from, is, in, into, like, of, off, on, onto, per, since, than, the, this, that, to, up, via, with

# modules
# drush dl admin_menu_source apachesolr apachesolr_views bean bean_pane bundle_clone bundle_copy chartbeat computed_field
# content_lock editableviews elysia_cron facetapi field_collection field_permissions field_validation fuzzysearch globalredirect
# iframe jquery_update kwresearch manualcrop masquerade menu_attributes menu_css_names metatag migrate migrate_d2d modules_weight
# og og_vocab prev_next redirect redis remove_duplicates search_api_solr smart_trim smtp special_menu_items taxonomy_access_fix
# taxonomy_autocomplete_permission taxonomy_machine_name themekey view_unpublished views_datasource workbench workbench_og workbench_moderation
# workbench_scheduler workbench_email xmlsitemap

#zend_extension="/usr/lib/php5/20121212/xdebug.so"
#xdebug.default_enable = 1
#xdebug.idekey = "sonosdebug"
#xdebug.remote_enable = 1
#xdebug.remote_autostart = 0
#xdebug.remote_port = 9000
#xdebug.remote_handler=dbgp
#xdebug.remote_log="/var/log/xdebug/xdebug.log"
#xdebug.remote_host=192.168.19.1 ; IDE-Environments IP, from vagrant box.

# rebuild | restore
CONFIG="restore"
echo "Here we go!"

echo "Setting variables --------------------------------------------------------------------------"
# install node and git
MYSQL_PW="Herberger4u"
MYSQL_DRUPAL_PW="Herberger4u"
MYSQL_DRUPAL_PW_URL="Herberger4u"
DRUPAL_PW="Herberger4u!"
SITENAME="asu_hereberger"
URL="dev.asu_hereberger.local"
SSLPORT=443
WWW_DIR="drupal"
ENVIRON_PATH="/www/drupal/assets/environ"

sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $MYSQL_PW"
sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $MYSQL_PW"

echo "Installing packages --------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y nodejs npm git-core make apache2 mysql-server-5.5 drush libapache2-mod-auth-mysql libapache2-mod-php5 php5 php-pear php5-gd php5-mysql php5-curl php5-cli php5-cgi php5-dev zip unzip redis-server

#include glances
sudo apt-get install -y glances

#install xdebug
pecl install xdebug

#install terminus
sudo curl https://github.com/pantheon-systems/cli/releases/download/0.7.1/terminus.phar -L -o /usr/local/bin/terminus && sudo chmod +x /usr/local/bin/terminus

echo "Configure PHP debug --------------------------------------------------------------------------"
#Configure PHP debugging
echo "zend_extension=\"/usr/lib/php5/20121212/xdebug.so\"" | sudo tee -a /etc/php5/apache2/php.ini
echo "xdebug.default_enable = 1" | sudo tee -a /etc/php5/apache2/php.ini
echo "xdebug.idekey = \"vagrant\"" | sudo tee -a /etc/php5/apache2/php.ini
echo "xdebug.remote_enable = 1" | sudo tee -a /etc/php5/apache2/php.ini
echo "xdebug.remote_autostart = 0" | sudo tee -a /etc/php5/apache2/php.ini
echo "xdebug.remote_port = 9000" | sudo tee -a /etc/php5/apache2/php.ini
echo "xdebug.remote_handler=dbgp" | sudo tee -a /etc/php5/apache2/php.ini
echo "xdebug.remote_log=\"/var/log/xdebug/xdebug.log\"" | sudo tee -a /etc/php5/apache2/php.ini
echo "xdebug.remote_host=10.0.2.2 ; IDE-Environments IP, from vagrant box." | sudo tee -a /etc/php5/apache2/php.ini

echo "Build and Install Redis --------------------------------------------------------------------------"

# Set PHP memory limit to 256M
sudo sed -i "s/memory_limit = 128M/memory_limit = 256M/g" /etc/php5/apache2/php.ini

############################
# CONFIGURE PHP REDIS
############################
sudo apt-get install -y php5-redis
sudo /etc/init.d/apache2 restart

echo "Set up Varnish --------------------------------------------------------------------------"
############################
# SET UP VARNISH
############################
# https://ohthehugemanatee.org/2011/05/complete-drupal-cache-serving-http-and.html/
# user /etc/default/varnish to set DAEMON_OPTS
sudo apt-get -y install varnish

sudo sed -i "s/\([\s|\t]*Listen\).*/\1 8080/" /etc/apache2/ports.conf
# sudo sed -i "s/\([\s|\t]*Listen[\s|\t]*443\).*/\1 4430/" /etc/apache2/ports.conf
sudo a2dissite 000-default
# set daemon opts for varnish
sudo mv /etc/default/varnish /etc/default/varnish.bak
sudo cp ${ENVIRON_PATH}/varnishconfig/drupal.vcl /etc/varnish/
sudo cp ${ENVIRON_PATH}/varnishconfig/varnish /etc/default/
# sudo sed -i 's/DAEMON_OPTS="-a :6081 \\/DAEMON_OPTS="-a :80 \\/g' /etc/default/varnish
# sudo sed -i 's/-f \/etc\/varnish\/default.vcl \\/-f \/etc\/varnish\/drupal.vcl \\/g' /etc/default/varnish

sudo /etc/init.d/varnish restart

############################
# SET UP POUND / SSL
# See https://ohthehugemanatee.org/2011/05/complete-drupal-cache-serving-http-and.html/
############################
echo "Create SSL Development Cert--------------------------------------------------------------------------"
sudo mkdir /cert
cd /cert
sudo openssl req -new -newkey rsa:4096 -nodes -keyout $URL.private.key -out $URL.certreq.pem \
	-subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=$URL"
sudo openssl x509 -req -days 365 -in $URL.certreq.pem -signkey $URL.private.key -out $URL.crt
sudo cp $URL.crt /etc/ssl/certs
# sudo cp $URL.pem /etc/ssl/certs
sudo cp $URL.private.key /etc/ssl/private

# Concatenate certs into a single file
sudo openssl x509 -in /etc/ssl/certs/$URL.crt -out /etc/ssl/private/$URL.combined.pem
sudo bash -c "openssl rsa -in /etc/ssl/private/$URL.private.key >> /etc/ssl/private/$URL.combined.pem"

#sudo openssl x509 -in /etc/ssl/certs/$URL.crt -out /cert/$URL.combined.pem
#sudo bash -c "openssl rsa -in /cert/$URL.private.key >> /cert/$URL.combined.pem"
#sudo cp /cert/$URL.combined.pem /etc/ssl/private

echo "Set Up Pound / SSL Support --------------------------------------------------------------------------"
sudo apt-get -y install pound
sudo mv /etc/pound/pound.cfg /etc/pound/pound.cfg.bkp
sudo cp ${ENVIRON_PATH}/poundconfig/pound.cfg /etc/pound/
sudo sed -i "s/Port[\s|\t]*\[sslport\]/Port $SSLPORT/g" /etc/pound/pound.cfg
sudo sed -i "s/Cert[\s|\t]* \"\[certpath\]\"/Cert \"\/etc\/ssl\/private\/$URL.combined.pem\"/g" /etc/pound/pound.cfg
sudo sed -i "s/startup=0/startup=1/g" /etc/default/pound

# exit

# Install sass and compass
# sudo apt-get install -y ruby
# sudo gem update
# sudo gem install -y sass
# sudo gem install -y compass

echo "Enable apache modules --------------------------------------------------------------------------"

sudo a2enmod php5
sudo a2enmod rewrite

############################
# INSTALL MYSQL
############################
echo "Install MySQL --------------------------------------------------------------------------"

echo "check mysql password"

MYSQL_PW_COMMANDLINE="-p$MYSQL_PW"


# create database
echo "Create Database ${SITENAME}_drupal_web "
mysql -u root $MYSQL_PW_COMMANDLINE -e "CREATE DATABASE ${SITENAME}_drupal_web;"

#configure sql users
echo "configure sql users - Drupal User"
mysql -u root $MYSQL_PW_COMMANDLINE -e "CREATE USER 'drupaluser'@'%' identified by '$MYSQL_DRUPAL_PW';"
mysql -u root $MYSQL_PW_COMMANDLINE -e "GRANT ALL PRIVILEGES ON *.* TO 'drupaluser'@'%';"

echo "configure sql users - bgronek"
mysql -u root $MYSQL_PW_COMMANDLINE -e "CREATE USER 'bgronek'@'%' identified by 'a1k0a1k0;';"
mysql -u root $MYSQL_PW_COMMANDLINE -e "GRANT ALL PRIVILEGES ON *.* TO 'bgronek'@'%' WITH GRANT OPTION;"

echo "configure sql users - bgronek"
mysql -u root $MYSQL_PW_COMMANDLINE -e "CREATE USER 'bgronek'@'%' identified by 'a1k0a1k0;';"
mysql -u root $MYSQL_PW_COMMANDLINE -e "GRANT ALL PRIVILEGES ON *.* TO 'bgronek'@'%' WITH GRANT OPTION;"

if [ "$CONFIG" == "restore" ]
then
# RESTORE DB FROM BACKUP
echo "Restore DB from backup"
mysql -u root $MYSQL_PW_COMMANDLINE --database ${SITENAME}_drupal_web < ${ENVIRON_PATH}/dbbackup/${SITENAME}_drupal_web.sql
fi

#mysql -u root vjV22m8Ar < /assets/environ/dbbackup/asu_uto_drupal_web.sql
#mysql -u root -pHerberger4u --database asu_hereberger_drupal_web < /www/drupal/sites/dev-environment/assets/environ/dbbackup/asu_hereberger_drupal_web.sql

# set up for external access
echo "Set mysql bind address"
sudo sed -i "s/\(bind-address[\s|\t]*=[\s|\t]*\).*/\1 0\.0\.0\.0/" /etc/mysql/my.cnf

echo "Restart mysql."
sudo /etc/init.d/mysql restart

############################
# INSTALL DRUPAL
############################
echo "Install Drupal --------------------------------------------------------------------------"

sudo cp ${ENVIRON_PATH}/apacheconfig/drupal.conf /etc/apache2/sites-available
sudo ln -s /etc/apache2/sites-available/drupal.conf /etc/apache2/sites-enabled/drupal.conf

# if [ "$CONFIG" == "rebuild"]
# then
# cd /www
# sudo drush dl drupal --destination=/www --drupal-project-rename=$WWW_DIR -y

# sudo chown -R www-data:www-data /www/$WWW_DIR
# sudo chmod -R 777 /www/$WWW_DIR

# service apache2 restart

# sudo /etc/init.d/apache2 restart
# fi

cd /www/$WWW_DIR

if [ "$CONFIG" == "rebuild" ]
then
sudo drush site-install standard --account-name=admin --account-pass=$DRUPAL_PW --db-url=mysql://drupaluser:$MYSQL_DRUPAL_PW_URL@127.0.0.1/${SITENAME}_drupal_web -y
fi

echo "Install clean url's --------------------------------------------------------------------------"
############################
# Install and configure modules / Zen
############################
#enable clean url's
drush vset clean_url 1 --yes

if [ "$CONFIG" == "rebuild" ]
then
# IF REBUILDING FROM SCRATCH, ENABLE MODULES
# sudo drush -y en admin_devel admin_menu admin_menu_toolbar module_filter ctools ctools_custom_content page_manager views_content clean_markup_blocks clean_markup clean_markup_panels block color comment contextual dashboard dblog field field_sql_storage field_ui file filter help image list menu node number options overlay path rdf search shortcut system taxonomy text user devel ds ds_devel ds_extras ds_forms ds_search ds_ui features uuid_features entityreference imce advanced_help angularjs entity image_url_formatter libraries menu_block pathauto token panels_mini panels_node panelizer panels panels_ipe ckeditor jquery_update uuid views views_ui

sudo drush dl admin_devel admin_menu ctools views panels panelizer libraries menu_block jquery_update module_filter features redis

sudo drush -y en admin_devel admin_menu ctools views panels panelizer libraries menu_block jquery_update module_filter features redis admin_menu_toolbar

sudo drush dis -y toolbar

fi

##########################
# INSTALL SOLR
##########################
#sudo apt-get -y install openjdk-7-jdk
#sudo mkdir /usr/java
#sudo ln -s /usr/lib/jvm/java-7-openjdk-amd64 /usr/java/default
#sudo apt-get -y install solr-tomcat

sudo /etc/init.d/varnish restart
sudo /etc/init.d/pound restart
sudo /etc/init.d/apache2 restart

######################
# AFTER EXECUTION:
#	cp /assets/environ/pantheon.aliases.drushrc.php ~/.drush
# 1. Set redis module configuration.
######################


######################
# RESOURCES
######################
# Redis Config: http://www.techknowjoe.com/article/redis-drupal - replace phpredis
# List enabled modules
# echo $(sudo drush pm-list --type=Module --status=enabled --no core --pipe)
