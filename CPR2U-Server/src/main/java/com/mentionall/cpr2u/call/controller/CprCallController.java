package com.mentionall.cpr2u.call.controller;

import com.mentionall.cpr2u.call.dto.CprCallGuideResponseDto;
import com.mentionall.cpr2u.call.dto.CprCallIdDto;
import com.mentionall.cpr2u.call.dto.CprCallNearUserDto;
import com.mentionall.cpr2u.call.dto.CprCallOccurDto;
import com.mentionall.cpr2u.call.service.CprCallService;
import com.mentionall.cpr2u.user.domain.PrincipalDetails;
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

import static com.mentionall.cpr2u.util.exception.ResponseCode.OK_CPR_CALL_END_SITUATION;
import static com.mentionall.cpr2u.util.exception.ResponseCode.OK_SUCCESS;

@Tag(name = "CallController", description = "호출 화면 컨트롤러")
@RequestMapping("/call")
@RequiredArgsConstructor
@RestController
public class CprCallController {

    private final CprCallService cprCallService;

    @Operation(summary = "홈 화면", description = "현재 근처에서 진행중인 CPR 요청이 있는지 확인한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공", content = @Content(array = @ArraySchema(schema = @Schema(implementation = CprCallNearUserDto.class)))),
            @ApiResponse(responseCode = "400", description = "엔젤 자격증이 있으나, 주소를 설정하지 않음", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class))))
    })
    @GetMapping
    public ResponseEntity<ResponseDataTemplate> getNowCallStatusNearUser(@GetUserDetails PrincipalDetails userDetails) {
        return ResponseDataTemplate.toResponseEntity(OK_SUCCESS, cprCallService.getCallNearUser(userDetails.getUser()));
    }

    @Operation(summary = "호출하기", description = "사건 발생 지역의 CPR Angel들을 호출한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공", content = @Content(array = @ArraySchema(schema = @Schema(implementation = CprCallIdDto.class)))),
            @ApiResponse(responseCode = "404", description = "해당 주소지에 맞는 주소 지역구를 찾을 수 없습니다", content = @Content(array = @ArraySchema(schema = @Schema(implementation = CprCallIdDto.class))))
    })
    @PostMapping
    public ResponseEntity<ResponseDataTemplate> makeCall(@RequestBody CprCallOccurDto cprCallOccurDto,
                                                         @GetUserDetails PrincipalDetails userDetails) {
        return ResponseDataTemplate.toResponseEntity(OK_SUCCESS, cprCallService.makeCall(cprCallOccurDto, userDetails.getUser()));
    }

    @Operation(summary = "실시간 호출 상황 안내", description = "현재 출동 중인 CPR 엔젤이 몇명인지 확인한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공", content = @Content(array = @ArraySchema(schema = @Schema(implementation = CprCallGuideResponseDto.class)))),
            @ApiResponse(responseCode = "404", description = "해당 ID의 호출 정보를 찾을 수 없음", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class))))
    })
    @GetMapping("/{call_id}")
    public ResponseEntity<ResponseDataTemplate> getNumberOfAngelsDispatched(@PathVariable(name = "call_id") Long callId) {
        return ResponseDataTemplate.toResponseEntity(OK_SUCCESS, cprCallService.getNumberOfAngelsDispatched(callId));
    }

    @Operation(summary = "호출 상황 종료", description = "호출을 중단한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
            @ApiResponse(responseCode = "404", description = "해당 ID의 호출 데이터가 없습니다.", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
    })
    @PostMapping("/end/{call_id}")
    public ResponseEntity<ResponseTemplate> endCall(@PathVariable(name="call_id") Long callId) {
        cprCallService.endCall(callId);
        return ResponseTemplate.toResponseEntity(OK_CPR_CALL_END_SITUATION);
    }
}
