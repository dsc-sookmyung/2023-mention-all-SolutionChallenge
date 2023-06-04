package com.mentionall.cpr2u.user.dto.user;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CodeResponseDto {

    @Schema(example = "validation code")
    @JsonProperty("validation_code")
    String validationCode;
}
