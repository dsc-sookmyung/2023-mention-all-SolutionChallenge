package com.mentionall.cpr2u.education.repository;

import com.mentionall.cpr2u.education.domain.Quiz;

import java.util.List;

public interface QuizDslRepository {
    List<Quiz> findRandomLimit5();
}
