<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="java.sql.*"%>
<html>
<head>
<title>Query Result</title>
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
	
	<% 
String username = (String)request.getSession().getAttribute("username");
if(null == username){
	response.sendRedirect("login.jsp");
}
%>
	
</head>
<body>

	<% ResultSet result = (ResultSet) request.getAttribute("result"); 
	   int colCount = result.getMetaData().getColumnCount();
	   ResultSetMetaData metadata = result.getMetaData();%>

	<div class="container">
		<br>
		<div class="row text-center">
			<h2 class="form-signin-heading">Query Result</h2>
		</div>
		<div style="height: 500px; overflow-y: scroll">
		<table id="result-table" class="table table-striped table-bordered">
			<thead>
				<tr>
				<% for(int i = 0; i < colCount; i++){ %>
					<th><%= metadata.getColumnLabel(i) %></th>
					<% } %>
				</tr>
			</thead>

			<tbody>
				<% while(result.next()){ %>
				<tr>
				<% for(int i = 0; i < colCount; i++){ %>
					<td><%= result.getObject(i) %></td>
				<% } %>
				</tr>
				<% } %>
			</tbody>
		</table>
		</div>
	</div>
	<script>
	$(document).ready(function() {
		$('#result-table').DataTable();
	});
</script>
</body>
</html>