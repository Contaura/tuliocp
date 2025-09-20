#!/bin/bash

for file in /usr/local/tulio/bin/*; do
	echo "$file" >> ~/tulio_cli_help.txt
	[ -f "$file" ] && [ -x "$file" ] && "$file" >> ~/tulio_cli_help.txt
done

sed -i 's\/usr/local/tulio/bin/\\' ~/tulio_cli_help.txt
