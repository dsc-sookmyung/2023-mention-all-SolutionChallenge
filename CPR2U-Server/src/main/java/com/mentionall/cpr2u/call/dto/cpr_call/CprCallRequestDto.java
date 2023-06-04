package com.mentionall.cpr2u.call.dto.cpr_call;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CprCallRequestDto {

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
