<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<html>
<head>
	<title>Logout</title>
</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-md-4 col-md-offset-4">
			<div class="login-panel panel panel-default">
				<div class="panel-heading">
					<h3 class="panel-title">Logout Page</h3>
				</div>
				<div class="panel-body">
					<form role="form" method="post" action="/customLogout">
						<fieldset>
							<a href="index.html" class="btn btn-lg btn-success btn-block">Logout</a>
						</fieldset>
						<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
					</form>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
    $(".btn-success").on("click", function (e) {
        e.preventDefault();
        $("form").submit();
    });
</script>
<c:if test="${param.logout != null}">
	<script type="text/javascript">
		$(document).ready(function (){
            alert("로그아웃 완료");
		});
	</script>
</c:if>
</body>
</html>
