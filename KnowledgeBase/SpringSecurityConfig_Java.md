# 💡 Java를 이용한 스프링 시큐리티 설정
## ☕ Java 설정 추가
web.xml이 없고 `WebConfig` 클래스를 추가한 상태에선   
- `getServletFilters()`를 이용해 직접 스프링 시큐리티 관련 필터를 추가하는 방법
- `AbstractSecurityWebApplicationInitializer`를 상속하는 클래스 추가하는 방법
```java
// 내부적으로 `DelegatingFilterProxy`를 스프링에 등록한다.
// 클래스 추가만 하면 설정 완료
public class SecurityInitializer extends AbstractSecurityWebApplicationInitializer(){}
```
```java
@Configuration
@EnableWebSecurity // 스프링 MVC와 시큐리티를 결합하는 용도
@Log4j2
public class SecurityConfig extends WebSecurityConfigurerAdapter
{
    //xml에서 <security:http> 관련 설정을 대신함
    @Override
    public void configure(HttpSecurity http) throws Exception
    {
        http.authorizeRequests()
            .antMatchers("/sample/all").permitAll()
            .antMatchers("/sample/admin").access("hasRole('ROLE_ADMIN')")
            .antMatchers("/sample/member").access("hasRole('ROLE_MEMBER')");
    }
}
```

### WebConfig 클래스
```java
public class WebConfig extends AbstractAnnotationConfigDispatcherServletInitializer
{
    @Override
    protected Class<?>[] getRootConfigClasses()
    {
        return new Class[] {RootConfig.class, SecurityConfig.class};
    }
    ...
}
```

## 🛠 로그인 페이지 관련 설정
```java
// SecurityConfig.java 
public void configure(HttpSecurity http) throws Exception
{
    // 추가. Access Denied 후 로그인 페이지로 이동하고 로그인을 할 수 있는 설정
    http.formLogin().loginPage("/customLogin").loginProcessingUrl("/login");
}

protected void configure(AuthenticationManagerBuilder auth) throws Exception
{
    auth.inMemoryAuthentication().withUser("admin").password("{noop}admin").roles("ADMIN");
}
```

### 로그인 처리
```java
// SecurityConfig.java 추가
@Bean
public AuthenticationSuccessHandler loginSuccessHandler()
{
    return new CustomLoginSuccessHandler();
}

public void configure(HttpSecurity http) throws Exception
{
    http.formLogin().loginPage("/customLogin")
        .loginProcessingUrl("/login")
        .successHandler(loginSuccessHandler());// successHandler()추가
}
```

### 로그아웃 처리
```java
//SecurityConfig.java 추가
public void configure(HttpSecurity http) throws Exception
{
    http.logout().logoutUrl("/customLogout")
        .invalidateHttpSession(true)
        .deleteCookies("remeber-me", "JSESSION_ID");
}
```

## 🔏 PasswordEncoder 지정
```java
//SecurityConfig.java 추가
@Bean
public PasswordEncoder passwordEncoder()
{
    return new BcrpytPasswordEncoder();
}
//PasswordEncoder 주입 받은 후 bcrypt.encode(문자열);
```

## ⚙ JDBC를 이용한 Java 설정
1. username사용자의 정보를 얻어오는 과정
2. 적당한 권한 등을체크하는 과정
```java
//SecurityConfig.java 수정
@Autowired
private DataSource dataSource;

protected void configure(AuthenticationManagerBuilder auth) throws Exception
{
    String user = "SELECT userid, userpw, enalbed FROM tbl_member WHERE userid=?";
    String details = "SELECT userid, auth FROM tbl_member_auth WHERE userid=?";

    auth.jdbcAuthentication().dataSource(dataSource)
        .passwordEncoder(passwordEncoder())
        .usersByUsernameQuery(user)
        .authoritiesByUsernameQuery(details);
}
```

## 🔧 커스텀 UserDetailsService 설정
```java
//SecurityConfig.java 수정
@Bean
public UserDetailsService customUserService()
{
    return new CustomUserDetailsService();
}

@Override
protected void configure(AuthenticationManagerBuilder auth) throws Exception
{
    auth.userDetailsService(customUserService())
        .passwordEncoder(passwordEncoder());
}
```

## ⚙ 자동 로그인 설정(remember-me)
```java
//SecurityConfig.java 추가
public void configure(HttpSecurity http) throws Exception
{
    http.rememberMe().key("tmkim")
        .tokenRepository(persistentTokenRepository())
        .tokenValiditySeconds(604800);
}

@Bean
public PersistentTokenRepository persistentTokenRepository()
{
    JdbcTokenRepositoryImpl repo = new JdbcTokenRepositoryImpl();
    repo.setDataSource();
    return repo;
}
```
---
<details>
<summary>최종 코드</summary>

```java
@Configuration
@EnableWebSecurity
@Log4j2
public class SecurityConfig extends WebSecurityConfigurerAdapter
{
    @Autowired
    private DataSource dataSource;

    @Bean
    public UserDetailsService customUserService()
    {
        return new CustomUserDetailsService();
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception
    {
        auth.userDetailsService(customUserService())
            .passwordEncoder(passwordEncoder());
    }

    @Bean
    public AuthenticationSuccessHandler loginSuccessHandler()
    {
        return new CustomLoginSuccessHandler();
    }
    
    @Override
    public void configure(HttpSecurity http) throws Exception
    {
        //권한 추가
        http.authorizeRequests()
            .antMatchers("/sample/all").permitAll()
            .antMatchers("/sample/admin").access("hasRole('ROLE_ADMIN')")
            .antMatchers("/sample/member").access("hasRole('ROLE_MEMBER')");

        //로그인
        http.formLogin().loginPage("/customLogin")
            .loginProcessingUrl("/login")
            .successHandler(loginSuccessHandler());

        //로그아웃
        http.logout().logoutUrl("/customLogout")
            .invalidateHttpSession(true)
            .deleteCookies("remeber-me", "JSESSION_ID");
            
        //자동로그인 설정
        http.rememberMe().key("tmkim")
            .tokenRepository(persistentTokenRepository())
            .tokenValiditySeconds(604800);
    }

    //Bcrpty 해시 암호화
    @Bean
    public PasswordEncoder passwordEncoder()
    {
        return new BcrpytPasswordEncoder();
    }
    
    //자동로그인 설정
    @Bean
    public PersistentTokenRepository persistentTokenRepository()
    {
        JdbcTokenRepositoryImpl repo = new JdbcTokenRepositoryImpl();
        repo.setDataSource();
        return repo;
    }
}
```
</details>
