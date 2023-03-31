package com.mentionall.cpr2u.util;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum MessageEnum {
    ANGEL_EXPIRED_TITLE("CPR Angel 권한이 만료되었습니다."),
    ANGEL_EXPIRED_BODY("CPR2U에 접속해서 교육 받고 Angel 권한을 연장하세요."),
    CPR_CALL_TITLE("CPR Angel의 출동이 필요합니다.");

    private final String message;

}
