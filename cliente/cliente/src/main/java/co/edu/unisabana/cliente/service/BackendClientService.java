package co.edu.unisabana.cliente.service;

import co.edu.unisabana.cliente.config.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

/**
 * Servicio que comunica con Backend A (TLS) y Backend B (mTLS)
 */
@Service
public class BackendClientService {

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private JwtUtil jwtUtil;

    @Value("${backend.a.url}")
    private String backendAUrl;

    @Value("${backend.b.url}")
    private String backendBUrl;

    /**
     * Llama a Backend A (no necesita certificado del cliente)
     * Solo necesita confiar en el certificado del servidor
     */
    public String callBackendA(String endpoint) {
        try {
            String url = backendAUrl + "/api" + endpoint;
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            return response.getBody();
        } catch (RestClientException e) {
            return "Error llamando Backend A: " + e.getMessage();
        }
    }

    /**
     * Llama a Backend A con JWT
     */
    public String callBackendAProtected(String endpoint, String username, String role) {
        try {
            // Generar token
            String token = jwtUtil.generateToken(username, role);
            
            // Preparar headers
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + token);
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            // Hacer request
            String url = backendAUrl + "/api" + endpoint;
            ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);
            return response.getBody();
        } catch (RestClientException e) {
            return "Error llamando Backend A: " + e.getMessage();
        }
    }

    /**
     * Llama a Backend B (mTLS - requiere certificado del cliente)
     * 
     * El RestTemplate ya está configurado con:
     * - Keystore: certificado del cliente (cliente-keystore.p12)
     * - Truststore: confianza en Backend B (truststore.p12 con CA del profesor)
     */
    public String callBackendB(String endpoint, String username, String role) {
        try {
            // Generar token JWT
            String token = jwtUtil.generateToken(username, role);
            
            // Preparar headers con JWT
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + token);
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            // Hacer request a Backend B
            String url = backendBUrl + "/api" + endpoint;
            ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);
            return response.getBody();
        } catch (RestClientException e) {
            return "Error llamando Backend B (mTLS): " + e.getMessage();
        }
    }

    /**
     * Obtén información de seguridad de ambos backends
     */
    public String getBackendASecurityInfo() {
        return callBackendA("/security-info");
    }

    public String getBackendBSecurityInfo() {
        try {
            String url = backendBUrl + "/api/security-info";
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            return response.getBody();
        } catch (RestClientException e) {
            return "Error: " + e.getMessage();
        }
    }
}
