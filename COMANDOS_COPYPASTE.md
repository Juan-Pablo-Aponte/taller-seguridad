# 📋 COMANDOS COPYPASTE (5 MIN VIDEO)

**Ultra-condensado para máximo 5 minutos**
**Reemplaza `c:/Users/Juan Pablo/...` con tu ruta real**

---

## ⏱️ [0:00-0:30] CERTIFICADOS

```bash
cd c:/Users/Juan Pablo/Documents/GitHub/taller-seguridad

# Mostrar certificados
openssl x509 -in certificates/backend-a/backend-a.crt -text -noout | grep -E "Subject:|Issuer:|Public-Key:"

# Verificar firma
openssl verify -CAfile certificates/ca.crt certificates/backend-a/backend-a.crt
# Output: OK ✅
```

---

## ⏱️ [0:30-1:30] DIFERENCIAS TLS vs mTLS

```bash
echo "========== BACKEND A (TLS) =========="
grep "server.ssl" backend-a/backend-a/src/main/resources/application.properties | grep -v "^#"

echo ""
echo "========== BACKEND B (mTLS) =========="
grep "server.ssl" backend-b/backend-b/src/main/resources/application.properties | grep -v "^#"

echo ""
echo "========== DIFERENCIA CLAVE =========="
echo "Backend B tiene: server.ssl.client-auth=need"
echo "Eso requiere certificado del cliente."
---

## ⏱️ [1:30-2:30] JWT FLUJO

```bash
echo "========== GENERACIÓN JWT =========="
echo "(Mostrar código JwtUtil.java)"

echo ""
echo "========== OBTENER TOKEN =========="
TOKEN=$(curl -s -k -X POST https://localhost:8085/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | python -c "import sys, json; print(json.load(sys.stdin)['token'])")

echo "Token: ${TOKEN:0:80}..."

echo ""
echo "========== DECODIFICAR (partes separadas por .) =========="
echo "Header: ${TOKEN%%.*}"
echo "Payload: $(echo ${TOKEN} | cut -d'.' -f2)"
echo "Signature: $(echo ${TOKEN} | rev | cut -d'.' -f1 | rev)"
```

---

## ⏱️ [2:30-4:00] DEMO COMPLETA (COPIAR TODO DE UNA VEZ)

```bash
echo "========== INICIAR SERVIDORES =========="
echo "(Abre en Terminal 1, 2, 3 y espera 'Started')"

echo ""
echo "========== PASO 1: LOGIN BACKEND A =========="
TOKEN=$(curl -s -k -X POST https://localhost:8085/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | python -c "import sys, json; print(json.load(sys.stdin)['token'])")

echo "✅ Token Backend A: ${TOKEN:0:60}..."

echo ""
echo "========== PASO 2: ACCESO PROTEGIDO BACKEND A =========="
curl -sk -H "Authorization: Bearer $TOKEN" https://localhost:8085/api/protected

echo ""
echo ""
echo "========== PASO 3: LOGIN BACKEND B (con mTLS) =========="
# En Windows, usar TEMP o USERPROFILE
TEMP_DIR="${TEMP:-${USERPROFILE}/AppData/Local/Temp}"

# Convertir certificado PKCS12 a PEM
openssl pkcs12 -in certificates/cliente/cliente-keystore.p12 -out "$TEMP_DIR/cliente-cert.pem" -clcerts -nokeys -password pass:password123 2>/dev/null
openssl pkcs12 -in certificates/cliente/cliente-keystore.p12 -out "$TEMP_DIR/cliente-key.pem" -nocerts -nodes -password pass:password123 2>/dev/null

# Login con mTLS
TOKEN_B=$(python << 'PYTHON_EOF'
import requests, warnings, os
warnings.filterwarnings('ignore')
temp_dir = os.environ.get('TEMP', os.path.expandvars('${USERPROFILE}/AppData/Local/Temp'))
cert_files = (os.path.join(temp_dir, 'cliente-cert.pem'), os.path.join(temp_dir, 'cliente-key.pem'))
response = requests.post(
    'https://localhost:8082/api/login',
    json={'username': 'cliente', 'password': 'password'},
    cert=cert_files,
    verify=False
)
print(response.json()['token'])
PYTHON_EOF
)

echo "✅ Token Backend B: ${TOKEN_B:0:60}..."

echo ""
echo "========== PASO 4: ACCESO PROTEGIDO BACKEND B (con mTLS) =========="
python << 'PYTHON_EOF'
import requests, warnings, os
warnings.filterwarnings('ignore')
temp_dir = os.environ.get('TEMP', os.path.expandvars('${USERPROFILE}/AppData/Local/Temp'))
cert_files = (os.path.join(temp_dir, 'cliente-cert.pem'), os.path.join(temp_dir, 'cliente-key.pem'))
response = requests.get(
    'https://localhost:8082/api/protected',
    headers={'Authorization': f'Bearer ${TOKEN_B}'},
    cert=cert_files,
    verify=False
)
print(response.text)
PYTHON_EOF
```

---

## 🎟️ SECCIÓN 4: JWT

### 4.1 Iniciar Cliente

**En Terminal 3:**

```bash
cd c:/Users/Juan Pablo/Documents/GitHub/taller-seguridad/cliente/cliente
./mvnw spring-boot:run
```

**Esperar a ver: `Started ClienteApplication in X.XXX seconds`**

### 4.2 Obtener Token (Terminal 0)

```bash
# Obtener token de Backend A
TOKEN=$(curl -s -k -X POST https://localhost:8085/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | python -c "import sys, json; print(json.load(sys.stdin)['token'])")

echo "Token obtenido:"
echo $TOKEN
```

---

## ⏱️ [4:30-5:00] CONCLUSIÓN

```bash
echo "========== RESUMEN: 3 CAPAS SEGURIDAD =========="
echo ""
echo "CAPA 1: TLS/mTLS"
echo "  → Certificados del profesor = confianza"
echo "  → mTLS = más seguro (bidireccional)"
echo ""
echo "CAPA 2: JWT"
echo "  → Token con firma HMAC-SHA256"
echo "  → Imposible falsificar"
echo ""
echo "CAPA 3: Defensa en Profundidad"
echo "  → Si rompen 1 capa, quedan 2"
echo ""
echo "========== USADO EN PRODUCCIÓN =========="
echo "Netflix, AWS, Google usan esto."
```

---

## RESTO DE COMANDOS (SI NECESITAS MÁS DETALLES)

Todo lo anterior es suficiente para 5 minutos.
Si grabas más lentamente, agrega estos comandos adicionales:

---

## NOTAS FINALES

- Si los servicios no están iniciados, cópialos a Terminal 1, 2, 3
- Espera "Started..." antes de ejecutar comandos
- `-s` en curl = silencioso, `-k` = ignorar SSL validation
- `${TOKEN:0:60}` = primeros 60 caracteres del token

---

**Última actualización: 12 de Abril de 2026 - Versión 5 minutos**
