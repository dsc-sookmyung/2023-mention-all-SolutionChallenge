package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.config.security.JwtTokenProvider;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.*;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.util.exception.CustomException;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class AuthServiceTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    private String phoneNumber = "010-0000-0000";
    private String nickname = "예진";
    private String deviceToken = "device-code";

    @Test
    @Transactional
    @DisplayName("회원 가입")
    public void signup() {
        //given
        UserSignUpDto userSignUpDto = new UserSignUpDto(nickname, phoneNumber, deviceToken);

        //when
        UserTokenDto userTokenDto = userService.signup(userSignUpDto);

        //then
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        String userId1 = user.getId();
        String userId2 = jwtTokenProvider.getUserId(userTokenDto.getAccessToken());
        assertThat(userId1).isEqualTo(userId2);
    }

    @Test
    @Transactional
    @DisplayName("로그인")
    public void login() {
        //given
        UserSignUpDto userSignUpDto = new UserSignUpDto(nickname, phoneNumber, deviceToken);
        userService.signup(userSignUpDto);
        UserLoginDto userLoginDto = new UserLoginDto(phoneNumber, deviceToken);

        //when
        UserTokenDto userTokenDto = userService.login(userLoginDto);

        //then
        User user = userRepository.findByPhoneNumber(phoneNumber).get();
        String userId1 = user.getId();
        String userId2 = jwtTokenProvider.getUserId(userTokenDto.getAccessToken());
        assertThat(userId1).isEqualTo(userId2);
    }

    @Test
    @Transactional
    @DisplayName("전화번호 인증코드 생성")
    public void verification(){
        //given
        UserPhoneNumberDto userPhoneNumberDto = new UserPhoneNumberDto(phoneNumber);

        for(int i = 0 ; i < 100 ; i ++) {
            //when
            UserCodeDto userCodeDto = userService.getVerificationCode(userPhoneNumberDto);

            //then
            assertThat(userCodeDto.getValidationCode().length()).isEqualTo(4);
        }
    }

    @Test
    @Transactional
    @DisplayName("토큰 재발급")
    public void autoLogin() {
        //given
        UserSignUpDto userSignUpDto = new UserSignUpDto(nickname, phoneNumber, deviceToken);
        userService.signup(userSignUpDto);
        UserLoginDto userLoginDto = new UserLoginDto(phoneNumber, deviceToken);
        UserTokenDto userTokenDto = userService.login(userLoginDto);
        String userId = jwtTokenProvider.getUserId(userTokenDto.getAccessToken());
        UserTokenReissueDto userTokenReissueDto = new UserTokenReissueDto(userTokenDto.getRefreshToken());

        //when
        UserTokenDto newUserTokenDto = userService.reissueToken(userTokenReissueDto);

        //then
        assertThat(userId).isEqualTo(jwtTokenProvider.getUserId(newUserTokenDto.getAccessToken()));
    }

    @Test
    @Transactional
    @DisplayName("닉네임 중복 체크")
    public void nicknameCheck() {
        //given
        UserSignUpDto userSignUpDto = new UserSignUpDto(nickname, phoneNumber, deviceToken);
        userService.signup(userSignUpDto);

        //when
        String newNickname = nickname;

        //then
        Assertions.assertThrows(CustomException.class, () -> {
                    userService.checkNicknameDuplicated(newNickname);
        });
    }
}
