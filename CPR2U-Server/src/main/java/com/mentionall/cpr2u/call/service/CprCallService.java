package com.mentionall.cpr2u.call.service;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.domain.DispatchStatus;
import com.mentionall.cpr2u.call.dto.cpr_call.*;
import com.mentionall.cpr2u.call.repository.CprCallRepository;
import com.mentionall.cpr2u.call.repository.DispatchRepository;
import com.mentionall.cpr2u.user.domain.Address;
import com.mentionall.cpr2u.user.domain.AngelStatus;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.repository.address.AddressRepository;
import com.mentionall.cpr2u.user.repository.device_token.DeviceTokenRepository;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import com.mentionall.cpr2u.util.fcm.FcmDataType;
import com.mentionall.cpr2u.util.fcm.FcmMessage;
import com.mentionall.cpr2u.util.fcm.FcmPushType;
import com.mentionall.cpr2u.util.fcm.FirebaseCloudMessageUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class CprCallService {
    private final CprCallRepository cprCallRepository;
    private final DispatchRepository dispatchRepository;
    private final AddressRepository addressRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final FirebaseCloudMessageUtil firebaseCloudMessageUtil;

    public CprCallNearUserResponseDto getCallNearUser(User user) {
        
        AngelStatus userAngelStatus = user.getAngelStatus();
        if (userAngelStatus != AngelStatus.ACQUIRED) {
            return new CprCallNearUserResponseDto(
                    userAngelStatus,
                    false,
                    new ArrayList<>()
            );
        }

        List<CprCallResponseDto> cprCallResponseDtoList = cprCallRepository.findAllCallInProcessByAddress(user.getAddress().getId());
        return new CprCallNearUserResponseDto(
                userAngelStatus,
                cprCallResponseDtoList.size() > 0,
                cprCallResponseDtoList
        );
    }

    public void endCall(Long callId) {
        CprCall cprCall = cprCallRepository.findById(callId).orElseThrow(
                () -> new CustomException(ResponseCode.NOT_FOUND_CPRCALL)
        );
        cprCall.endSituationCprCall();
        cprCallRepository.save(cprCall);
        List<Dispatch> notArrivedDispatchList = dispatchRepository.findAllNotArrivedAngelByCprCallId(cprCall.getId());
        for (Dispatch dispatch : notArrivedDispatchList) {
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

    public CprCallIdResponseDto makeCall(CprCallRequestDto cprCallRequestDto, User user) {
        Address callAddress = addressRepository.findByFullAddress(cprCallRequestDto.getFullAddress())
                .orElseThrow(() -> new CustomException(ResponseCode.NOT_FOUND_FAILED_TO_MATCH_ADDRESS));

        CprCall cprCall = new CprCall(user, callAddress, LocalDateTime.now(), cprCallRequestDto);
        cprCallRepository.save(cprCall);

        sendFcmPushToAddress(cprCall, user.getId());

        Integer minutesUntilCallDisappear = 15;
        endCprCallAfterMinutes(cprCall, minutesUntilCallDisappear);

        return new CprCallIdResponseDto(cprCall.getId());
    }

    private void sendFcmPushToAddress(CprCall cprCall, String userId) {

        int offset = 0;
        int maxSize = 500;
        Pageable pageable;

        LinkedHashMap<String, String> dataToSend = new LinkedHashMap<>() {{
            put(FcmDataType.TYPE.getType(), String.valueOf(FcmPushType.CPR_CALL.ordinal()));
            put(FcmDataType.CPR_CALL_ID.getType(), String.valueOf(cprCall.getId()));
        }};

        List<String> deviceTokenToSendPushList;
        do {
            pageable = PageRequest.of(offset, maxSize);
            deviceTokenToSendPushList = deviceTokenRepository.findAllDeviceTokenByUserAddressExceptCaller(cprCall.getAddress().getId(), userId, pageable);
            firebaseCloudMessageUtil.sendFcmMessage(
                    deviceTokenToSendPushList,
                    FcmMessage.CPR_CALL_TITLE.getMessage(),
                    cprCall.getFullAddress(),
                    dataToSend
            );
            offset += maxSize;
        } while (deviceTokenToSendPushList.size() >= maxSize);

    }

    private void endCprCallAfterMinutes(CprCall cprCall, Integer minutes) {
        ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();

        Runnable task = () -> {
            cprCall.endSituationCprCall();
            cprCallRepository.save(cprCall);
        };

        executor.schedule(task, minutes, TimeUnit.MINUTES);
        executor.shutdown();
    }

}
