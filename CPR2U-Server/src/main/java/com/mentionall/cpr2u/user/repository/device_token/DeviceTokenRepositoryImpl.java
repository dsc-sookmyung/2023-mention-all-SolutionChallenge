package com.mentionall.cpr2u.user.repository.device_token;

import com.mentionall.cpr2u.user.domain.AngelStatus;
import com.querydsl.jpa.impl.JPAQueryFactory;
import org.springframework.data.domain.Pageable;

import javax.persistence.EntityManager;
import java.util.List;

import static com.mentionall.cpr2u.user.domain.QDeviceToken.deviceToken;

public class DeviceTokenRepositoryImpl implements DeviceTokenDslRepository {

    private final JPAQueryFactory queryFactory;

    public DeviceTokenRepositoryImpl(EntityManager em) {
        this.queryFactory = new JPAQueryFactory(em);
    }

    @Override
    public List<String> findAllDeviceTokenByUserAddressExceptCaller(Long addressId, String userId, Pageable pageable) {
        return queryFactory.select(deviceToken.token)
                .from(deviceToken)
                .where(deviceToken.user.address.id.eq(addressId)
                        .and(deviceToken.user.id.ne(userId))
                        .and(deviceToken.user.certificate.status.eq(AngelStatus.ACQUIRED)))
                .offset(pageable.getOffset())
                .limit(pageable.getPageSize())
                .fetch();
    }
}
