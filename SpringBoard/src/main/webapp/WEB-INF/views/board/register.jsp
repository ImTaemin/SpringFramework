<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../includes/header.jsp" %>

<div class="row">
	<div class="col-lg-12">
		<h1 class="page-header">Board Register</h1>
	</div>
	<!-- /.col-lg-12 -->
</div>
<!-- /.row -->
<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">

			<div class="panel-heading">
				Board Register
			</div>

			<!-- /.panel-heading -->
			<div class="panel-body">
				<form role="form" action="/board/register" method="post">
					<div class="form-group">
						<label>title</label>
						<input class="form-control" name="title">
					</div>

					<div class="form-group">
						<label>Test area</label>
						<textarea class="form-control" rows="3" name="content"></textarea>
					</div>

					<div class="form-group">
						<label>Writer</label>
						<input class="form-control" name="writer">
					</div>

					<button type="submit" class="btn btn-default">Submit Button</button>
					<button type="reset" class="btn btn-default">Reset Button</button>
				</form>
			</div>
			<!-- /.panel-body -->
		</div>
		<!-- /.panel body-->
	</div>
	<!-- /.col-lg-12 -->
</div>
<!-- /.row -->

<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">

			<div class="panel-heading">
				File Attach
			</div>

			<!-- /.panel-heading -->
			<div class="panel-body">
				<div class=""form-group uploadDiv>
					<input type="file" name="uploadFile" multiple>
				</div>

				<div class="uploadResult">
					<ul>

					</ul>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
    document.addEventListener("DOMContentLoaded", function (e) {
		const formObj = document.querySelector("form[role='form']");
        const submitBtn = document.querySelector("button[type='submit']");
        submitBtn.addEventListener("click", (e) =>{
			e.preventDefault();
            console.log("submit clicked");

            let str = "";
            const lis = document.querySelectorAll(".uploadResult ul li");

            for(let i=0; i<lis.length; i++){
                console.dir(lis[i]);

                str += "<input type='hidden' name='attachList[" + i + "].fileName' value='" + lis[i].dataset.filename + "'>";
                str += "<input type='hidden' name='attachList[" + i + "].uuid' value='" + lis[i].dataset.uuid + "'>";
                str += "<input type='hidden' name='attachList[" + i + "].uploadPath' value='" + lis[i].dataset.path + "'>";
                str += "<input type='hidden' name='attachList[" + i + "].fileType' value='" + lis[i].dataset.type + "'>";
			}

            formObj.innerHTML = str;
            formObj.submit();
		});

        const regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
        const maxSize = 5242880; // 5MB

		const checkExtension = (fileName, fileSize) => {
            if(fileSize >= maxSize){
                alert("파일 사이즈 초과");
                return false;
            }

            if(regex.test(fileName)){
                alert("해당 종류의 파일은 업로드 할 수 없습니다.");
                return false;
            }
			return true;
		}

        const showUploadResult = (uploadResultArr) => {
            if(!uploadResultArr || uploadResultArr.length == 0)
            {
                return;
            }

            const uploadUL = document.querySelector(".uploadResult ul");
            let str = "";
            for(let i=0; i<uploadResultArr.length; i++){
                if(uploadResultArr[i].image) {
                    const fileCallPath = encodeURIComponent(uploadResultArr[i].uploadPath
                        + "/s_" + uploadResultArr[i].uuid
                        + "_" + uploadResultArr[i].fileName);

                    str += "<li data-path='" + uploadResultArr[i].uploadPath + "'";
                    str += "data-uuid='" + uploadResultArr[i].uuid + "'";
                    str += "data-fileName='" + uploadResultArr[i].fileName + "'";
                    str += "data-type='" + uploadResultArr[i].image + "'>";
                    str += "<div>";
                    str += "<span>" + uploadResultArr[i].fileName + "</span>";
                    str += "<button type='button' class='btn btn-warning btn-circle' data-file=\'" + fileCallPath + "\' data-type='image'>";
                    str += "<i class='fa fa-times'></i>";
                    str += "</button><br>";
					str += "<img src='/display?fileName=" + fileCallPath + "'>";
                    str += "</div></li>";
                }else{
                    const fileCallPath = encodeURIComponent(uploadResultArr[i].uploadPath
                        + "/" + uploadResultArr[i].uuid
                        + "_" + uploadResultArr[i].fileName);
                    const fileLink = fileCallPath.replace(new RegExp(/\\/g), "/");

                    str += "<li data-path='" + uploadResultArr[i].uploadPath + "'";
                    str += "data-uuid='" + uploadResultArr[i].uuid + "'";
                    str += "data-fileName='" + uploadResultArr[i].fileName + "'";
                    str += "data-type='" + uploadResultArr[i].image + "'>";
                    str += "<div>";
                    str += "<span>" + uploadResultArr[i].fileName + "</span>";
                    str += "<button type='button' class='btn btn-warning btn-circle' data-file=\'" + fileCallPath + "\' data-type='file'>";
                    str += "<i class='fa fa-times'></i>";
                    str += "</button><br>";
                    str += "<img src='/resources/img/folder.png'></a>";
                    str += "</div></li>";
                }
                uploadUL.innerHTML = str;

                const uploadResult = document.querySelectorAll(".uploadResult button");
                for(const result of uploadResult) {
                    result.addEventListener("click", (e) => {
                        console.log("delete file");
                        const targetFile = e.target.dataset.file;
                        const type = e.target.dataset.type;

                        const targetLi = e.target.closest("li");

                        let sendData = {fileName: targetFile, type: type};

                        fetch("/deleteFile", {
                            method: "POST",
                            headers: {"Content-Type": "application/json;charset=utf-8"},
                            body: JSON.stringify(sendData)
                        })
                            .then((response) => {
                                alert(response);
                                targetLi.remove();
                            });
                    });
                }
            }
        }

        const fileChange = document.querySelector("input[type='file']");
        fileChange.addEventListener("change", (e) => {
			const formData = new FormData();

            const inputFile = document.querySelector("input[name='uploadFile']");
            let files = inputFile.files;

            for (let i = 0; i < files.length; i++) {
                if (!checkExtension(files[i].name, files[i].size)) {
                    return false;
                }

                formData.append("uploadFile", files[i]);
            }

            fetch("/uploadAjaxAction", {
                method: "POST",
                body: formData
            })
			.then((response) => response.json())
			.then(commits => {
				console.log(commits);
				showUploadResult(commits);
			})
			.catch((error) => {
				alert(error)
			});
		});
    });
</script>
<%@ include file="../includes/footer.jsp" %>