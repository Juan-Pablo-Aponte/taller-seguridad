package co.edu.unisabana.backend_a.controller;

import co.edu.unisabana.backend_a.config.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * Backend A - Servicio con TLS simple
 * El servidor se identifica con certificado, el cliente NO necesita certificado
 */
@RestController
@RequestMapping("/api")
public class BackendAController {

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Endpoint público - Sin TLS (solo HTTP)
     */
    @GetMapping("/public")
    public String publicEndpoint() {
        return "Endpoint público de Backend A - Accesible sin autenticación";
    }

    /**
     * Endpoint para generar un token JWT
     * Esto simula: usuario se loguea y recibe un token
     */
    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        // En un caso real, validarías contra una BD
        String token = jwtUtil.generateToken(request.getUsername(), request.getRole());
        return new LoginResponse(token);
    }

    /**
     * Endpoint protegido - Requiere JWT válido en header Authorization
     */
    @GetMapping("/protected")
    public String protectedEndpoint(@RequestHeader("Authorization") String authorization) {
        String token = authorization.substring(7);
        String username = jwtUtil.getUsernameFromToken(token);
        String role = jwtUtil.getRoleFromToken(token);
        
        return String.format("Endpoint protegido - Usuario: %s, Rol: %s", username, role);
    }

    /**
     * Endpoint que informa sobre seguridad
     */
    @GetMapping("/security-info")
    public String securityInfo() {
        return """
            Backend A - Configuración de Seguridad:
            - TLS: HABILITADO (certificado del servidor)
            - mTLS: NO (cliente no necesita certificado)
            - JWT: OPCIONAL (algunos endpoints los requieren)
            - Puerto: 8081 (HTTPS)
            
            Usa JWT para endpoints /protected
            """;
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
