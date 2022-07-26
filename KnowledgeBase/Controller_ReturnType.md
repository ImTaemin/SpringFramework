# Controller의 리턴타입
+ String : jsp를 이용하는 경우에는 jsp 파일의 경로와 파일이름을 나타내기 위해서 사용
+ void : 호출하는 URL과 동일한 이름의 jsp를 의미
+ VO, DTO 타입 : 주로 JSON 타입의 데이터를 만들어 반환하는 용도로 사용
+ ResponseEntity 타입 : response 할 때 Http 헤더 정보와 내용을 가공하는 용도로 사용
+ Model, ModelAndView : Model로 데이터를 반환하거나 화면까지 같이 지정하는 경우에 사용 (최근 많이 사용x)
+ HttpHeaders : 응답에 내용 없이 Http 헤더 메시지만 전달하는 용도로 사용