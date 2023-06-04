package com.mentionall.cpr2u.user.dto.user;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LoginRequestDto {

    @Schema(example = "사용자 전화번호")
    @JsonProperty("phone_number")
    String phoneNumber;

    @Schema(example = "device token")
    @JsonProperty("device_token")
    String deviceToken;
}
