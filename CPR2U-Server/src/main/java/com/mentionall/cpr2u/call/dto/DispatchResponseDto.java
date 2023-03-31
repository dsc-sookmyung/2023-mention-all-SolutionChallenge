package com.mentionall.cpr2u.call.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.Dispatch;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class DispatchResponseDto {
    @Schema(description = "출동 데이터 ID")
    @JsonProperty("dispatch_id")
    Long dispatchId;

    @Schema(description = "CPR 요청 주소지")
    @JsonProperty("full_address")
    String fullAddress;

    @Schema(description = "요청 시작 시간")
    @JsonProperty("called_at")
    LocalDateTime calledAt;

    @Schema(description = "CPR 요청 장소 위도")
    Double latitude;

    @Schema(description = "CPR 요청 장소 경도")
    Double  longitude;

    public DispatchResponseDto(CprCall cprCall, Dispatch dispatch) {
        this.dispatchId = dispatch.getId();
        this.fullAddress = cprCall.getFullAddress();
        this.calledAt = cprCall.getCalledAt();
        this.latitude = cprCall.getLatitude();
        this.longitude = cprCall.getLongitude();
    }
}
