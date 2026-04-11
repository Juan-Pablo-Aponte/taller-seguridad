# Sistema Seguro de 3 Microservicios - Documentación de Ejecución

## Descripción General

Sistema demostrativo de 3 microservicios que implementan:
- **TLS (Transport Layer Security)**: Cifrado de transporte HTTPS
- **mTLS (Mutual TLS)**: Autenticación bidireccional con certificados X.509
- **JWT (JSON Web Tokens)**: Autenticación sin estado a nivel de aplicación

---

## Arquitectura

```
┌──────────────┐
│   Cliente    │ (Puerto 8080)
│   HTTP       │ Proxy que consume Backend A y B
└──────┬───────┘
       │ HTTPS+JWT
       ├─────────────────┬─────────────────┐
       ↓                 ↓                 │
   ┌─────────┐      ┌──────────┐      │
   │Backend A│      │Backend B │      │
   │(8085)   │      │(8082)    │      │
   │TLS+JWT  │      │mTLS+JWT  │      │
   └─────────┘      └──────────┘      │
```

---

## Requisitos Previos

- **Java 21**: JDK instalado (verificar con `java -version`)
- **Maven 3.8.1+**: Build tool (verificar con `mvn -version`)
- **Git Bash** o terminal Unix/Linux: Para ejecutar scripts

---

## Archivos Generados

```
taller-clase-patrones/
├── backend-a/                          # Backend A - TLS Simple
│   ├── src/main/resources/certs/
│   │   ├── backend-a-keystore.p12     # Certificado servidor TLS
│   │   └── truststore.p12             # CA raíz para validar
│   └── ...
├── backend-b/                          # Backend B - mTLS
│   ├── src/main/resources/certs/
│   │   ├── backend-b-keystore.p12     # Certificado servidor mTLS
│   │   └── truststore.p12             # CA raíz + Cliente cert
│   └── ...
├── cliente/                            # Cliente - API Consumer
│   ├── src/main/resources/certs/
│   │   ├── cliente-keystore.p12       # Certificado cliente mTLS
│   │   └── truststore.p12             # Valida Backend A y B
│   └── ...
├── VERIFICACION_SEGURIDAD.md          # Resultados pruebas
└── test_security.sh                    # Script de pruebas
```

---

## Paso 1: Compilar los Servicios

### Backend A
```bash
cd backend-a/backend-a
./mvnw clean package -DskipTests
# o en Windows: mvnw.cmd clean package -DskipTests
```

### Backend B
```bash
cd backend-b/backend-b
./mvnw clean package -DskipTests
```

### Cliente
```bash
cd cliente/cliente
./mvnw clean package -DskipTests
```

---

## Paso 2: Iniciar los Servicios

**En 3 terminales separadas** (o en background):

### Terminal 1 - Backend A (Puerto 8085 - TLS)
```bash
cd backend-a/backend-a
export JAVA_HOME="/path/to/jdk-21"  # Si necesario
./mvnw spring-boot:run
# Esperado: "Started BackendAApplication in X seconds"
```

### Terminal 2 - Backend B (Puerto 8082 - mTLS)
```bash
cd backend-b/backend-b
export JAVA_HOME="/path/to/jdk-21"  # Si necesario
./mvnw spring-boot:run
# Esperado: "Started BackendBApplication in X seconds"
```

### Terminal 3 - Cliente (Puerto 8080)
```bash
cd cliente/cliente
export JAVA_HOME="/path/to/jdk-21"  # Si necesario
./mvnw spring-boot:run
# Esperado: "Started ClienteApplication in X seconds"
```

**Alternativa: Background con nohup**
```bash
cd backend-a/backend-a && nohup ./mvnw spring-boot:run > backend-a.log 2>&1 &
cd backend-b/backend-b && nohup ./mvnw spring-boot:run > backend-b.log 2>&1 &
cd cliente/cliente && nohup ./mvnw spring-boot:run > cliente.log 2>&1 &
```

---

## Paso 3: Verificar Puertos

```bash
# En Linux/Mac:
netstat -an | grep -E ":(8080|8082|8085)"

# En Windows:
netstat -ano | findstr ":8080\|:8082\|:8085"
```

Debe mostrar 3 conexiones LISTENING.

---

## Pruebas Manuales

### 1. Backend A - Endpoint Público (sin JWT)
```bash
curl -k https://localhost:8085/api/public
# Respuesta: "Endpoint público de Backend A - Accesible sin autenticación"
```

### 2. Backend A - Login & Obtener JWT
```bash
TOKEN=$(curl -s -k -X POST https://localhost:8085/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

echo "$TOKEN"
```

### 3. Backend A - Endpoint Protegido CON JWT
```bash
curl -s -k -H "Authorization: Bearer $TOKEN" \
  https://localhost:8085/api/protected
# Respuesta: "Endpoint protegido - Usuario: admin, Rol: null"
```

### 4. Backend A - Endpoint Protegido SIN JWT
```bash
curl -s -k https://localhost:8085/api/protected
# Respuesta: {"error": "Falta token JWT"}
# HTTP Status: 401 Unauthorized
```

### 5. Cliente Llamando Backend A
```bash
curl -s http://localhost:8080/api/call-backend-a
# Respuesta: "Respuesta de Backend A: Endpoint público..."
```

### 6. Cliente Llamando Backend B (con mTLS)
```bash
curl -s http://localhost:8080/api/call-backend-b
# Respuesta: Datos de Backend B con JWT validado
```

### 7. Información de Seguridad
```bash
# Backend A
curl -k https://localhost:8085/api/security-info

# Backend B
curl -k https://localhost:8082/api/security-info

# Cliente
curl http://localhost:8080/api/info
```

---

## Ejecutar Test Automatizado

```bash
bash test_security.sh
```

Esto ejecutará ~15 tests verificando:
- ✓ TLS en todos los servicios
- ✓ JWT generation y validation
- ✓ Endpoints públicos vs protegidos
- ✓ Comunicación inter-servicio
- ✓ Puertos correctos

---

## Endpoints Disponibles

### Backend A (https://localhost:8085)

| Endpoint | Método | Autenticación | Descripción |
|----------|--------|---------------|-------------|
| `/api/public` | GET | No | Público sin JWT |
| `/api/login` | POST | Body JSON | Genera JWT token |
| `/api/protected` | GET | JWT Bearer | Protegido por JWT |
| `/api/security-info` | GET | No | Info seguridad |

### Backend B (https://localhost:8082)

| Endpoint | Método | Autenticación | Descripción |
|----------|--------|---------------|-------------|
| `/api/login` | POST | Body JSON | Genera JWT token |
| `/api/protected` | GET | JWT + mTLS | Protegido JWT + cert cliente |
| `/api/health` | GET | No | Health check |
| `/api/security-info` | GET | No | Info seguridad |

### Cliente (http://localhost:8080)

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/info` | GET | Información del servicio |
| `/api/call-backend-a` | GET | Llama Backend A públicamente |
| `/api/call-backend-a-protected` | GET | Llama Backend A con JWT |
| `/api/call-backend-b` | GET | Llama Backend B (mTLS+JWT) |
| `/api/security-test` | GET | Test de seguridad completo |

---

## Detener Servicios

```bash
# Linux/Mac - Matar por puerto
lsof -ti:8080,8082,8085 | xargs kill -9

# Windows - PowerShell
Get-NetTCPConnection -LocalPort 8080,8082,8085 | Stop-Process -Force

# O simplemente presionar Ctrl+C en cada terminal
```

---

## Visualizar Logs

```bash
# Backend A
tail -f backend-a/backend-a/target/*.log

# Backend B
tail -f backend-b/backend-b/target/*.log

# Cliente
tail -f cliente/cliente/target/*.log
```

---

## Características de Seguridad Implementadas

### 1. TLS (Encryption in Transit)
- Protocolo: TLSv1.2
- Certificados: RSA 2048-bit
- Autoridad: Firma del profesor

### 2. mTLS (Mutual Authentication)
- Backend B requiere certificado de cliente
- Cliente presenta `cliente-keystore.p12`
- Validación recíproca de certificados

### 3. JWT (Stateless Authentication)
- Algoritmo: HS256 (HMAC-SHA256)
- Claims: `sub` (username), `iat`, `exp`
- Validación en endpoints protegidos

### 4. Certificate Chains
- Validación automática de cadena de certificados
- CA root en truststore compartido
- PKIX path building

---

## Troubleshooting

### Error: "Port already in use"
```bash
# Matar proceso en puerto X
lsof -ti:8085 | xargs kill -9
# o
netstat -ano | findstr ":8085"  # Obtener PID
taskkill /PID <PID> /F
```

### Error: "Certificate not found"
- Verificar que archivos `.p12` están en `src/main/resources/certs/`
- Verificar permisos de lectura

### Error: "PKIX path building failed"
- El truststore no contiene el certificado del servidor
- Verificar `truststore.p12` en todos los servicios

### Error: "Token inválido"
- Verificar que el token no ha expirado
- Verificar que el secret JWT es el mismo en todos los servicios

---

## Información Técnica

### Dependencias Principales
- Spring Boot 4.0.5
- JJWT 0.11.5 (JWT)
- Tomcat 11.0.20 (Embedded)
- Java 21

### Variables de Configuración
- Todos en `application.properties` de cada servicio
- Rutas de certificados: `src/main/resources/certs/`
- Passwords: `password123` (demo, cambiar en producción)

### Puertos Configurables
- Backend A: 8085 (modificable en `application.properties`)
- Backend B: 8082
- Cliente: 8080

---

## Próximos Pasos (Producción)

1. Cambiar todas las passwords de keystores
2. Usar certificados reales (no autofirmados)
3. Implementar rate limiting
4. Agregar logging centralizado (ELK stack)
5. Implementar OAuth2 / OpenID Connect
6. Agregar API Gateway con security policies

---

## Contacto & Evaluación

Sistema implementado para demostración de:
- ✅ PKI (Public Key Infrastructure)
- ✅ TLS/mTLS (Transport Security)
- ✅ JWT (Application Security)
- ✅ Inter-service Communication Security
- ✅ Certificate-based Authentication

**Estado**: ✅ Completamente funcional y listo para evaluación

**Fecha de completación**: 11 de Abril, 2026
