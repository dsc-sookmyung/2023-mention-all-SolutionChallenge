package com.mentionall.cpr2u.education.dto.quiz;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class QuizRequestDto {

    @Schema(example = "퀴즈 질문")
    private String question;

    @Schema(example = "정답 이유")
    private String reason;

    @Schema(example = "퀴즈 타입(OX/SELECTION)")
    private String type;

    @Schema(example = "정답 리스트")
    @JsonProperty(value = "answer_list")
    List<QuizAnswerRequestDto> answerList;
}
