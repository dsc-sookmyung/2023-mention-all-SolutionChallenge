package com.mentionall.cpr2u.user.repository.address;

import com.mentionall.cpr2u.user.domain.Address;
import com.querydsl.jpa.impl.JPAQuery;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.extern.slf4j.Slf4j;

import javax.persistence.EntityManager;
import java.util.List;
import java.util.Optional;

import static com.mentionall.cpr2u.user.domain.QAddress.address;


@Slf4j
public class AddressRepositoryImpl implements AddressDslRepository {

    private final JPAQueryFactory queryFactory;

    public AddressRepositoryImpl(EntityManager em) {
        this.queryFactory = new JPAQueryFactory(em);
    }

    @Override
    public List<String> findAllSido(){
        return queryFactory.select(address.sido)
                .from(address)
                .distinct().fetch();
    }

    @Override
    public Optional<Address> findByFullAddress(String fullAddress) {
        String[] addressList = fullAddress.split(" ");
        JPAQuery<Address> findAddressQuery = queryFactory.selectFrom(address).where(address.sido.contains(addressList[0]));
        List<Address> findAddressList = findAddressQuery.fetch();


        for(int i = 1; findAddressList.size() > 1  && i <= 2; i++) {
            String sigugun = addressList[i];
            findAddressQuery = findBySigugunQuery(findAddressQuery, sigugun);
            findAddressList = findAddressQuery.fetch();
        }

        if(findAddressList.size() < 1) return Optional.empty();
        return Optional.of(findAddressList.get(0));

    }

    private JPAQuery<Address> findBySigugunQuery(JPAQuery<Address> findAddressQuery, String sigugun) {
        return findAddressQuery.where(address.sigugun.contains(sigugun));
    }
}
