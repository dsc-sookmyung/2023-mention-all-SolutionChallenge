package com.mentionall.cpr2u.call.controller;

import com.mentionall.cpr2u.call.dto.dispatch.DispatchRequestDto;
import com.mentionall.cpr2u.call.dto.dispatch.DispatchResponseDto;
import com.mentionall.cpr2u.call.dto.ReportRequestDto;
import com.mentionall.cpr2u.call.service.DispatchService;
import com.mentionall.cpr2u.user.domain.PrincipalDetails;
import com.mentionall.cpr2u.util.GetUserDetails;
import com.mentionall.cpr2u.util.ResponseDataTemplate;
import com.mentionall.cpr2u.util.ResponseTemplate;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
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

@Tag(name = "DispatchController", description = "출동 화면 컨트롤러")
@RequestMapping("/dispatch")
@RestController
@RequiredArgsConstructor
public class DispatchController {
    private final DispatchService dispatchService;

    @Operation(summary = "CPR 출동", description = "CPR 응급 상황으로 출동한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = DispatchResponseDto.class)))),
            @ApiResponse(responseCode = "400", description = "이미 종료되었거나, 본인이 생성한 호출에 대한 출동입니다.",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
            @ApiResponse(responseCode = "404", description = "해당 ID의 CPR 요청 정보를 찾을 수 없습니다.",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
    })
    @PostMapping
    public ResponseEntity<ResponseDataTemplate> dispatch(
            @RequestBody DispatchRequestDto requestDto,
            @GetUserDetails PrincipalDetails userDetails) {
        return ResponseDataTemplate.toResponseEntity(ResponseCode.OK_SUCCESS, dispatchService.dispatch(userDetails.getUser(), requestDto));
    }

    @Operation(summary = "CPR 출동 도착", description = "CPR 응급 상황에 도착했음을 알린다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
            @ApiResponse(responseCode = "404", description = "해당 ID의 출동 데이터 정보를 찾을 수 없습니다.",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
    })
    @PostMapping("/arrive/{dispatch_id}")
    public ResponseEntity<ResponseTemplate> arrive(
            @Parameter(description = "출동 데이터 ID") @PathVariable(value = "dispatch_id") Long dispatchId
    ) {
        dispatchService.arrive(dispatchId);
        return ResponseTemplate.toResponseEntity(OK_SUCCESS);
    }

    @Operation(summary = "잘못된 CPR 응급 상황 신고", description = "CPR 응급 상황이 허위인 경우, 신고한다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "성공",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
            @ApiResponse(responseCode = "404", description = "해당 ID의 CPR 출동 데이터를 찾을 수 없습니다.",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = ResponseTemplate.class)))),
    })
    @PostMapping("/report")
    public ResponseEntity<ResponseTemplate> report(@RequestBody ReportRequestDto requestDto) {
        dispatchService.report(requestDto);
        return ResponseTemplate.toResponseEntity(OK_SUCCESS);
    }
}
