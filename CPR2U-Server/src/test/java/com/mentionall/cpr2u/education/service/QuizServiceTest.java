package com.mentionall.cpr2u.education.service;

import com.mentionall.cpr2u.education.dto.quiz.QuizAnswerRequestDto;
import com.mentionall.cpr2u.education.dto.quiz.QuizRequestDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.DisplayNameGeneration;
import org.junit.jupiter.api.DisplayNameGenerator;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DisplayName("퀴즈 관련 테스트")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
public class QuizServiceTest {
    @Autowired
    private QuizService quizService;

    @Test
    public void 다섯개의_퀴즈를_무작위_조회한_경우() {
        //given
        createQuizCourse();

        //when
        var quizList = quizService.readRandom5Quiz();

        //then
        assertThat(quizList.size()).isEqualTo(5);
    }

    //TODO
    @Test
    public void 퀴즈_생성() {

    }

    private void createQuizCourse() {
        List<QuizAnswerRequestDto> answerList = new ArrayList<>();
        answerList.add(new QuizAnswerRequestDto(false, "O"));
        answerList.add(new QuizAnswerRequestDto(true, "X"));

        quizService.createQuiz(new QuizRequestDto("If the patient's pulse returns during CPR, the patient must be raised.",
                "Even if the pulse has returned, the cardiac arrest victim should rest in a lying position on a flat surface.",
                "OX",
                answerList));

        quizService.createQuiz(new QuizRequestDto("If the patient's pulse returns during CPR, the patient must be raised.",
                "Even if the pulse has returned, the cardiac arrest victim should rest in a lying position on a flat surface.",
                "OX",
                answerList));

        quizService.createQuiz(new QuizRequestDto("If the patient's pulse returns during CPR, the patient must be raised.",
                "Even if the pulse has returned, the cardiac arrest victim should rest in a lying position on a flat surface.",
                "OX",
                answerList));

        answerList = new ArrayList<>();
        answerList.add(new QuizAnswerRequestDto(false, "Forehead"));
        answerList.add(new QuizAnswerRequestDto(false, "Below the left clavicle"));
        answerList.add(new QuizAnswerRequestDto(false, "Chest"));
        answerList.add(new QuizAnswerRequestDto(true, "Below the right clavicle"));

        quizService.createQuiz(new QuizRequestDto("Select locations to attach pads on an AED.",
                "You have to attach AED to both below the right clavicle and left side.",
                "SELECTION",
                answerList));

        quizService.createQuiz(new QuizRequestDto("Select locations to attach pads on an AED.",
                "You have to attach AED to both below the right clavicle and left side.",
                "SELECTION",
                answerList));
    }
}
