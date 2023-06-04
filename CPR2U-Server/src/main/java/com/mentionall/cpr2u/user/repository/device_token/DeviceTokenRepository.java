package com.mentionall.cpr2u.user.repository.device_token;

import com.mentionall.cpr2u.user.domain.DeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;

import java.util.Optional;

public interface DeviceTokenRepository extends JpaRepository<DeviceToken, String>, DeviceTokenDslRepository, QuerydslPredicateExecutor<DeviceToken> {
    Optional<DeviceToken> findByUserId(String userId);
}
