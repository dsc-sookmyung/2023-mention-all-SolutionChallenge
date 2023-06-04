package com.mentionall.cpr2u.user.dto.address;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
public class AddressResponseDto {
    @Schema(example = "시/도")
    private String sido;

    @JsonProperty("gugun_list")
    private List<SigugunResponseDto> gugunList = new ArrayList();

    public AddressResponseDto(String sido, List<SigugunResponseDto> gugunList) {
        int bracketIndex = sido.indexOf("(");
        if(bracketIndex != -1)
            sido = sido.substring(0, bracketIndex);
        this.sido = sido;
        this.gugunList = gugunList;
    }
}