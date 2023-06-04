package com.mentionall.cpr2u.call.repository;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.dto.cpr_call.CprCallResponseDto;

import java.util.List;

public interface CprCallDslRepository {
    List<CprCallResponseDto> findAllCallInProcessByAddress(Long addressId);

    List<CprCall> findAllCallInProgressButExpired();
}
