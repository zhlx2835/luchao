<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.client.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/home/CheckUser.jspf" %>

<%
//
//Opens the login pane as a system pane and goes home
//
if(!CurrentUser.isDefaultUser())
{
	CurrentPage.makeSystemPortlet("pane_layout");
	response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?pane_layout0=showLayout&pageNo=" + CurrentPage.PAGE_NUMBER);
	return;
}
response.sendRedirect(request.getContextPath() + "/user/home/home.jsp");
%>
