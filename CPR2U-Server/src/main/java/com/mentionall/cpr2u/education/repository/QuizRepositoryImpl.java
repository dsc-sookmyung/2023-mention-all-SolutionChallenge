package com.mentionall.cpr2u.education.repository;

import com.mentionall.cpr2u.education.domain.Quiz;
import com.querydsl.core.types.dsl.Expressions;
import com.querydsl.jpa.impl.JPAQueryFactory;

import javax.persistence.EntityManager;
import java.util.List;

import static com.mentionall.cpr2u.education.domain.QQuiz.quiz;

public class QuizRepositoryImpl implements QuizDslRepository {
    private final JPAQueryFactory queryFactory;

    public QuizRepositoryImpl(EntityManager em) {
        this.queryFactory = new JPAQueryFactory(em);
    }

    @Override
    public List<Quiz> findRandomLimit5() {
        return queryFactory.selectFrom(quiz)
                .orderBy(Expressions.numberTemplate(Double.class, "function('rand')").asc())
                .limit(5)
                .fetch();
    }
}
