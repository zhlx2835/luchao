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
if(!CurrentUser.isDefaultUser())
{
	//
	//Opens the edit details pane as a system pane and goes home
	//
	CurrentPage.makeSystemPortlet("user_edit");

	response.sendRedirect(request.getContextPath() + "/user/home/home.jsp" );
}
else
{
	CurrentPage.makeSystemPortlet("login");
	response.sendRedirect(request.getContextPath() + "/user/home/home.jsp");
}
%>
