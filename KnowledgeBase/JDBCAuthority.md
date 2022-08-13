# JDBC를 이용한 인증/권한 체크
## 지정된 형식으로 테이블을 생성해 사용하는 방식
`JDBCUserDetailsManager` : 스프링 시큐리티가 JDBC를 이용하는 경우에 사용하는 클래스   
###### [참고] (https://github.com/spring-projects/spring-security/blob/main/core/src/main/java/org/springframework/security/provisioning/JdbcUserDetailsManager.java)
```sql
create table users
(
    username varchar2(50) not null primary key,
    password varchar2(50) not null,
    enabled char(1) default '1'
);

create table authorities
(
    username varchar2(50) not null,
    authority varchar2(50) not null,
    CONSTRAINT fk_authorities_users foreign key(username) REFERENCES users(username)
);

create unique index ix_auth_username on authorities (username, authority);

insert into users (username, password) values ('user00', 'pw00');
insert into users (username, password) values ('member00', 'pw00');
insert into users (username, password) values ('admin00', 'pw00');

insert into authorities (username, authority) values ('user00', 'ROLE_USER');
insert into authorities (username, authority) values ('member00', 'ROLE_MANAGER');
insert into authorities (username, authority) values ('admin00', 'ROLE_MANAGER');
insert into authorities (username, authority) values ('admin00', 'ROLE_ADMIN');
```
```xml
<!--security-context.xml 추가-->
<security:jdbc-user-service data-source-ref="dataSource"/>
```
인증/권한이 필요한 URI 호출 시 자동으로 필요한 쿼리들이 호출된다. (패스워드 평문이라 예외 발생 - `PasswordEncoder` 사용)
```java
// PasswordEncoder 구현
@Override
public String encode(CharSequence rawPassword){}
@Override
public boolean matches(CharSequence rawPassword, String){}
```
```xml
<!--security-context.xml 추가-->
<bean id="customPasswordEncoder" class="org.tmkim.security.CustomNoOpPasswordEncoder" />

<security:password-encoder ref="customPasswordEncoder" />
```
## 기존에 작성된 데이터베이스를 이용하는 방식
`<security:jdbc-user-service>` 태그의 속성 중 `authorities-by-username-query` 속성과 `users-by-username-query` 속성에 적당한 쿼리문을 지정하면 JDBC를 이용하는 설정을 그대로 사용할 수 있다.

### 🔑 BCryptPasswordEncoder 클래스를 이용한 패스워드 보호
패스워드를 저장하는 용도로 설계된 **해시 함수**
```xml
<!--security-context.xml 추가, 전 코드 제거 -->
<!--스프링 시큐리티에서 bcypt를 이용한 PasswordEncoder 기본 제공-->
<bean id="bcryptPasswordEncoder" class="org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder" />

<security:password-encoder ref="bcryptPasswordEncoder" />
```

### 📃쿼리를 이용하는 인증
- users-by-username-query : 인증을 하는데 필요한 쿼리
- authorities-by-username-query : 권한을 확인하는데 필요한 쿼리
```xml
<!--최종적인 형태-->
<!--<security:jdbc-user-service data-source-ref="dataSource" />-->
<security:jdbc-user-service data-source-ref="dataSource"
    users-by-username-query="SELECT userid, userpw, enabled FROM tbl_member WHERE userid=?"
    authorities-by-username-query="SELECT userid, auth FROM tbl_member_auth WHERE userid=?"/>
```

# 커스텀 UserDetailsService 활용
스프링 시큐리티에서 **username**이라고 부르는 사용자의 정보만을 이용하기 때문에 실제 프로젝트에서 사용자의 이름이나 이메일등의 자세한 정보를 이용할 경우에는 충분하지 않다.   
이런 문제를 해결하기 위해 직접 `UserDetailsService`를 구현하는 방식(커스텀)을 이용하는 것이 좋다.   
*원하는 객체를 인증과 권한 체크에 활용할 수 있기 때문에 많이 사용된다*

`UserDetailsService` 인터페이스는 `loadUserByUsername()`이라는 메서드만 존재하며, 반환 타입인 `UserDetails` 역시 인터페이스로 사용자의 정보와 권한 정보 등을 담는 타입이다.   
`UserDetails` 타입은 `getAuthorities()`, `getPassword()`, `getUserName()`등의 여러 추상 메서드를 가지고 있어, <u>개발 전에 직접 구현할 것</u>인지 <u>`UserDetails` 인터페이스를 구현해둔 스프링 시큐리티의 여러 하위 클래스를 이용할 것</u>인지 판단해야 한다    
가장 일반적으로 많이 사용되는 방법은 여러 하위 클래스들 중에서 `org.springframework.core.userdetails.User` 클래스를 상속하는 형태이다.

## 🔩 CustomUserDetailsService 구성
```java
public class CustomUserDetailsService implements UserDetailsService
{
@Setter(onMethod_ = @Autowired)
private MemberMapper memberMapper;

@Override
public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException{}
```
```xml
<bean id="customUserDetailsService" class="org.tmkim.security.CustomUserDetailsService" />

<!--user-service-ref 속성 추가-->
<security:authentication-provider user-service-ref="customUserDetailsService">
```
최종적으로 `MemberVO`의 인스턴스를 스프링 시큐리티의 `UserDetails` 타입으로 변환하는 작업을 처리해야 한다.
```java
@Getter
public class CustomUser extends User
{
    private static final long serialVersionUID = 1L;
    private MemberVO member;

    public CustomUser(String username, String password, Collection<? extends GrantedAuthority> authorities)
    {
        super(username, password, authorities);
    }

    public CustomUser(MemberVO vo)
    {
        super(vo.getUserid(), vo.getUserpw(), vo.getAuthList().stream()
                .map(auth -> new SimpleGrantedAuthority(auth.getAuth()))
                .collect(Collectors.toList()));

        this.member = vo;
    }
}
```
*`CustomUser`는 `org.springframework.security.core.userdetails.User` 클래스를 상속하기 때문에 부모 클래스의 생성자를 호출해야만 정상적인 객체를 생성할 수 있다.*   
`CustomUserDetailsService`에서 `CustomUser`를 반환하도록 수정
```xml
<resultMap id="memberMap" type="org.tmkim.domain.MemberVO">
    <id property="userid" column="userid"/>
    <result property="userid" column="userid"/>
    <result property="userpw" column="userpw"/>
    <result property="userName" column="username"/>
    <result property="regDate" column="regdate"/>
    <result property="updateDate" column="updatedate"/>
    <collection property="authList" resultMap="authMap">

    </collection>
</resultMap>

<resultMap id="authMap" type="org.tmkim.domain.AuthVO">
    <result property="userid" column="userid"/>
    <result property="auth" column="auth"/>
</resultMap>

<select id="read" resultMap="memberMap">
    SELECT mem.userid, userpw, username, enabled, regdate, updatedate, auth
    FROM tbl_member mem LEFT OUTER JOIN tbl_member_auth auth on mem.userid=auth.userid
    WHERE mem.userid=#{userid}
</select>
```
```java
public class CustomUserDetailsService implements UserDetailsService
{
    @Setter(onMethod_ = @Autowired)
    private MemberMapper memberMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException
    {
        // username은 userid
        MemberVO vo = memberMapper.read(username);
        return vo == null ? null : new CustomUser(vo);
    }
}
```
`loadUserByUsername()`은 내부적으로 `MemberMapper`를 이용해서 `MemberVO()`를 조회하고, 만일 `MemberVO`의 인스턴스를 얻을 수 있다면 `CustomUser` 타입의 객체로 변환해서 반환한다.

# JSP에서 스프링 시큐리티 사용하기
## 🔍 JSP에서 로그인한 사용자 정보 보여주기
JSP 상단에 스프링 시큐리티 관련 태그 라이브러리의 사용을 선언하고,   
`<sec:authentication>` 태그와 `principal`이라는 이름이 속성을 사용한다.
```html
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<p>principal : <sec:authentication property="principal"/></p>
<p>MemberVO : <sec:authentication property="principal.member"/></p>
<p>사용자이름 : <sec:authentication property="principal.member.userName"/></p>
<p>사용자아이디 : <sec:authentication property="principal.username"/></p>
<p>사용자 권한 리스트 : <sec:authentication property="principal.member.authList"/></p>
```
`principal`은 `UserDetailsService`에서 반환된 객체이다.   
즉 `CustomUserDetailsService`를 이용했다면 `loadUserByUsername()`에서 반환된 `CustomUser`객체가 된다.  

## 🔩표현식을 이용하는 동적 화면 구성
경우에 따라 특정 페이지에서 로그인한 사용자의 경우 특정한 내용을 보여주고, 그렇지 않은 경우에는 다른 내용을 보여주는 경우가 있다. 이럴 경우 스프링 시큐리티의 **표현식**(expression)을 사용한다.   

스프링 시큐리티에서 주로 사용되는 표현식
|표현식|설명|
|:---|:---|
|hasRole([role])<br>hasAuthority([authority])|해당 권한이 있으면 true|
|hasAnyRole([role,role2])<br>hasAnyAuthority([authority])|여러 권한들 중에서 하나라도 해당하는 권한이 있으면 true|
|principal|현재 사용자 정보를 의미|
|permitAll|모든 사용자에게 허용|
|denyAll|모든 사용자에게 거부|
|isAnonymous()|익명의 사용자의 경우(로그인을 하지 않은 경우도 해당)|
|isAuthenticated()|인증된 사용자면 true|
|isFullyAuthenticated()|Remember-me로 인증된 것이 아닌 인증된 사용자인 경우 true|

스프링 표현식은 거의 대부분 `true/false`를 리턴하기 때문에 조건문을 사용하는 것처럼 사용된다.
```html
<sec:authorize access="isAnonymous()">
    <a href="/customLogin">로그인</a>
</sec:authorize>

<sec:authorize access="isAuthenticated()">
    <a href="/customLogout">로그아웃</a>
</sec:authorize>
```