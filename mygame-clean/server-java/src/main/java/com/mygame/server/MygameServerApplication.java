package com.mygame.server;

import com.mygame.server.cdn.CdnProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableConfigurationProperties(CdnProperties.class)
@EnableAsync
public class MygameServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(MygameServerApplication.class, args);
	}

}
