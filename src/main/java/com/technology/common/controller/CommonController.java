package com.technology.common.controller;


import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/commons")
public class CommonController {

    @GetMapping("/health-check")
    public ResponseEntity healthCheck(){
        return ResponseEntity.ok("health check success");
    }
}
