<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../includes/header.jsp" %>

<div class="row">
	<div class="col-lg-12">
		<h1 class="page-header">Board Modify Page</h1>
	</div>
	<!-- /.col-lg-12 -->
</div>
<!-- /.row -->
<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">

			<div class="panel-heading">
				Board Modify Page
			</div>

			<!-- /.panel-heading -->
			<div class="panel-body">
				<form role="form" action="/board/modify" method="post">

					<input type="hidden" name="pageNum" value="<c:out value='${cri.pageNum}'/>">
					<input type="hidden" name="amount" value="<c:out value='${cri.amount}'/>">
					<input type="hidden" name="type" value="<c:out value='${cri.type}'/>">
					<input type="hidden" name="keyword" value="<c:out value='${cri.keyword}'/>">

					<div class="form-group">
						<label>Bno</label>
						<input class="form-control" name="bno" value="<c:out value='${board.bno}'/>"
							   readonly="readonly">
					</div>

					<div class="form-group">
						<label>Title</label>
						<input class="form-control" name="title" value="<c:out value='${board.title}'/>">
					</div>

					<div class="form-group">
						<label>Test area</label>
						<textarea class="form-control" rows="3" name="content"><c:out value="${board.content}"/></textarea>
					</div>

					<div class="form-group">
						<label>Writer</label>
						<input class="form-control" name="writer" value="<c:out value='${board.writer}'/>" readonly="readonly">
					</div>

					<div class="form-group">
						<label>RegDate</label>
						<input class="form-control" name="regDate"
							   value="<fmt:formatDate pattern="yyyy/MM/dd" value='${board.regdate}'/>" readonly="readonly">
					</div>

					<div class="form-group">
						<label>Update Date</label>
						<input class="form-control" name="updateDate"
							   value="<fmt:formatDate pattern="yyyy/MM/dd" value='${board.updateDate}'/>"
							   readonly="readonly">
					</div>

					<button type="submit" data-oper="modify" class="btn btn-default">Modify</button>
					<button type="submit" data-oper="remove" class="btn btn-danger">Remove</button>
					<button type="submit" data-oper="list" class="btn btn-info">List</button>
				</form>
			</div>
			<!-- /.panel-body -->
		</div>
		<!-- /.panel body-->
	</div>
	<!-- /.col-lg-12 -->
</div>
<!-- /.row -->

<div class="bigPictureWrapper">
	<div class="bigPicture">

	</div>
</div>

<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				Files
			</div>
			<div class="form-group uploadDiv">
				<input type="file" name="uploadFile" multiple>
			</div>
			<div class="uploadResult">
				<ul>

				</ul>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        let formObj = $("form");

        $("button").on("click", function (e) {
            // e.preventDefault();

            let operation = $(this).data("oper");
            console.log(operation);

            if (operation === 'remove') {
                formObj.attr("action", "/board/remove");
            } else if (operation === 'list') {
                formObj.attr("action", "/board/list").attr("method", "get");
                
                let pageNumTag = document.querySelector("input[name='pageNum']").cloneNode();
                let amountTag = document.querySelector("input[name='amount']").cloneNode();
                let keywordTag = document.querySelector("input[name='keyword']").cloneNode();
                let typeTag = document.querySelector("input[name='type']").cloneNode();

                formObj.empty();
                formObj.append(pageNumTag);
                formObj.append(amountTag);
                formObj.append(keywordTag);
                formObj.append(typeTag);
            } else if (operation === 'modify'){
                console.log("submit clicked");

                $(".uploadResult ul li").each((i, obj) =>{
					const jobj = $(obj);
                    console.log(jobj);

                    const hiddenFileName = document.createElement("input");
                    hiddenFileName.setAttribute("type", "hidden");
                    hiddenFileName.setAttribute("name", "attachList[" + i +"].fileName");
                    hiddenFileName.setAttribute("value", jobj.data("filename"));

                    const hiddenUuid = document.createElement("input");
                    hiddenUuid.setAttribute("type", "hidden");
                    hiddenUuid.setAttribute("name", "attachList[" + i +"].uuid");
                    hiddenUuid.setAttribute("value", jobj.data("uuid"));

                    const hiddenUploadPath = document.createElement("input");
                    hiddenUploadPath.setAttribute("type", "hidden");
                    hiddenUploadPath.setAttribute("name", "attachList[" + i +"].uploadPath");
                    hiddenUploadPath.setAttribute("value", jobj.data("path"));

                    const hiddenFileType = document.createElement("input");
                    hiddenFileType.setAttribute("type", "hidden");
                    hiddenFileType.setAttribute("name", "attachList[" + i +"].fileType");
                    hiddenFileType.setAttribute("value", jobj.data("type"));

                    formObj.append(hiddenFileName);
                    formObj.append(hiddenUuid);
                    formObj.append(hiddenUploadPath);
                    formObj.append(hiddenFileType);
				});
            }

            formObj.submit();
        });

        (function (){
            const bno = '<c:out value="${board.bno}"/>';
            fetch("/board/getAttachList?bno="+bno)
                .then((response) => response.json())
                .then((result) => {
                    for(let i=0; i<result.length; i++){
                        const li = document.createElement("li");
                        li.setAttribute("data-path", result[i].uploadPath);
                        li.setAttribute("data-uuid", result[i].uuid);
                        li.setAttribute("data-filename", result[i].fileName);
                        li.setAttribute("data-type", result[i].fileType);

                        const fileCallPath = encodeURIComponent(result[i].uploadPath
                            + "/s_" + result[i].uuid
                            + "_" + result[i].fileName);

                        const span = document.createElement("span");
                        span.append(result[i].fileName);

                        const btn = document.createElement("button");
                        btn.setAttribute("type", "button")
                        btn.setAttribute("class", "btn btn-warning btn-circle");
                        btn.setAttribute("data-file", fileCallPath);
                        btn.setAttribute("data-type", "image");

                        const iTag = document.createElement("i");
                        iTag.setAttribute("class", "fa fa-times");
                        btn.append(iTag);

                        const img = document.createElement("img");
                        // 이미지 타입
                        if(result[i].fileType) {
                            img.setAttribute("src", "/display?fileName=" + fileCallPath);

                        } else {
                            img.setAttribute("src", "/resources/img/folder.png");
                        }
                        const div = document.createElement("div");
                        div.append(span);
                        div.append(btn);
                        div.append(document.createElement("br"));
                        div.append(img);

                        li.append(div);

                        document.querySelector(".uploadResult ul").append(li);
                    }

                    const uploadResult = document.querySelectorAll(".uploadResult button");
                    for(const result of uploadResult) {
                        result.addEventListener("click", (e) =>{
                            if(confirm("Remove this file?")) {
								const targetLi = e.target.closest("li");
                                targetLi.remove();
							}
                        });
                    }
                });
        })();

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
