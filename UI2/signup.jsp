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
<title>User Registration</title>
</head>
<body>
	<div class="container-fluid">
		<div class="row">
			<div class="col-lg-4"></div>
			<div class="col-lg-4">
				<div class="container"
					style="margin-top: 30%">
					<br>
					<table class="table table-bordered"
						style="border-style: solid; border-width: 2px; border-color: #D6D1D0; background-color: #f9f9f9;">
						<thead style="background-color: #E8E8E8;">
							<tr>
								<th><center>Register</center></th>
							</tr>
						</thead>

						<tr>
							<th>

								<form class="form-signin" action="signup" method="POST"
									name="newUserRegistration">
									<!-- <text class="form-control" id="sel3"
												name="UserName"
												style="background-color: #f9f9f9;">												
											</text> -->

									<div id="signupErrorMsg">
										<center>
											<%
												String errorMsg = (String) request.getAttribute("signupError");
												if (errorMsg != null) {
													out.println("<font color=red>" + errorMsg + "</font>");
												}
											%>
										</center>
									</div>
									<br /> <input type="text" class="form-control"
										onblur="checkUserNameExist()" name="username"
										placeholder="Username" required="" autofocus="true"
										oninvalid="this.setCustomValidity('Please provide Username')"
										oninput="setCustomValidity('')" /><span id="isUserExist"></span>
									<br> <input type="password" class="form-control"
										id="password" name="password"
										oninvalid="this.setCustomValidity('Password is required')"
										oninput="setCustomValidity('')" placeholder="Password"
										required="" autofocus="" /> <br> <input type="password"
										class="form-control" id="confirmPassword"
										name="confirmPassword" placeholder="Confirm Password"
										required="" autofocus="" /> <br>

									<button class="btn btn-sm btn-success"
										style="float: left; text-decoration: none;" type="button"
										id="backBtn" onclick="window.location.href='login.jsp'">Back</button>
									<!-- <a href="login.jsp" style="color:#e67e22" ><left>Back to Login Page</left></a> -->
									<button class="btn btn-sm btn-success"
										style="float: right; text-decoration: none;" type="submit"
										id="registerBtn">Register</button>

								</form>


							</th>
						</tr>
					</table>
				</div>
			</div>
			<div class="col-lg-4"></div>

			<script type="text/javascript">
				var password = document.getElementById("password"), confirmPassword = document
						.getElementById("confirmPassword");

				function validatePassword() {
					if (password.value != confirmPassword.value) {
						confirmPassword
								.setCustomValidity("Passwords Don't Match");
					} else {
						confirmPassword.setCustomValidity('');
					}
				}

				password.onchange = validatePassword;
				confirmPassword.onkeyup = validatePassword;

				function checkUserNameExist() {

					var xmlhttp = new XMLHttpRequest();
					var username = document.forms["newUserRegistration"]["username"].value;
					if (username.trim() != "") {
						var url = "checkUserExists.jsp?username=" + username;
						xmlhttp.onreadystatechange = function() {
							if (xmlhttp.readyState == 4
									&& xmlhttp.status == 200) {

								if (xmlhttp.responseText.indexOf("exists") !== -1) {
									document.getElementById("isUserExist").style.color = "red";
									//document.getElementById("registerBtn").disabled = true;
								} else {
									document.getElementById("isUserExist").style.color = "green";
									//document.getElementById("registerBtn").disabled = false;
								}
								document.getElementById("isUserExist").innerHTML = xmlhttp.responseText;
							}

						};
						try {
							xmlhttp.open("GET", url, true);
							xmlhttp.send();
						} catch (e) {
							alert("unable to connect to server");
						}
					}
				}
			</script>
</body>
</html>