package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.config.security.JwtTokenProvider;
import com.mentionall.cpr2u.education.domain.EducationProgress;
import com.mentionall.cpr2u.education.repository.EducationProgressRepository;
import com.mentionall.cpr2u.user.domain.DeviceToken;
import com.mentionall.cpr2u.user.domain.RefreshToken;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.*;
import com.mentionall.cpr2u.user.repository.DeviceTokenRepository;
import com.mentionall.cpr2u.user.repository.RefreshTokenRepository;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.rest.verify.v2.service.Verification;
import com.twilio.type.PhoneNumber;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;
    private final EducationProgressRepository progressRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final DeviceTokenRepository deviceTokenRepository;

    @Value("${security.twilio.account-sid}")
    private String twilioAccountSid;

    @Value("${security.twilio.auth-token}")
    private String twilioAuthToken;

    @Value("${security.twilio.service-sid}")
    private String twilioServiceSid;

    @Value("${security.twilio.phone-number}")
    private String phoneNumber;

    public UserTokenDto signup(UserSignUpDto userSignUpDto) {
        User user = new User(userSignUpDto);
        userRepository.save(user);
        deviceTokenRepository.save(new DeviceToken(userSignUpDto.getDeviceToken(), user));
        progressRepository.save(new EducationProgress(user));
        return issueUserToken(user);
    }

    public UserCodeDto getVerificationCode(UserPhoneNumberDto userPhoneNumberDto) {
//        String code = String.format("%04.0f", Math.random() * Math.pow(10, 4));
        String code = "1111";

//        Twilio.init(twilioAccountSid, twilioAuthToken);
//
//        Verification.creator(
//                        twilioServiceSid,
//                        userPhoneNumberDto.getPhoneNumber(),
//                        "sms");
//
//        Message.creator(new PhoneNumber(userPhoneNumberDto.getPhoneNumber()),
//                new PhoneNumber(phoneNumber), "Your verification code is " + code).create();

        return new UserCodeDto(code);
    }

    @Transactional
    public UserTokenDto login(UserLoginDto userLoginDto) {
        if(userRepository.existsByPhoneNumber(userLoginDto.getPhoneNumber())){
            User user = userRepository.findByPhoneNumber(userLoginDto.getPhoneNumber())
                    .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_USER));

            DeviceToken deviceToken = deviceTokenRepository.findByUserId(user.getId())
                    .orElseGet(()->new DeviceToken(userLoginDto.getDeviceToken(), user));

            if(!deviceToken.getToken().equals(userLoginDto.getDeviceToken())) {
                deviceToken.setToken(userLoginDto.getDeviceToken());
                deviceTokenRepository.save(deviceToken);
                user.setDeviceToken(deviceToken);
                userRepository.save(user);
            }

            return issueUserToken(user);
        }
        throw new CustomException(ResponseCode.NOT_FOUND_USER);
    }

    @Transactional
    public UserTokenDto reissueToken(UserTokenReissueDto userTokenReissueDto) {
        RefreshToken refreshToken;
        if(jwtTokenProvider.validateToken(userTokenReissueDto.getRefreshToken()))
            refreshToken = refreshTokenRepository.findRefreshTokenByToken(userTokenReissueDto.getRefreshToken())
                    .orElseThrow(()-> new CustomException(ResponseCode.FORBIDDEN_TOKEN_NOT_VALID));
        else throw new CustomException(ResponseCode.FORBIDDEN_TOKEN_NOT_VALID);

        User user = refreshToken.getUser();
        return issueUserToken(user);
    }

    private UserTokenDto issueUserToken(User user){
        String newRefreshToken = jwtTokenProvider.createRefreshToken();
        RefreshToken refreshToken = refreshTokenRepository.findByUserId(user.getId()).orElseGet(() -> new RefreshToken(user));
        refreshToken.setToken(newRefreshToken);
        refreshTokenRepository.save(refreshToken);

        return new UserTokenDto(
                jwtTokenProvider.createToken(user.getId(), user.getRoles()),
                newRefreshToken);
    }

    public void checkNicknameDuplicated(String nickname) {
        if(userRepository.existsByNickname(nickname))
            throw new CustomException(ResponseCode.BAD_REQUEST_NICKNAME_DUPLICATED);
    }

    public void certificate(User user) {
        user.acquireCertification();
        userRepository.save(user);
    }
}
