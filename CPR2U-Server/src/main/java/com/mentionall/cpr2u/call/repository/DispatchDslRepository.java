package com.mentionall.cpr2u.call.repository;

import com.mentionall.cpr2u.call.domain.Dispatch;

import java.util.List;
import java.util.Optional;

public interface DispatchDslRepository {
    List<Dispatch> findAllNotArrivedAngelByCprCallId(Long cprCallId);

}
