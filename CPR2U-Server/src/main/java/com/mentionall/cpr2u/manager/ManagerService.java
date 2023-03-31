package com.mentionall.cpr2u.manager;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.dto.FcmPushTypeEnum;
import com.mentionall.cpr2u.call.repository.CprCallRepository;
import com.mentionall.cpr2u.call.service.FirebaseCloudMessageService;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.util.MessageEnum;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ManagerService {
    private final UserRepository userRepository;
    private final CprCallRepository cprCallRepository;
    private final FirebaseCloudMessageService firebaseCloudMessageService;

    @Scheduled(cron = "1 0 0 * * *")
    public void updateAngelStatus() {
        List<User> userList = userRepository.findAllAngel();
        for (User user : userList) {
            int leftDays = 90 + (int) (ChronoUnit.DAYS.between(LocalDate.now(), user.getDateOfIssue().toLocalDate().atStartOfDay()));
            if (leftDays < 0) {
                user.expireCertificate();
                userRepository.save(user);
                try {
                    firebaseCloudMessageService.sendMessageTo(user.getDeviceToken().getToken(),
                            MessageEnum.ANGEL_EXPIRED_TITLE.getMessage(),
                            MessageEnum.ANGEL_EXPIRED_BODY.getMessage(),
                            new LinkedHashMap<>(){{
                                put("type", String.valueOf(FcmPushTypeEnum.ANGLE_EXPIRATION.ordinal()));
                            }});
                } catch (IOException e) {
                    throw new CustomException(ResponseCode.SERVER_ERROR_FAILED_TO_SEND_FCM);
                }
            }
        }

        List<CprCall> callList = cprCallRepository.findAllCallInProgressButExpired();
        for(CprCall cprCall : callList){
            cprCall.endSituationCprCall();
            cprCallRepository.save(cprCall);
        }
    }
}
