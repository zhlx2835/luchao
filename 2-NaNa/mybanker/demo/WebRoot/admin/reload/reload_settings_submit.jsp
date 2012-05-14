<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "";
String sAdminHeader_image = "plugins32.gif";
%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ include file="/admin/header/adminhome_header.jspf" %>

<%
//
try
{
	System.out.println("Trying to initialise Portal-in-a-Box 4..");
	PortalDistributor.initialise(BACKEND_LOCATION);
	System.out.println("initialized Portal-in-a-Box 4!");
	CurrentPortal.Log("reload_settings_submit: Welcome to Autonomy Portal-in-a-box");
	System.out.println("There is a log file at " + BACKEND_LOCATION);
	%>
	<font class="normalbold">
	The portal settings have successfully been reloaded - click on a menu option to continue:
	<br /><br />
	</font>
	<%
}
catch(Exception e)
{
	System.out.println("Failed - error cause:" );
	e.printStackTrace( System.out );
	%>
	<html>
	<head>
		<title>Portal-in-a-box 4</title>
		<link rel="stylesheet" type="text/css" href="../../portalinabox.css">

	</head>

	<body bgcolor="<%=BODY_BGCOLOR%>">
		<br />
		<table align="center" width="60%" cellpadding="1" cellspacing="0" border="1">
			<tr>
				<td bgcolor="#cccccc" align="center" width="100%" ><br /><font class="normal" >An error occurred while this page was being initialized.  To find out the cause please check your portal configuration settings and your 'standard out' log<br /><br />
				<a href="../home/home.jsp"><font class="normal" >Please click here to try again</a>
				</td>
			</tr>
		</table>
	</body>
	<%
	out.flush();
	
	return;
}
%>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
