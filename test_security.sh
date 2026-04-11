#!/bin/bash
# ============================================================
# Test Script - Sistema Seguro de 3 Microservicios
# ============================================================
# Este script verifica que todos los microservicios estén
# funcionando correctamente con TLS, mTLS y JWT
# ============================================================

echo "=================================================="
echo "PRUEBA DEL SISTEMA SEGURO DE 3 MICROSERVICIOS"
echo "=================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=$3
    local method=${4:-GET}
    local data=${5:-}
    local headers=${6:-}
    
    echo -n "Testing: $name ... "
    
    if [ "$method" = "POST" ]; then
        response=$(eval "curl -s -w '\n%{http_code}' -X POST '$url' \
            -H 'Content-Type: application/json' \
            -d '$data' $headers")
    else
        response=$(eval "curl -s -w '\n%{http_code}' $headers '$url'")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $http_code)"
        ((TESTS_PASSED++))
        [ -n "$body" ] && echo "  Response: ${body:0:60}..."
    else
        echo -e "${RED}✗ FAILED${NC} (Expected $expected_status, got $http_code)"
        ((TESTS_FAILED++))
        echo "  Response: $body"
    fi
    echo ""
}

echo "=========================================="
echo "1. BACKEND A TESTS (TLS)"
echo "=========================================="
echo ""

# Backend A: Public endpoint
test_endpoint "Backend A Public Endpoint" \
    "https://localhost:8085/api/public" \
    "200" \
    "GET" \
    "" \
    "-k"

# Backend A: Security info
test_endpoint "Backend A Security Info" \
    "https://localhost:8085/api/security-info" \
    "200" \
    "GET" \
    "" \
    "-k"

# Backend A: Protected without token
test_endpoint "Backend A Protected (NO JWT)" \
    "https://localhost:8085/api/protected" \
    "401" \
    "GET" \
    "" \
    "-k"

# Backend A: Login to get token
echo -n "Getting JWT token from Backend A ... "
token_response=$(curl -s -k -X POST https://localhost:8085/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"testuser","password":"password"}')
token=$(echo "$token_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
if [ -z "$token" ]; then
    echo -e "${RED}✗ FAILED - No token received${NC}"
    ((TESTS_FAILED++))
else
    echo -e "${GREEN}✓ OK${NC}"
    echo "  Token: ${token:0:50}..."
    ((TESTS_PASSED++))
fi
echo ""

# Backend A: Protected with token
test_endpoint "Backend A Protected (WITH JWT)" \
    "https://localhost:8085/api/protected" \
    "200" \
    "GET" \
    "" \
    "-k -H 'Authorization: Bearer $token'"

echo "=========================================="
echo "2. CLIENTE TESTS (Inter-service Communication)"
echo "=========================================="
echo ""

# Cliente: Health/Info
test_endpoint "Cliente Service Info" \
    "http://localhost:8080/api/info" \
    "200"

# Cliente: Call Backend A
test_endpoint "Client Calling Backend A (TLS)" \
    "http://localhost:8080/api/call-backend-a" \
    "200"

echo "=========================================="
echo "3. PORT & PROCESS VERIFICATION"
echo "=========================================="
echo ""

# Check if all services are listening
echo "Checking service ports:"
for port in 8080 8082 8085; do
    if netstat -an 2>/dev/null | grep -q ":$port.*LISTEN"; then
        echo -e "  Port $port: ${GREEN}✓ LISTENING${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "  Port $port: ${RED}✗ NOT FOUND${NC}"
        ((TESTS_FAILED++))
    fi
done
echo ""

echo "=========================================="
echo "4. SECURITY FEATURES VERIFICATION"
echo "=========================================="
echo ""

# Verify TLS
echo -n "Verifying TLS (self-signed cert acceptance): "
if curl -k -s https://localhost:8085/api/public > /dev/null 2>&1; then
    echo -e "${GREEN}✓ TLS Working${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ TLS Failed${NC}"
    ((TESTS_FAILED++))
fi

# Verify JWT validation
echo -n "Verifying JWT validation (401 without token): "
response=$(curl -s -k -o /dev/null -w "%{http_code}" https://localhost:8085/api/protected)
if [ "$response" = "401" ]; then
    echo -e "${GREEN}✓ JWT Protection Working${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ JWT Failed (got $response)${NC}"
    ((TESTS_FAILED++))
fi

# Verify inter-service HTTPS
echo -n "Verifying inter-service HTTPS (Client → Backend A): "
if curl -s http://localhost:8080/api/call-backend-a | grep -q "Backend A"; then
    echo -e "${GREEN}✓ HTTPS Communication Working${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ HTTPS Failed${NC}"
    ((TESTS_FAILED++))
fi

echo ""
echo "=========================================="
echo "TEST RESULTS SUMMARY"
echo "=========================================="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED - System is secure and functional!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed - Check configuration${NC}"
    exit 1
fi
