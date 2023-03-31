package com.mentionall.cpr2u.call.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CprCallIdDto {
    @Schema(description = "호출 id")
    @JsonProperty("call_id")
    private Long callId;
}
