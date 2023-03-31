package com.mentionall.cpr2u.call.repository;

import com.mentionall.cpr2u.call.domain.Report;
import com.mentionall.cpr2u.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    public List<Report> findAllByReporter(User user);
}
