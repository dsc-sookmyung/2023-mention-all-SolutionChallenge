package com.mentionall.cpr2u.education.repository;

import com.mentionall.cpr2u.education.domain.Lecture;
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
import java.util.stream.Collectors;

public class FakeLectureRepository implements LectureRepository{

    Map<Long, Object> map = new HashMap();

    @Override
    public Boolean existsByStep(int step) {
        return null;
    }

    @Override
    public List<Lecture> findAll() {
        return map.values().stream()
                .map(l -> (Lecture) l)
                .collect(Collectors.toList());
    }

    @Override
    public List<Lecture> findAll(Sort sort) {
        return null;
    }

    @Override
    public Page<Lecture> findAll(Pageable pageable) {
        return null;
    }

    @Override
    public List<Lecture> findAllById(Iterable<Long> longs) {
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
    public void delete(Lecture entity) {

    }

    @Override
    public void deleteAllById(Iterable<? extends Long> longs) {

    }

    @Override
    public void deleteAll(Iterable<? extends Lecture> entities) {

    }

    @Override
    public void deleteAll() {

    }

    @Override
    public <S extends Lecture> S save(S entity) {
        map.put(entity.getId(), entity);
        return entity;
    }

    @Override
    public <S extends Lecture> List<S> saveAll(Iterable<S> entities) {
        return null;
    }

    @Override
    public Optional<Lecture> findById(Long aLong) {
        return Optional.of((Lecture) map.get(aLong));
    }

    @Override
    public boolean existsById(Long aLong) {
        return false;
    }

    @Override
    public void flush() {

    }

    @Override
    public <S extends Lecture> S saveAndFlush(S entity) {
        return null;
    }

    @Override
    public <S extends Lecture> List<S> saveAllAndFlush(Iterable<S> entities) {
        return null;
    }

    @Override
    public void deleteAllInBatch(Iterable<Lecture> entities) {

    }

    @Override
    public void deleteAllByIdInBatch(Iterable<Long> longs) {

    }

    @Override
    public void deleteAllInBatch() {

    }

    @Override
    public Lecture getOne(Long aLong) {
        return null;
    }

    @Override
    public Lecture getById(Long aLong) {
        return null;
    }

    @Override
    public Lecture getReferenceById(Long aLong) {
        return null;
    }

    @Override
    public <S extends Lecture> Optional<S> findOne(Example<S> example) {
        return Optional.empty();
    }

    @Override
    public <S extends Lecture> List<S> findAll(Example<S> example) {
        return null;
    }

    @Override
    public <S extends Lecture> List<S> findAll(Example<S> example, Sort sort) {
        return null;
    }

    @Override
    public <S extends Lecture> Page<S> findAll(Example<S> example, Pageable pageable) {
        return null;
    }

    @Override
    public <S extends Lecture> long count(Example<S> example) {
        return 0;
    }

    @Override
    public <S extends Lecture> boolean exists(Example<S> example) {
        return false;
    }

    @Override
    public <S extends Lecture, R> R findBy(Example<S> example, Function<FluentQuery.FetchableFluentQuery<S>, R> queryFunction) {
        return null;
    }
}
