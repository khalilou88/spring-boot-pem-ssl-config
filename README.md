# Spring Boot SSL Communication Project

A modern Spring Boot multi-module project demonstrating secure SSL communication between two services using PEM certificates and SSL bundles._

## Project Structure

```
ssl-communication-parent/
├── server-a/           # First Spring Boot service (port 8443)
├── server-b/           # Second Spring Boot service (port 9443)
├── shared/             # Common DTOs and utilities
├── generate-certs.sh   # Certificate generation script
└── pom.xml             # Parent POM
```

## Features

- **Modern Spring Boot 3.3.2** with Java 17
- **SSL/TLS encryption** using PEM certificates
- **SSL Bundles** for certificate management
- **WebFlux WebClient** for reactive HTTP communication
- **Maven multi-module** project structure
- **Mutual SSL authentication** between services
- **Health endpoints** with SSL verification
- **Comprehensive logging** for debugging

## Prerequisites

- Java 17 or higher
- Maven 3.8+
- OpenSSL (for certificate generation)
- Bash shell (for running scripts)

## Quick Start

### 1. Generate SSL Certificates

```bash
chmod +x generate-certs.sh
./generate-certs.sh
```

### 2. Build the Project

```bash
./mvnw clean install
```

### 3. Start Server A

```bash
./mvnw spring-boot:run -pl server-a
```

### 4. Start Server B (in a new terminal)

```bash
./mvnw spring-boot:run -pl server-b
```

### 5. Test the Communication

**Test Server A health:**
```bash
curl -k https://localhost:8443/api/v1/messages/health
```

**Test Server B health:**
```bash
curl -k https://localhost:9443/api/v1/messages/health
```

**Test Server A → Server B communication:**
```bash
curl -k https://localhost:8443/api/v1/messages/send-to-b/HelloFromA
```

**Test Server B → Server A communication:**
```bash
curl -k https://localhost:9443/api/v1/messages/send-to-a/HelloFromB
```

**Test direct message processing:**
```bash
curl -k -X POST https://localhost:8443/api/v1/messages \
  -H "Content-Type: application/json" \
  -d '{"id":"test-123","content":"Hello World","timestamp":"2025-01-01T12:00:00Z","source":"client"}'
```

## API Endpoints

### Server A (https://localhost:8443)
- `GET /api/v1/messages/health` - Health check
- `GET /api/v1/messages/send-to-b/{content}` - Send message to Server B
- `POST /api/v1/messages` - Process incoming message
- `GET /actuator/health` - Spring Boot health endpoint

### Server B (https://localhost:9443)
- `GET /api/v1/messages/health` - Health check
- `GET /api/v1/messages/send-to-a/{content}` - Send message to Server A
- `POST /api/v1/messages` - Process incoming message
- `GET /actuator/health` - Spring Boot health endpoint

## SSL Configuration

The project uses Spring Boot's SSL Bundle feature with PEM certificates:

- **CA Certificate**: `ca.crt` - Root certificate authority
- **Server A**: `server-a.crt` + `server-a.key` - Server certificate and private key
- **Server B**: `server-b.crt` + `server-b.key` - Server certificate and private key

Each server:
1. Uses its own certificate for HTTPS endpoints
2. Trusts the CA certificate for outgoing requests
3. Validates peer certificates using the CA

## Debugging SSL Issues

Enable detailed SSL logging by adding to `application.yml`:
```yaml
logging:
  level:
    javax.net.ssl: DEBUG
    org.springframework.web.reactive.function.client: TRACE
```

## Certificate Management

### Regenerate Certificates
```bash
./generate-certs.sh
```

### Verify Certificate Details
```bash
openssl x509 -in certs/server-a.crt -text -noout
openssl x509 -in certs/server-b.crt -text -noout
```

### Check Certificate Chain
```bash
openssl verify -CAfile certs/ca.crt certs/server-a.crt
openssl verify -CAfile certs/ca.crt certs/server-b.crt
```