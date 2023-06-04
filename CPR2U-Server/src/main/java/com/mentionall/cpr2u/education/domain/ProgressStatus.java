package com.mentionall.cpr2u.education.domain;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public enum ProgressStatus {
    NotCompleted("Not Completed"),
    InProgress("In Progress"),
    Completed("Completed");

    private final String status;
}
