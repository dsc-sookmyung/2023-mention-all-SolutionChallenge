package com.mentionall.cpr2u.call.service;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.domain.DispatchStatus;
import com.mentionall.cpr2u.call.domain.Report;
import com.mentionall.cpr2u.call.dto.ReportRequestDto;
import com.mentionall.cpr2u.call.dto.cpr_call.CprCallRequestDto;
import com.mentionall.cpr2u.call.dto.dispatch.DispatchRequestDto;
import com.mentionall.cpr2u.call.repository.CprCallRepository;
import com.mentionall.cpr2u.call.repository.DispatchRepository;
import com.mentionall.cpr2u.call.repository.ReportRepository;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.address.AddressResponseDto;
import com.mentionall.cpr2u.user.dto.user.SignUpRequestDto;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.user.service.AddressService;
import com.mentionall.cpr2u.user.service.AuthService;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DisplayName("출동 관련 테스트")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
public class DispatchServiceTest {

    @Autowired
    private DispatchService dispatchService;
    @Autowired
    private DispatchRepository dispatchRepository;
    @Autowired
    private AuthService authService;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private CprCallService callService;
    @Autowired
    private CprCallRepository callRepository;
    @Autowired
    private AddressService addressService;
    @Autowired
    private ReportRepository reportRepository;

    private static final String fullAddress = "서울특별시 용산구 청파로47길 100";
    private static final double latitude = 37.545183430559604;
    private static final double longitude = 126.9648022541866;
    private static final String callerPhoneNumber  = "010-0000-0000";
    private static final String dispatcherPhoneNumber = "010-0000-0001";

    @BeforeEach
    public void beforeEach() {
        addressService.loadAddressList();
    }

    @Test
    @Transactional
    public void CPR_출동_호출상황_정보_조회() {
        //given
        createCallerAndDispatcher();
        User caller = userRepository.findByPhoneNumber(callerPhoneNumber).get();
        User dispatcher = userRepository.findByPhoneNumber(dispatcherPhoneNumber).get();

        long callId = callService.makeCall(new CprCallRequestDto(fullAddress, latitude, longitude), caller).getCallId();

        //when
        var dispatchInfo = dispatchService.dispatch(dispatcher, new DispatchRequestDto(callId));

        //then
        CprCall cprCall = callRepository.findById(callId).get();
        assertThat(dispatchInfo.getCalledAt()).isEqualTo(cprCall.getCalledAt());
        assertThat(dispatchInfo.getLatitude()).isEqualTo(latitude);
        assertThat(dispatchInfo.getLongitude()).isEqualTo(longitude);
        assertThat(dispatchInfo.getFullAddress()).isEqualTo(fullAddress);
    }

    @Test
    @Transactional
    public void CPR_출동_시_출동상태_진행중() {
        //given
        createCallerAndDispatcher();
        User caller = userRepository.findByPhoneNumber(callerPhoneNumber).get();
        User dispatcher = userRepository.findByPhoneNumber(dispatcherPhoneNumber).get();

        long callId = callService.makeCall(new CprCallRequestDto(fullAddress, latitude, longitude), caller).getCallId();

        //when
        var callInfo = dispatchService.dispatch(dispatcher, new DispatchRequestDto(callId));

        //then
        Dispatch dispatch = dispatchRepository.findById(callInfo.getDispatchId()).get();
        assertThat(dispatch.getStatus()).isEqualTo(DispatchStatus.IN_PROGRESS);
    }

    @Test
    @Transactional
    public void CPR_출동_도착_시_출동상태_도착() {
        //given
        createCallerAndDispatcher();
        User caller = userRepository.findByPhoneNumber(callerPhoneNumber).get();
        User dispatcher = userRepository.findByPhoneNumber(dispatcherPhoneNumber).get();

        long callId = callService.makeCall(new CprCallRequestDto(fullAddress, latitude, longitude), caller).getCallId();
        var dispatchInfo = dispatchService.dispatch(dispatcher, new DispatchRequestDto(callId));

        //when
        dispatchService.arrive(dispatchInfo.getDispatchId());

        //then
        var dispatch = dispatchRepository.findById(dispatchInfo.getDispatchId()).get();
        assertThat(dispatch.getStatus()).isEqualTo(DispatchStatus.ARRIVED);
    }

    @Test
    @Transactional
    public void CPR_허위_호출_신고() {
        //given
        createCallerAndDispatcher();
        User caller = userRepository.findByPhoneNumber(callerPhoneNumber).get();
        User dispatcher = userRepository.findByPhoneNumber(dispatcherPhoneNumber).get();

        long callId = callService.makeCall(new CprCallRequestDto(fullAddress, latitude, longitude), caller).getCallId();
        var dispatchInfo = dispatchService.dispatch(dispatcher, new DispatchRequestDto(callId));

        //when
        dispatchService.report(new ReportRequestDto(dispatchInfo.getDispatchId(), "신고 내용"));

        //then
        List<Report> reportList = reportRepository.findAllByReporter(dispatcher);
        assertThat(reportList.size()).isEqualTo(1);
        assertThat(reportList.get(0).getCprCall().getId()).isEqualTo(callId);
        assertThat(reportList.get(0).getContent()).isEqualTo("신고 내용");
    }

    private void createCallerAndDispatcher() {
        List<AddressResponseDto> addressList = addressService.readAll();
        var address = addressList.get(0);
        var addressDetail = address.getGugunList().get(0);

        authService.signup(new SignUpRequestDto("호출자", "010-0000-0000", addressDetail.getId(), "device_token"));
        authService.signup(new SignUpRequestDto("출동자", "010-0000-0001", addressDetail.getId(), "device_token"));
    }
}
