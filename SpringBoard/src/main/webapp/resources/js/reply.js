// 댓글 모듈
const replyService = (() => {

    // 댓글 작성
    const add = (reply, callback, error) => {
        const xhrWrite = new XMLHttpRequest();
        xhrWrite.open("POST", "/replies/new", true);
        xhrWrite.setRequestHeader('content-type', 'application/json; charset=utf-8');
        xhrWrite.onload = function () {
            if (this.status == 200 && this.readyState == this.DONE) {
                callback(this.response);
            } else {
                error(this.response);
            }
        };
        xhrWrite.send(JSON.stringify(reply));
    }

    //댓글 목록 조회
    const getList = (param, callback, error) => {
        const bno = param.bno;
        const page = param.page || 1;

        const xhrList = new XMLHttpRequest();
        xhrList.open("GET", `/replies/pages/${bno}/${page}.json`, true);
        xhrList.onload = function () {
            if (this.status == 200 && this.readyState == this.DONE) {
                const data = JSON.parse(this.response);
                // callback(JSON.parse(data)); // 댓글 목록만 가져오는 경우
                callback(data.replyCnt, data.list);
            } else {
                error(this.response);
            }
        };
        xhrList.send(null);
    }
    
    // 댓글 삭제
    const remove = (rno, callback, error) => {
        const xhrRemove = new XMLHttpRequest();
        xhrRemove.open("DELETE", `/replies/${rno}`, true);
        xhrRemove.onload = function () {
            if (this.status == 200 && this.readyState == this.DONE) {
                callback(this.response);
            } else {
                error(this.response);
            }
        };
        xhrRemove.send(null);
    }

    // 댓글 수정
    const update = (reply, callback, error) => {
        const rno = reply.rno;

        const xhrUpdate = new XMLHttpRequest();
        xhrUpdate.open("PUT", `/replies/${rno}`, true);
        xhrUpdate.setRequestHeader('content-type', 'application/json; charset=utf-8');
        xhrUpdate.onload = function () {
            if (this.status == 200 && this.readyState == this.DONE) {
                callback(this.response);
            } else {
                error(this.response);
            }
        };
        xhrUpdate.send(JSON.stringify(reply));
    }

    // 댓글 조회
    const get = (rno, callback, error) => {
        const xhrGet = new XMLHttpRequest();
        xhrGet.open("GET", `/replies/${rno}.json`, true);
        xhrGet.onload = function () {
            if (this.status == 200 && this.readyState == this.DONE) {
                callback(this.response);
            } else {
                error(this.response);
            }
        };
        xhrGet.send(null);
    }
    
    // 시간 처리 (24시간 이후는 날짜만 표시)
    const displayTime = (timeValue) =>{
        const today = new Date();
        const gap = today.getTime() - timeValue;
        const dateObj = new Date(timeValue);
        let str = "";

        if(gap < (1000 * 60 * 60 * 24)) {
            const hours = dateObj.getHours();
            const minutes = dateObj.getMinutes();
            const seconds = dateObj.getSeconds();

            return [
                (hours > 9 ? "" : "0") + hours, ":",
                (minutes > 9 ? "" : "0") + minutes, ":",
                (seconds > 9 ? "" : "0") + seconds
            ].join('');
        } else {
            const year = dateObj.getFullYear();
            const month = dateObj.getMonth() + 1;
            const day = dateObj.getDate();

            return [
                year, "/",
                (month > 9 ? "" : "0") + month, "/",
                (day > 9 ? "" : "0") + day
            ].join("");
        }
    }

    return {
        add: add,
        getList: getList,
        remove:remove,
        update:update,
        get:get,
        displayTime:displayTime
    };
})();