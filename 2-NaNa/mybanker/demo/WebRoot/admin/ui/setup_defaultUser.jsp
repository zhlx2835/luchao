<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/functions/admin_functions.jspf" %>
<%@ include file="/admin/home/admin_checkUser.jspf" %>
<%
//
//Log in as default user and go home
//
try
{
	String sAdminUserName = CurrentUser.getUserName();
	String sDefaultUserName = CurrentPortal.readString( CurrentPortal.ADMIN_SECTION, "DefaultSetupUser", "default_setup");
	CurrentUser = CurrentPortal.getUserInfo(sDefaultUserName);
	CurrentUser.setAttribute("IAmAdmin", sAdminUserName );
	Functions.f_initUser(CurrentPortal, CurrentUser, false, "", session, request);
	session.setAttribute(CurrentPortal.PORTAL_BACKEND_LOCATION + "CurrentUser", CurrentUser);
	session.removeAttribute("CurrentPage");
	response.sendRedirect(request.getContextPath());
}
catch(Exception e)
{
	%>
	<html>
	<head>
		<title>Portal-in-a-box</title>
		<link rel="stylesheet" type="text/css" href="../../portalinabox.css">

	</head>

	<body bgcolor="#ffffff">
		<br />
		<table align="center" width="60%" cellpadding="1" cellspacing="0" border="1">
			<tr>
				<td bgcolor="#ffffff" align="center" width="100%" ><br /><font class="normal" >Could not read default user<br /><br />
				<a href="javascript:history.back()"><font class="normal" >Please click here to go back</a>
				</td>
			</tr>
		</table>
	</body>
	<%
}
%>
