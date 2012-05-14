<%@ page import="java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/home/admin_checkUser.jspf" %>
<%
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
String[] asUsers = request.getParameterValues("username");


String sMessage = null;
if( asUsers == null )
{
	sMessage = "Select at least one user to delete";
}
else if( StringUtils.isStringInStringArray( asUsers, CurrentUser.getUserName(), true ) > -1 )
{
	sMessage = "You cannot delete yourself";
}

if( sMessage == null )
{
	try
	{
		CurrentPortal.removeUsers( asUsers );
		sMessage = "The users were successfully removed";
	}
	catch( Exception e )
	{
		sMessage = "There was an error removing the users: " + e.getMessage();
		CurrentPortal.LogThrowable( e );
	}
}
CurrentUser.setAttribute("message", sMessage );
response.sendRedirect(request.getContextPath() + "/admin/users/remove.jsp" + Functions.f_requestToQueryString(request, true) );
%>
