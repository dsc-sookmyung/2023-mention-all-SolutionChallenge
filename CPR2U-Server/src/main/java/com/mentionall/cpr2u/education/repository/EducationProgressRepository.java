package com.mentionall.cpr2u.education.repository;

import com.mentionall.cpr2u.education.domain.EducationProgress;
import com.mentionall.cpr2u.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EducationProgressRepository extends JpaRepository<EducationProgress, Long> {
    Optional<EducationProgress> findByUser(User user);
}
