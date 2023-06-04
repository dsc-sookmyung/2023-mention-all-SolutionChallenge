package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.user.domain.AngelStatus;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.user.SignUpRequestDto;
import com.mentionall.cpr2u.user.repository.UserRepository;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DisplayName("유저 관련 테스트")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
public class UserServiceTest {
    @Autowired
    private AuthService authService;
    @Autowired
    private UserService userService;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private AddressService addressService;

    private static final String phoneNumber = "010-0000-0000";
    private static final String nickname = "예진";
    private static final String deviceToken = "device-code";

    @BeforeEach
    private void beforeEach() {
        addressService.loadAddressList();
    }

    @Test
    @Transactional
    public void CPR_Angel_수료증_얻기(){
        //given
        var address = addressService.readAll().get(0).getGugunList().get(0);
        authService.signup(new SignUpRequestDto(nickname, phoneNumber, address.getId(), deviceToken));
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        //when
        AngelStatus bfStatus = user.getAngelStatus();
        userService.certificate(user, LocalDateTime.now());

        //then
        assertThat(bfStatus).isEqualTo(AngelStatus.UNACQUIRED);
        assertThat(user.getAngelStatus()).isEqualTo(AngelStatus.ACQUIRED);
    }

}
