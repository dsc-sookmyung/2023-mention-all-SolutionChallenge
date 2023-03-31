package com.mentionall.cpr2u.call.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.call.domain.CprCall;
import com.querydsl.core.annotations.QueryProjection;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.format.DateTimeFormatter;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CprCallOccurDto {

    @Schema(description = "전체 주소")
    @JsonProperty("full_address")
    private String fullAddress;

    @Schema(description = "호출 장소 위도")
    @JsonProperty
    private Double latitude;

    @Schema(description = "호출 장소 경도")
    @JsonProperty
    private Double longitude;


}
