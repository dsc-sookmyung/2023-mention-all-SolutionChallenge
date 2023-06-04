package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.user.domain.Address;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.address.AddressRequestDto;
import com.mentionall.cpr2u.user.dto.address.AddressResponseDto;
import com.mentionall.cpr2u.user.dto.address.SigugunResponseDto;
import com.mentionall.cpr2u.user.repository.address.AddressRepository;
import com.mentionall.cpr2u.user.repository.UserRepository;
import com.mentionall.cpr2u.util.CsvFileParser;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import static com.mentionall.cpr2u.util.exception.ResponseCode.SERVER_ERROR_PARSING_URI;

@Slf4j
@Service
@RequiredArgsConstructor
public class AddressService {
    private final AddressRepository addressRepository;
    private final UserRepository userRepository;
    private final CsvFileParser csvFileParser;

    private static final String csvFileName = "cpr2u_address_table.csv";

    public void loadAddressList() {
        addressRepository.deleteAll();

        List<List<String>> parsingList;
        try {
            parsingList = csvFileParser.parse(new ClassPathResource(csvFileName).getURI());
        } catch (IOException e) {
            e.printStackTrace();
            throw new CustomException(SERVER_ERROR_PARSING_URI);
        }

        // remove a header row.
        parsingList.remove(0);

        List<Address> addressList = parsingList.stream()
                .map(l -> (l.size() > 1) ? new Address(l.get(0), l.get(1)) : new Address(l.get(0), ""))
                .collect(Collectors.toList());

        addressRepository.saveAll(addressList);
    }

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
