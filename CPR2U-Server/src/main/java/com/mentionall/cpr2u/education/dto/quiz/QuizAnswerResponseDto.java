package com.mentionall.cpr2u.education.dto.quiz;

import com.mentionall.cpr2u.education.domain.QuizAnswer;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
public class QuizAnswerResponseDto {
    @Schema(example = "후보답 ID")
    private Long id;

    @Schema(example = "후보담 내용")
    private String content;

    public QuizAnswerResponseDto(QuizAnswer answer) {
        this.id = answer.getId();
        this.content = answer.getContent();
    }
}
