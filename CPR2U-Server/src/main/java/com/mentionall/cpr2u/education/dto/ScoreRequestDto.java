package com.mentionall.cpr2u.education.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ScoreRequestDto {

    @Schema(example = "점수(1 ~ 100)")
    @JsonProperty
    int score;

}
