package com.mentionall.cpr2u.user.repository;

import com.mentionall.cpr2u.user.domain.AngelStatus;
import com.mentionall.cpr2u.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String>{
    Optional<User> findByPhoneNumber(String phoneNumber);

    List<User> findAllByCertificateStatus(AngelStatus status);

    Boolean existsByNickname(String nickname);
}
