<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//
//Opens the login pane as a system pane and goes home
//
%>
<%@ include file = "/user/home/CheckUser.jspf" %>
<%
CurrentPortal.LogFull("login: Opening Login pane");
CurrentPage.makeSystemPortlet("login");
//
//Save the value in the users session, but not to disk
//
response.sendRedirect(request.getContextPath() + "/user/home/home.jsp");

%>
