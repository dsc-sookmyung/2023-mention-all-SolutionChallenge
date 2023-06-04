package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.config.security.JwtTokenProvider;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.user.*;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.twilio.TwilioUtil;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;

import javax.transaction.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

@SpringBootTest
@DisplayName("로그인 관련 테스트")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
public class AuthServiceTest {
    @Autowired
    private AuthService authService;

    @MockBean
    private TwilioUtil twilioUtil;

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private JwtTokenProvider jwtTokenProvider;
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
    public void 회원가입() {
        //given
        var address = addressService.readAll().get(0).getGugunList().get(0);
        SignUpRequestDto signUpRequestDto = new SignUpRequestDto(nickname, phoneNumber, address.getId(), deviceToken);

        //when
        authService.signup(signUpRequestDto).getAccessToken();

        //then
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        assertThat(user.getNickname()).isEqualTo(nickname);
        assertThat(user.getDeviceToken().getToken()).isEqualTo(deviceToken);
        assertThat(user.getEducationProgress()).isNotNull();
        assertThat(user.getAddress().getId()).isEqualTo(address.getId());
    }

    @Test
    @Transactional
    public void 로그인() {
        //given
        var address = addressService.readAll().get(0).getGugunList().get(0);
        authService.signup(new SignUpRequestDto(nickname, phoneNumber, address.getId(), deviceToken));

        //when
        var accessToken = authService.login(new LoginRequestDto(phoneNumber, deviceToken)).getAccessToken();

        //then
        User findUser = userRepository.findByPhoneNumber(phoneNumber).get();
        assertThat(findUser.getId()).isEqualTo(jwtTokenProvider.getUserId(accessToken));
        assertThat(findUser.getDeviceToken().getToken()).isEqualTo(deviceToken);
    }

    @Test
    @Transactional
    public void 전화번호_인증코드_생성(){
        //given
        var phoneNumberInfo = new PhoneNumberRequestDto(phoneNumber);

        for(int i = 0 ; i < 100 ; i ++) {
            //when
            CodeResponseDto codeResponseDto = authService.getVerificationCode(phoneNumberInfo);

            //then
            assertThat(codeResponseDto.getValidationCode().length()).isEqualTo(4);
        }
    }

    @Test
    @Transactional
    public void 자동_로그인() {
        //given
        var address = addressService.readAll().get(0).getGugunList().get(0);
        authService.signup(new SignUpRequestDto(nickname, phoneNumber, address.getId(), deviceToken));
        var tokens = authService.login(new LoginRequestDto(phoneNumber, deviceToken));

        //when
        var newTokens = authService.reissueToken(new TokenReissueRequestDto(tokens.getRefreshToken()));

        //then
        assertThat(jwtTokenProvider.getUserId(tokens.getAccessToken()))
                .isEqualTo(jwtTokenProvider.getUserId(newTokens.getAccessToken()));
    }

    @Test
    @Transactional
    public void 닉네임_중복체크시_중복되는_경우() {
        //given
        var address = addressService.readAll().get(0).getGugunList().get(0);
        authService.signup(new SignUpRequestDto(nickname, phoneNumber, address.getId(), deviceToken));

        //when
        String newNickname = nickname;

        //then
        Assertions.assertThrows(CustomException.class, () -> {
            authService.checkNicknameDuplicated(newNickname);});
    }

    @Test
    @Transactional
    public void 닉네임_중복체크시_사용가능한_경우() {
        //given
        var address = addressService.readAll().get(0).getGugunList().get(0);
        authService.signup(new SignUpRequestDto(nickname, phoneNumber, address.getId(), deviceToken));

        //when
        String newNickname = "new" + nickname;

        //then
        assertDoesNotThrow(() -> authService.checkNicknameDuplicated(newNickname));
    }

    @Test
    @Transactional
    public void 로그아웃() {
        //given
        var address = addressService.readAll().get(0).getGugunList().get(0);
        authService.signup(new SignUpRequestDto(nickname, phoneNumber, address.getId(), deviceToken));
        User user = userRepository.findByPhoneNumber(phoneNumber).get();

        //when
        authService.logout(user);

        //then
        assertThat(user.getRefreshToken().getToken()).isEqualTo("expired");
    }
}
