<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/home/CheckUser.jspf" %>

<%
//
//Opens the new user pane as a system pane and goes home
//
CurrentPortal.LogFull("New_User:  Applying the New_User pane");
CurrentPage = (UserPageInfo) CurrentUser.getAttribute("CurrentPage");
CurrentPage.makeSystemPortlet("New_User");
response.sendRedirect(request.getContextPath() + "/user/home/home.jsp");
%>
