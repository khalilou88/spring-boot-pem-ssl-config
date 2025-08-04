package com.example.servera.controller;

import com.example.servera.service.MessageService;
import com.example.shared.dto.MessageDto;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/messages")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    @PostMapping
    public ResponseEntity<MessageDto> receiveMessage(@Valid @RequestBody MessageDto message) {
        MessageDto processedMessage = messageService.processMessage(message);
        return ResponseEntity.ok(processedMessage);
    }

    @GetMapping("/send-to-b/{content}")
    public ResponseEntity<MessageDto> sendToServerB(@PathVariable String content) {
        MessageDto response = messageService.sendMessageToServerB(content);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Server A is running with SSL");
    }
}