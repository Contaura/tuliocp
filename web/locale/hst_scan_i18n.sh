#!/bin/bash

if [ ! -x /usr/bin/xgettext ]; then
	echo " **********************************************************"
	echo " * Unable to find xgettext please install gettext package *"
	echo " **********************************************************"
	exit 3
fi

echo "[ * ] Move tuliocp.pot to tuliocp.pot.old"
mv tuliocp.pot tuliocp.pot.old
true > tuliocp.pot

echo "[ * ] Search *.php *.html and *.sh for php based gettext functions"
find ../.. \( -name '*.php' -o -name '*.html' -o -name '*.sh' \) | xgettext --output=tuliocp.pot --language=PHP --join-existing -f -

# Scan the description string for list updates page
while IFS= read -r string; do
	if ! grep -q "\"$string\"" tuliocp.pot; then
		echo -e "\n#: ../../bin/v-list-sys-tulio-updates:$(grep -n "$string" ../../bin/v-list-sys-tulio-updates | cut -d: -f1)\nmsgid \"$string\"\nmsgstr \"\"" >> tuliocp.pot
	fi
done < <(awk -F'DESCR=' '/data=".+ DESCR=[^"]/ {print $2}' ../../bin/v-list-sys-tulio-updates | cut -d\' -f2)

# Scan the description string for list server page
while IFS= read -r string; do
	if ! grep -q "\"$string\"" tuliocp.pot; then
		echo -e "\n#: ../../bin/v-list-sys-services:$(grep -n "$string" ../../bin/v-list-sys-services | cut -d: -f1)\nmsgid \"$string\"\nmsgstr \"\"" >> tuliocp.pot
	fi
done < <(awk -F'SYSTEM=' '/data=".+ SYSTEM=[^"]/ {print $2}' ../../bin/v-list-sys-services | cut -d\' -f2)

# Prevent only date change become a commit
if [ "$(diff tuliocp.pot tuliocp.pot.old | wc -l)" -gt 4 ]; then
	rm tuliocp.pot.old
else
	mv -f tuliocp.pot.old tuliocp.pot
fi
