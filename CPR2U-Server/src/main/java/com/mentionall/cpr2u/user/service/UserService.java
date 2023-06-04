package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public void certificate(User user, LocalDateTime dateTime) {
        user.acquireCertification(dateTime);
        userRepository.save(user);
    }

}
