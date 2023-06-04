package com.mentionall.cpr2u.call.domain;

import com.mentionall.cpr2u.user.domain.User;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Dispatch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dispatcher_id")
    private User dispatcher;

    @Column
    @Enumerated(EnumType.STRING)
    private DispatchStatus status;

    @CreatedDate
    private LocalDateTime dispatchedAt;

    @Column
    private LocalDateTime arrivedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cpr_call_id")
    private CprCall cprCall;


    public Dispatch(User user, CprCall cprCall) {
        this.dispatcher = user;
        this.cprCall = cprCall;
        this.status = DispatchStatus.IN_PROGRESS;
    }

    public Dispatch(Long id, User user, CprCall cprCall) {
        this.dispatcher = user;
        this.cprCall = cprCall;
        this.status = DispatchStatus.IN_PROGRESS;
    }

    public void arrive() {
        this.status = DispatchStatus.ARRIVED;
        this.arrivedAt = LocalDateTime.now();
    }

    public void setStatus(DispatchStatus status) {
        this.status = status;
    }
}
