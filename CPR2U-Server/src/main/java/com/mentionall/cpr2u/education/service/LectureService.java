package com.mentionall.cpr2u.education.service;

import com.mentionall.cpr2u.education.domain.Lecture;
import com.mentionall.cpr2u.education.domain.progress.EducationProgress;
import com.mentionall.cpr2u.education.dto.lecture.LectureListResponseDto;
import com.mentionall.cpr2u.education.dto.lecture.LectureRequestDto;
import com.mentionall.cpr2u.education.dto.lecture.LectureResponseDto;
import com.mentionall.cpr2u.education.repository.EducationProgressRepository;
import com.mentionall.cpr2u.education.repository.LectureRepository;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LectureService {
    private final LectureRepository lectureRepository;
    private final EducationProgressRepository progressRepository;

    public void createLecture(LectureRequestDto requestDto) {
        lectureRepository.save(new Lecture(requestDto));
    }

    public LectureListResponseDto readLectureProgressAndList(User user) {
        EducationProgress progress = progressRepository.findByUser(user).orElseThrow(
                () -> new CustomException(ResponseCode.SERVER_ERROR_FAILED_TO_GET_EDUCATION_PROGRESS)
        );

        List<LectureResponseDto> lectureList = lectureRepository.findAll()
                .stream().sorted()
                .map(l -> new LectureResponseDto(l))
                .collect(Collectors.toList());

        return new LectureListResponseDto(
                progress.getLectureProgress().getLastStep(),
                lectureList
        );
    }
}
