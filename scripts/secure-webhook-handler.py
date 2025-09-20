#!/usr/bin/env python3
"""
Secure TulioCP Webhook Handler
Production-ready webhook server with SSL, authentication, and security features

Usage: python3 secure-webhook-handler.py
Required: Set WEBHOOK_SECRET environment variable
"""

import os
import ssl
import json
import hmac
import hashlib
import logging
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from datetime import datetime

# Configuration
WEBHOOK_SECRET = os.environ.get('WEBHOOK_SECRET', 'change-me-in-production')
WEBHOOK_PORT = int(os.environ.get('WEBHOOK_PORT', 8443))  # HTTPS port
BUILD_PATH = '/opt/tuliocp-build'
LOG_FILE = os.path.join(BUILD_PATH, 'webhook.log')
MAX_PAYLOAD_SIZE = 1024 * 1024  # 1MB max payload
ALLOWED_IPS = {
    # GitHub webhook IP ranges (update as needed)
    '140.82.112.0/20',
    '185.199.108.0/22',
    '192.30.252.0/22',
    '143.55.64.0/20',
}

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class SecureWebhookHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        """Override to use our logger"""
        logger.info("%s - %s" % (self.address_string(), format % args))

    def verify_github_signature(self, payload, signature):
        """Verify GitHub webhook signature"""
        if not signature:
            return False
        
        if not signature.startswith('sha256='):
            return False
        
        signature = signature[7:]  # Remove 'sha256=' prefix
        expected_signature = hmac.new(
            WEBHOOK_SECRET.encode('utf-8'),
            payload,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(signature, expected_signature)

    def is_valid_github_payload(self, payload_data):
        """Validate the GitHub webhook payload"""
        try:
            data = json.loads(payload_data)
            
            # Check if it's a push event to main branch
            if data.get('ref') != 'refs/heads/main':
                logger.info("Ignoring non-main branch push")
                return False
                
            # Verify repository
            repo_name = data.get('repository', {}).get('full_name', '')
            if repo_name != 'Contaura/tuliocp':
                logger.warning(f"Unexpected repository: {repo_name}")
                return False
                
            return True
        except json.JSONDecodeError:
            logger.error("Invalid JSON payload")
            return False

    def run_build_process(self):
        """Execute the build process securely"""
        try:
            logger.info("Starting build process...")
            
            # Change to build directory
            os.chdir(BUILD_PATH)
            
            # Update repository first
            logger.info("Updating repository...")
            result = subprocess.run(
                ['git', '-C', f'{BUILD_PATH}/tuliocp', 'pull', 'origin', 'main'],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode != 0:
                logger.error(f"Git pull failed: {result.stderr}")
                return False, f"Repository update failed: {result.stderr}"
            
            logger.info("Repository updated successfully")
            
            # Run build script
            logger.info("Starting package build...")
            result = subprocess.run(
                [f'{BUILD_PATH}/auto-build.sh'],
                capture_output=True,
                text=True,
                timeout=600,  # 10 minute timeout
                env={**os.environ, 'DEBIAN_FRONTEND': 'noninteractive'}
            )
            
            if result.returncode != 0:
                logger.error(f"Build failed: {result.stderr}")
                return False, f"Build process failed: {result.stderr}"
            
            logger.info("Build completed successfully")
            
            # Run deployment script
            logger.info("Deploying to repository...")
            result = subprocess.run(
                [f'{BUILD_PATH}/deploy-to-repo.sh'],
                capture_output=True,
                text=True,
                timeout=120,  # 2 minute timeout
                env={**os.environ, 'DEBIAN_FRONTEND': 'noninteractive'}
            )
            
            if result.returncode != 0:
                logger.error(f"Deployment failed: {result.stderr}")
                return False, f"Deployment failed: {result.stderr}"
            
            logger.info("Deployment completed successfully")
            return True, "Build and deployment completed successfully"
            
        except subprocess.TimeoutExpired:
            logger.error("Build process timed out")
            return False, "Build process timed out"
        except Exception as e:
            logger.error(f"Build process error: {str(e)}")
            return False, f"Build process error: {str(e)}"

    def send_json_response(self, status_code, data):
        """Send JSON response with proper headers"""
        response = json.dumps(data).encode('utf-8')
        
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(response)))
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('X-Frame-Options', 'DENY')
        self.send_header('X-XSS-Protection', '1; mode=block')
        self.end_headers()
        self.wfile.write(response)

    def do_POST(self):
        """Handle POST requests"""
        try:
            # Check content length
            content_length = int(self.headers.get('Content-Length', 0))
            if content_length > MAX_PAYLOAD_SIZE:
                logger.warning(f"Payload too large: {content_length} bytes")
                self.send_json_response(413, {
                    'status': 'error',
                    'message': 'Payload too large'
                })
                return
            
            # Only handle /webhook endpoint
            if self.path != '/webhook':
                logger.warning(f"Invalid endpoint: {self.path}")
                self.send_json_response(404, {
                    'status': 'error',
                    'message': 'Endpoint not found'
                })
                return
            
            # Read payload
            payload = self.rfile.read(content_length)
            
            # Verify GitHub signature
            github_signature = self.headers.get('X-Hub-Signature-256', '')
            if not self.verify_github_signature(payload, github_signature):
                logger.warning("Invalid GitHub signature")
                self.send_json_response(401, {
                    'status': 'error',
                    'message': 'Invalid signature'
                })
                return
            
            # Validate payload
            if not self.is_valid_github_payload(payload.decode('utf-8')):
                self.send_json_response(400, {
                    'status': 'error',
                    'message': 'Invalid or ignored payload'
                })
                return
            
            # Check GitHub event type
            event_type = self.headers.get('X-GitHub-Event', '')
            if event_type not in ['push', 'ping']:
                logger.info(f"Ignoring event type: {event_type}")
                self.send_json_response(200, {
                    'status': 'ignored',
                    'message': f'Event type {event_type} ignored'
                })
                return
            
            # Handle ping event
            if event_type == 'ping':
                logger.info("Webhook ping received")
                self.send_json_response(200, {
                    'status': 'success',
                    'message': 'Webhook is active'
                })
                return
            
            # Execute build process
            success, message = self.run_build_process()
            
            if success:
                self.send_json_response(200, {
                    'status': 'success',
                    'message': message,
                    'timestamp': datetime.utcnow().isoformat() + 'Z'
                })
            else:
                self.send_json_response(500, {
                    'status': 'error',
                    'message': message,
                    'timestamp': datetime.utcnow().isoformat() + 'Z'
                })
                
        except Exception as e:
            logger.error(f"Request handling error: {str(e)}")
            self.send_json_response(500, {
                'status': 'error',
                'message': 'Internal server error'
            })

    def do_GET(self):
        """Handle GET requests (health check)"""
        if self.path == '/health':
            self.send_json_response(200, {
                'status': 'healthy',
                'timestamp': datetime.utcnow().isoformat() + 'Z',
                'version': '1.0.0'
            })
        else:
            self.send_json_response(404, {
                'status': 'error',
                'message': 'Endpoint not found'
            })

def create_ssl_context(cert_file, key_file):
    """Create SSL context for HTTPS"""
    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    context.load_cert_chain(cert_file, key_file)
    context.minimum_version = ssl.TLSVersion.TLSv1_2
    return context

def generate_self_signed_cert():
    """Generate self-signed certificate for development"""
    cert_file = os.path.join(BUILD_PATH, 'webhook-cert.pem')
    key_file = os.path.join(BUILD_PATH, 'webhook-key.pem')
    
    if os.path.exists(cert_file) and os.path.exists(key_file):
        return cert_file, key_file
    
    try:
        import subprocess
        logger.info("Generating self-signed certificate...")
        subprocess.run([
            'openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-keyout', key_file,
            '-out', cert_file, '-days', '365', '-nodes', '-subj',
            '/C=US/ST=State/L=City/O=TulioCP/CN=localhost'
        ], check=True, capture_output=True)
        
        # Set proper permissions
        os.chmod(key_file, 0o600)
        os.chmod(cert_file, 0o644)
        
        logger.info(f"Self-signed certificate generated: {cert_file}")
        return cert_file, key_file
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to generate certificate: {e}")
        return None, None
    except ImportError:
        logger.error("OpenSSL not available for certificate generation")
        return None, None

def main():
    if WEBHOOK_SECRET == 'change-me-in-production':
        logger.warning("⚠️  Using default webhook secret! Set WEBHOOK_SECRET environment variable.")
    
    logger.info(f"Starting secure TulioCP webhook handler on port {WEBHOOK_PORT}...")
    
    # Check if build directory exists
    if not os.path.exists(BUILD_PATH):
        logger.error(f"Build directory not found: {BUILD_PATH}")
        return 1
    
    server = HTTPServer(('0.0.0.0', WEBHOOK_PORT), SecureWebhookHandler)
    
    # Set up SSL
    cert_file = os.environ.get('SSL_CERT_FILE')
    key_file = os.environ.get('SSL_KEY_FILE')
    
    if cert_file and key_file and os.path.exists(cert_file) and os.path.exists(key_file):
        logger.info("Using provided SSL certificate")
        server.socket = create_ssl_context(cert_file, key_file).wrap_socket(
            server.socket, server_side=True
        )
    else:
        logger.info("Generating self-signed certificate for development")
        cert_file, key_file = generate_self_signed_cert()
        if cert_file and key_file:
            server.socket = create_ssl_context(cert_file, key_file).wrap_socket(
                server.socket, server_side=True
            )
        else:
            logger.warning("⚠️  Running without SSL encryption!")
    
    logger.info(f"Webhook server ready at https://your-server:{WEBHOOK_PORT}/webhook")
    logger.info("Health check available at: /health")
    logger.info(f"Logs written to: {LOG_FILE}")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Shutting down webhook server...")
        server.shutdown()
        return 0
    except Exception as e:
        logger.error(f"Server error: {e}")
        return 1

if __name__ == '__main__':
    exit(main())