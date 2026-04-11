#!/bin/bash

# Script para generar CSRs (Certificate Signing Requests) y claves privadas
# El profesor firmará estos CSRs con su CA y devolverá los certificados firmados

set -e

echo "======================================"
echo "Generando CSRs para firmar por CA"
echo "======================================"

# Parámetros de la CA del profesor (ajusta según corresponda)
DAYS_VALID=365
KEY_SIZE=2048

# ========================
# 1. CLIENTE (MS Cliente)
# ========================
echo ""
echo "[1/3] Generando certificados para CLIENTE..."
mkdir -p cliente
cd cliente

# Generar clave privada
openssl genrsa -out cliente-key.pem $KEY_SIZE

# Generar CSR
openssl req -new \
  -key cliente-key.pem \
  -out cliente.csr \
  -subj "//C=CO\\ST=Cundinamarca\\L=Bogota\\O=Unisabana\\CN=cliente"

echo "✓ CSR generado: cliente/cliente.csr"
echo "  Clave privada: cliente/cliente-key.pem (GUARDAR PRIVADO)"
cd ..

# ========================
# 2. BACKEND A (TLS)
# ========================
echo ""
echo "[2/3] Generando certificados para BACKEND A..."
mkdir -p backend-a
cd backend-a

# Generar clave privada
openssl genrsa -out backend-a-key.pem $KEY_SIZE

# Generar CSR
openssl req -new \
  -key backend-a-key.pem \
  -out backend-a.csr \
  -subj "/C=CO/ST=Cundinamarca/L=Bogota/O=Unisabana/CN=backend-a"

echo "✓ CSR generado: backend-a/backend-a.csr"
echo "  Clave privada: backend-a/backend-a-key.pem (GUARDAR PRIVADO)"
cd ..

# ========================
# 3. BACKEND B (mTLS)
# ========================
echo ""
echo "[3/3] Generando certificados para BACKEND B..."
mkdir -p backend-b
cd backend-b

# Generar clave privada
openssl genrsa -out backend-b-key.pem $KEY_SIZE

# Generar CSR
openssl req -new \
  -key backend-b-key.pem \
  -out backend-b.csr \
  -subj "/C=CO/ST=Cundinamarca/L=Bogota/O=Unisabana/CN=backend-b"

echo "✓ CSR generado: backend-b/backend-b.csr"
echo "  Clave privada: backend-b/backend-b-key.pem (GUARDAR PRIVADO)"
cd ..

# ========================
# Resumen
# ========================
echo ""
echo "======================================"
echo "✓ CERTIFICADOS GENERADOS"
echo "======================================"
echo ""
echo "PROXIMOS PASOS:"
echo "1. Envía al profesor ESTOS archivos CSR:"
echo "   - cliente/cliente.csr"
echo "   - backend-a/backend-a.csr"
echo "   - backend-b/backend-b.csr"
echo ""
echo "2. El profesor los firmará con su CA y te devolverá:"
echo "   - cliente.crt"
echo "   - backend-a.crt"
echo "   - backend-b.crt"
echo ""
echo "3. Coloca los .crt en sus carpetas respectivas"
echo ""
echo "4. Ejecuta: bash convertir-a-keystores.sh"
echo ""
