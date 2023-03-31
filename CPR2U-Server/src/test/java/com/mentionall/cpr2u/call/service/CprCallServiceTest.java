package com.mentionall.cpr2u.call.service;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.CprCallStatus;
import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.domain.DispatchStatus;
import com.mentionall.cpr2u.call.dto.*;
import com.mentionall.cpr2u.call.repository.CprCallRepository;
import com.mentionall.cpr2u.call.repository.DispatchRepository;
import com.mentionall.cpr2u.user.domain.Address;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.UserSignUpDto;
import com.mentionall.cpr2u.user.repository.AddressRepository;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.user.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.ArrayList;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class CprCallServiceTest {

    @Autowired
    private CprCallService cprCallService;
    @Autowired
    private CprCallRepository cprCallRepository;
    @Autowired
    private UserService userService;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private DispatchService dispatchService;
    @Autowired
    private DispatchRepository dispatchRepository;
    @Autowired
    private AddressRepository addressRepository;

    @BeforeEach
    public void beforeEach(){
        Address address1 = addressRepository.save(new Address(101L, "서울시", "용산구", new ArrayList<>()));
        Address address2 = addressRepository.save(new Address(102L, "서울시", "동작구", new ArrayList<>()));

        registerUserWithNumberAndAddress(1, address1);
        registerUserWithNumberAndAddress(2, address2);
        registerUserWithNumber(3);
        registerUserWithNumber(4);
    }

    @Test
    @Transactional
    @DisplayName("엔젤 유저들의 근처 호출 조회")
    void getNowCallStatusNearUser() {
        //given
        User caller = userRepository.findByPhoneNumber("phoneNumber" + 1).get();
        User cprAngel = userRepository.findByPhoneNumber("phoneNumber" + 2).get();
        User notAngel = userRepository.findByPhoneNumber("phoneNumber" + 3).get();
        User cprAngelButNoPatient = userRepository.findByPhoneNumber("phoneNumber" + 4).get();

        makeCallInAngelArea(caller, cprAngel, 37.56559872345163, 126.9779734762639);
        makeCallInAngelArea(caller, cprAngel, 37.56520212814079, 126.9771473198163);
        makeCallInAngelArea(caller, cprAngel, 37.56520212814079, 126.9771473198163);
        CprCall endCall = makeCallInAngelArea(caller, cprAngel, 37.56549899694667, 126.97488345790383);
        cprCallService.endCall(endCall.getId());

        //when
        var callListForAngel = cprCallService.getCallNearUser(cprAngel);
        var callListForAngelButNoPatient = cprCallService.getCallNearUser(cprAngelButNoPatient);
        var callListForNotAngel = cprCallService.getCallNearUser(notAngel);

        //then
        assertThat(callListForAngel.getCprCallDtoList().size()).isEqualTo(3);
        assertThat(callListForAngelButNoPatient.getCprCallDtoList().size()).isEqualTo(0);
        assertThat(callListForNotAngel.getCprCallDtoList().size()).isEqualTo(0);

    }

    @Test
    @Transactional
    @DisplayName("호출 생성")
    void makeCall() {
        //given
        User user = userRepository.findByPhoneNumber("phoneNumber" + 1).get();

        //when
        Long callId1 = cprCallService.makeCall(new CprCallOccurDto("서울 종로구 종로 104", 37.56559872345163, 126.9779734762639), user).getCallId();
        Long callId2 = cprCallService.makeCall(new CprCallOccurDto("서울 중구 세종대로 지하 2", 37.56559872345163, 126.9779734762639), user).getCallId();
        Long callId3 = cprCallService.makeCall(new CprCallOccurDto("세종특별자치시 한누리대로 2130 (우)30151", 37.56559872345163, 126.9779734762639), user).getCallId();
        Long callId4 = cprCallService.makeCall(new CprCallOccurDto("경남 창원시 진해구 평안동 10", 37.56559872345163, 126.9779734762639), user).getCallId();

        //then
        CprCall cprCall1 = cprCallRepository.findById(callId1).get();
        CprCall cprCall2 = cprCallRepository.findById(callId2).get();
        CprCall cprCall3 = cprCallRepository.findById(callId3).get();
        CprCall cprCall4 = cprCallRepository.findById(callId4).get();

        assertThat(cprCall1.getAddress().getId()).isEqualTo(1L);
        assertThat(cprCall2.getAddress().getId()).isEqualTo(2L);
        assertThat(cprCall3.getAddress().getId()).isEqualTo(75L);
        assertThat(cprCall4.getAddress().getId()).isEqualTo(231L);

        assertThat(cprCall1.getStatus()).isEqualTo(CprCallStatus.IN_PROGRESS);

    }

    @Test
    @Transactional
    @DisplayName("호출 종료")
    void endCall() {
        //given
        User caller = userRepository.findByPhoneNumber("phoneNumber" + 1).get();
        User dispatcher = userRepository.findByPhoneNumber("phoneNumber" + 2).get();

        Long callId = cprCallService.makeCall(new CprCallOccurDto("서울시 용산구", 37.56559872345163, 126.9779734762639), caller).getCallId();
        DispatchResponseDto dispatchInfo = dispatchService.dispatch(dispatcher, new DispatchRequestDto(callId));

        //when
        cprCallService.endCall(callId);

        //then
        CprCall cprCall = cprCallRepository.findById(callId).get();
        assertThat(cprCall.getStatus()).isEqualTo(CprCallStatus.END_SITUATION);

        Dispatch dispatch = dispatchRepository.findById(dispatchInfo.getDispatchId()).get();
        assertThat(dispatch.getStatus()).isEqualTo(DispatchStatus.END_SITUATION);
    }

    @Test
    @Transactional
    @DisplayName("실시간 출동한 엔젤 수 안내")
    void getNumberOfAngelsDispatched() {
        //given
        User caller = userRepository.findByPhoneNumber("phoneNumber" + 1).get();
        User dispatcher = userRepository.findByPhoneNumber("phoneNumber" + 2).get();

        Long callId = cprCallService.makeCall(new CprCallOccurDto("서울시 동작구", 37.56559872345163, 126.9779734762639), caller).getCallId();

        //when no one dispatched
        var noOneDispatched = cprCallService.getNumberOfAngelsDispatched(callId);

        //then
        assertThat(noOneDispatched.getNumberOfAngels()).isEqualTo(0);

        //when 1 angel dispatched
        dispatchService.dispatch(dispatcher, new DispatchRequestDto(callId));
        var oneAngelDispatched = cprCallService.getNumberOfAngelsDispatched(callId);

        //then
        assertThat(oneAngelDispatched.getNumberOfAngels()).isEqualTo(1);
    }

    public void registerUserWithNumber(int number) {
        UserSignUpDto userSignUpDto = new UserSignUpDto("nickname" + number, "phoneNumber" + number, "deviceToken");
        userService.signup(userSignUpDto);
    }

    public void registerUserWithNumberAndAddress(int number, Address address) {
        UserSignUpDto userSignUpDto = new UserSignUpDto("nickname" + number, "phoneNumber" + number, "deviceToken");
        userService.signup(userSignUpDto);

        User user = userRepository.findByPhoneNumber("phoneNumber" + number).get();
        user.setAddress(address);
        user.acquireCertification();
        userRepository.save(user);
    }

    private CprCall makeCallInAngelArea(User caller, User angel, double latitude, double longitude) {
        return cprCallRepository.save(new CprCall(caller, angel.getAddress(), LocalDateTime.now(), new CprCallOccurDto("fullAddress", latitude, longitude)));
    }
}