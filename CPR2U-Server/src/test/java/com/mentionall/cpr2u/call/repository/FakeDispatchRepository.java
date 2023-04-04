package com.mentionall.cpr2u.call.repository;

import com.mentionall.cpr2u.call.domain.Dispatch;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.repository.query.FluentQuery;

import java.util.*;
import java.util.function.Function;

public class FakeDispatchRepository implements DispatchRepository {
    Map<Long, Object> map = new HashMap();

    @Override
    public List<Dispatch> findAll() {
        return null;
    }

    @Override
    public List<Dispatch> findAll(Sort sort) {
        return null;
    }

    @Override
    public Page<Dispatch> findAll(Pageable pageable) {
        return null;
    }

    @Override
    public List<Dispatch> findAllById(Iterable<Long> longs) {
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
    public void delete(Dispatch entity) {

    }

    @Override
    public void deleteAllById(Iterable<? extends Long> longs) {

    }

    @Override
    public void deleteAll(Iterable<? extends Dispatch> entities) {

    }

    @Override
    public void deleteAll() {

    }

    @Override
    public <S extends Dispatch> S save(S entity) {
        map.put(entity.getId(), entity);
        return entity;
    }

    @Override
    public <S extends Dispatch> List<S> saveAll(Iterable<S> entities) {
        return null;
    }

    @Override
    public Optional<Dispatch> findById(Long aLong) {
        return Optional.of((Dispatch) map.get(aLong));
    }

    @Override
    public boolean existsById(Long aLong) {
        return false;
    }

    @Override
    public void flush() {

    }

    @Override
    public <S extends Dispatch> S saveAndFlush(S entity) {
        return null;
    }

    @Override
    public <S extends Dispatch> List<S> saveAllAndFlush(Iterable<S> entities) {
        return null;
    }

    @Override
    public void deleteAllInBatch(Iterable<Dispatch> entities) {

    }

    @Override
    public void deleteAllByIdInBatch(Iterable<Long> longs) {

    }

    @Override
    public void deleteAllInBatch() {

    }

    @Override
    public Dispatch getOne(Long aLong) {
        return null;
    }

    @Override
    public Dispatch getById(Long aLong) {
        return null;
    }

    @Override
    public Dispatch getReferenceById(Long aLong) {
        return null;
    }

    @Override
    public <S extends Dispatch> Optional<S> findOne(Example<S> example) {
        return Optional.empty();
    }

    @Override
    public <S extends Dispatch> List<S> findAll(Example<S> example) {
        return null;
    }

    @Override
    public <S extends Dispatch> List<S> findAll(Example<S> example, Sort sort) {
        return null;
    }

    @Override
    public <S extends Dispatch> Page<S> findAll(Example<S> example, Pageable pageable) {
        return null;
    }

    @Override
    public <S extends Dispatch> long count(Example<S> example) {
        return 0;
    }

    @Override
    public <S extends Dispatch> boolean exists(Example<S> example) {
        return false;
    }

    @Override
    public <S extends Dispatch, R> R findBy(Example<S> example, Function<FluentQuery.FetchableFluentQuery<S>, R> queryFunction) {
        return null;
    }

    @Override
    public List<Dispatch> findAllByCprCallId(Long cprCallId) {
        List<Dispatch> dispatchList = new ArrayList<>();
        for(Object object : map.values()){
            Dispatch dispatch = (Dispatch) object;
            if(dispatch.getCprCall().getId() == cprCallId){
                dispatchList.add(dispatch);
            }
        }
        return dispatchList;
    }
}
