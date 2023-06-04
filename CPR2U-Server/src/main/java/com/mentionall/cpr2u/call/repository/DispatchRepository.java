package com.mentionall.cpr2u.call.repository;

import com.mentionall.cpr2u.call.domain.Dispatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;

import java.util.List;
import java.util.Optional;

public interface DispatchRepository extends JpaRepository<Dispatch, Long>  , DispatchDslRepository, QuerydslPredicateExecutor<Dispatch> {
    List<Dispatch> findAllByCprCallId(Long cprCallId);
    Optional<Dispatch> findByCprCallIdAndDispatcherId(Long cprCallId, String dispatcher);
}

