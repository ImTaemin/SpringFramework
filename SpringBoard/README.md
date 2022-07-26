# SpringBoard REST API
--- 
|작업명|URL|Method|Parameter|From|URL 이동|
|:---:|:---:|:---:|:---:|:---:|:---:|
|전체 목록|/board/list|GET| | |
|등록 처리|/board/register|POST|모든 항목|입력화면 필요|이동|
|조회|/board/get|GET|bno=123| | |
|삭제 처리|/board/remove|POST|bno|입력화면 필요|이동|
|수정 처리|/board/modify|POST|모든 항목|입력화면 필요|이동|
 ---
# SpringMVC - MyBatis의 처리 흐름
![MVC_Flow](https://user-images.githubusercontent.com/84948004/180598375-8b3139b2-63cc-42c2-8ff1-b060e18c57ae.png)
1. 웹 브라우저는 URL을 이용하여 요청을 보낸다.
2. Controller는 웹 브라우저의 요청을 처리<br>컨트롤러가 서비스를 호출한다.
3. Service는 비즈니스 로직을 처리한다.<br>데이터 베이스에 접근하는 Mapper를 이용하여 DB의 결과값을 받아온다.
4. Mapper는 데이터베이스에 접속하여 비즈니스 로직 실행에 필요한 쿼리를 호출한다
5. DB에서 알맞은 쿼리를 실행 후 결과값을 반환한다.

# SpringBoard Reply REST API
|작업|URL|METHOD|
|---|---|---|
|등록|/replies/new|POST|
|조회|/replies/:rno|GET|
|삭제|/replies/:rno|DELETE|
|수정|/replies/:rno|PUT or PATCH|
|페이지|/replies/pages/:bno/:page|GET|