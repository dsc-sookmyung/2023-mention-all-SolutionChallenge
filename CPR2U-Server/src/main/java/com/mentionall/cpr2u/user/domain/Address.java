package com.mentionall.cpr2u.user.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class Address {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 20)
    private String sido;

    @Column(length = 20)
    private String sigugun;

    @OneToMany(cascade = CascadeType.ALL, mappedBy = "address")
    List<User> userList = new ArrayList();

    public Address(String sido, String sigugun) {
        this.sido = sido;
        this.sigugun = sigugun;
    }
}
