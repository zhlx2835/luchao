<%@page import = "java.util.*" %>
<%@page import = "java.net.*" %>
<%@page import = "java.io.*" %>
<%@page import = "com.autonomy.portal4.*" %>
<%@page import = "com.autonomy.client.*" %>
<%@page import = "com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@include file = "/user/home/CheckUser.jspf" %>
<%
String sDefaultUserName = CurrentPortal.readString( CurrentPortal.ADMIN_SECTION, "DefaultUserName", "default" );
String sDefaultSetupUserName = CurrentPortal.readString( CurrentPortal.ADMIN_SECTION, "DefaultSetupUser", "default_setup" );

try
{
	CurrentUser.setExtendedField("PAGE", "1");
}
catch(Exception e)
{
	CurrentPortal.Log("updateDefaultUser: Could not read the default group (Update default_setup submit) " + e.toString());
	response.sendRedirect("home.jsp?headmessage=" + Functions.f_URLEncode("Could not read this user's group!  Please re-load the page and check your configuration settings"));
}

try
{
	//overwrite default user with new settings in both UAServer and default user cfg on disk
	//
	CurrentPortal.LogFull("updateDefaultUser: copying user " + sDefaultSetupUserName  + " to " + sDefaultUserName);
	// write to UAServer
	CurrentPortal.copyUser(sDefaultSetupUserName, sDefaultUserName, true);
	// read from UAServer
	UserInfo uiDefaultUser = CurrentPortal.getDefaultUser( true );
	// write to disk
	if(CurrentPortal.updateDefaultUserConfig(uiDefaultUser))
	{
		CurrentPortal.LogFull("Default user copied.");
	}
	else
	{
		CurrentPortal.LogFull("Failed to copy default user.");
		response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?headmessage=" + Functions.f_URLEncode("Could not save your settings, please try again"));
		return;
	}
	CurrentPortal.removeAttribute("DefaultUser");
}
catch(Exception e)
{
	CurrentPortal.Log("updateDefaultUser: Could not overwrite default user with new settings - " + e.toString());
	response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?headmessage=" + Functions.f_URLEncode("Could not save your settings, please try again"));
	return;
}
response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?headmessage=" + Functions.f_URLEncode("The default user has been updated to use this configuration"));
%>
