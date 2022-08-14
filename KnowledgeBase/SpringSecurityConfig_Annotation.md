# ＠ 어노테이션을 이용하는 스프링 시큐리티 설정
- @Secured : 스프링 시큐리티 초기부터 사용됨, ()안에 'ROLE_ADMIN'같은 문자열 or 문자열 배열
- @PreAuthorize, @PostAuthorize : 3버전부터 지원, ()안에 표현식
```java
//SampleController.java
@PreAuthorize("hasAnyRole('ROLE_ADMIN','ROLE_MEMBER)")
@GetMapping("/annoMember")
public void doMember2(){}

@Secured({"ROLE_ADMIN"})
@GetMapping("/annoAdmin")
public void doAdmin2(){}
```
※컨트롤러에 사용하는 스프링 시큐리티의 어노테이션을 활성화하기 위해서는 ~~security-context.xml~~이 아닌 servlet-context.xml에 설정을 추가해야 한다.
```xml
<!--servlet-context.xml으로 설정-->
<security:global-method-security pre-post-annotations="enabled" secured-annotations="enabled">
```
```java
//ServletConfig.java로 설정
@EnableWebMvc
@ComponentScan(basePackages = {"org.tmkim.contorller"})
@EnableGlobalMethodSecurity(prePostEnalbed=true, securedEnabled=true)
public class ServletConfig implements WebMvcConfigurer{}
```