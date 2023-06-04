package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.dto.address.AddressRequestDto;
import com.mentionall.cpr2u.user.dto.address.AddressResponseDto;
import com.mentionall.cpr2u.user.dto.user.SignUpRequestDto;
import com.mentionall.cpr2u.user.repository.UserRepository;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.transaction.Transactional;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DisplayName("주소지 관련 테스트")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
public class AddressServiceTest {
    @Autowired
    private AddressService addressService;
    @Autowired
    private UserService userService;
    @Autowired
    private AuthService authService;
    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    public void beforeEach() {
        addressService.loadAddressList();
    }

    @Test
    @Transactional
    public void 유저의_주소지_설정() {
        //given
        List<AddressResponseDto> addressList = addressService.readAll();
        var address = addressList.get(0);
        var addressDetail = address.getGugunList().get(0);

        authService.signup(new SignUpRequestDto("현애", "010-0000-0000", addressDetail.getId(), "device-token"));
        User user = userRepository.findByPhoneNumber("010-0000-0000").get();

        //when
        address = addressList.get(1);
        addressDetail = address.getGugunList().get(0);

        addressService.setAddress(user, new AddressRequestDto(addressDetail.getId()));

        //then
        User findUser = userRepository.findByPhoneNumber("010-0000-0000").get();
        assertThat(findUser.getAddress().getSido()).isEqualTo(address.getSido());
        assertThat(findUser.getAddress().getId()).isEqualTo(addressDetail.getId());
        assertThat(findUser.getAddress().getSigugun()).isEqualTo(addressDetail.getGugun());
    }

    @Test
    @Transactional
    public void 주소지_리스트_조회() {
        //given

        //when
        List<AddressResponseDto> response = addressService.readAll();

        //then
        assertThat(response.size()).isEqualTo(16);                           // count of sido
        assertThat(response.get(0).getSido()).isEqualTo("강원도");
        assertThat(response.get(0).getGugunList().size()).isEqualTo(18);     // count of sigugun
    }
}
