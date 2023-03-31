package com.mentionall.cpr2u.call.service;

import com.mentionall.cpr2u.call.domain.*;
import com.mentionall.cpr2u.call.dto.CprCallOccurDto;
import com.mentionall.cpr2u.call.dto.DispatchRequestDto;
import com.mentionall.cpr2u.call.dto.ReportRequestDto;
import com.mentionall.cpr2u.call.repository.*;
import com.mentionall.cpr2u.user.domain.Address;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.UserSignUpDto;
import com.mentionall.cpr2u.user.repository.AddressRepository;
import com.mentionall.cpr2u.user.repository.FakeAddressRepository;
import com.mentionall.cpr2u.user.repository.FakeUserRepository;
import com.mentionall.cpr2u.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class DispatchServiceTest {

    private DispatchService dispatchService;

    private DispatchRepository dispatchRepository;

    private CprCallRepository callRepository;

    private UserRepository userRepository;

    private ReportRepository reportRepository;

    private AddressRepository addressRepository;

    @BeforeEach
    public void beforeEach() {
        this.dispatchRepository = new FakeDispatchRepository();
        this.callRepository = new FakeCprCallRepository();
        this.userRepository = new FakeUserRepository();
        this.reportRepository = new FakeReportRepository();
        this.addressRepository = new FakeAddressRepository();
        this.dispatchService = new DispatchService(dispatchRepository, callRepository, reportRepository);
   }

    @BeforeEach
    public void insertData() {
        User caller = userRepository.save(new User("2L", new UserSignUpDto("호출자", "010-0000-0000", "device_token")));
        Address address = addressRepository.save(new Address(1L, "서울시", "용산구", new ArrayList<>()));
        callRepository.save(new CprCall(1L, caller, address, "서울시 용산구 어쩌구",
                LocalDateTime.now(), 36.44, 46.55, CprCallStatus.IN_PROGRESS,
                new ArrayList<>(), new ArrayList<>()));

        userRepository.save(new User("1L", new UserSignUpDto("출동자", "010-0000-0000", "device_token")));
    }

    @Test
    @DisplayName("CPR 출동")
    public void dispatch() {
        //given
        User user = userRepository.findById("1L").get();
        CprCall cprCall = callRepository.findById(1L).get();

        //when
        var response = dispatchService.dispatch(user, new DispatchRequestDto(cprCall.getId()));

        //then
        assertThat(response.getCalledAt()).isEqualTo(cprCall.getCalledAt());
        assertThat(response.getLatitude()).isEqualTo(36.44);
        assertThat(response.getLongitude()).isEqualTo(46.55);
        assertThat(response.getFullAddress()).isEqualTo("서울시 용산구 어쩌구");

        Dispatch dispatch = dispatchRepository.findById(response.getDispatchId()).get();
        assertThat(dispatch.getStatus()).isEqualTo(DispatchStatus.IN_PROGRESS);
    }

    @Test
    @DisplayName("CPR 출동 도착")
    public void arrive() {
        //given
        User user = userRepository.findById("1L").get();
        CprCall cprCall = callRepository.findById(1L).get();

        //when
        var response = dispatchService.dispatch(user, new DispatchRequestDto(cprCall.getId()));
        dispatchService.arrive(response.getDispatchId());

        //then
        var dispatchArrived = dispatchRepository.findById(response.getDispatchId()).get();
        assertThat(dispatchArrived.getStatus()).isEqualTo(DispatchStatus.ARRIVED);
    }

    @Test
    @DisplayName("출동 신고")
    public void report() {
        //given
        User user = userRepository.findById("1L").get();
        CprCall cprCall = callRepository.findById(1L).get();

        //when
        var response = dispatchService.dispatch(user, new DispatchRequestDto(cprCall.getId()));
        dispatchService.report(new ReportRequestDto(response.getDispatchId(), "신고 내용"));

        //then
        List<Report> reportList = reportRepository.findAllByReporter(user);
        assertThat(reportList.size()).isEqualTo(1);
        assertThat(reportList.get(0).getCprCall().getId()).isEqualTo(1L);
        assertThat(reportList.get(0).getContent()).isEqualTo("신고 내용");
    }
}
