package com.mentionall.cpr2u.user.domain;


import lombok.Getter;

@Getter
public enum UserRole {

    USER("ROLE_USER", "일반 사용자 권한"),
    VISITOR("VISITOR", "권한 없음");
    private final String code;
    private final String name;

    UserRole(String code, String name) {
        this.code = code;
        this.name = name;
    }
}
