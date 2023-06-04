package com.mentionall.cpr2u.user.controller;

import com.mentionall.cpr2u.user.domain.PrincipalDetails;
import com.mentionall.cpr2u.user.dto.address.AddressResponseDto;
import com.mentionall.cpr2u.user.dto.user.*;
import com.mentionall.cpr2u.user.service.AddressService;
import com.mentionall.cpr2u.user.service.AuthService;
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

import static com.mentionall.cpr2u.util.exception.ResponseCode.OK_NICKNAME_CHECK;
import static com.mentionall.cpr2u.util.exception.ResponseCode.OK_SUCCESS;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
@Tag(name = "AuthController", description = "회원가입/로그인")
public class AuthController {
    private final AuthService authService;
    private final AddressService addressService;

    @Operation(summary = "회원가입",
            method = "POST",
            description = "회원가입 API"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "회원가입 성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = TokenResponseDto.class))))
    })
    @PostMapping("/signup")
    public ResponseEntity<ResponseDataTemplate> signup(@RequestBody SignUpRequestDto signUpRequestDto){
        return ResponseDataTemplate.toResponseEntity(
                OK_SUCCESS,
                authService.signup(signUpRequestDto)
        );
    }

    @Operation(summary = "로그인 인증번호 발급",
            method = "POST",
            description = "로그인 인증번호 발급 API"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "인증번호 발급 성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = CodeResponseDto.class))))
    })
    @PostMapping("/verification")
    public ResponseEntity<ResponseDataTemplate> issueVerificationCode(@RequestBody PhoneNumberRequestDto userPhoneNumberRequestDto){
        return ResponseDataTemplate.toResponseEntity(
                OK_SUCCESS,
                authService.getVerificationCode(userPhoneNumberRequestDto)
        );
    }

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

    @Operation(summary = "인증된 사용자 로그인 처리",
            method = "POST",
            description = "인증된 사용자 로그인 처리 API"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "로그인 성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = TokenResponseDto.class)))),
            @ApiResponse(responseCode = "404", description = "회원가입이 필요한 사용자",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class))))
    })
    @PostMapping("/login")
    public ResponseEntity<ResponseDataTemplate> verificationUserLogin(@RequestBody LoginRequestDto loginRequestDto){
        return ResponseDataTemplate.toResponseEntity(
                OK_SUCCESS,
                authService.login(loginRequestDto)
        );
    }
    @Operation(summary = "닉네임 중복확인",
            method = "POST",
            description = "닉네임 중복확인 API"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "사용 가능한 닉네임",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
            @ApiResponse(responseCode = "400", description = "중복된 닉네임",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class))))
    })
    @GetMapping("/nickname")
    public ResponseEntity<ResponseTemplate> nicknameCheck(@RequestParam("nickname") String nickname){
        authService.checkNicknameDuplicated(nickname);

        return ResponseTemplate.toResponseEntity(OK_NICKNAME_CHECK);
    }

    @Operation(summary = "자동로그인",
            method = "POST",
            description = "자동로그인 API"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "자동 로그인 성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = TokenResponseDto.class)))),
            @ApiResponse(responseCode = "403", description = "유효하지 않은 refresh token",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class))))
    })
    @PostMapping("/auto-login")
    public ResponseEntity<ResponseDataTemplate> autoLogin(@RequestBody TokenReissueRequestDto tokenReissueRequestDto){
        return ResponseDataTemplate.toResponseEntity(
                OK_SUCCESS,
                authService.reissueToken(tokenReissueRequestDto)
        );
    }

    @Operation(summary = "로그아웃",
            method = "POST",
            description = "로그아웃 API"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "로그아웃 성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
    })
    @PostMapping("/logout")
    public ResponseEntity<ResponseTemplate> logout(@GetUserDetails PrincipalDetails userDetails) {
        authService.logout(userDetails.getUser());
        return ResponseTemplate.toResponseEntity(
                OK_SUCCESS
        );
    }

}
