package co.edu.unisabana.cliente.controller;

import co.edu.unisabana.cliente.service.BackendClientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * Cliente - API Consumer
 * 
 * Demuestra:
 * - TLS: Confía en certificados de los backends
 * - mTLS: Autentica con certificado propio hacia Backend B  
 * - JWT: Genera tokens para autenticarse en ambos backends
 */
@RestController
@RequestMapping("/api")
public class ClienteController {

    @Autowired
    private BackendClientService backendService;

    /**
     * Endpoint que muestra cómo el Cliente usa seguridad en capas:
     * 1. Capa de transporte: TLS/mTLS (certificados X509)
     * 2. Capa de aplicación: JWT (tokens para usuarios)
     */
    @GetMapping("/info")
    public String info() {
        return """
            ================== CLIENTE ==================
            Este servicio demuestra:
            
            1. COMUNICACIÓN CON BACKEND A (TLS)
               - El Cliente confía en el certificado de Backend A
               - Usa HTTP Client con Truststore
               - Se autentica con JWT
            
            2. COMUNICACIÓN CON BACKEND B (mTLS)
               - El Cliente presenta su propio certificado
               - Backend B valida el certificado del Cliente
               - Ambos se autentican con certificados X509
               - Se autentica con JWT
            
            ENDPOINTS DISPONIBLES:
            - GET /api/call-backend-a: Llama Backend A sin JWT
            - GET /api/call-backend-a-protected: Llama Backend A con JWT
            - GET /api/call-backend-b: Llama Backend B con JWT (mTLS)
            - GET /api/security-test: Prueba completa de seguridad
            """;
    }

    /**
     * Llama Backend A (endpoint público)
     */
    @GetMapping("/call-backend-a")
    public String callBackendA() {
        String result = backendService.callBackendA("/public");
        return "Respuesta de Backend A:\n" + result;
    }

    /**
     * Llama Backend A (endpoint protegido con JWT)
     */
    @GetMapping("/call-backend-a-protected")
    public String callBackendAProtected(
            @RequestParam(defaultValue = "juan") String username,
            @RequestParam(defaultValue = "USER") String role) {
        
        String result = backendService.callBackendAProtected("/protected", username, role);
        return "Respuesta de Backend A (protegido):\n" + result;
    }

    /**
     * Llama Backend B (mTLS + JWT)
     * IMPORTANTE: Esto solo funciona si el Cliente tiene su certificado
     */
    @GetMapping("/call-backend-b")
    public String callBackendB(
            @RequestParam(defaultValue = "cliente-app") String username,
            @RequestParam(defaultValue = "SERVICE") String role) {
        
        String result = backendService.callBackendB("/protected", username, role);
        return "Respuesta de Backend B (mTLS):\n" + result;
    }

    /**
     * Test completo: demuestra la estructura de seguridad
     */
    @GetMapping("/security-test")
    public String securityTest() {
        StringBuilder sb = new StringBuilder();
        
        sb.append("========== TEST DE SEGURIDAD ==========\n\n");
        
        sb.append("1. Información de seguridad de Backend A:\n");
        sb.append(backendService.getBackendASecurityInfo()).append("\n\n");
        
        sb.append("2. Información de seguridad de Backend B:\n");
        sb.append(backendService.getBackendBSecurityInfo()).append("\n\n");
        
        sb.append("3. Llamada a Backend A (TLS):\n");
        sb.append(backendService.callBackendA("/public")).append("\n\n");
        
        sb.append("4. Llamada a Backend B (mTLS):\n");
        sb.append(backendService.callBackendB("/protected", "cliente", "SERVICE")).append("\n");
        
        return sb.toString();
    }

    /**
     * Health check
     */
    @GetMapping("/health")
    public String health() {
        return "Cliente está funcionando";
    }
}
