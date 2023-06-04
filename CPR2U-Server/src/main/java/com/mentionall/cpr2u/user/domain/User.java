package com.mentionall.cpr2u.user.domain;

import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.domain.Report;
import com.mentionall.cpr2u.education.domain.progress.EducationProgress;
import com.mentionall.cpr2u.user.dto.user.SignUpRequestDto;
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

    @Embedded
    private Certificate certificate;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    private EducationProgress educationProgress;

    @OneToOne(mappedBy = "user", cascade = CascadeType.REMOVE)
    private RefreshToken refreshToken;

    @OneToOne(mappedBy = "user", cascade = CascadeType.REMOVE)
    private DeviceToken deviceToken;

    @ElementCollection(fetch = FetchType.LAZY)
    private List<UserRole> roles = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "address_id", nullable = false)
    private Address address;

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "dispatcher")
    List<Dispatch> dispatchList = new ArrayList();

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "reporter")
    List<Report> reportList = new ArrayList();

    public User(SignUpRequestDto requestDto, Address address) {
        this.nickname = requestDto.getNickname();
        this.phoneNumber = requestDto.getPhoneNumber();
        this.address = address;
        this.certificate = new Certificate(AngelStatus.UNACQUIRED, null);
        this.roles.add(UserRole.USER);
    }

    public AngelStatus getAngelStatus() {
        return this.certificate.getStatus();
    }

    public void setDeviceToken(DeviceToken deviceToken) {
        this.deviceToken = deviceToken;
    }
    public void setRefreshToken(RefreshToken refreshToken) {
        this.refreshToken = refreshToken;
    }

    public void setAddress(Address address) {
        this.address = address;
    }

    public void setEducationProgress(EducationProgress progress) {
        this.educationProgress = progress;
    }

    public void acquireCertification(LocalDateTime dateOfIssue) {
        this.certificate.acquire(dateOfIssue);
    }

    public void expireCertificate() {
        this.certificate.expire();
        this.educationProgress.reset();
    }
}
