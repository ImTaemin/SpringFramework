package org.tmkim.security;

import lombok.extern.log4j.Log4j2;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Log4j2
public class CustomLoginSuccessHandler implements AuthenticationSuccessHandler
{
    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication auth) throws IOException, ServletException
    {
        log.warn("Login Sucess");

        // 사용자가 가진 모든 권한 추가
        List<String> roleNames = new ArrayList<>();
        auth.getAuthorities().forEach(authority ->{
            roleNames.add(authority.getAuthority());
        });

        log.warn("ROLE NAMES : " + roleNames);

        if(roleNames.contains("ROLE_ADMIN"))
        {
            response.sendRedirect("/sample/admin");
            return;
        }

        if(roleNames.contains("ROLE_MEMBER"))
        {
            response.sendRedirect("/sample/member");
            return;
        }
        response.sendRedirect("/");
    }
}
