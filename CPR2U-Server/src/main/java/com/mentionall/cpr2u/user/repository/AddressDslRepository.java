package com.mentionall.cpr2u.user.repository;

import com.mentionall.cpr2u.user.domain.Address;

import java.util.Optional;

public interface AddressDslRepository {
    Optional<Address> findByFullAddress(String[] addressList);
}
