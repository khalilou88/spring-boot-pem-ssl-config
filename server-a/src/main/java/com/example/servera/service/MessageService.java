package com.example.servera.service;

import com.example.shared.dto.MessageDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.util.UUID;

@Service
public class MessageService {

    private static final Logger log = LoggerFactory.getLogger(MessageService.class);
    private final RestTemplate restTemplate;
    private final String serverBUrl;

    public MessageService(RestTemplate restTemplate, @Value("${app.server-b.url}") String serverBUrl) {
        this.restTemplate = restTemplate;
        this.serverBUrl = serverBUrl;
    }

    public MessageDto processMessage(MessageDto message) {
        log.info("Processing message from {}: {}", message.source(), message.content());

        return new MessageDto(UUID.randomUUID().toString(), "Processed by Server A: " + message.content(), Instant.now(), "server-a");
    }

    public MessageDto sendMessageToServerB(String content) {
        MessageDto message = new MessageDto(UUID.randomUUID().toString(), content, Instant.now(), "server-a");

        log.info("Sending message to Server B: {}", content);

        try {

            MessageDto response = restTemplate.postForObject(
                    serverBUrl + "/api/v1/messages",
                    message,
                    MessageDto.class
            );

            log.info("Received response from Server B: {}", response);
            return response;
        } catch (Exception e) {
            log.error("Error communicating with Server B", e);
            throw new RuntimeException("Failed to communicate with Server B", e);
        }
    }
}