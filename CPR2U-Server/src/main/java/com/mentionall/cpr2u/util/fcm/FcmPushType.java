package com.mentionall.cpr2u.util.fcm;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public enum FcmPushType {

    ANGLE_EXPIRATION("ANGEL_EXPIRATION"),
    CPR_CALL("CPR_CALL");

    private final String type;
}
