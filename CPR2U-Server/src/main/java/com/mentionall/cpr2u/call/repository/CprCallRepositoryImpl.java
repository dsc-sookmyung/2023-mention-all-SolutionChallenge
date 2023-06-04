package com.mentionall.cpr2u.call.repository;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.CprCallStatus;
import com.mentionall.cpr2u.call.dto.cpr_call.CprCallResponseDto;
import com.mentionall.cpr2u.call.dto.cpr_call.QCprCallResponseDto;
import com.querydsl.jpa.impl.JPAQueryFactory;

import javax.persistence.EntityManager;
import java.time.LocalDateTime;
import java.util.List;

import static com.mentionall.cpr2u.call.domain.QCprCall.cprCall;

public class CprCallRepositoryImpl implements CprCallDslRepository {

    private final JPAQueryFactory queryFactory;

    public CprCallRepositoryImpl(EntityManager em) {
        this.queryFactory = new JPAQueryFactory(em);
    }

    @Override
    public List<CprCallResponseDto> findAllCallInProcessByAddress(Long addressId) {
        return queryFactory.select(new QCprCallResponseDto(cprCall))
                .from(cprCall)
                .where(cprCall.status.eq(CprCallStatus.IN_PROGRESS).and(cprCall.address.id.eq(addressId)))
                .fetch();
    }

    @Override
    public List<CprCall> findAllCallInProgressButExpired() {
        return queryFactory.selectFrom(cprCall)
                .where(cprCall.status.eq(CprCallStatus.IN_PROGRESS)
                        .and(cprCall.calledAt.lt(LocalDateTime.now().minusMinutes(10))))
                .fetch();
    }
}
