package com.mentionall.cpr2u.call.service;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.domain.DispatchStatus;
import com.mentionall.cpr2u.call.dto.*;
import com.mentionall.cpr2u.call.repository.CprCallRepository;
import com.mentionall.cpr2u.call.repository.DispatchRepository;
import com.mentionall.cpr2u.user.domain.Address;
import com.mentionall.cpr2u.user.domain.AngelStatusEnum;
import com.mentionall.cpr2u.user.domain.DeviceToken;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.repository.AddressRepository;
import com.mentionall.cpr2u.user.repository.DeviceTokenRepository;
import com.mentionall.cpr2u.util.MessageEnum;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class CprCallService {
    private final CprCallRepository cprCallRepository;
    private final DispatchRepository dispatchRepository;
    private final AddressRepository addressRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final FirebaseCloudMessageService firebaseCloudMessageService;

    public CprCallNearUserDto getCallNearUser(User user) {
        AngelStatusEnum userAngelStatus = user.getStatus();
        if (userAngelStatus != AngelStatusEnum.ACQUIRED) {
            return new CprCallNearUserDto(
                    userAngelStatus,
                    false,
                    new ArrayList<>()
            );
        }
        if (user.getAddress() == null) {
            throw new CustomException(ResponseCode.BAD_REQUEST_ADDRESS_NOT_SET);
        }
        List<CprCallDto> cprCallDtoList = cprCallRepository.findAllCallInProcessByAddress(user.getAddress().getId());
        return new CprCallNearUserDto(
                userAngelStatus,
                cprCallDtoList.size() > 0,
                cprCallDtoList
        );
    }

    public CprCallIdDto makeCall(CprCallOccurDto cprCallOccurDto, User user) {
        Address callAddress = addressRepository.findByFullAddress(cprCallOccurDto.getFullAddress().split(" "))
                .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_FAILED_TO_MATCH_ADDRESS));

        CprCall cprCall = new CprCall(user, callAddress, LocalDateTime.now(), cprCallOccurDto);
        cprCallRepository.save(cprCall);

        List<DeviceToken> deviceTokenToSendPushList = deviceTokenRepository.findAllDeviceTokenByUserAddress(cprCall.getAddress().getId(), user.getId());
        for(DeviceToken deviceToken : deviceTokenToSendPushList){
            try {
                firebaseCloudMessageService.sendMessageTo(deviceToken.getToken(),
                        MessageEnum.CPR_CALL_TITLE.getMessage(),
                        cprCall.getFullAddress(),
                        new LinkedHashMap<>(){{
                            put("type", String.valueOf(FcmPushTypeEnum.CPR_CALL.ordinal()));
                            put("call", String.valueOf(cprCall.getId()));
                        }}
                );
            } catch (IOException e) {
                throw new CustomException(ResponseCode.SERVER_ERROR_FAILED_TO_SEND_FCM);
            }

            Timer timer = new Timer();
            TimerTask task = new TimerTask() {
                public void run() {
                    cprCall.endSituationCprCall();
                    cprCallRepository.save(cprCall);
                }
            };

            timer.schedule(task, 1000 * 60 * 10);
        }
        return new CprCallIdDto(cprCall.getId());
    }

    public void endCall(Long callId) {
        CprCall cprCall = cprCallRepository.findById(callId).orElseThrow(
                () -> new CustomException(ResponseCode.NOT_FOUND_CPRCALL)
        );
        cprCall.endSituationCprCall();
        cprCallRepository.save(cprCall);
        List<Dispatch> dispatchList = dispatchRepository.findAllByCprCallId(cprCall.getId());
        for (Dispatch dispatch : dispatchList) {
            dispatch.setStatus(DispatchStatus.END_SITUATION);
            dispatchRepository.save(dispatch);
        }

    }

    public CprCallGuideResponseDto getNumberOfAngelsDispatched(Long callId) {
        cprCallRepository.findById(callId).orElseThrow(
                () -> new CustomException(ResponseCode.NOT_FOUND_CPRCALL)
        );

        List<Dispatch> dispatchList = dispatchRepository.findAllByCprCallId(callId);
        return new CprCallGuideResponseDto(dispatchList.size());
    }
}
