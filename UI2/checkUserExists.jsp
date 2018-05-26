<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.impetus.eth.jdbc.web.dao.DatabaseUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    try{
            if(DatabaseUtil.checkUserExists(request.getParameter("username"))){
                out.print("User already exists");
            }else{
                out.print("User name is valid");
            }
        }catch (Exception e){
            System.out.println(e);  
        }
%>