<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="java.sql.*"%>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css">
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.6/umd/popper.min.js"></script>
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/js/bootstrap.min.js"></script>

<style>
.nav-pills .nav-link.active {
	background-color: #868e96;
}

a {
	color: #343a40;
}

.btn-block {
    width: 20%;
    float: right;
}
</style>

</head>

<body>

	<div class="navbar" style="background-color: #f9f9f9;">
		<nav class="navbar sticky-top navbar-light bg-faded">
			<a class="navbar-brand" href="#">Blockchain Query Explorer</a><a
				class="navbar-brand" href="#"> <img src="img/logo.svg"
				style="height: 20px;"></a>
		</nav>
	</div>

	<div class="container">
		<br>
		<ul class="nav nav-pills" role="tablist">
			<li class="nav-item"><a class="nav-link active"
				data-toggle="pill" href="#query">Query</a></li>
			<li class="nav-item"><a class="nav-link" data-toggle="pill"
				href="#insert">Insert</a></li>
			<li class="nav-item"><a class="nav-link" data-toggle="pill"
				href="#history">History</a></li>
		</ul>

		<div class="tab-content">

			<div id="query" class="container tab-pane active">
				<br>
				<form action="ethquery" method="POST">
					<textarea class="form-control" name="query" rows="10"
						placeholder="select * from transactions" required="" autofocus=""></textarea>
					<br>
					<button class="btn btn-lg btn-success btn-block" type="submit">Run
						Query</button>
				</form>
				<br>
				<br>
				<hr>
				<div id="queryresult">
					<c:if test="${not empty result}">
						<%
								    ResultSet result = (ResultSet) request.getAttribute("result");
												int colCount = result.getMetaData().getColumnCount();
												ResultSetMetaData metadata = result.getMetaData();
								%>

						<div class="container">
							<br>
							<div class="row text-center">
								<h2 class="form-signin-heading">Query Result</h2>
							</div>
							<div style="height: 500px; overflow-y: scroll">
								<table id="result-table"
									class="table table-striped table-bordered">
									<thead>
										<tr>
											<%
													    for (int i = 0; i < colCount; i++) {
													%>
											<th><%=metadata.getColumnLabel(i)%></th>
											<%
													    }
													%>
										</tr>
									</thead>

									<tbody>
										<%
												    while (result.next()) {
												%>
										<tr>
											<%
													    for (int i = 0; i < colCount; i++) {
													%>
											<td><%=result.getObject(i)%></td>
											<%
													    }
													%>
										</tr>
										<%
												    }
												%>
									</tbody>
								</table>
							</div>
						</div>
					</c:if>
				</div>
			</div>

			<div id="insert" class="container tab-pane fade">
				<br>
				<form class="form-signin" action="ethinsert" method="POST">
					<div class="row text-center">
						<h2 class="form-signin-heading">Insert Transaction</h2>
					</div>
					<input type="text" class="form-control" name="keystore_path"
						placeholder="Keystore Path" required="" autofocus="" /><br>
					<input type="password" class="form-control" name="keystore_pass"
						placeholder="Keystore Password" required="" /><br> <input
						type="text" class="form-control" name="to_address"
						placeholder="To Address" required="" autofocus="" /><br>
					<div class="row">
						<div class="col-sm-8">
							<input type="text" class="form-control" name="value"
								placeholder="Value to send" required="" autofocus="" />
						</div>
						<div class="col-sm-4">
							<select class="form-control" name="unit">
								<option>ETHER</option>
								<option>WEI</option>
								<option>KWEI</option>
								<option>MWEI</option>
								<option>GWEI</option>
								<option>SZABO</option>
								<option>FINNEY</option>
								<option>KETHER</option>
								<option>METHER</option>
								<option>GETHER</option>
							</select>
						</div>
					</div>
					<br>
					<div class="checkbox">
						<label><input type="checkbox" name="async"
							checked="checked"> Async request</label>
					</div>
					<button class="btn btn-lg btn-success btn-block" type="submit">Insert</button>
					<p class="text-success">${insertStatus}</p>
				</form>
			</div>

			<div id="history" class="container tab-pane fade">
				<br>
				<div class="row text-center">
					<h2 class="form-signin-heading">Query History</h2>
				</div>
				<div style="height: 500px; overflow-y: scroll">
					<table id="result-table" class="table table-striped table-bordered">
						<tbody>
							<c:forEach var="hist" items="${history}">
								<tr>
									<td>${hist}</td>
								</tr>
							</c:forEach>
						</tbody>
					</table>
				</div>
			</div>


		</div>
	</div>


	<script type="text/javascript">
		function divload() {
			var query = $('[name="query"]').val();
			alert(query);
			var data = "query=" + encodeURIComponent(query);
			$.ajax({
				url : "ethquery",
				data : data,
				type : "POST",

				success : function(response) {
					bootstrap_alert(response);
				},
				error : function(xhr, status, error) {
					// alert(xhr.responseText);
					alert("error" + error + status + xhr);
				}
			});

			document.getElementById("queryresult").innerHTML = "queryresult.jsp";
		}
	</script>

</body>
</html>