package com.mygame.server.cdn;

import java.util.Map;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/cdn")
public class CdnAdminController {
    private final CdnWarmupService warmup;

    public CdnAdminController(CdnWarmupService warmup) {
        this.warmup = warmup;
    }

    @PostMapping("/warmup")
    public Map<String, Object> warmup() {
        warmup.warmupAsync();
        return Map.of("status", "started");
    }
}
