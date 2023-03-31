package com.mentionall.cpr2u.user.repository;

import com.mentionall.cpr2u.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String>{
    Optional<User> findByPhoneNumber(String phoneNumber);

    Boolean existsByPhoneNumber(String phoneNumber);

    Boolean existsByNickname(String nickname);

    @Query("SELECT u FROM User u WHERE u.status = 'ACQUIRED'")
    List<User> findAllAngel();
}
