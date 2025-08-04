package com.example.serverb.service;

import com.example.shared.dto.MessageDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.UUID;

@Service
public class MessageService {

    private static final Logger log = LoggerFactory.getLogger(MessageService.class);
    private final WebClient webClient;
    private final String serverAUrl;

    public MessageService(WebClient webClient,
                          @Value("${app.server-a.url}") String serverAUrl) {
        this.webClient = webClient;
        this.serverAUrl = serverAUrl;
    }

    public MessageDto processMessage(MessageDto message) {
        log.info("Processing message from {}: {}", message.source(), message.content());

        return new MessageDto(
                UUID.randomUUID().toString(),
                "Processed by Server B: " + message.content(),
                Instant.now(),
                "server-b"
        );
    }

    public MessageDto sendMessageToServerA(String content) {
        MessageDto message = new MessageDto(
                UUID.randomUUID().toString(),
                content,
                Instant.now(),
                "server-b"
        );

        log.info("Sending message to Server A: {}", content);

        try {
            MessageDto response = webClient
                    .post()
                    .uri(serverAUrl + "/api/v1/messages")
                    .body(Mono.just(message), MessageDto.class)
                    .retrieve()
                    .bodyToMono(MessageDto.class)
                    .block();

            log.info("Received response from Server A: {}", response);
            return response;
        } catch (Exception e) {
            log.error("Error communicating with Server A", e);
            throw new RuntimeException("Failed to communicate with Server A", e);
        }
    }
}