package com.mentionall.cpr2u.call.domain;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public enum DispatchStatus {
    IN_PROGRESS("IN_PROGRESS"),
    ARRIVED("ARRIVED"),
    END_SITUATION("END_SITUATION");


    private String status;
}
