package com.mentionall.cpr2u.call.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ReportRequestDto {
    @Schema(description = "신고하는 사람의 출동 ID")
    @JsonProperty("dispatch_id")
    private Long dispatchId;

    @Schema(description = "신고 내용")
    private String content;
}
