package com.mentionall.cpr2u.call.domain;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public enum CprCallStatus {
    IN_PROGRESS("IN_PROGRESS"),
    END_SITUATION("END_SITUATION");


    private String status;
}
