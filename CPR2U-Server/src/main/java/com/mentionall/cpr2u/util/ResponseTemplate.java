package com.mentionall.cpr2u.util;

import com.mentionall.cpr2u.util.exception.ResponseCode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;

@Builder
@AllArgsConstructor
public class ResponseTemplate {
    @Schema(description = "응답 코드", example = "200")
    public int status;

    @Schema(description = "응답 메시지", example = "성공")
    public String message;

    private final LocalDateTime timestamp = LocalDateTime.now();

    public static ResponseEntity<ResponseTemplate> toResponseEntity(ResponseCode responseCode) {
        return ResponseEntity
                .status(responseCode.getHttpStatus())
                .body(ResponseTemplate.builder()
                        .status(responseCode.getHttpStatus().value())
                        .message(responseCode.getDetail())
                        .build()
                );
    }
}