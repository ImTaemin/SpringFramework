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