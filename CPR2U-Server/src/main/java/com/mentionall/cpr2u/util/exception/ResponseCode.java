package com.mentionall.cpr2u.util.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

import static org.springframework.http.HttpStatus.*;

@Getter
@AllArgsConstructor
public enum ResponseCode {
    OK_SUCCESS(OK, "성공"),
    OK_NICKNAME_CHECK(OK, "사용 가능한 닉네임 입니다."),
    OK_QUIZ_FAIL(OK, "점수가 낮아 퀴즈 테스트를 실패했습니다."),
    OK_POSTURE_FAIL(OK, "점수가 낮아 자세실습 테스트를 실패했습니다."),
    OK_CERTIFICATED(OK, "CPR 엔젤 수료증을 받았습니다."),
    OK_CPR_CALL_END_SITUATION(OK, "호출이 종료되었습니다."),

    BAD_REQUEST_NICKNAME_DUPLICATED(BAD_REQUEST, "중복된 닉네임 입니다."),
    BAD_REQUEST_NOT_VALID_DISPATCH(BAD_REQUEST, "이미 종료되었거나, 본인이 생성한 호출에 대한 출동입니다."),
    BAD_REQUEST_LECTURE_DUPLICATED(BAD_REQUEST, "중북되는 섹션의 강의가 존재합니다."),
    BAD_REQUEST_QUIZ_WRONG_ANSWER(BAD_REQUEST, "해당 퀴즈의 답안 인덱스가 잘못된 값을 갖고 있습니다."),
    BAD_REQUEST_EDUCATION_PERMISSION_DENIED(BAD_REQUEST, "이전 진도를 모두 완료해야 수강할 수 있습니다."),
    BAD_REQUEST_ADDRESS_NOT_SET(BAD_REQUEST, "주소가 아직 설정되지 않았습니다."),

    FORBIDDEN_TOKEN_NOT_VALID(FORBIDDEN, "유효하지 않은 토큰입니다."),
    
    NOT_FOUND_USER(NOT_FOUND, "회원 정보가 없습니다."),
    NOT_FOUND_CPRCALL(NOT_FOUND, "해당 ID의 CPR 요청을 찾을 수 없습니다."),
    NOT_FOUND_DISPATCH(NOT_FOUND, "해당 ID의 출동 데이터를 찾을 수 없습니다."),
    NOT_FOUND_ADDRESS(NOT_FOUND, "잘못된 주소 ID입니다." ),
    NOT_FOUND_QUIZ(NOT_FOUND, "해당 ID의 퀴즈를 찾을 수 없습니다."),
    NOT_FOUND_FAILED_TO_MATCH_ADDRESS(INTERNAL_SERVER_ERROR, "해당 주소지에 맞는 주소 지역구를 찾을 수 없습니다."),

    SERVER_ERROR_FAILED_TO_SEND_FCM(INTERNAL_SERVER_ERROR, "FCM 푸시 알림을 보내는 데 실패했습니다."),
    SERVER_ERROR_FAILED_TO_SIGNUP(INTERNAL_SERVER_ERROR, "회원가입에 실패했습니다."),
    SERVER_ERROR_FAILED_TO_FIND_LECTURE(INTERNAL_SERVER_ERROR, "해당 강의를 찾을 수 없습니다."),
    SERVER_ERROR_FAILED_TO_GET_EDUCATION_PROGRESS(INTERNAL_SERVER_ERROR, "유저의 교육 진도 정보가 조회되지 않습니다."),
    SERVER_ERROR_PARSING_FAILED(INTERNAL_SERVER_ERROR, "CSV 파싱을 실패했습니다."),
    SERVER_ERROR_PARSING_URI(INTERNAL_SERVER_ERROR, "해당 이름의 리소스 파일이 없습니다.");


    private final HttpStatus httpStatus;
    private final String detail;
}
