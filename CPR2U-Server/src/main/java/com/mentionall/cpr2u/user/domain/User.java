package com.mentionall.cpr2u.user.domain;

import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.domain.Report;
import com.mentionall.cpr2u.education.domain.EducationProgress;
import com.mentionall.cpr2u.user.dto.UserSignUpDto;
import com.mentionall.cpr2u.util.RandomGenerator;
import com.mentionall.cpr2u.util.Timestamped;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class User extends Timestamped{

    @Id
    @GeneratedValue(generator = RandomGenerator.generatorName)
    @GenericGenerator(name = RandomGenerator.generatorName, strategy = "com.mentionall.cpr2u.util.RandomGenerator")
    @Column(length = 20)
    private String id;

    @NotNull
    @Column(length = 40, unique = true)
    private String nickname;

    @NotNull
    @Column(length = 20, unique = true)
    private String phoneNumber;

    @Column
    private LocalDateTime dateOfIssue;

    @Column(length = 10)
    @Enumerated(EnumType.STRING)
    private AngelStatusEnum status;

    @OneToOne(mappedBy = "user")
    private EducationProgress educationProgress;

    @OneToOne(mappedBy = "user")
    private RefreshToken refreshToken;

    @OneToOne(mappedBy = "user")
    private DeviceToken deviceToken;

    @ElementCollection(fetch = FetchType.LAZY)
    private List<UserRole> roles = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "address_id")
    private Address address;

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "dispatcher")
    List<Dispatch> dispatchList = new ArrayList();

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "reporter")
    List<Report> reportList = new ArrayList();


    public User(String id, UserSignUpDto userSignUpDto) {
        this.id = id;
        this.nickname = userSignUpDto.getNickname();
        this.phoneNumber = userSignUpDto.getPhoneNumber();
        this.dateOfIssue = null;
        this.status = AngelStatusEnum.UNACQUIRED;
        this.roles.add(UserRole.USER);
    }

    public User(UserSignUpDto userSignUpDto) {
        this.nickname = userSignUpDto.getNickname();
        this.phoneNumber = userSignUpDto.getPhoneNumber();
        this.dateOfIssue = null;
        this.status = AngelStatusEnum.UNACQUIRED;
        this.roles.add(UserRole.USER);
    }

    public void setDeviceToken(DeviceToken deviceToken) {
        this.deviceToken = deviceToken;
    }

    public void setAddress(Address address) {
        this.address = address;
    }

    public void acquireCertification() {
        this.status = AngelStatusEnum.ACQUIRED;
        this.dateOfIssue = LocalDateTime.now();
    }

    public void expireCertificate() {
        this.status = AngelStatusEnum.EXPIRED;
    }
}
