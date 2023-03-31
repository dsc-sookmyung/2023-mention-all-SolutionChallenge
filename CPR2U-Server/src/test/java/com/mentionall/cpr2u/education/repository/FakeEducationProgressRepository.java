package com.mentionall.cpr2u.education.repository;

import com.mentionall.cpr2u.education.domain.EducationProgress;
import com.mentionall.cpr2u.user.domain.User;
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

public class FakeEducationProgressRepository implements EducationProgressRepository{

    Map<Long, Object> map = new HashMap();

    @Override
    public Optional<EducationProgress> findByUser(User user) {
        for (var key : map.keySet()) {
            EducationProgress progress = (EducationProgress) map.get(key);
            if (progress.getUser().getId() == user.getId())
                return Optional.of(progress);
        }
        return Optional.empty();
    }

    @Override
    public List<EducationProgress> findAll() {
        return null;
    }

    @Override
    public List<EducationProgress> findAll(Sort sort) {
        return null;
    }

    @Override
    public Page<EducationProgress> findAll(Pageable pageable) {
        return null;
    }

    @Override
    public List<EducationProgress> findAllById(Iterable<Long> longs) {
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
    public void delete(EducationProgress entity) {

    }

    @Override
    public void deleteAllById(Iterable<? extends Long> longs) {

    }

    @Override
    public void deleteAll(Iterable<? extends EducationProgress> entities) {

    }

    @Override
    public void deleteAll() {

    }

    @Override
    public <S extends EducationProgress> S save(S entity) {
        map.put(entity.getId(), entity);
        return entity;
    }

    @Override
    public <S extends EducationProgress> List<S> saveAll(Iterable<S> entities) {
        return null;
    }

    @Override
    public Optional<EducationProgress> findById(Long aLong) {
        return Optional.of((EducationProgress) map.get(aLong));
    }

    @Override
    public boolean existsById(Long aLong) {
        return false;
    }

    @Override
    public void flush() {

    }

    @Override
    public <S extends EducationProgress> S saveAndFlush(S entity) {
        return null;
    }

    @Override
    public <S extends EducationProgress> List<S> saveAllAndFlush(Iterable<S> entities) {
        return null;
    }

    @Override
    public void deleteAllInBatch(Iterable<EducationProgress> entities) {

    }

    @Override
    public void deleteAllByIdInBatch(Iterable<Long> longs) {

    }

    @Override
    public void deleteAllInBatch() {

    }

    @Override
    public EducationProgress getOne(Long aLong) {
        return null;
    }

    @Override
    public EducationProgress getById(Long aLong) {
        return null;
    }

    @Override
    public EducationProgress getReferenceById(Long aLong) {
        return null;
    }

    @Override
    public <S extends EducationProgress> Optional<S> findOne(Example<S> example) {
        return Optional.empty();
    }

    @Override
    public <S extends EducationProgress> List<S> findAll(Example<S> example) {
        return null;
    }

    @Override
    public <S extends EducationProgress> List<S> findAll(Example<S> example, Sort sort) {
        return null;
    }

    @Override
    public <S extends EducationProgress> Page<S> findAll(Example<S> example, Pageable pageable) {
        return null;
    }

    @Override
    public <S extends EducationProgress> long count(Example<S> example) {
        return 0;
    }

    @Override
    public <S extends EducationProgress> boolean exists(Example<S> example) {
        return false;
    }

    @Override
    public <S extends EducationProgress, R> R findBy(Example<S> example, Function<FluentQuery.FetchableFluentQuery<S>, R> queryFunction) {
        return null;
    }
}
