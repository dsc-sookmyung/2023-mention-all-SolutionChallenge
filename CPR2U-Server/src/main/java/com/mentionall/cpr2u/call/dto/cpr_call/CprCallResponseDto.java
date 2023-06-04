package com.mentionall.cpr2u.call.dto.cpr_call;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.call.domain.CprCall;
import com.querydsl.core.annotations.QueryProjection;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CprCallResponseDto {
    @Schema(description = "호출 id")
    @JsonProperty("cpr_call_id")
    private Long id;

    @Schema(description = "전체 주소")
    @JsonProperty("full_address")
    private String fullAddress;

    @Schema(description = "호출 시작한 시간")
    @JsonProperty("called_at")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    private LocalDateTime calledAt;

    @Schema(description = "호출 장소 위도")
    @JsonProperty
    private Double latitude;

    @Schema(description = "호출 장소 경도")
    @JsonProperty
    private Double longitude;

    @QueryProjection
    public CprCallResponseDto(CprCall cprCall) {
        this.id = cprCall.getId();
        this.fullAddress = cprCall.getFullAddress();
        this.calledAt = cprCall.getCalledAt();
        this.latitude = cprCall.getLatitude();
        this.longitude = cprCall.getLongitude();
    }

}
