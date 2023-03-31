package com.mentionall.cpr2u.call.repository;

import com.mentionall.cpr2u.call.domain.CprCall;
import com.mentionall.cpr2u.call.domain.Dispatch;
import com.mentionall.cpr2u.call.dto.CprCallDto;
import com.querydsl.core.types.OrderSpecifier;
import com.querydsl.core.types.Predicate;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.repository.query.FluentQuery;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;

public class FakeCprCallRepository implements CprCallRepository {
    Map<Long, Object> map = new HashMap();
    @Override
    public List<CprCallDto> findAllCallInProcessByAddress(Long addressId) {
        return null;
    }

    @Override
    public List<CprCall> findAll() {
        return null;
    }

    @Override
    public List<CprCall> findAll(Sort sort) {
        return null;
    }

    @Override
    public Page<CprCall> findAll(Pageable pageable) {
        return null;
    }

    @Override
    public List<CprCall> findAllById(Iterable<Long> longs) {
        return null;
    }

    @Override
    public long count() {
        return 0;
    }

    @Override
    public void deleteById(Long aLong) {

    }

    @Override
    public void delete(CprCall entity) {

    }

    @Override
    public void deleteAllById(Iterable<? extends Long> longs) {

    }

    @Override
    public void deleteAll(Iterable<? extends CprCall> entities) {

    }

    @Override
    public void deleteAll() {

    }

    @Override
    public <S extends CprCall> S save(S entity) {
        map.put(entity.getId(), entity);
        return entity;
    }

    @Override
    public <S extends CprCall> List<S> saveAll(Iterable<S> entities) {
        return null;
    }

    @Override
    public Optional<CprCall> findById(Long aLong) {
        return Optional.of((CprCall) map.get(aLong));
    }

    @Override
    public boolean existsById(Long aLong) {
        return false;
    }

    @Override
    public void flush() {

    }

    @Override
    public <S extends CprCall> List<S> saveAllAndFlush(Iterable<S> entities) {
        return null;
    }

    @Override
    public void deleteAllInBatch(Iterable<CprCall> entities) {

    }

    @Override
    public void deleteAllByIdInBatch(Iterable<Long> longs) {

    }

    @Override
    public void deleteAllInBatch() {

    }

    @Override
    public CprCall getOne(Long aLong) {
        return null;
    }

    @Override
    public CprCall getById(Long aLong) {
        return null;
    }

    @Override
    public CprCall getReferenceById(Long aLong) {
        return null;
    }

    @Override
    public <S extends CprCall> Optional<S> findOne(Example<S> example) {
        return Optional.empty();
    }

    @Override
    public <S extends CprCall> List<S> findAll(Example<S> example) {
        return null;
    }

    @Override
    public <S extends CprCall> List<S> findAll(Example<S> example, Sort sort) {
        return null;
    }

    @Override
    public <S extends CprCall> Page<S> findAll(Example<S> example, Pageable pageable) {
        return null;
    }

    @Override
    public <S extends CprCall> long count(Example<S> example) {
        return 0;
    }

    @Override
    public <S extends CprCall> boolean exists(Example<S> example) {
        return false;
    }

    @Override
    public <S extends CprCall, R> R findBy(Example<S> example, Function<FluentQuery.FetchableFluentQuery<S>, R> queryFunction) {
        return null;
    }

    @Override
    public <S extends CprCall> S saveAndFlush(S entity) {
        return null;
    }

    @Override
    public Optional<CprCall> findOne(Predicate predicate) {
        return Optional.empty();
    }

    @Override
    public Iterable<CprCall> findAll(Predicate predicate) {
        return null;
    }

    @Override
    public Iterable<CprCall> findAll(Predicate predicate, Sort sort) {
        return null;
    }

    @Override
    public Iterable<CprCall> findAll(Predicate predicate, OrderSpecifier<?>... orders) {
        return null;
    }

    @Override
    public Iterable<CprCall> findAll(OrderSpecifier<?>... orders) {
        return null;
    }

    @Override
    public Page<CprCall> findAll(Predicate predicate, Pageable pageable) {
        return null;
    }

    @Override
    public long count(Predicate predicate) {
        return 0;
    }

    @Override
    public boolean exists(Predicate predicate) {
        return false;
    }

    @Override
    public <S extends CprCall, R> R findBy(Predicate predicate, Function<FluentQuery.FetchableFluentQuery<S>, R> queryFunction) {
        return null;
    }
}
