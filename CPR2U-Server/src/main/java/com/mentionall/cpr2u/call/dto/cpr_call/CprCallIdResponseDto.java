package com.mentionall.cpr2u.call.dto.cpr_call;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CprCallIdResponseDto {
    @Schema(description = "호출 id")
    @JsonProperty("call_id")
    private Long callId;
}
