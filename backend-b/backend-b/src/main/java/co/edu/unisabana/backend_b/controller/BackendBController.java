package co.edu.unisabana.backend_b.controller;

import co.edu.unisabana.backend_b.config.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Enumeration;

/**
 * Backend B - Servicio con mTLS
 * Tanto el servidor como el cliente deben presentar certificados válidos
 */
@RestController
@RequestMapping("/api")
public class BackendBController {

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Endpoint protegido por mTLS
     * Solo clientes con certificado válido pueden acceder
     */
    @GetMapping("/protected")
    public String protectedEndpoint(HttpServletRequest request,
                                    @RequestHeader("Authorization") String authorization) {
        String token = authorization.substring(7);
        String username = jwtUtil.getUsernameFromToken(token);
        String role = jwtUtil.getRoleFromToken(token);
        
        // El certificado ClientAuth viene en attributes del request
        String clientCert = request.getAttribute("javax.servlet.request.X509Certificate") != null 
            ? "Certificado del cliente presente" 
            : "Sin certificado";
        
        return String.format(
            """
            Backend B (mTLS) - Acceso protegido
            - Usuario: %s
            - Rol: %s
            - Certificado cliente: %s
            
            Esto demuestra que:
            1. El cliente se autenticó con certificado (mTLS)
            2. El usuario se autenticó con JWT
            """, username, role, clientCert);
    }

    /**
     * Endpoint para generar token (login)
     */
    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        String token = jwtUtil.generateToken(request.getUsername(), request.getRole());
        return new LoginResponse(token);
    }

    /**
     * Endpoint que informa sobre seguridad de Backend B
     */
    @GetMapping("/security-info")
    public String securityInfo() {
        return """
            Backend B - Configuración de Seguridad:
            - TLS: HABILITADO (certificado del servidor)
            - mTLS: HABILITADO (requiere certificado del cliente)
            - JWT: REQUERIDO (para endpoints protegidos)
            - Puerto: 8082 (HTTPS)
            
            SOLO el Cliente puede acceder a /protected
            Rechazo de borde: certificados inválidos o faltantes
            """;
    }

    /**
     * Endpoint para que el Cliente pruebe la conexión mTLS
     */
    @GetMapping("/health")
    public String health() {
        return "Backend B está funcionando con mTLS";
    }

    // ============ DTOs ============
    public static class LoginRequest {
        public String username;
        public String role;

        public LoginRequest() {}
        public LoginRequest(String username, String role) {
            this.username = username;
            this.role = role;
        }

        public String getUsername() { return username; }
        public String getRole() { return role; }
    }

    public static class LoginResponse {
        public String token;

        public LoginResponse(String token) {
            this.token = token;
        }

        public String getToken() { return token; }
    }
}
