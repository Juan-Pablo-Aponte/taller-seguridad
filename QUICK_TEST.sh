#!/bin/bash
# QUICK REFERENCE - Sistema Seguro de 3 Microservicios
# Ejecutar comandos individuales para probar el sistema

echo "================================"
echo "QUICK REFERENCE TESTING GUIDE"
echo "================================"
echo ""

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

show_command() {
    echo -e "${BLUE}$1${NC}"
    echo "$2"
    echo ""
}

echo -e "${GREEN}=== 1. VERIFY SERVICES ARE RUNNING ===${NC}"
show_command "Check all ports listening:" \
    "netstat -an | grep -E ':(8080|8082|8085)' | grep LISTEN"

echo -e "${GREEN}=== 2. BACKEND A TESTS (TLS) ===${NC}"

show_command "Public endpoint (no JWT needed):" \
    "curl -k https://localhost:8085/api/public"

show_command "Get JWT token:" \
    "curl -s -k -X POST https://localhost:8085/api/login \\
  -H 'Content-Type: application/json' \\
  -d '{\"username\":\"admin\",\"password\":\"password\"}' \\
  | grep -o '\"token\":\"[^\"]*' | cut -d'\"' -f4"

show_command "Access protected endpoint WITH JWT:" \
    "curl -k -H 'Authorization: Bearer [PASTE_TOKEN_HERE]' \\
  https://localhost:8085/api/protected"

show_command "Access protected endpoint WITHOUT JWT (should get 401):" \
    "curl -k https://localhost:8085/api/protected"

show_command "Security info:" \
    "curl -k https://localhost:8085/api/security-info"

echo -e "${GREEN}=== 3. CLIENT TESTS (Inter-service Communication) ===${NC}"

show_command "Client general info:" \
    "curl http://localhost:8080/api/info"

show_command "Client calling Backend A (TLS):" \
    "curl http://localhost:8080/api/call-backend-a"

show_command "Client calling Backend B (mTLS):" \
    "curl http://localhost:8080/api/call-backend-b"

echo -e "${GREEN}=== 4. BACKEND B TESTS (mTLS) ===${NC}"

show_command "Backend B info (requires mTLS):" \
    "curl -k https://localhost:8082/api/security-info"

show_command "Backend B health check:" \
    "curl -k https://localhost:8082/api/health"

echo -e "${GREEN}=== 5. AUTOMATED FULL TEST ===${NC}"

show_command "Run full test suite:" \
    "bash test_security.sh"

echo ""
echo -e "${GREEN}=== 6. COMMON CURL FLAGS ===${NC}"
echo "-k              : Accept self-signed certificates"
echo "-X POST         : Specify HTTP method"
echo "-H              : Add header"
echo "-d              : Request body (JSON)"
echo "-s              : Silent mode"
echo "-w              : Show HTTP status code"
echo "-v              : Verbose output"
echo ""

echo -e "${GREEN}=== 7. EXTRACT TOKEN USAGE ===${NC}"
echo "Save token to variable:"
echo "  TOKEN=\$(curl -s -k -X POST https://localhost:8085/api/login \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"username\":\"test\",\"password\":\"test\"}' \\"
echo "    | grep -o '\"token\":\"[^\"]*' | cut -d'\"' -f4)"
echo ""
echo "Use in request:"
echo "  curl -k -H \"Authorization: Bearer \$TOKEN\" \\"
echo "    https://localhost:8085/api/protected"
echo ""

echo -e "${GREEN}=== 8. TROUBLESHOOTING ===${NC}"

show_command "Kill service on port 8085:" \
    "lsof -ti:8085 | xargs kill -9"

show_command "View service logs:" \
    "tail -f backend-a/backend-a/target/*.log"

show_command "Restart a service:" \
    "cd backend-a/backend-a && ./mvnw spring-boot:run"

echo -e "${GREEN}=== 9. SECURITY FEATURES SUMMARY ===${NC}"
cat << 'EOF'
✓ TLS 1.2 - All traffic encrypted
✓ mTLS - Backend B requires client certificate
✓ JWT - Application-level authentication
✓ PKI - Certificates signed by CA
✓ Public Endpoints - /api/public (no auth needed)
✓ Protected Endpoints - /api/protected (JWT required)
✓ Certificate Validation - Automatic chain validation
EOF

echo ""
echo "For full documentation, see:"
echo "  • README_EJECUCION.md  (Complete setup guide)"
echo "  • VERIFICACION_SEGURIDAD.md (Test results)"
echo "  • SUMMARY.md (Executive summary)"
