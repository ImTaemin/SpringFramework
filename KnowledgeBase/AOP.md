# 💡 AOP[Aspect Oriented Programming]란?
> ### <font style="color:orange;">※***Aspect로 모듈화하고 핵심적인 비즈니스 로직에서 분리하여 재사용하겠다는 것***※</font>
> - 객체지향의 기본원칙을 적용하여도 핵심기능에서 부가기능을 분리해서 모듈화하는 것은 매우 어렵다.   
> - *AOP는 애플리케이션에서의 **관심사의 분리(기능의 분리), 핵심적인 기능에서 부가적인 기능을 분리**한다.*   
> - 분리한 부가기능을 **에스펙트(Aspect)** 라는 독특한 모듈형태로 만들어서 설계하고 개발하는 방법  


<br>

# 📗 용어 정리
> ## 📌 Target
> - 부가기능을 부여할 대상 (**핵심기능**을 담고 있는 **모듈**)
> ## ✔ Aspect
> - Aspect = Advice + PointCut
> - <font style="color:orange;">부가기능 모듈</font>을 Aspect라고 부른다. (핵심기능에 부가되어 의미를 갖는 모듈)
> - 어플리케이션의 핵심적인 기능에서, 부가적인 기능을 분리해서 Aspect라는 모듈로 만들어서 설계하고 개발하는 방법
> ## ✔ Advice
> - 실질적으로 부가기능을 담은 구현체
> - Aspect가 <font style="color:orange;">무엇을 언제</font> 할지를 정의
> - 타겟 오브젝트에 종속되지 않기 때문에, 부가기능에만 집중할 수 있음
> ## ✔ PointCut
> - 부가기능이 적용될 <font style="color:orange;">대상(Method)</font>을 선정하는 방법   
> - Advice를 적용할 JoinPoint를 선별하는 기능을 정의한 모듈
> ## ✔ JoinPoint
> - Advice가 적용될 수 있는 <font style="color:orange;">위치</font>   
> - Spring에서는 메소드 조인포인트만 제공한다.
> - 타겟 객체가 구현한 모든 메소드는 조인 포인트가 된다.
> ## ✔ Proxy
> - Target을 감싸서 <font style="color:orange;">Target의 요청을 대신 받아주는 랩핑 오브젝트.</font>
> - 클라이언트에서 Target을 호출하게되면 타겟이 아닌 타겟을 감싸고 있는 Proxy가 호출되어 타겟메소드 실행 전에 선처리 후처리를 실행한다.
> ## ✔ Introduction
> - 타겟 클래스에 코드변경 없이 신규 메소드나 멤버 변수를 추가하는 기능
> ## ✔ Weaving
> - 지정된 객체에 Aspect를 적용해서, 새로운 프록시 객체를 생성하는 과정
> - Spring AOP는 런타임에서 프록시 객체가 생성된다.

<br>

> # 📎 특징
> ## ✔ Spring은 프록시 기반 AOP를 지원한다.
> - Spring은 타겟(target) 객체에 대한 프록시를 만들어 제공한다.
> - 타겟을 감싸는 프록시는 실행시간(Runtime)에 생성된다.
> - 프록시는 어드바이스를 타겟 객체에 적용하면서 생성되는 객체이다.
> ## ✔ 프록시(Proxy)가 호출을 가로챈다(Intercept)
> - 프록시는 타겟 객체에 대한 호출을 가로챈 다음 어드바이스의 부가기능 로직을 수행하고 난 후에 타겟의 핵심기능 로직을 호출한다.(전처리 어드바이스)
> - 또는 타겟의 핵심기능 로직 메서드를 호출한 후에 부가기능(어드바이스)을 수행하는 경우도 있다.(후처리 어드바이스)
> ## ✔ Spring AOP는 메서드 조인 포인트만 지원한다.
> - Spring은 동적 프록시를 기반으로 AOP를 구현하므로 메서드 조인 포인트만 지원한다.
> - 핵심기능(타겟)의 메서드가 호출되는 런타임 시점에만 부가기능(어드바이스)을 적용할 수 있다.
> - 반면에 AspectJ 같은 고급 AOP 프레임워크를 사용하면 객체의 생성, 필드값의 조회와 조작, static 메서드 호출 및 초기화 등의 다양한 작업에 부가기능을 적용 할 수 있다.
> 
<br>

# 📁 동작 위치
|구분|설명|
|---|---|
|Before Advice|target의 JoinPoint를 호출하기 전에 실행되는 코드. <br>코드의 실행 자체에는 관여할 수 없다. 
|After Returning Advice|모든 실행이 정상적으로 이루어진 후에 동작하는 코드
|After Throwing Advice|예외가 발생한 뒤에 동작하는 코드
|After Advice|정상적으로 실행되거나 예외가 발생했을 때 구분 없이 실행되는 코드
|Around Advice|메서드의 실행 자체를 제어할 수 있는 가장 강력한 코드.<br>직접 대상 메서드를 호출하고 결과나 예외를 처리할 수 있다.

# 📍 PointCut의 주요 설정
|구분|설명|
|---|---|
|execution(@execution)|메서드를 기준으로 Pointcut으로 설정
|within(@within)|특정한 타입(클래스)을 기준으로 Pointcut을 설정
|this|주어진 인터페이스를 구현한 객체를 대상으로 Pointcut을 설정
|args(@args)|특정한 파라미터를 가지는 대상들만을 Pointcut으로 설정
|@annotaion|특정한 어노테이션이 적용된 대상들만을 Pointcut으로 설정
