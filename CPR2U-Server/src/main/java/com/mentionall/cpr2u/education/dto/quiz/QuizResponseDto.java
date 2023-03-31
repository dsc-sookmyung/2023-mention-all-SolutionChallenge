package com.mentionall.cpr2u.education.dto.quiz;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.mentionall.cpr2u.education.domain.Quiz;
import com.mentionall.cpr2u.education.domain.QuizAnswer;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
@AllArgsConstructor
public class QuizResponseDto {
    @Schema(example = "인덱스")
    private int index;

    @Schema(example = "퀴즈 질문")
    private String question;

    @Schema(example = "퀴즈 타입(0: OX/1: SELECTION)")
    private int type;

    @Schema(example = "퀴즈 정답 ID")
    private Long answer;

    @Schema(example = "퀴즈 정답 ID")
    @JsonProperty(value = "answer_content")
    private String answerContent;

    @Schema(example = "정답 이유")
    private String reason;

    @Schema(example = "정답 후보 리스트")
    @JsonProperty(value = "answer_list")
    List<QuizAnswerResponseDto> answerList = new ArrayList<>();

    public QuizResponseDto(int index, Quiz quiz) {
        this.index = index;
        this.question = quiz.getQuestion();
        this.type = quiz.getType().ordinal();
        this.reason = quiz.getReason();

        for (int i = 0; i < quiz.getAnswerList().size(); i++) {
            QuizAnswer answer = quiz.getAnswerList().get(i);
            if (answer.isAnswer()) {
                this.answer = answer.getId();
                this.answerContent = answer.getContent();
            }
            this.answerList.add(new QuizAnswerResponseDto(answer));
        }
    }
}
