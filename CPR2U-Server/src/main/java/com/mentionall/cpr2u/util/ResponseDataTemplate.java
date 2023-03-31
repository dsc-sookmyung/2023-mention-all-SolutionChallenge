package com.mentionall.cpr2u.util;

import com.mentionall.cpr2u.util.exception.ResponseCode;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;

@Builder
@AllArgsConstructor
public class ResponseDataTemplate {
    public int status;
    public String message;
    public Object data;

    private final LocalDateTime timestamp = LocalDateTime.now();

    public static ResponseEntity<ResponseDataTemplate> toResponseEntity(ResponseCode responseCode, Object data) {
        return ResponseEntity
                .status(responseCode.getHttpStatus())
                .body(ResponseDataTemplate.builder()
                        .status(responseCode.getHttpStatus().value())
                        .message(responseCode.getDetail())
                        .data(data)
                        .build()
                );
    }
}