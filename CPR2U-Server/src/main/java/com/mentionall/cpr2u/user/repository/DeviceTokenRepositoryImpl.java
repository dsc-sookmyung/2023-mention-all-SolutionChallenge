package com.mentionall.cpr2u.user.repository;

import com.mentionall.cpr2u.user.domain.DeviceToken;
import com.mentionall.cpr2u.user.domain.QDeviceToken;
import com.querydsl.jpa.impl.JPAQueryFactory;

import javax.persistence.EntityManager;
import java.util.List;

import static com.mentionall.cpr2u.user.domain.QDeviceToken.*;

public class DeviceTokenRepositoryImpl implements DeviceTokenDslRepository {

    private final JPAQueryFactory queryFactory;

    public DeviceTokenRepositoryImpl(EntityManager em) {
        this.queryFactory = new JPAQueryFactory(em);
    }

    @Override
    public List<DeviceToken> findAllDeviceTokenByUserAddress(Long addressId, String userId) {
        return queryFactory.selectFrom(deviceToken)
                .where(deviceToken.user.address.id.eq(addressId)
                        .and(deviceToken.user.id.ne(userId)))
                .fetch();
    }
}
