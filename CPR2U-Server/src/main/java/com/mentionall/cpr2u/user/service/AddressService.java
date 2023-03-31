package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.user.domain.Address;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.AddressRequestDto;
import com.mentionall.cpr2u.user.dto.AddressResponseDto;
import com.mentionall.cpr2u.user.dto.SigugunResponseDto;
import com.mentionall.cpr2u.user.repository.AddressRepository;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AddressService {
    private final AddressRepository addressRepository;

    private final UserRepository userRepository;

    public List<AddressResponseDto> readAll() {
        List<Address> addressList = addressRepository.findAll();
        List<AddressResponseDto> response = new ArrayList();

        for (String sido : addressRepository.findAllSido()) {
            AddressResponseDto address = new AddressResponseDto(
                    sido,
                    addressList.stream()
                            .filter(a -> a.getSido().equals(sido))
                            .map(a -> new SigugunResponseDto(a.getId(), a.getSigugun()))
                            .collect(Collectors.toList()));
            response.add(address);
        }

        return response;
    }

    public void setAddress(User user, AddressRequestDto requestDto) {
        Address address = addressRepository.findById(requestDto.getAddressId()).orElseThrow(
                () -> new CustomException(ResponseCode.NOT_FOUND_ADDRESS)
        );

        user.setAddress(address);
        userRepository.save(user);
    }
}
