package com.mentionall.cpr2u.user.service;

import com.mentionall.cpr2u.user.domain.PrincipalDetails;
import com.mentionall.cpr2u.user.domain.User;
import com.mentionall.cpr2u.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CustomUserDetailService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String id) throws UsernameNotFoundException {
        User user =  userRepository.findById(id).orElseThrow(() -> new UsernameNotFoundException("해당 id의 사용자가 없습니다."));
        return new PrincipalDetails(user);
    }

}
