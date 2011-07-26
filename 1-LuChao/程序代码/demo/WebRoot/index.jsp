<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">
    
    <title>My JSP 'index.jsp' starting page</title>
    
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->

  </head>
  
  <body>
    <table width="100%" border="0">
    	<tr>
    		<td >
    			<iframe src="left1.jsp" width="300" height="1000px" style="border: 0"></iframe>
    		</td>
    		<td>
    			<iframe src="right1.jsp" width="900" height="600px"></iframe>
    			<iframe src="right2.jsp" width="900" height="1000px"></iframe>
    		</td>
    	</tr>
    	<tr>
    		<td>1212</td>
    		<td></td>
    	</tr>
    </table>
  </body>
</html>
