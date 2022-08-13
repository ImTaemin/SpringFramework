package org.tmkim.security;

import lombok.Setter;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.tmkim.domain.MemberVO;
import org.tmkim.mapper.MemberMapper;
import org.tmkim.security.domain.CustomUser;

@Log4j2
public class CustomUserDetailsService implements UserDetailsService
{
    @Setter(onMethod_ = @Autowired)
    private MemberMapper memberMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException
    {
        log.warn("Load User By UserName : " + username);

        // username은 userid
        MemberVO vo = memberMapper.read(username);

        log.warn("queried by member mapper : " + vo);

        return vo == null ? null : new CustomUser(vo);
    }
}
