#!/bin/bash

# Script to generate SSL certificates for the Spring Boot SSL communication project
# This creates a CA certificate and server certificates for both servers

set -e

CERT_DIR="certs"
VALIDITY_DAYS=365

echo "🔒 Generating SSL certificates for Spring Boot SSL communication..."

# Create certificate directory
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Clean up existing certificates
rm -f *.crt *.key *.csr *.srl

echo "📋 Creating CA certificate..."

# Generate CA private key
openssl genrsa -out ca.key 4096

# Generate CA certificate
openssl req -new -x509 -days $VALIDITY_DAYS -key ca.key -out ca.crt \
    -subj "/C=US/ST=CA/L=San Francisco/O=Example Corp/OU=IT Department/CN=Example CA"

echo "🖥️  Creating Server A certificate..."

# Generate Server A private key
openssl genrsa -out server-a.key 4096

# Generate Server A certificate signing request
openssl req -new -key server-a.key -out server-a.csr \
    -subj "/C=US/ST=CA/L=San Francisco/O=Example Corp/OU=IT Department/CN=localhost"

# Create extensions file for Server A
cat > server-a.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = server-a
IP.1 = 127.0.0.1
EOF

# Generate Server A certificate signed by CA
openssl x509 -req -in server-a.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out server-a.crt -days $VALIDITY_DAYS -extensions v3_req -extfile server-a.ext

echo "🖥️  Creating Server B certificate..."

# Generate Server B private key
openssl genrsa -out server-b.key 4096

# Generate Server B certificate signing request
openssl req -new -key server-b.key -out server-b.csr \
    -subj "/C=US/ST=CA/L=San Francisco/O=Example Corp/OU=IT Department/CN=localhost"

# Create extensions file for Server B
cat > server-b.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = server-b
IP.1 = 127.0.0.1
EOF

# Generate Server B certificate signed by CA
openssl x509 -req -in server-b.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out server-b.crt -days $VALIDITY_DAYS -extensions v3_req -extfile server-b.ext

echo "🧹 Cleaning up temporary files..."
rm -f *.csr *.ext *.srl

echo "📁 Copying certificates to resource directories..."

# Copy certificates to server-a resources
mkdir -p ../server-a/src/main/resources/certs
cp ca.crt server-a.crt server-a.key ../server-a/src/main/resources/certs/

# Copy certificates to server-b resources
mkdir -p ../server-b/src/main/resources/certs
cp ca.crt server-b.crt server-b.key ../server-b/src/main/resources/certs/

echo "✅ Certificate generation completed!"
echo ""
echo "📋 Generated files:"
echo "   - ca.crt (CA Certificate)"
echo "   - ca.key (CA Private Key)"
echo "   - server-a.crt (Server A Certificate)"
echo "   - server-a.key (Server A Private Key)"
echo "   - server-b.crt (Server B Certificate)"
echo "   - server-b.key (Server B Private Key)"
echo ""
echo "🔍 To verify certificates:"
echo "   openssl x509 -in certs/server-a.crt -text -noout"
echo "   openssl x509 -in certs/server-b.crt -text -noout"
echo ""
echo "🚀 Certificates are ready for use with Spring Boot SSL bundles!"

cd ..