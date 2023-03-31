package com.mentionall.cpr2u.user.repository;

import com.mentionall.cpr2u.user.domain.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, String> {
    Optional<RefreshToken> findByUserId(String userId);

    Optional<RefreshToken> findRefreshTokenByToken(String refreshToken);
}
