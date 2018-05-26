<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css">

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

<title>Login</title>
</head>
<body>

	<div class="container-fluid" >
		<div class="row">
			<div class="col-lg-4"></div>
			<div class="col-lg-4">

				<div class="container" style="margin-top: 30%;">
					<br>
					<table class="table table-bordered"
						style="border-style: solid; border-width: 2px; border-color: #D6D1D0;background-color: #f9f9f9;">
						<thead style="background-color: #E8E8E8;">
							<tr>
								<th><center>Login</center></th>
							</tr>
						</thead>

						<tr>
							<th>

								<form class="form-signin" action="login" method="POST">
									<div id="error">
										<%
											String login_err_msg = (String)request.getAttribute("error");
											if(login_err_msg != null){
												out.println("<font color=red>"+login_err_msg+"</font>");
											}
											%>
									</div>
									</text>
									<br> <input type="text" class="form-control"
										name="username" placeholder="Username" required=""
										oninvalid="this.setCustomValidity('Please fill User Name')"
										oninput="setCustomValidity('')" autofocus="" /> <br> <input
										type="password" class="form-control" name="password"
										placeholder="Password" required=""
										oninvalid="this.setCustomValidity('Password is required')"
										oninput="setCustomValidity('')" autofocus="" /> <br>

									<button class="btn btn-sm btn-success"
										style="float: right; text-decoration: none;" type="submit">Login</button>

									<br /> <br /> <a href="signup.jsp" style="color: #e67e22"><center>New
											User? Register Here</center></a>
									<!-- <button class="btn btn-sm btn-success"
												style="float: right; text-decoration: none;" type="submit" onclick="location.href = 'signup.jsp';" >Signup</button>
 -->
								</form>


							</th>
						</tr>
					</table>
				</div>
			</div>
			<div class="col-lg-4"></div>
</body>
</html>