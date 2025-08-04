package com.example.serverb.controller;

import com.example.serverb.service.MessageService;
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

    @GetMapping("/send-to-a/{content}")
    public ResponseEntity<MessageDto> sendToServerA(@PathVariable("content") String content) {
        MessageDto response = messageService.sendMessageToServerA(content);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Server B is running with SSL");
    }
}