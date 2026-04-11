# INDEX - Archivos Importantes del Proyecto

## 📄 Documentación (EMPEZAR AQUÍ)

### Para Profesores/Evaluadores
1. **SUMMARY.md** ⭐ LEER PRIMERO
   - Resumen ejecutivo del proyecto
   - Estado final del sistema
   - Requisitos cumplidos
   - Conclusiones

2. **VERIFICACION_SEGURIDAD.md** ⭐ REVISAR RESULTADOS
   - Todas las pruebas ejecutadas
   - Casos de uso demostrados
   - Evidencia de funcionamiento
   - Características verificadas

### Para Ejecutar el Sistema
3. **README_EJECUCION.md** 📖 GUÍA COMPLETA
   - Paso a paso para compilar
   - Paso a paso para ejecutar
   - Cómo verificar puertos
   - Troubleshooting

4. **QUICK_TEST.sh** ⚡ PRUEBAS RÁPIDAS
   - Comandos individuales para probar
   - Copy-paste ready
   - Explicación de cada test
   - Referencia rápida

### Para Pruebas Automatizadas
5. **test_security.sh** 🤖 TEST SUITE
   - ~15 tests automatizados
   - Verifica todas las características
   - Reporta resultados
   - Exit code para CI/CD

---

## 💾 Código Fuente

### Backend A (TLS)
```
backend-a/backend-a/src/main/java/co/edu/unisabana/backend_a/
├── BackendAApplication.java
│   └── Punto de entrada Spring Boot
│
├── controller/
│   └── BackendAController.java ⭐ ENDPOINTS
│       ├── GET /api/public
│       ├── POST /api/login
│       ├── GET /api/protected
│       └── GET /api/security-info
│
├── service/
│   └── BackendAService.java
│       └── Lógica de negocio
│
├── util/
│   └── JwtUtil.java ⭐ JWT GENERATION/VALIDATION
│       ├── Generación de tokens
│       ├── Validación de firmas
│       └── Extracción de claims
│
└── config/
    └── JwtAuthFilter.java ⭐ SECURITY MIDDLEWARE
        ├── Filtro de JWT
        ├── Lista blanca de endpoints públicos
        ├── Rechazo de requests sin JWT
        └── Extracción de usuario
```

### Backend B (mTLS)
```
backend-b/backend-b/src/main/java/co/edu/unisabana/backend_b/
├── (Estructura similar a Backend A)
├── BackendBController.java
│   ├── Endpoints protegidos por mTLS + JWT
│   └── Validación de certificado cliente
└── config/
    └── JwtAuthFilter.java
        └── (Adaptado para mTLS)
```

### Cliente (Proxy)
```
cliente/cliente/src/main/java/co/edu/unisabana/cliente/
├── ClienteApplication.java
│   └── Punto de entrada
│
├── controller/
│   └── ClienteController.java ⭐ PROXY ENDPOINTS
│       ├── GET /api/info
│       ├── GET /api/call-backend-a
│       ├── GET /api/call-backend-a-protected
│       └── GET /api/call-backend-b
│
├── service/
│   └── BackendClientService.java ⭐ HTTP CLIENT
│       ├── Llama Backend A (TLS)
│       ├── Llama Backend B (mTLS)
│       └── Propaga JWT
│
├── util/
│   └── JwtUtil.java
│       └── Generación de tokens
│
└── config/
    └── RestTemplateConfiguration.java ⭐ SSL SETUP
        ├── Carga truststore
        ├── Configura SSLContext
        └── Valida certificados
```

---

## 🔐 Certificados y Keystores

### Ubicaciones
```
backend-a/src/main/resources/certs/
├── backend-a-keystore.p12    ← Servidor TLS (Backend A)
└── truststore.p12             ← CA root + certs públicos

backend-b/src/main/resources/certs/
├── backend-b-keystore.p12    ← Servidor mTLS (Backend B)
└── truststore.p12             ← CA root + Cliente cert

cliente/src/main/resources/certs/
├── cliente-keystore.p12      ← Cliente mTLS (para Backend B)
└── truststore.p12             ← Valida ambos backends
```

### Información de Certificados
```
Format: PKCS12 (.p12)
Key Size: RSA 2048-bit
Password: password123
CA: Firma de profesor
Validity: Válidos para workshop

⚠️ Cambiar passwords en PRODUCCIÓN
```

---

## 📋 Archivos de Configuración

### Backend A
```
backend-a/src/main/resources/application.properties
├── server.port=8085
├── server.ssl.key-store=classpath:certs/backend-a-keystore.p12
├── jwt.secret=mi-secret-super-seguro-que-debe-tener-minimo-32-caracteres
├── jwt.expiration=86400000 (24 horas)
└── logging.level=INFO
```

### Backend B
```
backend-b/src/main/resources/application.properties
├── server.port=8082
├── server.ssl.key-store=classpath:certs/backend-b-keystore.p12
├── server.ssl.client-auth=need ⭐ (REQUIERE CERT CLIENTE)
├── server.ssl.trust-store=classpath:certs/truststore.p12
└── [JWT config igual a Backend A]
```

### Cliente
```
cliente/src/main/resources/application.properties
├── server.port=8080
├── server.ssl.enabled=false (Solo HTTP externamente)
├── client.truststore.path=classpath:certs/truststore.p12
├── backend.a.url=https://localhost:8085 ⭐ (Cambió de 8081)
├── backend.b.url=https://localhost:8082
└── [JWT config igual a Backend A]
```

---

## 🏗️ Estructura de Directorios Completa

```
taller-clase-patrones/
│
├── backend-a/
│   ├── backend-a/          ← El proyecto actual
│   │   ├── pom.xml         ← Maven config, JDK 21, JJWT 0.11.5
│   │   ├── src/
│   │   ├── target/         ← Compilados
│   │   ├── mvnw            ← Maven wrapper script
│   │   └── mvnw.cmd        ← Maven wrapper Windows
│   └── HELP.md
│
├── backend-b/
│   ├── backend-b/
│   │   ├── pom.xml
│   │   ├── src/
│   │   ├── target/
│   │   ├── mvnw
│   │   └── mvnw.cmd
│   └── HELP.md
│
├── cliente/
│   ├── cliente/
│   │   ├── pom.xml
│   │   ├── src/
│   │   ├── target/
│   │   ├── mvnw
│   │   └── mvnw.cmd
│   └── HELP.md
│
├── SUMMARY.md                 ⭐ LEER: Resumen ejecutivo
├── VERIFICACION_SEGURIDAD.md  ⭐ LEER: Resultados pruebas
├── README_EJECUCION.md        ⭐ LEER: Cómo ejecutar
├── QUICK_TEST.sh              ⭐ LEER: Tests rápidos
├── test_security.sh           ⭐ LEER: Suite completa
└── INDEX.md (Este archivo)    ← Estás aquí
```

---

## 🧪 Cómo Reviews/Verificar el Proyecto

### Para Revisar Rápidamente (5 minutos)
1. Leer `SUMMARY.md`
2. Revisar `VERIFICACION_SEGURIDAD.md` sección "Pruebas Ejecutadas"
3. Ver estructura en `INDEX.md`

### Para Ejecutar y Verificar (15 minutos)
1. Seguir `README_EJECUCION.md` Paso 1 y 2
2. Ejecutar en terminal: `bash test_security.sh`
3. Todos los tests deben pasar ✓

### Para Inspección Detallada (30+ minutos)
1. Revisar código en `JwtUtil.java` (genera/valida JWT)
2. Revisar código en `JwtAuthFilter.java` (aplica seguridad)
3. Revisar código en `RestTemplateConfiguration.java` (maneja TLS)
4. Revisar `application.properties` (configuración SSL)
5. Ejecutar tests individuales en `QUICK_TEST.sh`

---

## 🎯 Puntos Clave para Evaluadores

### ✅ TLS Implementation
- 📁 Ver: `application.properties` (server.ssl.*)
- 📄 Ver: `RestTemplateConfiguration.java` (carga truststore)
- 🔑 Ver: Certificados en `src/main/resources/certs/`

### ✅ JWT Implementation
- 🔐 Ver: `JwtUtil.java` (generación y validación)
- 🚪 Ver: `JwtAuthFilter.java` (middleware)
- 📝 Ver: `BackendAController.java` (endpoints /login, /protected)

### ✅ mTLS Implementation
- 🔒 Ver: Backend B `application.properties` (server.ssl.client-auth=need)
- 🔑 Ver: `cliente-keystore.p12` (certificado cliente) en Cliente
- 🌐 Ver: `ClienteController.java` (llama Backend B)

### ✅ Security Features
- 🌐 Public endpoints: Endpoints sin JWT en BackendAController
- 🔐 Protected endpoints: Mismos endpoints con JWT requerido
- 📡 Inter-service: ClienteController llama Backend A y B vía HTTPS+JWT
- ✓ Validation: Automaticidad gracias a Java's SSLContext

---

## 📞 Contacto y Notas

**Proyecto Completado**: 11 de Abril, 2026  
**Estado**: ✅ Completamente funcional  
**Todos los requisitos**: ✅ Implementados  
**Documentación**: ✅ Completa  
**Tests**: ✅ Todos pasan  

---

## 🔗 Referencias Rápidas

| Tema | Archivo | Líneas |
|------|---------|---------|
| JWT Generation | `JwtUtil.java` | Token creation method |
| JWT Validation | `JwtUtil.java` | Validation method |
| JWT Middleware | `JwtAuthFilter.java` | Dofilter method |
| Public Endpoints List | `JwtAuthFilter.java` | Line: path.equals("/api/public") |
| TLS Config | `application.properties` | server.ssl.* properties |
| mTLS Config | Backend B `application.properties` | server.ssl.client-auth |
| RestTemplate SSL | `RestTemplateConfiguration.java` | Complete class |
| Inter-service Calls | `BackendClientService.java` | Complete class |
| Portal HTTP | `ClienteController.java` | All endpoints |

---

**FIN - INDEX**

Para comenzar: Leer `SUMMARY.md` → `README_EJECUCION.md` → Ejecutar `test_security.sh`
