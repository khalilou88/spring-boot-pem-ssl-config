package com.example.shared.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;

public record MessageDto(
        @JsonProperty("id")
        @NotBlank
        String id,

        @JsonProperty("content")
        @NotBlank
        String content,

        @JsonProperty("timestamp")
        @NotNull
        Instant timestamp,

        @JsonProperty("source")
        @NotBlank
        String source
) {}