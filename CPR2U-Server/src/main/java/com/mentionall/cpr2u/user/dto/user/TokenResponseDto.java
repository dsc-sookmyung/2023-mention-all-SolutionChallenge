package com.mentionall.cpr2u.user.dto.user;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TokenResponseDto {

    @Schema(example = "access token")
    @JsonProperty("access_token")
    String accessToken;

    @Schema(example = "refresh token")
    @JsonProperty("refresh_token")
    String refreshToken;

}
