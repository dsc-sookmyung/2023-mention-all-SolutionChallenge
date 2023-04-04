package com.mentionall.cpr2u.call.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.CprCallStatus;
import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.domain.DispatchStatus;
import com.mentionall.cpr2u.call.dto.CprCallOccurDto;
import com.mentionall.cpr2u.call.dto.DispatchRequestDto;
import com.mentionall.cpr2u.call.dto.DispatchResponseDto;
import com.mentionall.cpr2u.call.repository.*;
import com.mentionall.cpr2u.config.security.JwtTokenProvider;
import com.mentionall.cpr2u.education.repository.EducationProgressRepository;
import com.mentionall.cpr2u.user.domain.Address;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.UserSignUpDto;
import com.mentionall.cpr2u.user.repository.*;
import com.mentionall.cpr2u.user.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ExtendWith(MockitoExtension.class)
class CprCallServiceTest {


    private CprCallService cprCallService;

    private DispatchService dispatchService;

    private UserService userService;

    private CprCallRepository cprCallRepository;

    private UserRepository userRepository;

    private DispatchRepository dispatchRepository;

    private AddressRepository addressRepository;

    private DeviceTokenRepository deviceTokenRepository;

    private EducationProgressRepository progressRepository;

    private JwtTokenProvider jwtTokenProvider;

    private RefreshTokenRepository refreshTokenRepository;

    @BeforeEach
    public void beforeEach() {
        this.dispatchRepository = new FakeDispatchRepository();
        this.userRepository = new FakeUserRepository();
        this.addressRepository = new FakeAddressRepository();
        this.cprCallRepository = new FakeCprCallRepository();
        this.deviceTokenRepository = new FakeDeviceTokenRepository();
        this.cprCallService = new CprCallService(cprCallRepository, dispatchRepository, addressRepository, deviceTokenRepository, new FirebaseCloudMessageService(null));
        this.dispatchService = new DispatchService(dispatchRepository, cprCallRepository, null);
    }

    @BeforeEach
    public void insertData() {
        User dispatcher = userRepository.save(new User(new UserSignUpDto("출동자", "phoneNumber" + 1, UUID.randomUUID().toString())));
        User caller = userRepository.save(new User(new UserSignUpDto("호출자", "phoneNumber" + 2, UUID.randomUUID().toString())));
        Address address1 = addressRepository.save(new Address(1L, "서울시", "용산구", new ArrayList<>()));
        Address address2 = addressRepository.save(new Address(2L, "서울시", "동작구", new ArrayList<>()));
        Address address3 = addressRepository.save(new Address(3L, "서울시", "종로구", new ArrayList<>()));
        Address address4 = addressRepository.save(new Address(4L, "세종특별자치시", "", new ArrayList<>()));
        Address address5 = addressRepository.save(new Address(5L, "경남", "창원시", new ArrayList<>()));
        cprCallRepository.save(new CprCall(1L, caller, address1, "서울시 용산구 어쩌구",
                LocalDateTime.now(), 37.542547, 126.963796, CprCallStatus.IN_PROGRESS,
                new ArrayList<>(), new ArrayList<>()));
    }

    //TODO: 테스트 실패 - address DB 데이터가 없는 경우, address를 찾지 못하고 실패
    @Test
    @Transactional
    @DisplayName("엔젤 유저들의 근처 호출 조회")
    public void getNowCallStatusNearUser() {
        //given

        Address address1 = addressRepository.findById(1L).get();
        Address address2 = addressRepository.findById(2L).get();

        //CPR 엔젤이고 환자도 있음
        User cprAngelUser = userRepository.findByPhoneNumber("phoneNumber" + 1).get();
        cprAngelUser.setAddress(address1);
        cprAngelUser.acquireCertification();
        userRepository.save(cprAngelUser);

        //CPR 엔젤이지만 환자가 없는 동네에 있음
        User cprAngelUserButNoPatient = userRepository.findByPhoneNumber("phoneNumber" + 2).get();
        cprAngelUserButNoPatient.setAddress(address2);
        cprAngelUserButNoPatient.acquireCertification();
        userRepository.save(cprAngelUserButNoPatient);

        //cpr 엔젤이 아닌데 환자가 있는 동네에 있음
        User notAngel = userRepository.findByPhoneNumber("phoneNumber" + 3).get();
        notAngel.setAddress(address1);
        userRepository.save(notAngel);

        //when
        var callListForAngel = cprCallService.getCallNearUser(cprAngelUser);
        var callListForAngelButNoPatient = cprCallService.getCallNearUser(cprAngelUserButNoPatient);
        var callListForNotAngel = cprCallService.getCallNearUser(notAngel);

        //then
        assertThat(callListForAngel.getCprCallDtoList().size()).isEqualTo(1);
        assertThat(callListForAngelButNoPatient.getCprCallDtoList().size()).isEqualTo(0);
        assertThat(callListForNotAngel.getCprCallDtoList().size()).isEqualTo(0);

    }

    //TODO: 테스트 실패 - address DB 데이터가 없는 경우, address를 찾지 못하고 실패
    @Test
    @Transactional
    @DisplayName("호출 생성")
    public void makeCall() {
        //given
        User user = userRepository.findByPhoneNumber("phoneNumber" + 1).get();

        //when
        Long callId1 = cprCallService.makeCall(new CprCallOccurDto("서울 용산구 청파로47길 100", 37.56559872345163, 126.9779734762639), user).getCallId();
        Long callId2 = cprCallService.makeCall(new CprCallOccurDto("서울 종로구 종로 104", 37.56559872345163, 126.9779734762639), user).getCallId();
        Long callId3 = cprCallService.makeCall(new CprCallOccurDto("세종특별자치시 한누리대로 2130 (우)30151", 37.56559872345163, 126.9779734762639), user).getCallId();
        Long callId4 = cprCallService.makeCall(new CprCallOccurDto("경남 창원시 진해구 평안동 10", 37.56559872345163, 126.9779734762639), user).getCallId();

        //then
        CprCall cprCall1 = cprCallRepository.findById(callId1).get();
        CprCall cprCall2 = cprCallRepository.findById(callId2).get();
        CprCall cprCall3 = cprCallRepository.findById(callId3).get();
        CprCall cprCall4 = cprCallRepository.findById(callId4).get();

        assertThat(cprCall1.getAddress().getId()).isEqualTo(1L);
        assertThat(cprCall2.getAddress().getId()).isEqualTo(3L);
        assertThat(cprCall3.getAddress().getId()).isEqualTo(4L);
        assertThat(cprCall4.getAddress().getId()).isEqualTo(5L);

        assertThat(cprCall1.getStatus()).isEqualTo(CprCallStatus.IN_PROGRESS);

    }

    @Test
    @Transactional
    @DisplayName("호출 종료")
    void endCall() {
        //given
        User caller = userRepository.findByPhoneNumber("phoneNumber" + 1).get();
        User dispatcher = userRepository.findByPhoneNumber("phoneNumber" + 2).get();

        Long callId = cprCallService.makeCall(new CprCallOccurDto("서울 용산구 청파로47길 100", 37.56559872345163, 126.9779734762639), caller).getCallId();
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
}