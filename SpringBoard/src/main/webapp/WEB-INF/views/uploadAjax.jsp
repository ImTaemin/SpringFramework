<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Insert title</title>
	<style>
        .uploadResult {
            width: 100%;
            background-color: gray;
        }

        .uploadResult ul {
            display: flex;
            flex-flow: row;
            justify-content: center;
            align-items: center;
        }

        .uploadResult ul li {
            list-style: none;
            padding: 10px;
            align-content: center;
            text-align: center;
        }

        .uploadResult ul li img {
            width: 100px;
        }

        .uploadResult ul li span {
            color: white;
        }

        .bigPictureWrapper {
            position: absolute;
            display: none;
            justify-content: center;
            align-items: center;
            top: 0%;
            width: 100%;
            height: 100%;
            background-color: gray;
            z-index: 100;
            background-color: rgba(255, 255, 255, 0.5);
        }

        .bigPicture {
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .bigPicture img {
            width: 600px;
        }
	</style>
</head>
<body>
<h1> Upload with Ajax</h1>

<div class="uploadDiv">
	<input type="file" name="uploadFile" multiple>
</div>

<div class="uploadResult">
	<ul>

	</ul>
</div>

<div class="bigPictureWrapper">
	<div class="bigPicture"></div>
</div>

<button id="uploadBtn">Upload</button>

<script type="text/javascript">
    const showImage = (fileCallPath) => {
        const bigPictureWrapper = document.querySelector(".bigPictureWrapper");
        bigPictureWrapper.style.display = 'flex';

        // 이미지 로드 후 애니메이션 처리
        const bigPicture = document.querySelector(".bigPicture");
        const img = document.createElement("img");
        img.setAttribute("src", "/display?fileName=" + encodeURI(fileCallPath));
        bigPicture.append(img);
        img.animate({
            width: ["0%", "600px"],
            height: ["0%", "100%"]
        }, 500);

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
    };


    document.addEventListener("DOMContentLoaded", function (e) {
        const regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
        const maxSize = 5242880; // 5MB

        const checkExtenstion = (fileName, fileSize) => {
            if (fileSize >= maxSize) {
                alert("파일 사이즈 초과");
                return false;
            }

            if (regex.test(fileName)) {
                alert("해당 종류의 파일은 업로드 할 수 없습니다.");
                return false;
            }
            return true;
        };

        const cloneObj = document.querySelector(".uploadDiv").cloneNode(true);

        const uploadBtn = document.getElementById("uploadBtn");
        uploadBtn.addEventListener("click", function (e) {
            let formData = new FormData();
            const inputFile = document.querySelector("input[name='uploadFile']");
            let files = inputFile.files;

            for (let i = 0; i < files.length; i++) {
                if (!checkExtenstion(files[i].name, files[i].size)) return false;
                formData.append("uploadFile", files[i]);
            }

            fetch("/uploadAjaxAction", {
                method: "POST",
                body: formData
            })
			.then((response) => response.json())
			.then(commits => {
				console.log(commits);
				showUploadedFile(commits);
				document.querySelector(".uploadDiv").outerHTML = cloneObj.outerHTML;
			})
			.catch((error) => {
				alert(error)
			});
        });

        const uploadResultUl = document.querySelector(".uploadResult ul");

        const showUploadedFile = (uploadResultArr) => {
            for (let i = 0; i < uploadResultArr.length; i++) {
                const li = document.createElement("li");
                if (!uploadResultArr[i].image) {
                    const fileCallPath = encodeURIComponent(uploadResultArr[i].uploadPath
                        + "/" + uploadResultArr[i].uuid
                        + "_" + uploadResultArr[i].fileName);

                    const fileLink = fileCallPath.replace(new RegExp(/\\/g), "/");

                    const div = document.createElement("div");

                    const a = document.createElement("a");
                    a.setAttribute("href", "/download?fileName=" + fileCallPath);
                    div.append(a);

                    const img = document.createElement("img");
                    img.setAttribute("src", "/resources/img/folder.png");
                    a.append(img);
                    a.append(uploadResultArr[i].fileName);

                    const span = document.createElement("span");
                    span.setAttribute("data-file", fileCallPath);
                    span.setAttribute("data-type", "file");
                    span.append("x");
                    div.append(span);

                    li.append(div);
                } else {
                    const fileCallPath = encodeURIComponent(uploadResultArr[i].uploadPath
                        + "/s_" + uploadResultArr[i].uuid
                        + "_" + uploadResultArr[i].fileName);

                    let originPath = uploadResultArr[i].uploadPath
                        + "\\" + uploadResultArr[i].uuid
                        + "_" + uploadResultArr[i].fileName;
                    originPath = originPath.replace(new RegExp(/\\/g), "/");

                    const a = document.createElement("a");
                    a.setAttribute("href", "javascript:showImage('" + originPath + "')");

                    const img = document.createElement("img");
                    img.setAttribute("src", "/display?fileName=" + fileCallPath);
                    a.append(img);

                    const span = document.createElement("span");
                    span.setAttribute("data-file", fileCallPath);
                    span.setAttribute("data-type", "image");
                    span.append("x");

                    li.append(a);
                    li.append(span);
                }
                uploadResultUl.append(li);

                const uploadResult = document.querySelectorAll(".uploadResult span");
                for(const result of uploadResult)
                {
                    result.addEventListener("click", (e) =>{
						const targetFile = e.target.dataset.file;
						const type = e.target.dataset.type;

						let sendData = {fileName: targetFile, type: type};

						fetch("/deleteFile", {
							method: "POST",
							headers: {"Content-Type" : "application/json;charset=utf-8"},
							body: JSON.stringify(sendData)
						})
						.then((response) => alert(response));
					});
                }
            }
        }
    });
</script>
</body>
</html>
