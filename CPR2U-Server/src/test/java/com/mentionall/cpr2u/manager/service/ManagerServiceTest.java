package com.mentionall.cpr2u.manager.service;


import com.mentionall.cpr2u.education.domain.ProgressStatus;
import com.mentionall.cpr2u.education.service.EducationProgressService;
import com.mentionall.cpr2u.manager.ManagerService;
import com.mentionall.cpr2u.user.domain.AngelStatus;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.user.SignUpRequestDto;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.user.service.AddressService;
import com.mentionall.cpr2u.user.service.AuthService;
import com.mentionall.cpr2u.user.service.UserService;
import com.mentionall.cpr2u.util.fcm.FirebaseCloudMessageUtil;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

import javax.transaction.Transactional;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DisplayName("관리자 관련 테스트")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
public class ManagerServiceTest {
    @Autowired
    private ManagerService managerService;
    @MockBean
    private FirebaseCloudMessageUtil firebaseCloudMessageUtil;
    @Autowired
    private EducationProgressService progressService;
    @Autowired
    private UserService userService;
    @Autowired
    private AuthService authService;
    @Autowired
    private UserRepository userRepository;
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
    public void 수료증_만료시_진도_초기화() {
        //given
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        userService.certificate(user, LocalDate.now().minusDays(91).atStartOfDay());

        //when
        managerService.updateAngelStatus();

        //then
        user = userRepository.findByPhoneNumber(phoneNumber).get();
        var educationInfo = progressService.readEducationInfo(user);

        assertThat(educationInfo.getAngelStatus()).isEqualTo(AngelStatus.EXPIRED);
        assertThat(educationInfo.getProgressPercent()).isEqualTo(.0);

        assertThat(educationInfo.getIsLectureCompleted()).isEqualTo(ProgressStatus.NotCompleted.ordinal());
        assertThat(educationInfo.getIsQuizCompleted()).isEqualTo(ProgressStatus.NotCompleted.ordinal());
        assertThat(educationInfo.getIsPostureCompleted()).isEqualTo(ProgressStatus.NotCompleted.ordinal());
    }
}
