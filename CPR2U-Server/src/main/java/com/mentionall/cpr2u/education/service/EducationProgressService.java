package com.mentionall.cpr2u.education.service;

import com.mentionall.cpr2u.education.domain.progress.EducationProgress;
import com.mentionall.cpr2u.education.domain.Lecture;
import com.mentionall.cpr2u.education.domain.ProgressStatus;
import com.mentionall.cpr2u.education.domain.TestStandard;
import com.mentionall.cpr2u.education.dto.ProgressResponseDto;
import com.mentionall.cpr2u.education.dto.ScoreRequestDto;
import com.mentionall.cpr2u.education.repository.EducationProgressRepository;
import com.mentionall.cpr2u.education.repository.LectureRepository;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;

import static com.mentionall.cpr2u.education.domain.ProgressStatus.*;

@Service
@RequiredArgsConstructor
public class EducationProgressService {
    private final EducationProgressRepository progressRepository;
    private final LectureRepository lectureRepository;

    @Transactional
    public void completeQuiz(User user, ScoreRequestDto requestDto) {
        EducationProgress progress = getEducationProgress(user);

        if (!checkPossibleToTakeQuiz(progress))
            throw new CustomException(ResponseCode.BAD_REQUEST_EDUCATION_PERMISSION_DENIED);

        progress.getQuizProgress().updateScore(requestDto.getScore());
        progressRepository.save(progress);

        if (requestDto.getScore() < TestStandard.quizScore)
            throw new CustomException(ResponseCode.OK_QUIZ_FAIL);
    }

    @Transactional
    public void completePosture(User user, ScoreRequestDto requestDto) {
        EducationProgress progress = getEducationProgress(user);

        if (!checkPossibleToTakePractice(progress))
            throw new CustomException(ResponseCode.BAD_REQUEST_EDUCATION_PERMISSION_DENIED);

        progress.getPostureProgress().updateScore(requestDto.getScore());
        progressRepository.save(progress);

        if (progress.getPostureProgress().getScore() < TestStandard.postureScore)
            throw new CustomException(ResponseCode.OK_POSTURE_FAIL);
    }

    @Transactional
    public ProgressResponseDto readEducationInfo(User user) {
        return new ProgressResponseDto(getEducationProgress(user));
    }

    @Transactional
    public void completeLecture(User user, Long lectureId) {
        EducationProgress progress = getEducationProgress(user);

        Lecture lecture = lectureRepository.findById(lectureId).orElseThrow(
                () -> new CustomException(ResponseCode.SERVER_ERROR_FAILED_TO_FIND_LECTURE)
        );

        progress.getLectureProgress().updateLastLecture(lecture);
        progressRepository.save(progress);
    }

    private EducationProgress getEducationProgress(User user) {
        return progressRepository.findByUser(user).orElseThrow(
                () -> new CustomException(ResponseCode.SERVER_ERROR_FAILED_TO_GET_EDUCATION_PROGRESS)
        );
    }

    private boolean checkPossibleToTakeQuiz(EducationProgress progress) {
        return progress.getLectureProgress().getStatus() == Completed;
    }

    private boolean checkPossibleToTakePractice(EducationProgress progress) {
        return progress.getLectureProgress().getStatus() == Completed &&
                progress.getQuizProgress().getStatus() == Completed;
    }
}
