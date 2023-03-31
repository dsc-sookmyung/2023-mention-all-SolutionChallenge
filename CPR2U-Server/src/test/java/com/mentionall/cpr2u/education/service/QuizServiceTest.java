package com.mentionall.cpr2u.education.service;

import com.mentionall.cpr2u.education.dto.quiz.QuizAnswerRequestDto;
import com.mentionall.cpr2u.education.dto.quiz.QuizRequestDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class QuizServiceTest {
    @Autowired
    private QuizService quizService;

    @Test
    @Transactional
    @DisplayName("5개의 퀴즈를 무작위 조회")
    public void readRandom5Quiz() {
        //given
        create7OXQuiz();
        create2SelectionQuiz();

        //when
        var quizList = quizService.readRandom5Quiz();

        //then
        assertThat(quizList.size()).isEqualTo(5);
    }

    private void create2SelectionQuiz() {
        List<QuizAnswerRequestDto> answerList = new ArrayList<>();
        answerList.add(new QuizAnswerRequestDto(true, "한국"));
        answerList.add(new QuizAnswerRequestDto(false, "미국"));
        answerList.add(new QuizAnswerRequestDto(false, "일본"));
        answerList.add(new QuizAnswerRequestDto(false, "호주"));
        quizService.createQuiz(new QuizRequestDto("여기는 어디?","정답 이유", "SELECTION",  answerList));

        answerList = new ArrayList<>();
        answerList.add(new QuizAnswerRequestDto(false, "Corea"));
        answerList.add(new QuizAnswerRequestDto(true, "Korea"));
        answerList.add(new QuizAnswerRequestDto(false, "KKorea"));
        answerList.add(new QuizAnswerRequestDto(false, "CCorea"));
        quizService.createQuiz(new QuizRequestDto("한국은 영어로?", "정답 이유", "SELECTION", answerList));
    }

    private void create7OXQuiz() {
        List<QuizAnswerRequestDto> oIsAnswer = new ArrayList<>();
        oIsAnswer.add(new QuizAnswerRequestDto(true, "O"));
        oIsAnswer.add(new QuizAnswerRequestDto(false, "X"));

        List<QuizAnswerRequestDto> xIsAnswer = new ArrayList<>();
        xIsAnswer.add(new QuizAnswerRequestDto(false, "O"));
        xIsAnswer.add(new QuizAnswerRequestDto(true, "X"));

        quizService.createQuiz(new QuizRequestDto("지구는 둥글다.", "정답 이유", "OX", oIsAnswer));
        quizService.createQuiz(new QuizRequestDto("고양이는 귀엽다.", "정답 이유", "OX", oIsAnswer));
        quizService.createQuiz(new QuizRequestDto("숙명여대는 일본에 있다.", "정답 이유", "OX", xIsAnswer));
        quizService.createQuiz(new QuizRequestDto("배고프다.", "정답 이유", "OX", xIsAnswer));
        quizService.createQuiz(new QuizRequestDto("질문은 총 7개이다.", "정답 이유", "OX", oIsAnswer));
        quizService.createQuiz(new QuizRequestDto("CPR2U는 4글자이다.", "정답 이유", "OX", xIsAnswer));
        quizService.createQuiz(new QuizRequestDto("이것은 임시 질문들이다.", "정답 이유", "OX", oIsAnswer));
    }
}
