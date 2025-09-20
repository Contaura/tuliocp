#!/bin/bash

# Function Description
# Manual upgrade script from Nginx + Apache2 + PHP-FPM to Nginx + PHP-FPM

#----------------------------------------------------------#
#                    Variable&Function                     #
#----------------------------------------------------------#

# Includes
# shellcheck source=/etc/tuliocp/tulio.conf
source /etc/tuliocp/tulio.conf
# shellcheck source=/usr/local/tulio/func/main.sh
source $TULIO/func/main.sh
# shellcheck source=/usr/local/tulio/conf/tulio.conf
source $TULIO/conf/tulio.conf

#----------------------------------------------------------#
#                    Verifications                         #
#----------------------------------------------------------#

if [ "$WEB_BACKEND" != "php-fpm" ]; then
	check_result $E_NOTEXISTS "PHP-FPM is not enabled" > /dev/null
	exit 1
fi

if [ "$WEB_SYSTEM" != "apache2" ]; then
	check_result $E_NOTEXISTS "Apache2 is not enabled" > /dev/null
	exit 1
fi

#----------------------------------------------------------#
#                       Action                             #
#----------------------------------------------------------#

# Remove apache2 from config
sed -i "/^WEB_PORT/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
sed -i "/^WEB_SSL/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
sed -i "/^WEB_SSL_PORT/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
sed -i "/^WEB_RGROUPS/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
sed -i "/^WEB_SYSTEM/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf

# Remove nginx (proxy) from config
sed -i "/^PROXY_PORT/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
sed -i "/^PROXY_SSL_PORT/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
sed -i "/^PROXY_SYSTEM/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf

# Add Nginx settings to config
echo "WEB_PORT='80'" >> $TULIO/conf/tulio.conf
echo "WEB_SSL='openssl'" >> $TULIO/conf/tulio.conf
echo "WEB_SSL_PORT='443'" >> $TULIO/conf/tulio.conf
echo "WEB_SYSTEM='nginx'" >> $TULIO/conf/tulio.conf

# Add Nginx settings to config
echo "WEB_PORT='80'" >> $TULIO/conf/defaults/tulio.conf
echo "WEB_SSL='openssl'" >> $TULIO/conf/defaults/tulio.conf
echo "WEB_SSL_PORT='443'" >> $TULIO/conf/defaults/tulio.conf
echo "WEB_SYSTEM='nginx'" >> $TULIO/conf/defaults/tulio.conf

rm $TULIO/conf/defaults/tulio.conf
cp $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf

# Rebuild web config

for user in $($BIN/v-list-users plain | cut -f1); do
	echo $user
	for domain in $($BIN/v-list-web-domains $user plain | cut -f1); do
		$BIN/v-change-web-domain-tpl $user $domain 'default'
		$BIN/v-rebuild-web-domain $user $domain no
	done
done

systemctl restart nginx
