package com.mentionall.cpr2u.call.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public enum FcmPushTypeEnum {

    ANGLE_EXPIRATION("ANGEL_EXPIRATION"),
    CPR_CALL("CPR_CALL");

    private final String type;
}
