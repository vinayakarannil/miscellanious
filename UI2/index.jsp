<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="java.sql.*"%>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet"
	href="https://jonmiles.github.io/bootstrap-treeview/css/bootstrap-treeview.css">
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.6/umd/popper.min.js"></script>
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/js/bootstrap.min.js"></script>

<script
	src="https://jonmiles.github.io/bootstrap-treeview/js/bootstrap-treeview.js"></script>
<script
	src="https://cdn.jsdelivr.net/gh/atatanasov/gijgo@1.7.3/dist/combined/js/gijgo.min.js"
	type="text/javascript"></script>
<link
	href="https://cdn.jsdelivr.net/gh/atatanasov/gijgo@1.7.3/dist/combined/css/gijgo.min.css"
	rel="stylesheet" type="text/css" />
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

<%
	String username = (String) request.getSession().getAttribute("username");
	String keyPath = (String) request.getSession().getAttribute("keystorepath");
	String keyPass = (String) request.getSession().getAttribute("keystorepswd");
	String conPath = (String) request.getSession().getAttribute("configpath");
	String channel = (String) request.getSession().getAttribute("channel");
	if (null == username) {
		response.sendRedirect("login.jsp");
	}
	if (keyPath == null) {
		keyPath = "";
	}
	if (keyPass == null) {
		keyPass = "";
	}
	if (conPath == null) {
		conPath = "";
	}
	if (channel == null) {
		channel = "";
	}
%>
<style>
.active_sel
{
    background: #E8E8E8;
    color: white;
}
</style>
</head>

<body style="background-color: #f9f9f9;">


	<div class="navbar" style="background-color: #f9f9f9;">
		<nav class="navbar sticky-top navbar-light bg-faded">
			<a class="navbar-brand" href="#"><h4>Blockchain Query
					Explorer</h4></a><a class="navbar-brand" href="#"> <img
				src="img/logo.svg" style="height: 20px; margin-bottom: 10px"></a>
		</nav>
		<ul class="dropdown" style="padding-left: 2%; margin-right: 6%">
			<a href="#" class="dropdown-toggle" data-toggle="dropdown"> <strong><%=request.getSession().getAttribute("username")%></strong>
			
			</a>
			<ul class="dropdown-menu" style="min-width: 6rem">


				<li><br/>
					<form action="logout" method="POST">
						<button class="btn btn-md btn-danger"
							style="text-decoration: none; margin-left: 10%;" type="submit">Logout</button>
					</form></li>
			</ul>
		</ul>
	</div>

	<div class="container-fluid">
		<div class="row">
			<div class="col-lg-2" style="background-color: #f9f9f9;">
                 <br/> <br/>
				<nav class="navbar">
					
					<ul id="offerings" class="navbar-nav">
						<li class="nav-item active" id="queryselect"><a class="nav-link active_sel"
							href="#querybrowser" ><center>
									<i class="fa fa-database" style="font-size: 50px; color: black"></i><br/>
									<p style="color: black">Query Browser</p>
								</center></a></li>
						<br/>
						<li class="nav-item" ><a class="nav-link" href="#analytics"><center>
									<i class="fa fa-bar-chart"
										style="font-size: 50px; color: black"></i><br/>
									<p style="color: black">Blockchain Analytics</p>
								</center></a></li>
						<br/>
						<li class="nav-item" ><a class="nav-link" href="#metadata"><center>
									<i class="fa fa-cogs" style="font-size: 50px; color: black"></i><br/>
									<p style="color: black">Metadata Management</p>
								</center></a></li>
						<br/>
						<li class="nav-item"><a class="nav-link" href="#operations"><center>
									<i class="fa fa-cubes" style="font-size: 50px; color: black"></i><br/>
									<p style="color: black">Operations</p>
								</center></a></li>

					</ul>
				</nav>
			</div>
			<div class="col-lg-10">
				<div id="querybrowser" style="background-color: white;">


					<ul id="myTab" class="nav nav-tabs nav-justified"
						style="background-color: #E8E8E8;">
						<li class="nav-item"><a class="nav-link active"
							style="color: black" data-toggle="tab" href="#query">Query</a></li>
						<!-- 		<li class="nav-item"><a class="nav-link" style="color: black" -->
						<!-- 			data-toggle="tab" href="#insert">Insert</a></li> -->
						<li class="nav-item" id="historytab"><a class="nav-link"
							style="color: black" data-toggle="tab" href="#history">History</a></li>

						<!-- <ul class="nav navbar-nav navbar-right"> -->

						<!-- </ul> -->
					</ul>


					<div class="tab-content">
						<div class="tab-pane active" id="query" role="tabpanel">
							<div class="container-fluid">
								<div class="row">
									<div class="col-lg-4">
										<div class="container">
											<br/>
											<table class="table table-bordered"
												style="border-style: solid; border-width: 2px; border-color: #D6D1D0;">
												<thead style="background-color: #E8E8E8;">
													<tr>
														<th><center>Settings</center></th>
													</tr>
												</thead>

												<tr>
													<th>

														<form class="form-signin" action="connection"
															method="POST">
															<select class="form-control" id="sel3"
																name="network_type" style="background-color: #f9f9f9;"
																onchange="network()">
																<option value="Ethererum" selected="selected">Ethereum</option>
																<option value="Fabric">Fabric</option>

															</select> <br/>

															<div id="ethconfig">
																<input type="text" id="keystore_path"
																	placeholder="Keystore Path" class="form-control"
																	name="keystore_path" value=<%=keyPath%>></input><br/>
																<input type="password" id="keystore_pass"
																	placeholder="Keystore password" class="form-control"
																	name="keystore_pass" value=<%=keyPass%>></input><br/>
																<input type="checkbox" onclick="myFunction()"><span
																	style="font-weight: normal"><font size="3">
																		show password</font></span>
															</div>
															<div id="fabconfig" style="display: none">
																<input type="text" id="config_path"
																	placeholder="Config Path" class="form-control"
																	name="config_path" value=<%=conPath%>></input><br/>
																<input type="text" id="channel" placeholder="Channel"
																	class="form-control" name="channel" value=<%=channel%>></input><br/>
															</div>

															<button class="btn btn-sm btn-success"
																style="float: right; text-decoration: none;"
																type="submit">Save</button>

														</form>
													</th>
												</tr>
											</table>
										</div>
									</div>

									<div class="col-lg-8">
										<div class="container tab-pane active">
											<br/>
											<table class="table table-bordered"
												style="border-style: solid; border-width: 2px; border-color: #D6D1D0;">
												<thead style="background-color: #E8E8E8;">
													<tr>
														<th><center>Query Editor</center></th>
													</tr>
												</thead>
												<tr>
													<th>
														<ul class="nav nav-tabs">
															<li class="nav-item"><a class="nav-link active"
																data-toggle="tab" href="#query">Worksheet1</a></li>

														</ul> <!-- 										<form action="ethquery" id="ethquery" method="POST"> -->
														<textarea class="form-control" name="query" id="queryarea"
															rows="12" placeholder="select * from transactions"
															required=""></textarea> <br/> <c:if
															test="${not empty clearbtn}">
															<button class="btn btn-sm" id="clear"
																style="float: left; text-decoration: none;"
																type="submit">Clear Result</button>
														</c:if>
														<button class="btn btn-sm btn-success" id="qrySubmit"
															style="float: right; text-decoration: none;"
															type="submit">Run Query</button>
														<p class="text-success">${insertStatus}</p> <!-- 										</form> -->
													</th>
												</tr>
											</table>
											<c:if test="${not empty errorMessage}">
												<div id="syntaxerror"
													class="alert alert-danger alert-dismissible fade show"
													role="alert">
													<button type="button" class="close" data-dismiss="alert"
														aria-label="Close">
														<span aria-hidden="true">&times;</span>
													</button>
													<span id="insertalert4"><c:out
															value="${errorMessage}" /></span>
												</div>

											</c:if>
											<div id="keyerror"
												class="alert alert-danger alert-dismissible fade show"
												role="alert" style="display: none">
												<button type="button" class="close" data-dismiss="alert"
													aria-label="Close" onclick="location.reload();">
													<span aria-hidden="true">&times;</span>
												</button>
												<span id="insertalert0">Keystore Path and Keystore
													password should not be null for Insert query</span>
											</div>
											<div id="insertstatus"
												class="alert alert-warning alert-dismissible fade show"
												role="alert" style="display: none">
												<button type="button" class="close" data-dismiss="alert"
													aria-label="Close">
													<span aria-hidden="true">&times;</span>
												</button>
												<span id="insertalert1">Transaction initiated</span>
											</div>

											<div id="insertsuccess"
												class="alert alert-success alert-dismissible fade show"
												role="alert" style="display: none">
												<button type="button" class="close" data-dismiss="alert"
													aria-label="Close" onclick="location.reload();">
													<span aria-hidden="true">&times;</span>
												</button>
												<span id="insertalert2"></span>
											</div>
										</div>
									</div>
								</div>
							</div>

							<hr>
							<div id="queryresult">
								<c:if test="${not empty result}">
									<%
										ResultSet result = (ResultSet) request.getAttribute("result");
											int colCount = result.getMetaData().getColumnCount();
											ResultSetMetaData metadata = result.getMetaData();
									%>

									<div class="container">
										<br/>
										<div>
											<center>
												<h4 class="form-signin-heading">Result</h4>
												
											</center>
										</div>
										<br/>
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
						

						<div class="tab-pane" id="history" role="tabpanel">
							<div class="container">
								<br/>
								<div>
									<center>
										<h4 class="form-signin-heading">Query History</h4>
										<a title='Refresh' onclick="location.reload();"><i class="fa fa-refresh" style="font-size: 20px; color: black"></i></a>
									</center>
								</div>
								<br/>
								<div id="queryhistory">
									<c:if test="${not empty queryhistory}">
										<%
											ResultSet queryhistory = (ResultSet) request.getAttribute("queryhistory");
												int colCount = queryhistory.getMetaData().getColumnCount();

												ResultSetMetaData metadata = queryhistory.getMetaData();
										%>

										<div class="container">

											<div></div>

											<div style="height: 500px;">
												<table id="result-table"
													class="table table-striped table-bordered">
													<thead>
														<tr>


															<th><center>User</center></th>
															<th><center>Query</center></th>
															<th><center>Start Time</center></th>
															<th><center>Execution Time(ms)</center></th>
															<th><center>Status</center></th>
														</tr>
													</thead>

													<tbody>
														<%
															while (queryhistory.next()) {
														%>
														<tr>
															<%
																for (int i = 2; i <= colCount; i++) {
															%>
															<td><%=queryhistory.getObject(i)%></td>
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
						</div>

					</div>
				</div>
				<div id="analytics" style="display: none">
					<center>
						<p style="margin-top: 20%">
						<h2>In progress</h2>
						</p>
					</center>
				</div>
				<div id="metadata" style="display: none">
					<center>
						<p style="margin-top: 20%">
						<h2>In progress</h2>
						</p>
					</center>
				</div>
				<div id="operations" style="display: none">
					<center>
						<p style="margin-top: 20%">
						<h2>In progress</h2>
						</p>
					</center>
				</div>
			</div>
		</div>
	</div>

	<script type="text/javascript">
	
	
		$(document).ready(function() {
			if (location.hash) {
				$("a[href='" + location.hash + "']").tab("show");
			}
			$(document.body).on("click", "a[data-toggle]", function(event) {
				location.hash = this.getAttribute("href");
			});
		});

		var selectedItem = sessionStorage.getItem('SelectedItem');
		if (selectedItem == 'Fabric') {
			$('#ethconfig').hide();
			$('#fabconfig').show();
			//$("#sel3").val(network_type);
		} else {
			$('#fabconfig').hide();
			$('#ethconfig').show();
		}
		
		if(selectedItem != null){
		$('#sel3').val(selectedItem);
		}
		
		$('#sel3').change(function() {
			var dropVal = $(this).val();

			sessionStorage.setItem("SelectedItem", dropVal);

			//$("#sel3").val(network_type);

		});

		function network() {

			var network_type = $("#sel3 option:selected").val();
			if (network_type == 'Fabric') {
				$('#ethconfig').hide();
				$('#fabconfig').show();
				//$("#sel3").val(network_type);
			} else {
				$('#fabconfig').hide();
				$('#ethconfig').show();
				//$("#sel3").val(network_type);

			}

		}

		function runinsert(query) {
			$('#insertstatus').show();

			//alert(query)
			$
					.ajax({
						url : 'http://localhost.63:8080/blkchn-ui/ethquery',
						type : 'POST',
						//accepts : "application/json",
						cache : false,
						headers : {
							'X-Requested-With' : 'XMLHttpRequest'
						},
						data : {
							'query' : query
						},
						success : function(response) {

							console.log("SERVER RESPONSE");
							//var result = response["0"].status;
							//$('#insertstatus').hide();
							$('#insertsuccess').show();
							//alert(response)
							document.getElementById("insertalert2").innerHTML = response;
						},
						error : function(response) {
							console.log("SERVER RESPONSE ERROR");

						}
					});

		}

		/*  $('#btnlogout').on('click',function(e){
			window.location.href="logout.jsp"
		})   */

		$("#qrySubmit")
				.click(
						function() {

							var network_type = $("#sel3 option:selected").val();
							if (network_type == 'Ethererum') {

								var query_entered = $('#queryarea').val();

								if (query_entered.search(/insert/i) != -1) {

									var element = $("#queryarea")[0];
									var kpselement = document
											.getElementById("keystore_path");
									var kpwdelement = document
											.getElementById("keystore_pass");

									var keystore_path = $('#keystore_path')
											.val();
									var keystore_pass = $('#keystore_pass')
											.val();

									var test = query_entered.search(/insert/i);
									if (query_entered.search(/insert/i) != -1
											&& (keystore_path === "" || keystore_pass === "")) {

										//element
										//.setCustomValidity("Keystore Path and Keystore password should not be null For Insert query");
										$('#keyerror').show();

									} else {
										element.setCustomValidity('');
										runinsert(query_entered)
									}
								}

								else {
									runquery(query_entered);
								}
							} else {
								alert("Fabric querying not implemented");
							}
						});

		function runquery(query) {
			var form = document.createElement("form");
			form.setAttribute("method", "POST");
			form.setAttribute("action", "ethquery");

			var hiddenField = document.createElement("input");
			hiddenField.setAttribute("type", "hidden");
			hiddenField.setAttribute("name", "query");
			hiddenField.setAttribute("value", query);

			form.appendChild(hiddenField);

			document.body.appendChild(form);
			form.submit();
			$('#clear').show();
		}

		$("#clear").click(function() {
			var form = document.createElement("form");
			form.setAttribute("method", "GET");
			form.setAttribute("action", "index");
			document.body.appendChild(form);
			form.submit();
		});

		function myFunction() {
			var x = document.getElementById("keystore_pass");
			if (x.type === "password") {
				x.type = "text";
			} else {
				x.type = "password";
			}
		}

		$("#offerings li").click(function() {
			$("#queryselect a").removeClass("active_sel");
			$("#offerings li").removeClass("active_sel");
			$(this).addClass("active_sel");
			var text = $(this).text()
			switch (text.trim()) {
			case 'Query Browser':
				$('#querybrowser').hide();
				$('#operations').hide();
				$('#metadata').hide();
				$('#analytics').hide();
				$('#querybrowser').show();
				break;
			case 'Metadata Management':
				$('#querybrowser').hide();
				$('#analytics').hide();
				$('#operations').hide();
				$('#metadata').show();

				break;
			case 'Blockchain Analytics':
				$('#querybrowser').hide();
				$('#operations').hide();
				$('#metadata').hide();
				$('#analytics').show();
				break;
			case 'Operations':
				$('#querybrowser').hide();
				$('#metadata').hide();
				$('#analytics').hide();
				$('#operations').show();
				break;

			}

		});
	</script>


</body>
</html>
