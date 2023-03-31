package com.mentionall.cpr2u.education.domain;

import com.mentionall.cpr2u.education.dto.quiz.QuizAnswerRequestDto;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@Entity
@Getter
@NoArgsConstructor
public class QuizAnswer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String content;

    @Column
    private boolean isAnswer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id")
    private Quiz quiz;


    public QuizAnswer(QuizAnswerRequestDto requestDto, Quiz quiz) {
        this.content = requestDto.getContent();
        this.isAnswer = requestDto.isAnswer();
        this.quiz = quiz;
        quiz.addAnswer(this);
    }
}
