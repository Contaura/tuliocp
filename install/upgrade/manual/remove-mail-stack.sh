#!/bin/bash

# Function Description
# Soft remove the mail stack

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

echo "This will soft remove the mail stack from TulioCP and disable related systemd service."
echo "You won't be able to access mail related configurations from TulioCP."
echo "Your existing mail data and apt packages will be kept back."
read -p 'Would you like to continue? [y/n]'

#----------------------------------------------------------#
#                       Action                             #
#----------------------------------------------------------#

if [ "$ANTISPAM_SYSTEM" == "spamassassin" ]; then
	echo Removing Spamassassin
	sed -i "/^ANTISPAM_SYSTEM/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
	systemctl disable --now spamassassin
fi

if [ "$ANTIVIRUS_SYSTEM" == "clamav-daemon" ]; then
	echo Removing ClamAV
	sed -i "/^ANTIVIRUS_SYSTEM/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
	systemctl disable --now clamav-daemon clamav-freshclam
fi

if [ "$IMAP_SYSTEM" == "dovecot" ]; then
	echo Removing Dovecot
	sed -i "/^IMAP_SYSTEM/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
	systemctl disable --now dovecot
fi

if [ "$MAIL_SYSTEM" == "exim4" ]; then
	echo Removing Exim4
	sed -i "/^MAIL_SYSTEM/d" $TULIO/conf/tulio.conf $TULIO/conf/defaults/tulio.conf
	systemctl disable --now exim4
fi
