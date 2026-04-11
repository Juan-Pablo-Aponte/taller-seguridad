#!/bin/bash

# Script simplificado para generar CSRs usando archivos de configuración
set -e

echo "======================================"
echo "Generando CSRs para firmar por CA"
echo "======================================"

KEY_SIZE=2048

# ========================
# 1. CLIENTE
# ========================
echo ""
echo "[1/3] Generando certificados para CLIENTE..."
mkdir -p cliente
cd cliente

openssl genrsa -out cliente-key.pem $KEY_SIZE 2>/dev/null || true
openssl req -new -config ../cliente.conf \
  -key cliente-key.pem \
  -out cliente.csr

echo "✓ CSR generado: cliente.csr"
cd ..

# ========================
# 2. BACKEND A
# ========================
echo ""
echo "[2/3] Generando certificados para BACKEND A..."
mkdir -p backend-a
cd backend-a

openssl genrsa -out backend-a-key.pem $KEY_SIZE 2>/dev/null || true
openssl req -new -config ../backend-a.conf \
  -key backend-a-key.pem \
  -out backend-a.csr

echo "✓ CSR generado: backend-a.csr"
cd ..

# ========================
# 3. BACKEND B
# ========================
echo ""
echo "[3/3] Generando certificados para BACKEND B..."
mkdir -p backend-b
cd backend-b

openssl genrsa -out backend-b-key.pem $KEY_SIZE 2>/dev/null || true
openssl req -new -config ../backend-b.conf \
  -key backend-b-key.pem \
  -out backend-b.csr

echo "✓ CSR generado: backend-b.csr"
cd ..

# ========================
# Resumen
# ========================
echo ""
echo "======================================"
echo "✓ CERTIFICADOS GENERADOS"
echo "======================================"
echo ""
echo "PARA ENVIAR AL PROFESOR:"
echo "  1. cliente/cliente.csr"
echo "  2. backend-a/backend-a.csr"
echo "  3. backend-b/backend-b.csr"
echo ""
echo "El profesor devolverá:"
echo "  - cliente.crt"
echo "  - backend-a.crt"
echo "  - backend-b.crt"
echo "  - ca.crt (certificado raíz de la CA)"
echo ""
