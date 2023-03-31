package com.mentionall.cpr2u.education.service;

import com.mentionall.cpr2u.education.domain.Quiz;
import com.mentionall.cpr2u.education.domain.QuizAnswer;
import com.mentionall.cpr2u.education.dto.quiz.QuizAnswerRequestDto;
import com.mentionall.cpr2u.education.dto.quiz.QuizRequestDto;
import com.mentionall.cpr2u.education.dto.quiz.QuizResponseDto;
import com.mentionall.cpr2u.education.repository.QuizAnswerRepository;
import com.mentionall.cpr2u.education.repository.QuizRepository;
import com.mentionall.cpr2u.util.exception.CustomException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.ArrayList;
import java.util.List;

import static com.mentionall.cpr2u.util.exception.ResponseCode.BAD_REQUEST_QUIZ_WRONG_ANSWER;
import static com.mentionall.cpr2u.util.exception.ResponseCode.NOT_FOUND_QUIZ;

@Slf4j
@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizRepository quizRepository;
    private final QuizAnswerRepository answerRepository;

    @Transactional
    public void createQuiz(QuizRequestDto requestDto) {
        Quiz quiz = new Quiz(requestDto);
        quizRepository.save(quiz);

        boolean haveAnswer = false;
        for (QuizAnswerRequestDto answerDto : requestDto.getAnswerList()) {
            if (answerDto.isAnswer()) haveAnswer = true;
            answerRepository.save(new QuizAnswer(answerDto, quiz));
        }
        if (!haveAnswer) throw new CustomException(BAD_REQUEST_QUIZ_WRONG_ANSWER);
    }

    @Transactional
    public List<QuizResponseDto> readRandom5Quiz() {
        List<Quiz> quizList = quizRepository.findRandomLimit5();
        List<QuizResponseDto> response = new ArrayList<>();
        for (int i = 0; i < quizList.size(); i++) {
            response.add(new QuizResponseDto(i+1, quizList.get(i)));
        }
        return response;
    }

    @Transactional
    public void deleteQuiz(Long id) {
        Quiz quiz = quizRepository.findById(id).orElseThrow (() -> new CustomException(NOT_FOUND_QUIZ));
        quizRepository.delete(quiz);
    }
}
