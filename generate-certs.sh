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
    -out server-b.crt -days $