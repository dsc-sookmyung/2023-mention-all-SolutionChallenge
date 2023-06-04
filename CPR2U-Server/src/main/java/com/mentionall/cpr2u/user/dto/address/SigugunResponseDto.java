package com.mentionall.cpr2u.user.dto.address;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public
class SigugunResponseDto {

    @Schema(example = "주소지 ID")
    private Long id;

    @Schema(example = "시/구/군")
    private String gugun;
}