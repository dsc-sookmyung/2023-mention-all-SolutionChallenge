package com.mentionall.cpr2u.call.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.call.domain.CprCall;
import com.querydsl.core.annotations.QueryProjection;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.format.DateTimeFormatter;

@Data
public class CprCallDto {
    @Schema(description = "호출 id")
    @JsonProperty("cpr_call_id")
    private Long id;

    @Schema(description = "전체 주소")
    @JsonProperty("full_address")
    private String fullAddress;

    @Schema(description = "호출 시작한 시간")
    @JsonProperty("called_at")
    private String calledAt;

    @Schema(description = "호출 장소 위도")
    @JsonProperty
    private Double latitude;

    @Schema(description = "호출 장소 경도")
    @JsonProperty
    private Double  longitude;

    @QueryProjection
    public CprCallDto(CprCall cprCall){
        this.id = cprCall.getId();
        this.fullAddress = cprCall.getFullAddress();
        this.calledAt = cprCall.getCalledAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        this.latitude = cprCall.getLatitude();
        this.longitude = cprCall.getLongitude();
    }

}
