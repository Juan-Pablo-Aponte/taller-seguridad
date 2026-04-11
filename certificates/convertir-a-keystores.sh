#!/bin/bash

# Script para convertir certificados firmados a PKCS12 keystores
# Ejecutar DESPUÉS de que el profesor firme los CSRs y devuelva los .crt

set -e

echo "======================================"
echo "Convertendo certificados a keystores"
echo "======================================"

KEYSTORE_PASSWORD="password123"  # CAMBIAR EN PRODUCCION
DAYS_VALID=365

# ========================
# 1. CLIENTE - Keystore + Truststore
# ========================
echo ""
echo "[1/3] Procesando CLIENTE..."
cd cliente

if [ ! -f "cliente.crt" ]; then
  echo "ERROR: No encontré cliente.crt. ¿Lo colocaste aquí?"
  exit 1
fi

# Crear keystore (llave privada + certificado firmado)
openssl pkcs12 -export \
  -in cliente.crt \
  -inkey cliente-key.pem \
  -out cliente-keystore.p12 \
  -name cliente \
  -passout pass:$KEYSTORE_PASSWORD

echo "✓ Keystore creado: cliente-keystore.p12"
cd ..

# ========================
# 2. BACKEND A - Keystore
# ========================
echo ""
echo "[2/3] Procesando BACKEND A..."
cd ../backend-a/backend-a

if [ ! -f "../../certificates/backend-a/backend-a.crt" ]; then
  echo "ERROR: No encontré backend-a.crt"
  exit 1
fi

# Crear keystore
openssl pkcs12 -export \
  -in ../../certificates/backend-a/backend-a.crt \
  -inkey ../../certificates/backend-a/backend-a-key.pem \
  -out ../../certificates/backend-a/backend-a-keystore.p12 \
  -name backend-a \
  -passout pass:$KEYSTORE_PASSWORD

echo "✓ Keystore creado: backend-a-keystore.p12"
cd ../../certificates/backend-a

# ========================
# 3. BACKEND B - Keystore
# ========================
echo ""
echo "[3/3] Procesando BACKEND B..."
cd ../backend-b

if [ ! -f "backend-b.crt" ]; then
  echo "ERROR: No encontré backend-b.crt"
  exit 1
fi

# Crear keystore
openssl pkcs12 -export \
  -in backend-b.crt \
  -inkey backend-b-key.pem \
  -out backend-b-keystore.p12 \
  -name backend-b \
  -passout pass:$KEYSTORE_PASSWORD

echo "✓ Keystore creado: backend-b-keystore.p12"
cd ..

# ========================
# TRUSTSTORE - Para que los clientes confíen en los servidores
# ========================
echo ""
echo "======================================"
echo "Creando TRUSTSTORE (CA del profesor)"
echo "======================================"
echo ""
echo "Necesito el certificado CA del profesor."
echo "¿Ya tienes el archivo ca.crt?"
echo ""
read -p "Ruta del ca.crt del profesor: " CA_CERT_PATH

if [ ! -f "$CA_CERT_PATH" ]; then
  echo "ERROR: No encontré el archivo CA"
  exit 1
fi

# Crear truststore para todos los servicios
cd ..
keytool -import -alias ca -file "$CA_CERT_PATH" \
  -keystore truststore.p12 \
  -storetype PKCS12 \
  -storepass $KEYSTORE_PASSWORD \
  -noprompt

echo "✓ Truststore creado: truststore.p12"

# ========================
# Resumen
# ========================
echo ""
echo "======================================"
echo "✓ KEYSTORES Y TRUSTSTORES LISTOS"
echo "======================================"
echo ""
echo "Archivos generados:"
echo "  - cliente/cliente-keystore.p12"
echo "  - backend-a/backend-a-keystore.p12"
echo "  - backend-b/backend-b-keystore.p12"
echo "  - truststore.p12"
echo ""
echo "Contraseña: $KEYSTORE_PASSWORD"
echo ""
