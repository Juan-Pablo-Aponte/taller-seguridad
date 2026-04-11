package co.edu.unisabana.cliente.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;
import java.io.InputStream;
import java.security.KeyStore;

/**
 * Configuración de RestTemplate para comunicación HTTPS segura
 * Configura el SSLContext global para confiar en los certificados del truststore
 */
@Configuration
public class RestTemplateConfiguration {

    @Value("${client.truststore.path}")
    private String truststorePath;

    @Value("${client.truststore.password}")
    private String truststorePassword;

    @Bean
    public RestTemplate restTemplate() throws Exception {
        try {
            // Cargar el truststore desde resources
            ClassLoader cl = Thread.currentThread().getContextClassLoader();
            InputStream truststoreFile = cl.getResourceAsStream("certs/truststore.p12");
            
            if (truststoreFile != null) {
                KeyStore truststore = KeyStore.getInstance("PKCS12");
                truststore.load(truststoreFile, truststorePassword.toCharArray());

                // Crear TrustManagerFactory
                TrustManagerFactory tmf = TrustManagerFactory.getInstance(
                    TrustManagerFactory.getDefaultAlgorithm()
                );
                tmf.init(truststore);

                // Crear SSLContext
                SSLContext sslContext = SSLContext.getInstance("TLSv1.2");
                sslContext.init(null, tmf.getTrustManagers(), null);

                // Configurar como default para HTTPS
                javax.net.ssl.HttpsURLConnection.setDefaultSSLSocketFactory(
                    sslContext.getSocketFactory()
                );
            }
        } catch (Exception e) {
            System.err.println("Warning: Could not load truststore: " + e.getMessage());
        }

        // Retornar RestTemplate básico que usará el SSLContext configurado
        return new RestTemplate();
    }
}

