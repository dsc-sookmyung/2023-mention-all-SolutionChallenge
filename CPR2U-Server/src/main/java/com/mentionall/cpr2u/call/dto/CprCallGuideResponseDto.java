package com.mentionall.cpr2u.call.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class CprCallGuideResponseDto {
    @Schema(description = "출동한 엔젤의 수")
    @JsonProperty("number_of_angels")
    private int numberOfAngels;
}
