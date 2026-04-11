# ✅ MICROSERVICIOS SEGUROS - ESTADO FINAL

**Fecha**: 11 de abril de 2026  
**Estado**: 🟢 LISTO PARA EJECUCIÓN

---

## 📊 RESUMEN EJECUTIVO

Todos los objetivos del proyecto han sido implementados:

| Objetivo | Estado | Detalles |
|----------|--------|----------|
| **PKI / Certificados** | ✅ Completo | CSRs generadas, firmadas por CA del profesor, keystores creados |
| **Backend A (TLS)** | ✅ Completo | Servidor con HTTPS, sin mTLS requerido |
| **Backend B (mTLS)** | ✅ Completo | Servidor con HTTPS + autenticación mutua (cliente debe presentar certificado) |
| **Cliente** | ✅ Completo | Consume ambos backends de forma segura |
| **JWT** | ✅ Completo | Generación, validación y verificación de tokens firmados |
| **Compilación** | ✅ Completo | Los 3 servicios compilan sin errores |

---

## 🔧 CONFIGURACIÓN ACTUAL

### Certificados
```
certificates/
├── ca.crt                           (CA raíz del profesor)
├── truststore.p12                  (para que los clientes confíen en los servidores)
├── backend-a/
│   ├── backend-a-keystore.p12     (certificado + clave privada)
│   └── truststore.p12              (para validar CA)
├── backend-b/
│   ├── backend-b-keystore.p12     (certificado + clave privada)
│   └── truststore.p12              (para validar CA)  
└── cliente/
    ├── cliente-keystore.p12       (para autenticarse en Backend B - mTLS)
    └── truststore.p12              (para validar ambos backends)
```

**Contraseña de keystores**: `password123`

### Puertos
- **Cliente**: 8080 (HTTP con RestTemplate que llamará HTTPS)
- **Backend A**: 8081 (HTTPS - TLS)
- **Backend B**: 8082 (HTTPS - mTLS)

### Algoritmos
- **Certificados**: RSA 2048 bits, compilidos X.509, SHA-256
- **HTTPS/TLS**: TLSv1.2
- **JWT**: HS256 (HMAC-SHA256)

---

## 🚀 CÓMO EJECUTAR

### Opción 1: Línea de comandos (3 terminales)

**Terminal 1 - Backend A:**
```bash
export JAVA_HOME="/c/Program Files/Java/jdk-21.0.10"
export PATH="$JAVA_HOME/bin:$PATH"

cd backend-a/backend-a
./mvnw spring-boot:run
```

**Terminal 2 - Backend B:**
```bash
export JAVA_HOME="/c/Program Files/Java/jdk-21.0.10"
export PATH="$JAVA_HOME/bin:$PATH"

cd backend-b/backend-b
./mvnw spring-boot:run
```

**Terminal 3 - Cliente:**
```bash
export JAVA_HOME="/c/Program Files/Java/jdk-21.0.10"
export PATH="$JAVA_HOME/bin:$PATH"

cd cliente/cliente
./mvnw spring-boot:run
```

### Opción 2: VSCode
1. Abre cada carpeta en una terminal integrada diferente
2. Ejecuta `./mvnw spring-boot:run` en cada una

---

## 🧪 TESTS DE SEGURIDAD

Una vez que los 3 servicios estén ejecutándose, prueba estos casos:

### Test 1: Backend A - Endpoint Público (SIN autenticación)
```bash
curl -k https://localhost:8081/api/public
```
✅ **Esperado**: Respuesta exitosa (200 OK)

### Test 2: Backend A - Login (generar JWT)
```bash
TOKEN=$(curl -k -X POST https://localhost:8081/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"juan","role":"USER"}' \
  | jq -r '.token')

echo "Token générido: $TOKEN"
```

### Test 3: Backend A - Endpoint Protegido (CON JWT válido)
```bash
curl -k -H "Authorization: Bearer $TOKEN" \
  https://localhost:8081/api/protected
```
✅ **Esperado**: Respuesta con usuario y rol (200 OK)

### Test 4: Backend A - JWT Inválido (DEBE RECHAZAR)
```bash
curl -k -H "Authorization: Bearer INVALID_TOKEN" \
  https://localhost:8081/api/protected
```
❌ **Esperado**: Error 401 Unauthorized

### Test 5: Backend B - SIN certificado del cliente (DEBE RECHAZAR)
```bash
curl -k -X POST https://localhost:8082/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"cliente","role":"SERVICE"}'
```
❌ **Esperado**: Error SSL (certificate required o similar)

### Test 6: Cliente - Llamada a Backend A (TLS)
```bash
curl -k https://localhost:8080/api/call-backend-a
```
✅ **Esperado**: Respuesta del Backend A a través del Cliente

### Test 7: Cliente - Llamada a Backend B (mTLS)
```bash
curl -k https://localhost:8080/api/call-backend-b
```
✅ **Esperado**: Respuesta del Backend B (mTLS funciona correctamente)

### Test 8: Cliente - Test Completo
```bash
curl -k https://localhost:8080/api/security-test
```
✅ **Esperado**: Resumen completo de seguridad y pruebas

---

## 📋 EVIDENCIA DE IMPLEMENTACIÓN

### 1. Criptografía Asimétrica
- ✓ RSA 2048 bits para certificados X.509
- ✓ HMAC-SHA256 para firmar JWT
- ✓ Diferenciación entre llaves para transporte (TLS) vs autenticación (JWT)

### 2. TLS (Transporte Seguro - Backend A)
- ✓ Servidor con certificado firmado por CA
- ✓ Cliente confía en certificado via truststore
- ✓ Comunicación cifrada (HTTPS)
- ✓ Sin autenticación de cliente requerida

### 3. mTLS (Autenticación Mutua - Backend B)
- ✓ Servidor exige certificado del cliente
- ✓ Servidor valida certificado del cliente contra CA
- ✓ Cliente se presenta con su certificado
- ✓ Ambos se autentican mutuamente

### 4. JWT (Autenticación de Usuarios)
- ✓ Generación de tokens con claims (username, role)
- ✓ Firma con llave privada (HS256)
- ✓ Validación de firma en middleware
- ✓ Extracción de claims para autorización
- ✓ Validación de expiración

### 5. Confianza Basada en CA
- ✓ CA del profesor como autoridad raíz
- ✓ Keystores contienen certificados firmados por la CA
- ✓ Truststores contienen el certificado raíz de la CA
- ✓ Solo se aceptan certificados en la cadena de confianza

---

## 📁 ESTRUCTURA DEL PROYECTO

```
taller-clase-patrones/
├── ANALISIS_ESTADO.md              (análisis vs objetivos)
├── SETUP_COMPLETO.md               (guía de configuración)
├── RESUMEN_FINAL.md                (este archivo)
│
├── certificates/
│   ├── ca.crt
│   ├── truststore.p12
│   ├── backend-a/
│   ├── backend-b/
│   └── cliente/
│
├── backend-a/backend-a/
│   ├── src/main/java/co/edu/unisabana/backend_a/
│   │   ├── config/
│   │   │   ├── JwtUtil.java        (genera/valida JWT)
│   │   │   └── JwtAuthFilter.java  (valida JWT en requests)
│   │   ├── controller/
│   │   │   └── BackendAController.java
│   │   └── BackendAApplication.java
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   └── certs/backend-a-keystore.p12
│   └── pom.xml
│
├── backend-b/backend-b/
│   ├── src/main/java/co/edu/unisabana/backend_b/
│   │   ├── config/
│   │   │   ├── JwtUtil.java
│   │   │   └── JwtAuthFilter.java
│   │   ├── controller/
│   │   │   └── BackendBController.java
│   │   └── BackendBApplication.java
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   ├── certs/backend-b-keystore.p12
│   │   └── certs/truststore.p12
│   └── pom.xml
│
└── cliente/cliente/
    ├── src/main/java/co/edu/unisabana/cliente/
    │   ├── config/
    │   │   ├── JwtUtil.java
    │   │   └── RestTemplateConfiguration.java
    │   ├── service/
    │   │   └── BackendClientService.java
    │   ├── controller/
    │   │   └── ClienteController.java
    │   └── ClienteApplication.java
    ├── src/main/resources/
    │   ├── application.properties
    │   └── certs/
    │       ├── cliente-keystore.p12
    │       └── truststore.p12
    └── pom.xml
```

---

## 🔍 ARQUITECTURA DE SEGURIDAD

```
                    ┌──────────────────────────┐
                    │   CLIENTE (8080 HTTP)    │
                    │                          │
                    │ - Genera JWT             │
                    │ - Confía en CA           │
                    │ - Presenta certificado   │
                    │   a Backend B (mTLS)     │
                    └──────────────────────────┘
                              │
                ┌─────────────┴──────────────┐
                │                            │
                ▼                            ▼
        ┌──────────────────┐      ┌──────────────────┐
        │ Backend A (8081) │      │ Backend B (8082) │
        │   TLS            │      │   mTLS           │
        │                  │      │                  │
        │ - Certificado    │      │ - Certificado    │
        │ - Valida JWT     │      │ - Valida JWT     │
        │ - NO pide        │      │ - EXIGE          │
        │   certificado    │      │   certificado    │
        │   al cliente     │      │   del cliente    │
        └──────────────────┘      └──────────────────┘
              │                              │
              │                              │
              └──────────────┬───────────────┘
                            │
                     ┌──────▼────────┐
                     │   CA RAÍZ     │
                     │  (Profesor)   │
                     └───────────────┘
```

---

## ✨ PUNTOS CLAVE IMPLEMENTADOS

### Conceptos Demostrados
1. **PKI (Public Key Infrastructure)**: Jerarquía de confianza con CA
2. **Criptografía Asimétrica**: RSA para certificados, HMAC para JWT
3. **TLS**: Cifrado de transporte con validación de servidor
4. **mTLS**: Autenticación mutua servidor-cliente
5. **JWT**: Autenticación/autorización de usuarios independiente del transporte
6. **Separación de Responsabilidades**: Transporte seguro (TLS) vs autenticación de app (JWT)

### Seguridad Implementada
- ✓ Conocimiento de la CA antes de confiar en certificados
- ✓ Validación de cadenas de certificados
- ✓ Rechazo de certificados no confiables
- ✓ Firma digital de tokens con verificación
- ✓ Expiración de tokens
- ✓ Autenticación bidireccional (mTLS)

---

## 🎓 APRENDIZAJES CLAVE

### Diferencias
| Aspecto | TLS | mTLS | JWT |
|--------|-----|------|-----|
| **Qué asegura** | Cifrado de transporte | Autenticación mutua | Autenticación de usuario |
| **Quién se autentica** | Solo servidor | Servidor + cliente | Aplicación |
| **Nivel OSI** | Capa 4 (Transporte) | Capa 4 (Transporte) | Capa 7 (Aplicación) |
| **Certificados** | Sí | Sí | No (usa llaves simétricas) |
| **Revalidación** | Por sesión | Por sesión | Por token (configurable) |

### Casos de Uso
- **TLS**: Proteger comunicación con servidor público (HTTPS normal)
- **mTLS**: Comunicación segura entre microservicios confiables
- **JWT**: Autorización granular dentro de la aplicación (roles, permisos)

---

## ⚠️ NOTAS IMPORTANTES

### Para Producción
- [ ] Cambiar contraseña de keystores (`password123`)
- [ ] Usar certificados de una CA reconocida (no autofirmados)
- [ ] Implementar rotación de certificados
- [ ] Usar secret management para guardar contraseñas
- [ ] Implementar validación adicional de revocación de certificados
- [ ] Agregar logs and monitoring

### Limitaciones Actuales
- RestTemplate configurado de forma simplificada (ver `RestTemplateConfiguration.java`)
- JWT usa HS256 (simétrico), puede cambiarse a RS256 (asimétrico) si es necesario
- No hay implementación de Certificate Pinning
- No hay CRL (Certificate Revocation List) validation

---

## 📞 Próximos Pasos

1. **Ejecutar los 3 servicios** según instrucciones arriba
2. **Ejecutar tests** del apartado "Tests de Seguridad"
3. **Validar que se comportan como se especifica**
4. **Documentar hallazgos** en reporte final
5. **Crear diagramas** (opcional pero recomendado)

---

## ✅ CHECKLIST DE ENTREGAS

### Código
- [x] Backend A implementado (TLS)
- [x] Backend B implementado (mTLS)
- [x] Cliente implementado (TLS + mTLS)
- [x] JWT implementado en los 3 servicios
- [x] Compilación exitosa

### Configuración
- [x] Certificados generados y firmados
- [x] Keystores generados
- [x] Truststores generados
- [x] application.properties configurados
- [x] Recursos copiados correctamente

### Documentación
- [x] SETUP_COMPLETO.md (guía de configuración)
- [x] ANALISIS_ESTADO.md (análisis vs objetivos)
- [x] RESUMEN_FINAL.md (este archivo)
- [ ] Diagramas de arquitectura (opcional)

### Tests
- [ ] Tests manuales ejecutados
- [ ] Casos exitosos verificados
- [ ] Casos de rechazo verificados
- [ ] Reporte de resultados

---

**¿Necesitas ayuda para ejecutar los servicios o entender algo específico?**

