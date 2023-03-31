package com.mentionall.cpr2u.education.service;

import com.mentionall.cpr2u.education.domain.EducationProgress;
import com.mentionall.cpr2u.education.domain.Lecture;
import com.mentionall.cpr2u.education.dto.LectureProgressDto;
import com.mentionall.cpr2u.education.dto.lecture.LectureRequestDto;
import com.mentionall.cpr2u.education.dto.lecture.LectureResponseDto;
import com.mentionall.cpr2u.education.dto.lecture.PostureLectureResponseDto;
import com.mentionall.cpr2u.education.repository.EducationProgressRepository;
import com.mentionall.cpr2u.education.repository.LectureRepository;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LectureService {
    private final LectureRepository lectureRepository;
    private final EducationProgressRepository progressRepository;

    @Value("${lecture.posture-url}")
    private String postureUrl;

    public void createLecture(LectureRequestDto requestDto) {
        if (lectureRepository.existsByStep(requestDto.getStep()))
            throw new CustomException(ResponseCode.BAD_REQUEST_LECTURE_DUPLICATED);

        lectureRepository.save(new Lecture(requestDto));
    }

    public LectureProgressDto readLectureProgress(User user) {
        EducationProgress progress = progressRepository.findByUser(user).orElseThrow(
                () -> new CustomException(ResponseCode.SERVER_ERROR_FAILED_TO_GET_EDUCATION_PROGRESS)
        );

        List<LectureResponseDto> lectureResponseDtoList = lectureRepository.findAll()
                .stream().sorted()
                .map(l -> new LectureResponseDto(l))
                .collect(Collectors.toList());
        return new LectureProgressDto(progress, lectureResponseDtoList);
    }

    public List<LectureResponseDto> readAllTheoryLecture() {
        return lectureRepository.findAll().stream().sorted()
                .map(l -> new LectureResponseDto(l))
                .collect(Collectors.toList());
    }

    public PostureLectureResponseDto readPostureLecture() {
        return new PostureLectureResponseDto(postureUrl);
    }
}
