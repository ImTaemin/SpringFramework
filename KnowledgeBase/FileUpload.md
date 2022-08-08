# 파일 업로드 처리

## 📎 파일 업로드 방식
### ✔ \<form> 태그를 이용하는 방식 : 브라우저의 제한이 없어야 하는 경우에 사용   
- 일반적으로 페이지 이동과 동시에 첨부파일을 업로드 하는 방식   
-  `<iframe>`을 이용해서 화면의 이동 없이 첨부파일을 처리하는 방식    
```html
<form action="uploadFormAction" method="post" enctype="multipart/form-data">
```
```java
public void uploadFormPost(MultipartFile[] uploadFile, Model model)
{
    for (MultipartFile multipartFile : uploadFile)
    {
        File saveFile = new File(uploadFolder, multipartFile.getOriginalFilename());
        multipartFile.transferTo(saveFile); // 파일저장
    }
}
```
### ✔ Ajax를 이용하는 파일 업로드
- `<input type='file'>`을 이용하고 Ajax로 처리하는 방식
- HTML5의 Drag And Drop 기능이나 jQuery 라이브러리를 이용해서 처리하는 방식
```javascript
<input type="file" name="uploadFile" multiple>
<button id="uploadBtn">Upload</button>

let formData = new FormData();
const inputFile = document.querySelector("input[name='uploadFile']");
let files= inputFile.files;

for(let i = 0; i < files.length; i++) {
    formData.append("uploadFile", files[i]);
}

fetch("/uploadAjaxAction",{
    method: "POST",
    body: formData
})
.then(response => alert("Uploaded"));
``` 
```java
public void uploadAjaxPost(MultipartFile[] uploadFile)
{
    String uploadFolder = "C:\\upload";

    for(MultipartFile multipartFile : uploadFile)
    {
        String uploadFileName = multipartFile.getOriginalFilename();

        // IE는 파일 경로까지 가지고 옴
        uploadFileName = uploadFileName.substring(uploadFileName.lastIndexOf("\\") + 1);

        File saveFile = new File(uploadFolder, uploadFileName);
        multipartFile.transferTo(saveFile); // 파일저장
    }
}

```
### ❗ 파일 업로드 시 고려해야 할 점
- 동일한 이름으로 파일이 업로드 되었을 때 기존 파일이 사라지는 문제
- 이미지 파일의 경우에는 원본 파일의 용량이 큰 경우 섬네일 이미지를 생성해야 하는 문제
- 이미지 파일과 일반 파일을 구분해서 다운로드 혹은 페이지에서 조회하도록 처리하는 문제
- 첨부파일 공격에 대비하기 위한 업로드 파일의 확장자 제한
---
## 🔗파일 업로드 상세 처리
### ✔ 파일의 확장자나 크기의 사전 처리
```javascript
const regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
const maxSize = 5242880; // 5MB

const checkExtenstion = (fileName, fileSize) => {
    if(fileSize >= maxSize) return false;
    if(regex.test(fileName)) return false;
    return true;
}
```
중복된 이름의 파일 처리
- 현재 시간을 밀리세컨드까지 구분해서 파일 이름을 생성
- UUID를 이용해 중복이 발생할 가능성이 거의 없는 문자열 생성   
```java
UUID uuid = UUID.randomUUID();
uploadFileName = uuid.toString() + "_" + uploadFileName;
```
한 폴더 내에 너무 많은 파일의 생성 문제
- '년/월/일' 단위의 폴더를 생성하여 파일 저장.
```java
// 컨틀롤러
File uploadPath = new File(String.valueOf(uploadFile), getFolder());
log.info("upload path : " + uploadPath);
if(uploadPath.exists() == false)
    uploadPath.mkdirs(); // yyyy/MM/dd 형식의 폴더 생성
File saveFile = new File(uploadFolder, uploadFileName);

private String getFolder()
{
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    Date date = new Date();
    String str = sdf.format(date);
    return str.replace("-", File.separator);
}
```
### ✔ 섬네일 이미지 생성
💡용량이 큰 파일에 섬네일 처리를 하지 않는다면 모바일과 같은 환경에서 많은 데이터를 소비한다.
#### 섬네일 생성 단계
1. 업로드된 파일이 이미지 종류의 파일인지 확인
2. 이미지 파일의 경우 섬네일 이미지 생성 및 저장

이미지 파일의 판단
```java
//boolean checkImageType(File file) 메서드
String contentType = Files.probeContentType(file.toPath());
return contentType.startsWith("image");

//컨트롤러
if(checkImageType(saveFile))
{
    FileOutputStream thumbnail = new FileOutputStream(new File(uploadPath, "s_" + uploadFileName));
    Thumbnailator.createThumbnail(multipartFile.getInputStream(), thumbnail, 100, 100);
    thumbnail.close();
}
```
### ✔ 업로드된 파일의 데이터 반환
💡 브라우저로 전송해야 하는 데이터는 다음과 같은 정보를 포함하도록 설계한다.
- 업로드된 파일의 이름과 원본 파일의 이름
- 파일이 저장된 경로
- 업로드된 파일이 이미지인지 아닌지에 대한 정보

처리 방법
1. 업로드된 경로가 포함된 파일 이름을 반환하는 방식 - 브라우저에서의 처리↑
2. 별도의 객체를 생성해서 처리하는 방식 
- 서버 : DTO 생성 후 List에 담아 JSON 반환
```java
@ResponseBody
@PostMapping(value = "uploadAjaxAction", produces = MediaType.APPLICATION_JSON_VALUE)
public ResponseEntity<List<AttachFileDTO>> uploadAjaxPost(MultipartFile[] uploadFile)
{
    return new ResponseEntity<>(list, HttpStatus.OK);
}
```
- 클라이언트 : 응답 본문 JSON 형태로 파싱
```javascript
fetch("/uploadAjaxAction",{
    method: "POST",
    body: formData
})
.then((response) => response.json())
.then(commits => {
    console.log(commits);
})
.catch((error) => {alert(error)});
```
## 🖼 브라우저에서 섬네일 처리
### ✔ \<input type='file'> 초기화
```javascript
const cloneObj = document.querySelector(".uploadDiv").cloneNode(true).outerHTML;
// response.json() 이후
document.querySelector(".uploadDiv").outerHTML = cloneObj;
```
### ✔ 업로드 된 이미지 처리
섬네일 이미지 보여주기  
서버
```java
// byte[]로 파일의 데이터를 전송할 때 브라우저에 보내주는 MIME 타입이 달라진다.
// probeContentType()을 이용해 적절한 MIME 타입 데이터를 Http 헤더 메세지에 포함
HttpHeaders header = new HttpHeaders();
header.add("Content-Type", Files.probeContentType(file.toPath()));
result = new ResponseEntity<>(FileCopyUtils.copyToByteArray(file), header, HttpStatus.OK);
```
클라이언트
```javascript
const fileCallPath = encodeURIComponent(uploadResultArr[i].uploadPath
							+ "/s_" + uploadResultArr[i].uuid
							+ "_" + uploadResultArr[i].fileName);
img.setAttribute("src","/display?fileName=" + fileCallPath);
```
## 📁 첨부파일 다운로드, 원본 보여주기
- 섬네일 이미지 - 원본 파일을 크게 보여줌
- 일반 파일 - 다운로드
### ✔ 첨부파일 다운로드
```java
// 다운로드 MIME 타입
@GetMapping(value = "/download", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
public ResponseEntity<Resource> downloadFile(String fileName)
{
    Resource resource = new FileSystemResource("c:\\upload\\" + fileName);
    String resourceName = resource.getFilename();

    // UUID 제거
    String resourceOriginalName = resourceName.substring(resourceName.indexOf("_") + 1);

    HttpHeaders headers = new HttpHeaders();
    // filename과 함께 주면 Body에 오는 값 다운.
    headers.add("Content-Disposition"
            , "attachment; filename=" + new String(resourceName.getBytes("UTF-8")
            , "ISO-8859-1"));
    return new ResponseEntity<Resource>(resource, headers, HttpStatus.OK);
}
```
```javascript
const fileCallPath = encodeURIComponent(uploadResultArr[i].uploadPath
    + "/" + uploadResultArr[i].uuid
    + "_" + uploadResultArr[i].fileName);

const a = document.createElement("a");
a.setAttribute("href", "/download?fileName="+fileCallPath);
```
### ✔ 원본 이미지 보여주기
```javascript
const showImage = (fileCallPath) => {
    const bigPicture = document.querySelector(".bigPicture");
    const img = document.createElement("img");
    img.setAttribute("src", "/display?fileName=" + encodeURI(fileCallPath));
    bigPicture.append(img);
    // show
    img.animate({
        width: ["0%", "600px"],
        height: ["0%", "100%"]
    }, 500);

    // hide
    bigPictureWrapper.addEventListener("click", (e) => {
        img.animate({
            width: "0%",
            height: "0%"
        }, 500);
        setTimeout(() => {
            bigPictureWrapper.style.display = 'none';
            bigPicture.innerHTML = "";
        }, 500);
    });
}

const a = document.createElement("a");
a.setAttribute("href", "javascript:showImage('" + originPath + "')");
```
### ✔ 첨부파일 삭제
- 이미지 파일은 섬네일까지 같이 삭제
- 파일을 삭제한 후에는 브라우저에서도 섬네일, 파일 아이콘 삭제
- 비정상적으로 브라우저 종료 시 업로드된 파일 처리
## 📁 첨부파일 - 등록
### ✔ 
### ✔
### ✔
## 📁 첨부파일 - 수정
### ✔
### ✔
### ✔
## 📁 첨부파일 - 삭제
### ✔
### ✔
### ✔