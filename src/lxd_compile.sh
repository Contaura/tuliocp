#!/bin/bash

branch=${1-main}

apt -y install curl wget

curl https://raw.githubusercontent.com/contaura/tuliocp/$branch/src/hst_autocompile.sh > /tmp/hst_autocompile.sh
chmod +x /tmp/hst_autocompile.sh

mkdir -p /opt/tuliocp

# Building Tulio
if bash /tmp/hst_autocompile.sh --tulio --noinstall --keepbuild $branch; then
	cp /tmp/tuliocp-src/deb/*.deb /opt/tuliocp/
fi

# Building PHP
if bash /tmp/hst_autocompile.sh --php --noinstall --keepbuild $branch; then
	cp /tmp/tuliocp-src/deb/*.deb /opt/tuliocp/
fi

# Building NGINX
if bash /tmp/hst_autocompile.sh --nginx --noinstall --keepbuild $branch; then
	cp /tmp/tuliocp-src/deb/*.deb /opt/tuliocp/
fi
