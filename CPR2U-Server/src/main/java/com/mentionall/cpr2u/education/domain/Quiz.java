package com.mentionall.cpr2u.education.domain;

import com.mentionall.cpr2u.education.dto.quiz.QuizRequestDto;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Getter
@Entity
@NoArgsConstructor
public class Quiz {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String question;

    @Column
    @Enumerated(EnumType.STRING)
    private QuizType type;

    @Column
    private String reason;

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "quiz")
    List<QuizAnswer> answerList = new ArrayList();

    public Quiz(QuizRequestDto requestDto) {
        this.question = requestDto.getQuestion();
        this.type = QuizType.valueOf(requestDto.getType());
        this.reason = requestDto.getReason();
    }

    public void addAnswer(QuizAnswer answer) {
        this.answerList.add(answer);
    }
}
