package com.mentionall.cpr2u.call.dto.dispatch;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DispatchRequestDto {
    @Schema(description = "출동할 CPR 요청의 ID")
    @JsonProperty("cpr_call_id")
    private Long cprCallId;
}
