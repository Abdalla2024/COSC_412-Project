<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page language="java" import="java.sql.*" %> 
<%@ page language="java" import="java.util.*" %> 
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>


<%

String rating = request.getParameter("rating");
String movieName =request.getParameter("movieName");

out.println(rating);
out.println(movieName);

%>



</body>
</html>