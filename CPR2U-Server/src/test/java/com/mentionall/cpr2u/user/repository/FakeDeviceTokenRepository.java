package com.mentionall.cpr2u.user.repository;

import com.mentionall.cpr2u.user.domain.DeviceToken;
import com.querydsl.core.types.OrderSpecifier;
import com.querydsl.core.types.Predicate;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.repository.query.FluentQuery;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;

public class FakeDeviceTokenRepository implements DeviceTokenRepository {
    @Override
    public List<DeviceToken> findAllDeviceTokenByUserAddress(Long addressId, String userId) {
        return new ArrayList<>();
    }

    @Override
    public Optional<DeviceToken> findByUserId(String userId) {
        return Optional.empty();
    }

    @Override
    public List<DeviceToken> findAll() {
        return null;
    }

    @Override
    public List<DeviceToken> findAll(Sort sort) {
        return null;
    }

    @Override
    public Page<DeviceToken> findAll(Pageable pageable) {
        return null;
    }

    @Override
    public List<DeviceToken> findAllById(Iterable<String> strings) {
        return null;
    }

    @Override
    public long count() {
        return 0;
    }

    @Override
    public void deleteById(String s) {

    }

    @Override
    public void delete(DeviceToken entity) {

    }

    @Override
    public void deleteAllById(Iterable<? extends String> strings) {

    }

    @Override
    public void deleteAll(Iterable<? extends DeviceToken> entities) {

    }

    @Override
    public void deleteAll() {

    }

    @Override
    public <S extends DeviceToken> S save(S entity) {
        return null;
    }

    @Override
    public <S extends DeviceToken> List<S> saveAll(Iterable<S> entities) {
        return null;
    }

    @Override
    public Optional<DeviceToken> findById(String s) {
        return Optional.empty();
    }

    @Override
    public boolean existsById(String s) {
        return false;
    }

    @Override
    public void flush() {

    }

    @Override
    public <S extends DeviceToken> S saveAndFlush(S entity) {
        return null;
    }

    @Override
    public <S extends DeviceToken> List<S> saveAllAndFlush(Iterable<S> entities) {
        return null;
    }

    @Override
    public void deleteAllInBatch(Iterable<DeviceToken> entities) {

    }

    @Override
    public void deleteAllByIdInBatch(Iterable<String> strings) {

    }

    @Override
    public void deleteAllInBatch() {

    }

    @Override
    public DeviceToken getOne(String s) {
        return null;
    }

    @Override
    public DeviceToken getById(String s) {
        return null;
    }

    @Override
    public DeviceToken getReferenceById(String s) {
        return null;
    }

    @Override
    public <S extends DeviceToken> Optional<S> findOne(Example<S> example) {
        return Optional.empty();
    }

    @Override
    public <S extends DeviceToken> List<S> findAll(Example<S> example) {
        return null;
    }

    @Override
    public <S extends DeviceToken> List<S> findAll(Example<S> example, Sort sort) {
        return null;
    }

    @Override
    public <S extends DeviceToken> Page<S> findAll(Example<S> example, Pageable pageable) {
        return null;
    }

    @Override
    public <S extends DeviceToken> long count(Example<S> example) {
        return 0;
    }

    @Override
    public <S extends DeviceToken> boolean exists(Example<S> example) {
        return false;
    }

    @Override
    public <S extends DeviceToken, R> R findBy(Example<S> example, Function<FluentQuery.FetchableFluentQuery<S>, R> queryFunction) {
        return null;
    }

    @Override
    public Optional<DeviceToken> findOne(Predicate predicate) {
        return Optional.empty();
    }

    @Override
    public Iterable<DeviceToken> findAll(Predicate predicate) {
        return null;
    }

    @Override
    public Iterable<DeviceToken> findAll(Predicate predicate, Sort sort) {
        return null;
    }

    @Override
    public Iterable<DeviceToken> findAll(Predicate predicate, OrderSpecifier<?>... orders) {
        return null;
    }

    @Override
    public Iterable<DeviceToken> findAll(OrderSpecifier<?>... orders) {
        return null;
    }

    @Override
    public Page<DeviceToken> findAll(Predicate predicate, Pageable pageable) {
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
    public <S extends DeviceToken, R> R findBy(Predicate predicate, Function<FluentQuery.FetchableFluentQuery<S>, R> queryFunction) {
        return null;
    }
}
