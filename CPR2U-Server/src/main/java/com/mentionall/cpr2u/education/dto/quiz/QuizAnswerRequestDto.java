package com.mentionall.cpr2u.education.dto.quiz;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class QuizAnswerRequestDto {
    @Schema(example = "정답 여부(true/false)")
    @JsonProperty("is_answer")
    private boolean isAnswer;

    @Schema(example = "후보 정답 내용")
    private String content;
}
