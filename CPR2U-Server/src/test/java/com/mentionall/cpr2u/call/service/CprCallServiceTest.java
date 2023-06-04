package com.mentionall.cpr2u.call.service;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.CprCallStatus;
import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.domain.DispatchStatus;
import com.mentionall.cpr2u.call.dto.cpr_call.CprCallRequestDto;
import com.mentionall.cpr2u.call.dto.dispatch.DispatchRequestDto;
import com.mentionall.cpr2u.call.repository.CprCallRepository;
import com.mentionall.cpr2u.call.repository.DispatchRepository;
import com.mentionall.cpr2u.call.util.FakeFirebaseCloudMessageUtil;
import com.mentionall.cpr2u.user.domain.Address;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.user.SignUpRequestDto;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.user.repository.address.AddressRepository;
import com.mentionall.cpr2u.user.service.AddressService;
import com.mentionall.cpr2u.user.service.AuthService;
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
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DisplayName("호출 관련 테스트")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
class CprCallServiceTest {
    @Autowired
    private CprCallService cprCallService;

    @Autowired
    private FakeFirebaseCloudMessageUtil firebaseCloudMessageUtil;

    @Autowired
    private CprCallRepository cprCallRepository;
    @Autowired
    private AuthService authService;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private DispatchService dispatchService;
    @Autowired
    private DispatchRepository dispatchRepository;
    @Autowired
    private AddressService addressService;
    @Autowired
    private AddressRepository addressRepository;

    private static final double latitude = 37.56559872345163;
    private static final double longitude = 126.9771473198163;
    private static final String userPhoneNumber = "010-0000-0000";
    private static final String angelPhoneNumber = "010-1111-1111";
    private static final String testFullAddress1 = "서울 종로구 종로 104";
    private static final String testFullAddress2 = "서울 중구 세종대로 지하 2";
    private static final String testFullAddress3 = "세종특별자치시 한누리대로 2130 (우)30151";
    private static final String testFullAddress4 = "경상남도 창원시 진해구 평안동 10";

    @BeforeEach
    private void beforeEach() {
        addressService.loadAddressList();
    }

    @Test
    @Transactional
    public void 호출_주변에_엔젤이_있는_경우() {
        //given
        createUsers();
        User caller = userRepository.findByPhoneNumber(userPhoneNumber).get();
        User cprAngel = userRepository.findByPhoneNumber(angelPhoneNumber).get();

        cprCallService.makeCall(new CprCallRequestDto(testFullAddress1, latitude, longitude), caller);

        //when
        var callListForAngel = cprCallService.getCallNearUser(cprAngel);

        //then
        assertThat(callListForAngel.getCprCallResponseDtoList().size()).isEqualTo(1);
    }

    @Test
    @Transactional
    public void 호출_주변에_일반인이_있는_경우() {
        //given
        createUsers();
        User caller = userRepository.findByPhoneNumber(angelPhoneNumber).get();
        User notAngel = userRepository.findByPhoneNumber(userPhoneNumber).get();

        cprCallService.makeCall(new CprCallRequestDto(testFullAddress1, latitude, longitude), caller);

        //when
        var callListForNotAngel = cprCallService.getCallNearUser(notAngel);

        //then
        assertThat(callListForNotAngel.getCprCallResponseDtoList().size()).isEqualTo(0);
    }

    @Test
    @Transactional
    public void 호출_주변에_만료된_엔젤이_있는_경우() {
        //given
        createUsers();
        User caller = userRepository.findByPhoneNumber(angelPhoneNumber).get();
        User expiredAngel = userRepository.findByPhoneNumber(userPhoneNumber).get();
        expiredAngel.expireCertificate();

        cprCallService.makeCall(new CprCallRequestDto(testFullAddress1, latitude, longitude), caller);

        //when
        var callListForExpiredAngel = cprCallService.getCallNearUser(expiredAngel);

        //then
        assertThat(callListForExpiredAngel.getCprCallResponseDtoList().size()).isEqualTo(0);
    }

    @Test
    @Transactional
    public void 호출_종료() {
        //given
        createUsers();
        User caller = userRepository.findByPhoneNumber(userPhoneNumber).get();
        User cprAngel = userRepository.findByPhoneNumber(angelPhoneNumber).get();

        Long callId = cprCallService.makeCall(new CprCallRequestDto(testFullAddress1, latitude, longitude), caller).getCallId();
        cprCallService.endCall(callId);

        //when
        var callListForAngel = cprCallService.getCallNearUser(cprAngel);

        //then
        assertThat(callListForAngel.getCprCallResponseDtoList().size()).isEqualTo(0);
    }

    @Test
    @Transactional
    public void 호출_종료_출동한_엔젤이_있는_경우() {
        //given
        createUsers();
        User caller = userRepository.findByPhoneNumber(userPhoneNumber).get();
        User dispatcher = userRepository.findByPhoneNumber(angelPhoneNumber).get();

        Long callId = cprCallService
                .makeCall(new CprCallRequestDto(testFullAddress1, latitude, longitude), caller)
                .getCallId();

        var dispatchInfo = dispatchService.dispatch(dispatcher, new DispatchRequestDto(callId));

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
    public void 지역별_호출_생성() {
        //given
        createUsers();
        User user = userRepository.findByPhoneNumber(userPhoneNumber).get();
        Address testAddress1 = addressRepository.findByFullAddress(testFullAddress1).get();
        Address testAddress2 = addressRepository.findByFullAddress(testFullAddress2).get();
        Address testAddress3 = addressRepository.findByFullAddress(testFullAddress3).get();
        Address testAddress4 = addressRepository.findByFullAddress(testFullAddress4).get();

        //when
        Long callId1 = cprCallService.makeCall(new CprCallRequestDto(testFullAddress1, latitude, longitude), user).getCallId();
        Long callId2 = cprCallService.makeCall(new CprCallRequestDto(testFullAddress2, latitude, longitude), user).getCallId();
        Long callId3 = cprCallService.makeCall(new CprCallRequestDto(testFullAddress3, latitude, longitude), user).getCallId();
        Long callId4 = cprCallService.makeCall(new CprCallRequestDto(testFullAddress4, latitude, longitude), user).getCallId();

        //then
        CprCall cprCall1 = cprCallRepository.findById(callId1).get();
        CprCall cprCall2 = cprCallRepository.findById(callId2).get();
        CprCall cprCall3 = cprCallRepository.findById(callId3).get();
        CprCall cprCall4 = cprCallRepository.findById(callId4).get();

        assertThat(cprCall1.getAddress().getId()).isEqualTo(testAddress1.getId());
        assertThat(cprCall2.getAddress().getId()).isEqualTo(testAddress2.getId());
        assertThat(cprCall3.getAddress().getId()).isEqualTo(testAddress3.getId());
        assertThat(cprCall4.getAddress().getId()).isEqualTo(testAddress4.getId());

        assertThat(cprCall1.getStatus()).isEqualTo(CprCallStatus.IN_PROGRESS);

    }

    @Test
    @Transactional
    public void 실시간_출동_안내_출동한_엔젤이_없는_경우() {
        //given
        createUsers();
        User caller = userRepository.findByPhoneNumber(userPhoneNumber).get();
        Long callId = cprCallService.makeCall(new CprCallRequestDto(testFullAddress1, latitude, longitude), caller)
                .getCallId();

        //when
        var callGuide = cprCallService.getNumberOfAngelsDispatched(callId);

        //then
        assertThat(callGuide.getNumberOfAngels()).isEqualTo(0);
    }

    @Test
    @Transactional
    public void 실시간_출동_안내_출동한_엔젤이_있는_경우() {
        //given
        createUsers();
        User caller = userRepository.findByPhoneNumber(userPhoneNumber).get();
        User dispatcher = userRepository.findByPhoneNumber(angelPhoneNumber).get();

        Long callId = cprCallService.makeCall(new CprCallRequestDto(testFullAddress1, latitude, longitude), caller).getCallId();
        dispatchService.dispatch(dispatcher, new DispatchRequestDto(callId));

        //when
        var callGuide = cprCallService.getNumberOfAngelsDispatched(callId);

        //then
        assertThat(callGuide.getNumberOfAngels()).isEqualTo(1);
    }

    private void createUsers() {

        String userNickname = "예진";
        String angelNickname = "현애";
        String deviceToken = "device-code";
        var address = addressRepository.findByFullAddress(testFullAddress1).get();
        authService.signup(new SignUpRequestDto(userNickname, userPhoneNumber, address.getId(), deviceToken));
        authService.signup(new SignUpRequestDto(angelNickname, angelPhoneNumber, address.getId(), deviceToken));

        User angel = userRepository.findByPhoneNumber(angelPhoneNumber).get();
        angel.acquireCertification(LocalDateTime.now());
        userRepository.save(angel);
    }
}