# Spring REST
|어노테이션|기능|
|---|---|
|@RestController|Controller가 REST 방식을 처리하기 위한 것임을 명시
|@ResponseBody|일반적인JSP와 같은 뷰로 전달되는 게 아니라 데이터 자체를 전달하귀 위한 용도
|@PathVariable|URL 경로에 있는 값을 파라미터로 추출하려고 할 때 사용
|@CrossOrigin|Ajax의 크로스 도메인 문제를 해결해주는 어노테이션
|@RequestBody|JSON 데이터를 원하는 타입으로 바인딩 처리