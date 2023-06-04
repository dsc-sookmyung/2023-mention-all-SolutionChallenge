package com.mentionall.cpr2u.user.repository.address;

import com.mentionall.cpr2u.user.domain.Address;

import java.util.List;
import java.util.Optional;

public interface AddressDslRepository {
    List<String> findAllSido();

    Optional<Address> findByFullAddress(String fullAddress);
}
