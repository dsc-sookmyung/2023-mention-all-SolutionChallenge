package com.mentionall.cpr2u.user.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.Embeddable;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import java.time.LocalDateTime;

@Getter
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
public class Certificate {
    @Enumerated(EnumType.STRING)
    private AngelStatus status;
    private LocalDateTime dateOfIssue;

    public void acquire(LocalDateTime dateOfIssue) {
        this.status = AngelStatus.ACQUIRED;
        this.dateOfIssue = dateOfIssue;
    }

    public void expire() {
        this.status = AngelStatus.EXPIRED;
    }
}
