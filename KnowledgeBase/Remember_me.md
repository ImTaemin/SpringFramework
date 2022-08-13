# 💡 자동 로그인(remember-me)
스프링 시큐리티의 경우 'remember-me' 기능을 **메모리상**에 처리하거나, **데이터베이스**를 이용하는 형태로 약간의 설정만으로 구현이 가능하다.   
`security-context.xml`에서는 `<security:remember-me>`태그를 이용해 기능을 구현한다.   
주요 속성
- key : 쿠키에 사용되는 값을 암호화하기 위한 키(key)값
- data-source-ref : DataSource를 지정하고 테이블을 이용해서 기존 로그인 정보를 기록(옵션)
- remember-me-cookie : 브라우저에 보관되는 쿠키의 이름을 지정. 기본값은 'remember-me'
- remember-me-parameter : 웹 화면에서 로그인할 때 'remember-me'는 대부분 체크박스를 이용해서 처리. 이때 체크박스 태그는 name 속성을 의미
- tokem-validity-seconds : 쿠키의 유효시간을 지정

## 📱 데이터 베이스를 이용하는 자동 로그인
가장 많이 사용되는 방식은 로그인이 되었던 정보를 데이터베이스에 기록해 두었다가 재방문 시 세션에 정보가 없으면 데이터베이스를 조회해서 사용한다.   
서버의 메모리상에만 저장하는 방식보다 좋은 점은 데이터베이스에 정보가 공유되기 때문에 좀 더 안정적으로 운영이 가능하다.

- ~~직접 구현하는 방식~~
- JDBC 처럼 지정된 테이블을 이용하는 방식
```sql
-- 스프링 시큐리티의 공식 문서에 나오는 자동 로그인 테이블
CREATE TABLE persistent_logins
(
    username VARCHAR2(64) NOT NULL,
    series VARCHAR2(64) PRIMARY KEY,
    token VARCHAR2(64) NOT NULL,
    last_used timestamp NOT NULL
);
```
```xml
<!--security-context.xml 추가-->
<security:remember-me data-source-ref="dataSource" token-validity-seconds="604800" />
```
### 자동 로그인 설정
```html
<!--로그인 페이지에 추가-->
<input type="checkbox" name="remember-me"> Remember Me
```
### 로그아웃 시 쿠키 삭제
```xml
<!--security-context.xml delete-cookies 속성 추가-->
<security:logout logout-url="/customLogout" invalidate-session="true" delete-cookies="remember-me, JSESSION_ID"/>
```
