package com.mentionall.cpr2u.education.service;

import com.mentionall.cpr2u.education.domain.EducationProgress;
import com.mentionall.cpr2u.education.domain.TestStandard;
import com.mentionall.cpr2u.education.dto.lecture.LectureRequestDto;
import com.mentionall.cpr2u.education.dto.lecture.LectureResponseDto;
import com.mentionall.cpr2u.education.dto.lecture.PostureLectureResponseDto;
import com.mentionall.cpr2u.education.repository.EducationProgressRepository;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.UserSignUpDto;
import com.mentionall.cpr2u.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class LectureServiceTest {

    @Autowired
    private LectureService lectureService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EducationProgressRepository progressRepository;

    @Test
    @Transactional
    @DisplayName("사용자의 강의 진도 조회")
    public void readLectureProgress() {
        //given
        User user = userRepository.save(new User("1L", new UserSignUpDto("현애", "010-9980-6523", "device_token")));
        progressRepository.save(new EducationProgress(user));

        lectureService.createLecture(new LectureRequestDto(1, "강의1", "1입니다.", "https://naver.com"));

        //when
        var progressDto = lectureService.readLectureProgress(user);

        //then
        assertThat(progressDto.getCurrentStep()).isEqualTo(0);
        assertThat(progressDto.getLectureList().size()).isEqualTo(TestStandard.finalLectureStep);

        int beforeStep = 0;
        for (LectureResponseDto lecture : progressDto.getLectureList()) {
            assertThat(lecture.getStep()).isGreaterThan(beforeStep);
            beforeStep = lecture.getStep();
        }
    }

    @Test
    @DisplayName("자세실습 강의 조회")
    public void readPostureLecture() {
        //given & when
        PostureLectureResponseDto postureLecture = lectureService.readPostureLecture();

        //then
        assertThat(postureLecture.getVideoUrl()).isEqualTo("https://www.naver.com");
    }
}
