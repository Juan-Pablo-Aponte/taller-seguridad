# 📋 ANÁLISIS COMPLETO: Estado vs Objetivos

## ✅ LO QUE YA ESTÁ HECHO

### 1. Infraestructura de Confianza (PKI)
- ✓ Profesor (CA raíz) emitió certificados 
- ✓ 3 CSRs generados y enviados
- ✓ 3 Certificados firmados recibidos:
  - `certificates/cliente/cliente.crt`
  - `certificates/backend-a/backend-a.crt`
  - `certificates/backend-b/backend-b.crt`
- ✓ CA raíz recibida: `certificates/ca.crt`

### 2. Microservicio Backend A (TLS)
- ✓ Application.properties configurado con TLS
- ✓ Endpoints implementados:
  - `/api/public` - Acceso público
  - `/api/protected` - Requiere JWT
  - `/api/login` - Genera JWT
  - `/api/security-info` - Info de configuración
- ✓ JwtUtil implementado (genera/valida tokens)
- ✓ JwtAuthFilter implementado (valida JWT en middleware)

### 3. Microservicio Backend B (mTLS)
- ✓ Application.properties configurado para mTLS
- ✓ Endpoints implementados:
  - `/api/protected` - Requiere mTLS + JWT
  - `/api/login` - Genera JWT
  - `/api/security-info` - Info de configuración
  - `/api/health` - Health check
- ✓ JwtUtil implementado

### 4. Microservicio Cliente
- ✓ Application.properties configurado con paths a keystores
- ✓ RestTemplateConfiguration implementada (SSL/mTLS setup)
- ✓ BackendClientService implementada (llamadas seguras)
- ✓ ClienteController con endpoints de demostración

### 5. Implementación de JWT
- ✓ JwtUtil con:
  - Generación de tokens (HS256)
  - Validación de firma
  - Extracción de claims (username, role)
  - Validación de expiración
- ✓ Tokens incluyen: username, role, iat, exp

### 6. Criptografía Asimétrica
- ✓ Generación de pares RSA 2048 bits
- ✓ Diferenciación entre:
  - Llaves para certificados (X509)
  - Llaves para JWT (HS256 - simétrico, pero validable)

---

## ⚠️ LO QUE FALTA (PASOS INMEDIATOS)

### FALTA 1: Generar Keystores PKCS12
Los datos binarios que Spring Boot necesita:
```
- cliente-keystore.p12      (cliente.crt + cliente-key.pem)
- backend-a-keystore.p12   (backend-a.crt + backend-a-key.pem)
- backend-b-keystore.p12   (backend-b.crt + backend-b-key.pem)
- truststore.p12           (ca.crt para confiar en la CA)
```

**Estado**: NO GENERADOS AÚN

### FALTA 2: Copiar keystores a resources
```
backend-a/backend-a/src/main/resources/certs/backend-a-keystore.p12
backend-b/backend-b/src/main/resources/certs/backend-b-keystore.p12
cliente/cliente/src/main/resources/certs/cliente-keystore.p12
cliente/cliente/src/main/resources/certs/truststore.p12
```

**Estado**: NO COPIADOS AÚN (porque no existen los keystores)

### FALTA 3: Descomenta configuración en application.properties
Descomentar las líneas que usan certificados firmados (ahora mismo usan self-signed para testing)

**Estado**: PARCIALMENTE (están comentadas esperando keystores)

### FALTA 4: JwtAuthFilter en Backend B
Backend B también debería validar JWT en middleware (como Backend A)

**Estado**: NO IMPLEMENTADO (solo existe en Backend A)

### FALTA 5: Tests de seguridad
Scripts o documentación de cómo probar:
- ✗ Cliente sin certificado accede a mTLS → debe rechazar
- ✗ JWT inválido → debe rechazar
- ✗ JWT expirado → debe rechazar
- ✗ Cliente + JWT válidos → debe funcionar

**Estado**: NO DOCUMENTADO

### FALTA 6: Diagramas de arquitectura
- Flujo de comunicación TLS
- Flujo de comunicación mTLS
- Flujo de validación JWT

**Estado**: NO CREADOS

---

## 🔄 PASO A PASO A COMPLETAR

### PASO 1: Generar Keystores PKCS12

```bash
cd "c:/Users/Juan Pablo/Documents/taller-clase-patrones/certificates"

# 1.1 Cliente - Keystore
openssl pkcs12 -export \
  -in cliente/cliente.crt \
  -inkey cliente/cliente-key.pem \
  -out cliente/cliente-keystore.p12 \
  -name cliente \
  -passout pass:password123

# 1.2 Backend A - Keystore
openssl pkcs12 -export \
  -in backend-a/backend-a.crt \
  -inkey backend-a/backend-a-key.pem \
  -out backend-a/backend-a-keystore.p12 \
  -name backend-a \
  -passout pass:password123

# 1.3 Backend B - Keystore
openssl pkcs12 -export \
  -in backend-b/backend-b.crt \
  -inkey backend-b/backend-b-key.pem \
  -out backend-b/backend-b-keystore.p12 \
  -name backend-b \
  -passout pass:password123

# 1.4 Truststore con CA (para todos)
keytool -import -alias ca-root -file ca.crt \
  -keystore truststore.p12 \
  -storetype PKCS12 \
  -storepass password123 \
  -noprompt
```

---

### PASO 2: Copiar keystores a src/main/resources

```bash
# Backend A
mkdir -p backend-a/backend-a/src/main/resources/certs
cp certificates/backend-a/backend-a-keystore.p12 \
   backend-a/backend-a/src/main/resources/certs/

# Backend B
mkdir -p backend-b/backend-b/src/main/resources/certs
cp certificates/backend-b/backend-b-keystore.p12 \
   backend-b/backend-b/src/main/resources/certs/

# Cliente (necesita ambos)
mkdir -p cliente/cliente/src/main/resources/certs
cp certificates/cliente/cliente-keystore.p12 \
   cliente/cliente/src/main/resources/certs/
cp certificates/truststore.p12 \
   cliente/cliente/src/main/resources/certs/

# También Backend B necesita el truststore para mTLS
cp certificates/truststore.p12 \
   backend-b/backend-b/src/main/resources/certs/
```

---

### PASO 3: Descomenta certificados en application.properties

#### Backend A
Descomenta estas líneas:
```properties
# Cambiar de:
server.ssl.key-store=classpath:certs/self-signed.p12

# A:
server.ssl.key-store=classpath:certs/backend-a-keystore.p12
```

#### Backend B
Descomenta:
```properties
# Cambiar de:
server.ssl.key-store=classpath:certs/self-signed-b.p12
# server.ssl.client-auth=need
server.ssl.trust-store=classpath:certs/truststore.p12

# A:
server.ssl.key-store=classpath:certs/backend-b-keystore.p12
server.ssl.client-auth=need
server.ssl.trust-store=classpath:certs/truststore.p12
```

---

### PASO 4: Agregar JwtAuthFilter a Backend B

Backend B también debe validar JWT (igual que Backend A).

Crear archivo: `backend-b/backend-b/src/main/java/co/edu/unisabana/backend_b/config/JwtAuthFilter.java`

```java
package co.edu.unisabana.backend_b.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
                                    FilterChain filterChain) throws ServletException, IOException {
        
        String path = request.getRequestURI();
        if (path.startsWith("/actuator") || path.equals("/api/health")) {
            filterChain.doFilter(request, response);
            return;
        }

        String authHeader = request.getHeader("Authorization");
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            
            if (jwtUtil.validateToken(token)) {
                String username = jwtUtil.getUsernameFromToken(token);
                String role = jwtUtil.getRoleFromToken(token);
                
                request.setAttribute("username", username);
                request.setAttribute("role", role);
                
                filterChain.doFilter(request, response);
            } else {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"error\": \"Token inválido\"}");
            }
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\": \"Falta token JWT\"}");
        }
    }
}
```

---

### PASO 5: Descargar dependencias

```bash
export JAVA_HOME="/c/Program Files/Java/jdk-21.0.10"
export PATH="$JAVA_HOME/bin:$PATH"

cd backend-a/backend-a && ./mvnw clean install
cd ../../backend-b/backend-b && ./mvnw clean install
cd ../../cliente/cliente && ./mvnw clean install
```

---

### PASO 6: Iniciar servicios (3 terminales)

**Terminal 1 - Backend A:**
```bash
cd backend-a/backend-a
./mvnw spring-boot:run
```

**Terminal 2 - Backend B:**
```bash
cd backend-b/backend-b
./mvnw spring-boot:run
```

**Terminal 3 - Cliente:**
```bash
cd cliente/cliente
./mvnw spring-boot:run
```

---

### PASO 7: Tests de seguridad

#### 7.1 Test: Backend A (TLS) - Acceso público
```bash
curl -k https://localhost:8081/api/public
```
**Esperado**: Respuesta exitosa sin ningún token

#### 7.2 Test: Backend A (TLS) - Login JWT
```bash
TOKEN=$(curl -k -X POST https://localhost:8081/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"juan","role":"USER"}' \
  | jq -r '.token')

echo $TOKEN
```

#### 7.3 Test: Backend A (TLS) - Endpoint protegido
```bash
curl -k -H "Authorization: Bearer $TOKEN" \
  https://localhost:8081/api/protected
```
**Esperado**: Respuesta con username y role

#### 7.4 Test: Backend B (mTLS) SIN certificado del cliente
```bash
curl -k -X POST https://localhost:8082/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"cliente","role":"SERVICE"}'
```
**Esperado**: RECHAZO (SSL: CERTIFICATE_VERIFY_FAILED o similar)

#### 7.5 Test: Cliente llama Backend A
```bash
curl -k https://localhost:8080/api/call-backend-a
```

#### 7.6 Test: Cliente llama Backend B (mTLS)
```bash
curl -k https://localhost:8080/api/call-backend-b
```

#### 7.7 Test: JWT inválido
```bash
curl -k -H "Authorization: Bearer INVALID_TOKEN" \
  https://localhost:8081/api/protected
```
**Esperado**: RECHAZO (401 Unauthorized)

---

## 📊 CHECKLIST DE COMPLETITUD

### PKI / Certificados
- [x] CS generadas
- [x] Certificados firmados recibidos
- [x] CA raíz recibida
- [ ] **FALTA**: Keystores PKCS12 generados
- [ ] **FALTA**: Keystores copiados a resources
- [ ] **FALTA**: application.properties descomentados

### Backend A (TLS)
- [x] Application.properties configurado
- [x] JwtUtil implementado
- [x] JwtAuthFilter implementado
- [x] Endpoints implementados
- [ ] **FALTA**: Ejecutar mvnw clean install

### Backend B (mTLS)
- [x] Application.properties configurado
- [x] JwtUtil implementado
- [ ] **FALTA**: JwtAuthFilter implementado
- [x] Endpoints implementados (parcial)
- [ ] **FALTA**: Ejecutar mvnw clean install

### Cliente
- [x] Application.properties configurado
- [x] RestTemplateConfiguration implementada (pero NO COMPLETA - falta configurar protocolo)
- [x] BackendClientService implementada
- [x] ClienteController implementado
- [ ] **FALTA**: Ejecutar mvnw clean install
- [ ] **FALTA**: Probar conexiones

### JWT
- [x] JwtUtil generación de tokens
- [x] JwtUtil validación de firma
- [x] JwtUtil extracción de claims
- [x] JwtAuthFilter middleware
- [ ] **FALTA**: Tests de JWT inválido

### Documentación/Entregables
- [x] SETUP_COMPLETO.md
- [ ] **FALTA**: Diagramas de arquitectura
- [ ] **FALTA**: Documento de tests de seguridad
- [ ] **FALTA**: Explicación técnica de TLS vs mTLS vs JWT

---

## 🚀 ORDEN DE EJECUCIÓN (Para ahora mismo)

```
1. PASO 1: Generar keystores.p12 (openssl)
   ↓
2. PASO 2: Copiar keystores a src/main/resources
   ↓
3. PASO 3: Descomenta application.properties
   ↓
4. PASO 4: Agregar JwtAuthFilter a Backend B
   ↓
5. PASO 5: mvnw clean install en los 3 servicios
   ↓
6. PASO 6: Iniciar servicios
   ↓
7. PASO 7: Ejecutar tests de seguridad
   ↓
8. PASO 8: Crear documentación final
```

---

## 📝 RESUMEN EJECUTIVO

**¿Qué está funcionando?**
- ✓ Estructura de certificados lista
- ✓ Código de microservicios implementado
- ✓ JWT funcionará cuando se configure

**¿Qué está pendiente?**
- ⚠️ Convertir certificados .crt a keystores .p12 (15 minutos)
- ⚠️ Copiar archivos a recursos (5 minutos)
- ⚠️ Descomentar config (5 minutos)
- ⚠️ Agregar JwtAuthFilter a Backend B (10 minutos)
- ⚠️ Tests de seguridad (30 minutos)
- ⚠️ Documentación final (30 minutos)

**Tiempo total estimado**: 2 horas

---

## 🎯 Próximo comando a ejecutar

```bash
cd "c:/Users/Juan Pablo/Documents/taller-clase-patrones/certificates"

# Generar keystores
openssl pkcs12 -export -in cliente/cliente.crt -inkey cliente/cliente-key.pem -out cliente/cliente-keystore.p12 -name cliente -passout pass:password123

openssl pkcs12 -export -in backend-a/backend-a.crt -inkey backend-a/backend-a-key.pem -out backend-a/backend-a-keystore.p12 -name backend-a -passout pass:password123

openssl pkcs12 -export -in backend-b/backend-b.crt -inkey backend-b/backend-b-key.pem -out backend-b/backend-b-keystore.p12 -name backend-b -passout pass:password123

keytool -import -alias ca-root -file ca.crt -keystore truststore.p12 -storetype PKCS12 -storepass password123 -noprompt
```

¿Ejecuto esto?
