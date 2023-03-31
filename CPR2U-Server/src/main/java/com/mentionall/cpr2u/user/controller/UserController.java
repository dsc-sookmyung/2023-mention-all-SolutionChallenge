package com.mentionall.cpr2u.user.controller;

import com.mentionall.cpr2u.user.domain.PrincipalDetails;
import com.mentionall.cpr2u.user.dto.AddressRequestDto;
import com.mentionall.cpr2u.user.dto.AddressResponseDto;
import com.mentionall.cpr2u.user.service.AddressService;
import com.mentionall.cpr2u.util.GetUserDetails;
import com.mentionall.cpr2u.util.ResponseDataTemplate;
import com.mentionall.cpr2u.util.ResponseTemplate;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.mentionall.cpr2u.util.exception.ResponseCode.OK_SUCCESS;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
@Tag(name = "UserController", description = "회원 정보 관리")
public class UserController {

    private final AddressService addressService;

    @Operation(summary = "주소 리스트 조회", description = "전국 시도와 시군구 주소 리스트를 조회한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공", content = @Content(array = @ArraySchema(schema = @Schema(implementation = AddressResponseDto.class)))),
    })
    @GetMapping("/address")
    public ResponseEntity<ResponseDataTemplate> readAddressList() {
        return ResponseDataTemplate.toResponseEntity(
                OK_SUCCESS,
                addressService.readAll()
        );
    }

    @Operation(summary = "사용자 주소 설정", description = "사용자의 주소를 파라미터로 넘어온 ID의 주소로 설정한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
            @ApiResponse(responseCode = "404", description = "해당 ID의 주소 데이터가 없습니다.", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
    })
    @PostMapping("/address")
    public ResponseEntity<ResponseTemplate> setAddress(@GetUserDetails PrincipalDetails userDetails, @RequestBody AddressRequestDto requestDto) {
        addressService.setAddress(userDetails.getUser(), requestDto);

        return ResponseTemplate.toResponseEntity(OK_SUCCESS);
    }

}
