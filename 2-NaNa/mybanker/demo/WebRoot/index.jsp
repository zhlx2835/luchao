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
    <center>
    <a href="user/home/home.jsp?languageCode=en">英文</a>
    <a href="user/home/home.jsp?languageCode=zh">中文</a>
    <a href="user/home/login.jsp">登陆</a><br>
    <a href="portlets/AutonomyRetrieval/AutonomyRetrieval.jsp">智能搜索</a>
    <a href="portlets/AutonomyAgents/AutonomyAgents.jsp">个性化订阅</a>
    
    <a href="portlets/Autonomy2DMap/Autonomy2DMap.jsp">信息热点</a>
    <a href="portlets/AutonomyHotNews/AutonomyHotNews.jsp">热点新闻</a>
    <a href="portlets/AutonomyChannels/AutonomyChannels.jsp">定制分类</a>
    <a href="portlets/AutonomyCategoryAdmin/AutonomyCategoryAdmin.jsp">定制分类管理</a>
    <a href="portlets/AutonomyProfile/AutonomyProfile.jsp">个性化推送</a>
    </center>
  </body>
</html>
