package com.mentionall.cpr2u.call.repository;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.dto.CprCallDto;

import java.util.List;

public interface CprCallDslRepository {
    List<CprCallDto> findAllCallInProcessByAddress(Long addressId);

    List<CprCall> findAllCallInProgressButExpired();
}
