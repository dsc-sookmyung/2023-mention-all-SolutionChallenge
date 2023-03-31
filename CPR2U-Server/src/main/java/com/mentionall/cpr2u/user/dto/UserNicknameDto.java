package com.mentionall.cpr2u.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserNicknameDto {

    @Schema(example = "사용자 이름")
    @JsonProperty("nickname")
    @NotBlank(message = "이름이 입력되지 않았습니다.")
    String nickname;

}
