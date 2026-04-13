#!/bin/bash
# DEMO VIDEO COMPLETO - 5 MINUTOS
# Ejecutar con: bash demo-5min.sh

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       DEMOSTRACIÓN SEGURIDAD: TLS + mTLS + JWT (5 min)    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================
# PASO 1: LOGIN A BACKEND A (TLS + JWT)
# ============================================================
echo ""
echo "========== PASO 1: LOGIN BACKEND A =========="
echo ""
TOKEN=$(curl -s -k -X POST https://localhost:8085/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | python -c "import sys, json; print(json.load(sys.stdin)['token'])")

echo "✅ Token obtenido (primeros 60 caracteres):"
echo "   ${TOKEN:0:60}..."
echo ""
echo "Estructura JWT (3 partes separadas por '.'):"
HEADER=$(echo $TOKEN | cut -d'.' -f1)
PAYLOAD=$(echo $TOKEN | cut -d'.' -f2)
SIGNATURE=$(echo $TOKEN | cut -d'.' -f3)
echo "   Header:    ${HEADER:0:30}..."
echo "   Payload:   ${PAYLOAD:0:30}..."
echo "   Signature: ${SIGNATURE:0:30}..."

# ============================================================
# PASO 2: ACCESO PROTEGIDO EN BACKEND A
# ============================================================
echo ""
echo ""
echo "========== PASO 2: ACCESO PROTEGIDO BACKEND A =========="
echo ""
curl -s -k -H "Authorization: Bearer $TOKEN" https://localhost:8085/api/protected

# ============================================================
# PASO 3: SETUP PARA mTLS
# ============================================================
echo ""
echo ""
echo "========== PASO 3: CONVERTIR CERTIFICADOS (setup mTLS) =========="
echo ""

TEMP_DIR="${TEMP:-${USERPROFILE}/AppData/Local/Temp}"
echo "Usando directorio temp: $TEMP_DIR"
echo ""

# Convertir PKCS12 a PEM
openssl pkcs12 -in certificates/cliente/cliente-keystore.p12 \
  -out "$TEMP_DIR/cliente-cert.pem" -clcerts -nokeys \
  -password pass:password123 2>/dev/null

openssl pkcs12 -in certificates/cliente/cliente-keystore.p12 \
  -out "$TEMP_DIR/cliente-key.pem" -nocerts -nodes \
  -password pass:password123 2>/dev/null

echo "✅ Certificados preparados en PEM"

# ============================================================
# PASO 4: LOGIN A BACKEND B (mTLS + JWT)
# ============================================================
echo ""
echo ""
echo "========== PASO 4: LOGIN BACKEND B (mTLS + JWT) =========="
echo ""

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

echo "✅ Token obtenido del Backend B (mTLS):"
echo "   ${TOKEN_B:0:60}..."

# ============================================================
# PASO 5: ACCESO PROTEGIDO EN BACKEND B
# ============================================================
echo ""
echo ""
echo "========== PASO 5: ACCESO PROTEGIDO BACKEND B (mTLS + JWT) =========="
echo ""

python << PYTHON_EOF
import requests, warnings, os
warnings.filterwarnings('ignore')

temp_dir = os.environ.get('TEMP', os.path.expandvars('\${USERPROFILE}/AppData/Local/Temp'))
cert_files = (os.path.join(temp_dir, 'cliente-cert.pem'), os.path.join(temp_dir, 'cliente-key.pem'))

response = requests.get(
    'https://localhost:8082/api/protected',
    headers={'Authorization': 'Bearer $TOKEN_B'},
    cert=cert_files,
    verify=False
)

print(response.text)
PYTHON_EOF

# ============================================================
# CASOS FALLIDOS
# ============================================================
echo ""
echo ""
echo "========== DEMOSTRACIÓN: SEGURIDAD EN ACCIÓN =========="
echo ""

echo "❌ FALLO 1: Acceso sin JWT"
echo "   comando: curl https://localhost:8085/api/protected"
curl -s -k https://localhost:8085/api/protected | head -5
echo ""

echo "❌ FALLO 2: JWT inválido"
echo "   comando: curl con JWT falso"
curl -s -k -H "Authorization: Bearer tokenInvalido123" https://localhost:8085/api/protected | head -5
echo ""

echo "❌ FALLO 3: Sin certificado mTLS"
echo "   comando: curl https://localhost:8082/api/protected (sin cert)"
echo "   (Conexión TLS rechazada en capa SSL - no llega al código)"
curl -v -k https://localhost:8082/api/protected 2>&1 | grep -i "certificate" | head -3 || echo "   → Conexión rechazada por SSL/TLS"

# ============================================================
# RESUMEN
# ============================================================
echo ""
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    RESUMEN SEGURIDAD                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ CAPA 1: TLS / mTLS"
echo "   → Backend A: Servidor autenticado (TLS)"
echo "   → Backend B: Servidor + Cliente autenticados (mTLS)"
echo "   → Certificados del profesor = confianza"
echo ""
echo "✅ CAPA 2: JWT"
echo "   → Token con firma HMAC-SHA256"
echo "   → Imposible falsificar sin clave secreta"
echo "   → Valida identidad del usuario"
echo ""
echo "✅ CAPA 3: Defensa en profundidad"
echo "   → 3 capas: TLS + mTLS + JWT"
echo "   → Si rompen una, quedan 2"
echo "   → Muy usado en producción (Netflix, AWS, Google)"
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    FIN DE DEMOSTRACIÓN                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
