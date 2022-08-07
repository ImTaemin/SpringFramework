<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"  %>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Insert title</title>
</head>
<body>
	<h1> Upload with Ajax</h1>

	<div class="uploadDiv">
		<input type="file" name="uploadFile" multiple>
	</div>

	<button id="uploadBtn">Upload</button>

	<script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function (e) {
			const regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
            const maxSize = 5242880; // 5MB

			const checkExtenstion = (fileName, fileSize) => {
				if(fileSize >= maxSize) {
                    alert("파일 사이즈 초과");
                    return false;
				}

                if(regex.test(fileName)){
                    alert("해당 종류의 파일은 업로드 할 수 없습니다.");
                    return false;
				}
                return true;
			};

			const uploadBtn = document.getElementById("uploadBtn");
            uploadBtn.addEventListener("click", function (e){
				let formData = new FormData();
                const inputFile = document.querySelector("input[name='uploadFile']");
                let files= inputFile.files;

                for(let i = 0; i < files.length; i++) {
                    if(!checkExtenstion(files[i].name, files[i].size)) return false;
                    formData.append("uploadFile", files[i]);
				}

                fetch("/uploadAjaxAction",{
                    method: "POST",
					body: formData
				})
				.then((response) => response.json())
				.then(commits => {
                    console.log(commits);
                })
				.catch((error) => {alert(error)});
			});
        });
	</script>
</body>
</html>
