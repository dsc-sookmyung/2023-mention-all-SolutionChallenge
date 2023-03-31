package com.mentionall.cpr2u.user.domain;

import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@Entity
@Getter
@NoArgsConstructor
public class DeviceToken {
    @Id
    @Column
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "device_token")
    private String token;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    public DeviceToken(String deviceToken, User user) {
        this.user = user;
        this.token = deviceToken;
    }

    public void setToken(String deviceToken) {
        this.token = deviceToken;
    }

}
