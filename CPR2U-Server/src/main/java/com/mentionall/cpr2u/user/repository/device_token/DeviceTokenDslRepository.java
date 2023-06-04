package com.mentionall.cpr2u.user.repository.device_token;

import org.springframework.data.domain.Pageable;

import java.util.List;

public interface DeviceTokenDslRepository {
    List<String> findAllDeviceTokenByUserAddressExceptCaller(Long addressId, String userId, Pageable pageable);
}
