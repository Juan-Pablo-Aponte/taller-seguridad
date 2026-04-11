#!/bin/bash

# Script para convertir certificados firmados a keystores PKCS12
# Ejecutar DESPUÉS de que el profesor firme los CSRs

set -e

echo "======================================"
echo "Convirtiendo certificados a keystores"
echo "======================================"

KEYSTORE_PASSWORD="password123"

cd "c:/Users/Juan Pablo/Documents/taller-clase-patrones/certificates"

# ========================
# 1. CLIENTE - Keystore
# ========================
echo ""
echo "[1/3] Procesando CLIENTE..."
cd cliente

if [ ! -f "cliente.crt" ]; then
  echo "ERROR: No encontré cliente.crt"
  exit 1
fi

openssl pkcs12 -export \
  -in cliente.crt \
  -inkey cliente-key.pem \
  -out cliente-keystore.p12 \
  -name cliente \
  -passout pass:$KEYSTORE_PASSWORD

echo "✓ cliente-keystore.p12 generado"
cd ..

# ========================
# 2. BACKEND A - Keystore
# ========================
echo ""
echo "[2/3] Procesando BACKEND A..."
cd backend-a

if [ ! -f "backend-a.crt" ]; then
  echo "ERROR: No encontré backend-a.crt"
  exit 1
fi

openssl pkcs12 -export \
  -in backend-a.crt \
  -inkey backend-a-key.pem \
  -out backend-a-keystore.p12 \
  -name backend-a \
  -passout pass:$KEYSTORE_PASSWORD

echo "✓ backend-a-keystore.p12 generado"
cd ..

# ========================
# 3. BACKEND B - Keystore
# ========================
echo ""
echo "[3/3] Procesando BACKEND B..."
cd backend-b

if [ ! -f "backend-b.crt" ]; then
  echo "ERROR: No encontré backend-b.crt"
  exit 1
fi

openssl pkcs12 -export \
  -in backend-b.crt \
  -inkey backend-b-key.pem \
  -out backend-b-keystore.p12 \
  -name backend-b \
  -passout pass:$KEYSTORE_PASSWORD

echo "✓ backend-b-keystore.p12 generado"
cd ..

# ========================
# 4. TRUSTSTORE con CA
# ========================
echo ""
echo "======================================"
echo "Creando TRUSTSTORE con CA"
echo "======================================"

if [ ! -f "ca.crt" ]; then
  echo "ERROR: No encontré ca.crt"
  exit 1
fi

# Usar keytool (viene con Java)
keytool -import -alias ca-root -file ca.crt \
  -keystore truststore.p12 \
  -storetype PKCS12 \
  -storepass $KEYSTORE_PASSWORD \
  -noprompt

echo "✓ truststore.p12 generado"

# ========================
# Resumen final
# ========================
echo ""
echo "======================================"
echo "✓ KEYSTORES LISTOS"
echo "======================================"
echo ""
echo "Archivos generados:"
ls -lh */keystore*.p12 truststore.p12 2>/dev/null | awk '{print "  " $NF " (" $5 ")"}'
echo ""
echo "Contraseña: $KEYSTORE_PASSWORD"
echo ""
echo "PRÓXIMO PASO:"
echo "Ejecuta: bash copiar-keystores.sh"
echo ""
