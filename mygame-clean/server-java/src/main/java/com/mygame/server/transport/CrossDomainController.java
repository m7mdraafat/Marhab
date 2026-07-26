package com.mygame.server.transport;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CrossDomainController {
    @GetMapping(value = "/crossdomain.xml", produces = MediaType.APPLICATION_XML_VALUE)
    public String crossdomain() {
        return """
            <?xml version="1.0"?>
            <cross-domain-policy>
              <allow-access-from domain="*" to-ports="8080"/>
            </cross-domain-policy>
            """;
    }
}