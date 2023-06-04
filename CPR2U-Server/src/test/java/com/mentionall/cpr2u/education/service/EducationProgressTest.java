package com.mentionall.cpr2u.education.service;

import com.mentionall.cpr2u.education.dto.ScoreRequestDto;
import com.mentionall.cpr2u.education.dto.lecture.LectureRequestDto;
import com.mentionall.cpr2u.user.domain.AngelStatus;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.user.SignUpRequestDto;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.user.service.AddressService;
import com.mentionall.cpr2u.user.service.AuthService;
import com.mentionall.cpr2u.user.service.UserService;
import com.mentionall.cpr2u.util.exception.CustomException;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;
import java.time.LocalDate;

import static com.mentionall.cpr2u.education.domain.ProgressStatus.*;
import static com.mentionall.cpr2u.education.domain.TestStandard.*;
import static com.mentionall.cpr2u.user.domain.AngelStatus.ACQUIRED;
import static com.mentionall.cpr2u.user.domain.AngelStatus.UNACQUIRED;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DisplayName("유저 교육 진도 관련 테스트")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
public class EducationProgressTest {
    @Autowired
    private EducationProgressService progressService;
    @Autowired
    private UserService userService;
    @Autowired
    private AuthService authService;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private LectureService lectureService;
    @Autowired
    private AddressService addressService;

    private static final String phoneNumber = "010-0000-0000";

    @BeforeEach
    private void beforeEach() {
        addressService.loadAddressList();
        var address = addressService.readAll().get(0).getGugunList().get(0);
        authService.signup(new SignUpRequestDto("현애", phoneNumber, address.getId(), "device_token"));
    }

    @Test
    @Transactional
    public void 강의_수강중인_경우() {
        //given
        createLectureCourse();
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        //when
        var lectureList = lectureService.readLectureProgressAndList(user).getLectureList();
        for (var lecture : lectureList) {
            progressService.completeLecture(user, lecture.getId());
            if (lecture.getStep() == finalLectureStep) break;

            // then
            var educationInfo = progressService.readEducationInfo(user);
            assertThat(educationInfo.getIsLectureCompleted()).isEqualTo(InProgress.ordinal());

            double progressPercent = lecture.getStep() / totalStep;
            assertThat(educationInfo.getProgressPercent()).isEqualTo(progressPercent);
        }
    }

    @Test
    @Transactional
    public void 강의_수강완료한_경우() {
        //given
        createLectureCourse();
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        //when
        completeLectureCourse(user);

        //then
        var educationInfo = progressService.readEducationInfo(user);
        assertThat(educationInfo.getIsLectureCompleted()).isEqualTo(Completed.ordinal());
        assertThat(educationInfo.getProgressPercent()).isEqualTo((double)finalLectureStep / (double)totalStep);

        assertThat(educationInfo.getIsQuizCompleted()).isEqualTo(NotCompleted.ordinal());
        assertThat(educationInfo.getIsPostureCompleted()).isEqualTo(NotCompleted.ordinal());
    }

    @Test
    @Transactional
    public void 퀴즈_100점을_넘은_경우() {
        //given
        createLectureCourse();
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        completeLectureCourse(user);

        //when
        progressService.completeQuiz(user, new ScoreRequestDto(100));

        //then
        var quizStatus = progressService.readEducationInfo(user).getIsQuizCompleted();
        assertThat(quizStatus).isEqualTo(Completed.ordinal());

        var postureStatus = progressService.readEducationInfo(user).getIsPostureCompleted();
        assertThat(postureStatus).isEqualTo(NotCompleted.ordinal());
    }

    @Test
    @Transactional
    public void 퀴즈_100점을_넘지_않은_경우() {
        //given
        createLectureCourse();
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        completeLectureCourse(user);

        //when
        Assertions.assertThrows(CustomException.class,
                () -> progressService.completeQuiz(user, new ScoreRequestDto(99)));

        //then
        var quizStatus = progressService.readEducationInfo(user).getIsQuizCompleted();
        assertThat(quizStatus).isEqualTo(NotCompleted.ordinal());
    }

    @Test
    @Transactional
    public void 퀴즈_강의를_마무리하지_않고_테스트한_경우() {
        //given
        createLectureCourse();
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        //when, then
        Assertions.assertThrows(CustomException.class,
                () -> progressService.completeQuiz(user, new ScoreRequestDto(100))
        );
    }

    @Test
    @Transactional
    public void 자세실습_80점을_넘은_경우() {
        //given
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        createLectureCourse();
        completeLectureCourse(user);
        progressService.completeQuiz(user, new ScoreRequestDto(100));

        //when
        progressService.completePosture(user, new ScoreRequestDto(81));

        //then
        int postureStatus =  progressService.readEducationInfo(user).getIsPostureCompleted();
        assertThat(postureStatus).isEqualTo(Completed.ordinal());

        double progressPercent = progressService.readEducationInfo(user).getProgressPercent();
        assertThat(progressPercent).isEqualTo(1.0);
    }

    @Test
    @Transactional
    public void 자세실습_80점을_넘지않은_경우() {
        //given
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        createLectureCourse();
        completeLectureCourse(user);
        progressService.completeQuiz(user, new ScoreRequestDto(100));

        //when
        Assertions.assertThrows(CustomException.class,
                () -> progressService.completePosture(user, new ScoreRequestDto(79)));

        //then
        int postureStatus =  progressService.readEducationInfo(user).getIsPostureCompleted();
        assertThat(postureStatus).isEqualTo(NotCompleted.ordinal());
    }

    @Test
    @Transactional
    public void 자세실습_강의를_마무리하지_않고_테스트한_경우() {
        //given
        createLectureCourse();
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        //when, then
        Assertions.assertThrows(CustomException.class,
                () -> progressService.completePosture(user, new ScoreRequestDto(100)));
    }

    @Test
    @Transactional
    public void 자세실습_퀴즈를_마무리하지_않고_테스트한_경우() {
        //given
        createLectureCourse();
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        //when, then
        completeLectureCourse(user);
        Assertions.assertThrows(CustomException.class,
                () -> progressService.completePosture(user, new ScoreRequestDto(100)));
    }

    @Test
    @Transactional
    public void 교육_수료_전_수료증_확인() {
        //given
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        //when
        var educationInfo = progressService.readEducationInfo(user);

        //then
        assertThat(educationInfo.getAngelStatus()).isEqualTo(UNACQUIRED.ordinal());
        assertThat(educationInfo.getDaysLeftUntilExpiration()).isEqualTo(null);
    }

    //TODO: 당일, 3일, 90일, 91일 수료증 확인 과정 하나로 합치기
    @Test
    @Transactional
    public void 교육_수료_당일_수료증_확인() {
        //given
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        userService.certificate(user, LocalDate.now().atStartOfDay());

        //when
        var educationInfo = progressService.readEducationInfo(user);

        //then
        assertThat(educationInfo.getAngelStatus()).isEqualTo(ACQUIRED.ordinal());
        assertThat(educationInfo.getDaysLeftUntilExpiration()).isEqualTo(validTime);
    }

    @Test
    @Transactional
    public void 교육_수료_3일_후_수료증_확인() {
        //given
        int day = 3;
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        userService.certificate(user, LocalDate.now().minusDays(day).atStartOfDay());


        //when
        var educationInfo = progressService.readEducationInfo(user);

        //then
        assertThat(educationInfo.getAngelStatus()).isEqualTo(ACQUIRED.ordinal());
        assertThat(educationInfo.getDaysLeftUntilExpiration()).isEqualTo(validTime - day);
    }

    @Test
    @Transactional
    public void 교육_수료_90일_후_수료증_확인() {
        //given
        int day = 90;
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        userService.certificate(user, LocalDate.now().minusDays(day).atStartOfDay());

        //when
        var educationInfo = progressService.readEducationInfo(user);

        //then
        assertThat(educationInfo.getAngelStatus()).isEqualTo(ACQUIRED.ordinal());
        assertThat(educationInfo.getDaysLeftUntilExpiration()).isEqualTo(validTime - day);
    }

    @Test
    @Transactional
    public void 교육_수료_91일_후_수료증_만료() {
        //given
        int day = 91;
        User user = userRepository.findByPhoneNumber("010-0000-0000").get();
        userService.certificate(user, LocalDate.now().minusDays(day).atStartOfDay());

        //when
        var educationInfo = progressService.readEducationInfo(user);

        //then
        //assertThat(educationInfo.getAngelStatus()).isEqualTo(EXPIRED);
        assertThat(educationInfo.getDaysLeftUntilExpiration()).isEqualTo(null);
    }

    private void completeLectureCourse(User user) {
        var lectureList = lectureService.readLectureProgressAndList(user).getLectureList();
        for (var lecture : lectureList) {
            progressService.completeLecture(user, lecture.getId());
        }
    }

    private void createLectureCourse() {
        lectureService.createLecture(new LectureRequestDto(1, "일반인 심폐소생술 표준 교육", "2020 Korean Guideline", "https://youtu.be/5DWyihalLMM"));
    }
}