package com.mentionall.cpr2u.user.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Getter
public enum AngelStatus {

    ACQUIRED("ACQUIRED"),
    EXPIRED("EXPIRED"),
    UNACQUIRED("UNACQUIRED");

    private final String angelStatus;
}
