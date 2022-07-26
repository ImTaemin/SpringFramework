<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../includes/header.jsp" %>

<div class="row">
	<div class="col-lg-12">
		<h1 class="page-header">Board Read</h1>
	</div>
	<!-- /.col-lg-12 -->
</div>
<!-- /.row -->
<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">

			<div class="panel-heading">
				Board Read Page
			</div>

			<!-- /.panel-heading -->
			<div class="panel-body">
				<div class="form-group">
					<label>Bno</label>
					<input class="form-control" name="bno" value='<c:out value="${board.bno}"/>' readonly="readonly">
				</div>

				<div class="form-group">
					<label>Title</label>
					<input class="form-control" name="title" value="<c:out value='${board.title}'/>"
						   readonly="readonly">
				</div>

				<div class="form-group">
					<label>Test area</label>
					<textarea class="form-control" rows="3" name="content" readonly="readonly"><c:out
							value="${board.content}"/></textarea>
				</div>

				<div class="form-group">
					<label>Writer</label>
					<input class="form-control" name="writer" value="<c:out value='${board.writer}'/>"
						   readonly="readonly">
				</div>

				<button data-oper="modify" class="btn btn-default"
						onclick="location.href='/board/modify?bno=<c:out value="${board.bno}"/>'">Modify
				</button>
				<button data-oper="list" class="btn btn-info" onclick="location.href='/board/list'">List</button>

				<form id="operForm" action="/board/modify" method="get">
					<input type="hidden" id="bno" name="bno" value='<c:out value="${board.bno }"/>'>
					<input type="hidden" name="pageNum" value='<c:out value="${cri.pageNum }"/>'>
					<input type="hidden" name="amount" value='<c:out value="${cri.amount }"/>'>
					<input type="hidden" name="keyword" value='<c:out value="${cri.keyword }"/>'>
					<input type="hidden" name="type" value='<c:out value="${cri.type }"/>'>
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
				<i class="fa fa-comments fa-fw"></i> Reply
				<button id="addReplyBtn" class="btn btn-primary btn-xs pull-right" data-toggle="modal"
						data-target="#myModal"> New Reply
				</button>
			</div>

			<div class="panel-body">
				<ul class="chat">
					<!-- start reply -->
					<li class="left clearfix" data-rno="12">
						<div>
							<div class="header">
								<strong class="primary-front">user01</strong>
								<small class="pull-right text-muted">2022-07-25 01:43</small>
							</div>
							<p>Good job!</p>
						</div>
					</li>
				</ul>
			</div>

			<div class="panel-footer">

			</div>
		</div>
	</div>
</div>

<!-- Modal -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="myModalLabel">Reply Modal</h4>
			</div>
			<div class="modal-body">
				<div class="form-group">
					<label>Reply</label>
					<input class="form-control" name="reply" value="New Reply!">
				</div>
				<div class="form-group">
					<label>Replyer</label>
					<input class="form-control" name="replyer" value="replyer">
				</div>
				<div class="form-group">
					<label>Reply Date</label>
					<input class="form-control" name="replyDate" value="">
				</div>
			</div>
			<div class="modal-footer">
				<button id="modalModBtn" type="button" class="btn btn-warning">Modify</button>
				<button id="modalRemoveBtn" type="button" class="btn btn-danger">Remove</button>
				<button id="modalRegisterBtn" type="button" class="btn btn-info" data-dismiss="modal">Regist</button>
				<button id="modalCloseBtn" type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			</div>
		</div>
		<!-- /.modal-content -->
	</div>
	<!-- /.modal-dialog -->
</div>

<script type="text/javascript">
    document.addEventListener("DOMContentLoaded", function (e) {
        const operForm = $("#operForm");

        $("button[data-oper='modify']").on("click", function (e) {
            operForm.attr("action", "/board/modify").submit();
        });

        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefaEult();
            operForm.find("#bno").remove();
            operForm.attr("action", "/board/list")
            operForm.submit();
        });

        // 댓글 페이징
        let replyPageNum = 1;
        const replyPageFooter = document.querySelector(".panel-footer");

        const showReplyPage = (replyCnt) => {
            let endNum = Math.ceil(replyPageNum / 10.0) * 10;
            const startNum = endNum - 9;

            let prev = startNum != 1;
            let next = false;

            if(endNum * 10 >= replyCnt){
                endNum = Math.ceil(replyCnt / 10.0);
            }

            if(endNum * 10 < replyCnt) {
                next = true;
            }

            let str = "<ul class='pagination pull-right'>";

            if(prev) {
                str += `<li class='page-item'>
                <a class='page-link' href='` + (startNum - 1) + `'> Previous </a></li>`;
            }

            for(let i = startNum; i <= endNum; i++){
                const active = replyPageNum == i ? "active" : "";

                str += `<li class='page-item ` + active + `'>
                <a class='page-link' href='`+ i +`'>` + i +`</a></li>`;
            }

            if(next){
                str += `<li class='page-item'>
                <a class='page-link' href='` + (endNum + 1) + `'>Next</a></li>`;
            }

            str += "</ul></div>";

            console.log(str);

            replyPageFooter.innerHTML = str;
        }

        // 페이지 번호 클릭 -> 새로운 댓글 가져오기
		replyPageFooter.addEventListener("click", function(e){
			if(e.target.parentNode.tagName == "LI" && e.target.tagName == "A"){
                e.preventDefault();
                console.log("page click");

                let targetPageNum = e.target.getAttribute("href");
                console.log(`targetPageNum : ` + targetPageNum);

                showList(targetPageNum);
			}
		});

        // 댓글 출력
        const bnoValue = "<c:out value="${board.bno}"/>";
        let replyUL = document.querySelector(".chat");

        const showList = (page) => {
            console.log("show list " + page);

            replyService.getList({bno: bnoValue, page: page || 1}, (replyCnt, list) => {

                console.log(`replyCnt : ` + replyCnt);
                console.log(`list : ` + list);
                console.log(list);

                /*
				* 사용자가 새로운 댓글을 추가하면 showList(-1)을 호출해 전체 댓글의 숫자를 파악한다.
				* 이 후 마지막 페이지를 호출해 이동시키는 방식
				*/
                if (page == -1) {
                    const pageNum = Math.ceil(replyCnt / 10.0);
                    showList(pageNum);
                    return;
                }

                let str = "";

                // 댓글 목록이 없으면 끝냄.
                if (list == null || list.length == 0) {
                    return;
                }

                for (let i = 0, len = list.length || 0; i < len; i++) {
                    str += `
                    <li class='left clearfix' data-rno='` + list[i].rno + `'>
                    <div><div class='header'>
                    <strong class='primary-font'>` + list[i].replyer + `</strong>
                    <small class='pull-right text-muted'>` + replyService.displayTime(list[i].replyDate) + `</small></div>
                    <p>` + list[i].reply + `</p></div>
                    </li>
                    `;
                }
                replyUL.innerHTML = str;

                showReplyPage(replyCnt);
            });
        }

        showList(1);


        // 모달
        const modal = document.querySelector(".modal");
        const modalInputReply = modal.querySelector("input[name='reply']");
        const modalInputReplyer = modal.querySelector("input[name='replyer']");
        const modalInputReplyDate = modal.querySelector("input[name='replyDate']");

        const modalModBtn = document.querySelector("#modalModBtn");
        const modalRemoveBtn = document.querySelector("#modalRemoveBtn");

        const addReplyBtn = document.querySelector("#addReplyBtn");
        addReplyBtn.addEventListener("click", function (e) {
            for (let i of modal.querySelectorAll("input")) {
                i.removeAttribute("value");
            }
            modalInputReplyDate.closest("div").style.visibility = "hidden";
            modal.querySelector("button[id='modalModBtn']").style.visibility = "hidden";
            modal.querySelector("button[id='modalRemoveBtn']").style.visibility = "hidden";
            modalRegisterBtn.style.visibility = "visible";
        });

        const modalRegisterBtn = document.querySelector("#modalRegisterBtn");
        modalRegisterBtn.addEventListener("click", function (e) {
            const reply = {
                reply: modalInputReply.value,
                replyer: modalInputReplyer.value,
                bno: bnoValue
            }
            replyService.add(reply, (result) => {
                alert(result);
                modal.querySelector("input[name='reply']").value = "";
                modal.querySelector("input[name='replyer']").value = "";

                // showList(1);
                showList(-1);
            });
        });

        replyUL.addEventListener("click", function (e) {
            const target = e.target.closest("li");
            if (target.tagName == "LI") {
                const rno = target.dataset.rno;
                console.log(rno);
            }
        });

        // 모달 댓글 조회
        replyUL.addEventListener("click", function (e) {
            const target = e.target.closest("li");
            replyService.get(target.dataset.rno, (reply) => {
                reply = JSON.parse(reply);
                modalInputReply.value = reply.reply;
                modalInputReplyer.value = reply.replyer;
                modalInputReplyDate.value = replyService.displayTime(reply.replyDate);
                modalInputReplyDate.setAttribute("readonly", "readonly");
                modal.setAttribute("data-rno", reply.rno);

                modal.querySelector("button[id='modalModBtn']").style.visibility = "hidden";
                modal.querySelector("button[id='modalRemoveBtn']").style.visibility = "hidden";
                modal.querySelector("button[id='modalRegisterBtn']").style.display = "none";

                modalModBtn.style.visibility = "visible";
                modalRemoveBtn.style.visibility = "visible";

                $(".modal").modal("show");
            });
        });

        // 모달 댓글 수정
        modalModBtn.addEventListener("click", function (e) {
            const reply = {rno: modal.dataset.rno, reply: modalInputReply.value};
            replyService.update(reply, (result) => {
                alert(result);
                $(".modal").modal("hide");
                showList(replyPageNum);
            });
        });

        // 모달 댓글 삭제
        modalRemoveBtn.addEventListener("click", function (e) {
            const rno = modal.dataset.rno;
            replyService.remove(rno, (result) => {
                alert(result);
                $(".modal").modal("hide");
                showList(replyPageNum);
            });
        });
    });

    console.log("===========");
    console.log("JS Test");

    const bnoValue = "<c:out value='${board.bno}'/>";
    const replyUL = document.querySelector(".chat");

    // 댓글 추가 : add시킬 데이터, 콜백 메소드, 에러
    replyService.add(
        {reply: "JS Test", replyer: "tester", bno: bnoValue},
        (result) => {
            alert(`RESULT : result`);
        });

    // 댓글 목록 조회
    replyService.getList({bno: bnoValue, page: 1}, (list) => {
        for (let i = 0, len = list.length || 0; i < len; i++) {
            // console.log(JSON.stringify(list[i]));
        }
    });

    // 댓글 삭제
    replyService.remove(46, (count) => {
            console.log(count);

            if (count === "success") {
                alert("REMOVED");
            }
        },
        (err) => {
            alert("ERROR");
        });

    // 댓글 수정
    replyService.update({rno: 1, bno: bnoValue, reply: "Modify Reply..."}, (result) => {
        alert("수정 완료..");
    });

    // 댓글 조회
    replyService.get(47, (data) => {
        console.log(data);
    });
</script>

<script type="text/javascript" src="/resources/js/reply.js"></script>

<%@ include file="../includes/footer.jsp" %>