# Configuración Completa: TLS, mTLS y JWT

## ✅ Qué hemos hecho

### 1. Estructura de Certificados
```
certificates/
├── cliente/
│   ├── cliente-key.pem          (clave privada)
│   └── cliente.csr              (request para firma del profesor)
├── backend-a/
│   ├── backend-a-key.pem        (clave privada)
│   └── backend-a.csr            (request para firma del profesor)
├── backend-b/
│   ├── backend-b-key.pem        (clave privada)
│   └── backend-b.csr            (request para firma del profesor)
├── generar-csr.sh               (script generador)
└── convertir-a-keystores.sh     (convierte certificados a keystores)
```

### 2. Dependencias Maven Agregadas
- **jjwt** (JWT para autenticación de usuarios)
- **Spring Boot Web** (ya estaba configurado para TLS)

### 3. Configuración Spring Boot

#### Backend A (TLS simple - port 8081)
```properties
server.port=8081
server.ssl.key-store=classpath:certs/backend-a-keystore.p12
server.ssl.key-store-password=password123
server.ssl.key-store-type=PKCS12
```

#### Backend B (mTLS - port 8082)
```properties
server.port=8082
server.ssl.key-store=classpath:certs/backend-b-keystore.p12
server.ssl.client-auth=need
server.ssl.trust-store=classpath:certs/truststore.p12
```

#### Cliente (port 8080)
```properties
server.port=8080
client.truststore.path=classpath:certs/truststore.p12
client.keystore.path=classpath:certs/cliente-keystore.p12
```

### 4. Clases Java Implementadas

**Backend A:**
- `JwtUtil` → Genera y valida JWTs
- `JwtAuthFilter` → Middleware para validar JWTs
- `BackendAController` → Endpoints con TLS

**Backend B (mTLS):**  
- `JwtUtil` → Igual que Backend A
- `BackendBController` → Endpoints que requieren mTLS

**Cliente:**
- `JwtUtil` → Genera JWTs
- `RestTemplateConfiguration` → Configura HTTP Client con SSL/mTLS
- `BackendClientService` → Llama a los backends de forma segura
- `ClienteController` → Endpoints que demuestran la integración

---

## 🔄 PRÓXIMOS PASOS

### PASO 1: Enviar CSRs al Profesor

Envía estas 3 carpetas al profesor:
```
certificates/cliente/cliente.csr
certificates/backend-a/backend-a.csr
certificates/backend-b/backend-b.csr
```

### PASO 2: El Profesor devuelve

El profesor devolverá:
```
certificates/cliente/cliente.crt
certificates/backend-a/backend-a.crt
certificates/backend-b/backend-b.crt
certificates/ca.crt                    (raíz de autoridad certificadora)
```

### PASO 3: Convertir a Keystores

Una vez recibas los archivos firmados, colócalos en sus carpetas y ejecuta:
```bash
cd certificates
bash convertir-a-keystores.sh
```

Esto generará:
```
cliente-keystore.p12      (cliente-key.pem + cliente.crt)
backend-a-keystore.p12   (backend-a-key.pem + backend-a.crt)
backend-b-keystore.p12   (backend-b-key.pem + backend-b.crt)
truststore.p12           (ca.crt)
```

### PASO 4: Copiar Keystores a Spring Boot

```bash
# Backend A
cp certificates/backend-a/backend-a-keystore.p12 \
   backend-a/backend-a/src/main/resources/certs/

# Backend B
cp certificates/backend-b/backend-b-keystore.p12 \
   backend-b/backend-b/src/main/resources/certs/

# Cliente
cp certificates/cliente/cliente-keystore.p12 \
   cliente/cliente/src/main/resources/certs/

# Truststore (para todos)
cp certificates/truststore.p12 \
   cliente/cliente/src/main/resources/certs/
```

### PASO 5: Descomenta configuración en application.properties

En cada servicio, descomenta las líneas con los certificados firmados:

**Backend A** (`backend-a/application.properties`):
```properties
server.ssl.key-store=classpath:certs/backend-a-keystore.p12
server.ssl.key-store-password=password123
# Comenta la línea del self-signed
```

**Backend B** (`backend-b/application.properties`):
```properties
server.ssl.key-store=classpath:certs/backend-b-keystore.p12
server.ssl.trust-store=classpath:certs/truststore.p12
server.ssl.client-auth=need
```

**Cliente** (`cliente/application.properties`):
```properties
client.truststore.path=classpath:certs/truststore.p12
client.keystore.path=classpath:certs/cliente-keystore.p12
```

---

## 🧪 Cómo Probar

### 1. Descargar dependencias (si aún no lo hiciste)
```bash
cd backend-a/backend-a && ./mvnw clean install
cd ../../backend-b/backend-b && ./mvnw clean install
cd ../../cliente/cliente && ./mvnw clean install
```

### 2. Iniciar los servicios (en 3 terminales diferentes)
```bash
# Terminal 1 - Backend A (TLS)
cd backend-a/backend-a
./mvnw spring-boot:run

# Terminal 2 - Backend B (mTLS)
cd backend-b/backend-b
./mvnw spring-boot:run

# Terminal 3 - Cliente
cd cliente/cliente
./mvnw spring-boot:run
```

### 3. Hacer requests de prueba

```bash
# Info del cliente
curl -k https://localhost:8080/api/info

# Test completo
curl -k https://localhost:8080/api/security-test

# Llamar Backend A
curl -k https://localhost:8080/api/call-backend-a

# Llamar Backend B (mTLS)
curl -k https://localhost:8080/api/call-backend-b
```

---

## 📋 Separación de Conceptos

### TLS (Transport Layer Security)
- **Qué es**: Cifrado de la comunicación HTTP → HTTPS
- **Quién se identifica**: Solo el servidor (Backend A y B)
- **Dónde**: `server.ssl.*` en application.properties

### mTLS (Mutual TLS)
- **Qué es**: TLS donde AMBOS se identifican con certificados
- **Cliente se identifica**: Sí (presentando certificado)
- **Dónde**: Backend B requiere `server.ssl.client-auth=need` y Cliente usa `client.keystore.p12`

### JWT (JSON Web Tokens)  
- **Qué es**: Tokens para autenticación de USUARIOS (independiente de certificados)
- **Cuándo se valida**: En el middleware `JwtAuthFilter`
- **Dónde**: `jwt.secret` y `jwt.expiration` en application.properties

---

## 🔐 Diagrama de Flujo

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENTE (8080)                       │
│  - Genera JWT para identificarse como usuario           │
│  - Usa truststore para confiar en servidores            │
│  - Usa keystore para autenticarse en Backend B (mTLS)   │
└────────┬─────────────────────────────────┬──────────────┘
         │                                 │
    TLS (HTTPS)                    mTLS (HTTPS)
    Sin cert del cliente           + Cert del cliente
         │                                 │
         ▼                                 ▼
┌─────────────────┐            ┌──────────────────────┐
│ Backend A (8081)│            │ Backend B (8082)     │
│ - Certificado   │            │ - Certificado        │
│ - Valida JWT    │            │ - Valida Cert Cliente│
│ - Datos públicos│            │ - Valida JWT         │
└─────────────────┘            │ - Datos protegidos   │
                               └──────────────────────┘
```

---

## 📝 Notas Importantes

1. **Contraseña de keystores**: `password123`
   - En producción, usa una contraseña fuerte y mantenla en secreto

2. **Self-signed certificates** (mientras esperas del profesor):
   - Los archivos `self-signed.p12` son solo para testing local
   - Reemplázalos cuando recibas los certificados firmados

3. **JAVA_HOME**: Asegúrate que está configurado
   ```bash
   export JAVA_HOME="/c/Program Files/Java/jdk-21.0.10"
   ```

4. **Puertos**:
   - Cliente: `8080` (HTTP)
   - Backend A: `8081` (HTTPS)
   - Backend B: `8082` (HTTPS)

5. **Certificados autofirmados vs firmados**:
   - **Autofirmados**: No hay confianza, debes ignorar warnings (`-k` en curl)
   - **Firmados por CA**: Confianza total, sin warnings

---

## ✅ Checklist Final

- [ ] CSRs generados y enviados al profesor
- [ ] Certificados firmados recibidos del profesor
- [ ] Keystores y truststore generados
- [ ] Archivos copiados a `src/main/resources/certs/`
- [ ] application.properties descomentados
- [ ] `mvnw clean install` ejecutado en los 3 servicios
- [ ] Servicios iniciados sin errores
- [ ] Tests curl ejecutados exitosamente

¡Listo! Tu sistema de microservicios con TLS, mTLS y JWT está configurado. 🚀
