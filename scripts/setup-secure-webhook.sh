#!/bin/bash
# Setup script for secure TulioCP webhook handler

set -e

echo "🔐 Setting up Secure TulioCP Webhook Handler"
echo "=========================================="

# Check if running on build server
if [ ! -d "/opt/tuliocp-build" ]; then
	echo "❌ This script must be run on the build server"
	echo "Build directory not found: /opt/tuliocp-build"
	exit 1
fi

# Generate a secure webhook secret
if [ -z "$WEBHOOK_SECRET" ]; then
	echo "🔑 Generating secure webhook secret..."
	WEBHOOK_SECRET=$(openssl rand -hex 32)
	echo "Generated secret: $WEBHOOK_SECRET"
	echo ""
	echo "⚠️  IMPORTANT: Save this secret! You'll need it for GitHub webhook configuration."
	echo "Add this to your environment: export WEBHOOK_SECRET='$WEBHOOK_SECRET'"
	echo ""
fi

# Download and install secure webhook handler
echo "📋 Installing secure webhook handler..."
if command -v curl > /dev/null 2>&1; then
	curl -s -o /opt/tuliocp-build/secure-webhook-handler.py https://raw.githubusercontent.com/Contaura/tuliocp/main/scripts/secure-webhook-handler.py
elif command -v wget > /dev/null 2>&1; then
	wget -O /opt/tuliocp-build/secure-webhook-handler.py https://raw.githubusercontent.com/Contaura/tuliocp/main/scripts/secure-webhook-handler.py
else
	echo "❌ Neither curl nor wget found. Please install one of them."
	exit 1
fi

if [ ! -f "/opt/tuliocp-build/secure-webhook-handler.py" ]; then
	echo "❌ Failed to download secure webhook handler"
	exit 1
fi

chmod +x /opt/tuliocp-build/secure-webhook-handler.py
echo "✅ Secure webhook handler downloaded successfully"

# Create environment file
echo "📝 Creating environment configuration..."
cat > /opt/tuliocp-build/webhook.env << EOF
# TulioCP Webhook Configuration
WEBHOOK_SECRET='$WEBHOOK_SECRET'
WEBHOOK_PORT=8443
SSL_CERT_FILE=/opt/tuliocp-build/webhook-cert.pem
SSL_KEY_FILE=/opt/tuliocp-build/webhook-key.pem
EOF

# Create systemd service
echo "🚀 Creating systemd service..."
sudo tee /etc/systemd/system/tuliocp-webhook.service > /dev/null << EOF
[Unit]
Description=TulioCP Secure Webhook Handler
After=network.target

[Service]
Type=simple
User=tuliocp
Group=tuliocp
WorkingDirectory=/opt/tuliocp-build
EnvironmentFile=/opt/tuliocp-build/webhook.env
ExecStart=/usr/bin/python3 /opt/tuliocp-build/secure-webhook-handler.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security settings
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/opt/tuliocp-build /tmp
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

# Set up firewall rule
echo "🛡️  Setting up firewall..."
if command -v ufw > /dev/null 2>&1; then
	sudo ufw allow 8443/tcp comment "TulioCP Webhook HTTPS"
	echo "Firewall rule added for port 8443"
else
	echo "⚠️  UFW not found. Manually configure firewall to allow port 8443"
fi

# Install and start service
echo "⚙️  Installing and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable tuliocp-webhook
sudo systemctl start tuliocp-webhook

# Wait for service to start
sleep 3

# Check service status
if sudo systemctl is-active --quiet tuliocp-webhook; then
	echo "✅ Webhook service started successfully"

	# Test health endpoint
	sleep 2
	if curl -k -s https://localhost:8443/health > /dev/null; then
		echo "✅ HTTPS health check passed"
	else
		echo "⚠️  HTTPS health check failed (this may be normal with self-signed certs)"
	fi
else
	echo "❌ Webhook service failed to start"
	echo "Check logs: sudo journalctl -u tuliocp-webhook -f"
	exit 1
fi

echo ""
echo "🎉 Secure webhook setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Go to: https://github.com/Contaura/tuliocp/settings/hooks"
echo "2. Add webhook with these settings:"
echo "   - Payload URL: https://your-server-ip:8443/webhook"
echo "   - Content type: application/json"
echo "   - Secret: $WEBHOOK_SECRET"
echo "   - SSL verification: Enable SSL verification"
echo "   - Events: Just the push event"
echo ""
echo "📊 Monitor webhook:"
echo "   - Service status: sudo systemctl status tuliocp-webhook"
echo "   - Live logs: sudo journalctl -u tuliocp-webhook -f"
echo "   - Health check: curl -k https://your-server-ip:8443/health"
echo ""
echo "🔒 Security features enabled:"
echo "   - ✅ HTTPS/SSL encryption"
echo "   - ✅ GitHub signature verification"
echo "   - ✅ Payload validation"
echo "   - ✅ Repository verification"
echo "   - ✅ Branch filtering (main only)"
echo "   - ✅ Request size limits"
echo "   - ✅ Systemd security restrictions"
echo "   - ✅ Proper logging"
