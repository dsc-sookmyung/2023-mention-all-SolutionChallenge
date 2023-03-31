package com.mentionall.cpr2u.call.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.user.domain.AngelStatusEnum;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import java.util.ArrayList;
import java.util.List;

@Data
@AllArgsConstructor
public class CprCallNearUserDto {
    @Schema(description = "사용자의 현재 자격")
    @JsonProperty("angel_status")
    @Enumerated(EnumType.STRING)
    private AngelStatusEnum angelStatus;

    @Schema(description = "근처 환자 유무")
    @JsonProperty("is_patient")
    private Boolean isPatient;

    @Schema(description = "근처 환자 정보 리스트")
    @JsonProperty("call_list")
    private List<CprCallDto> CprCallDtoList = new ArrayList<>();


}
