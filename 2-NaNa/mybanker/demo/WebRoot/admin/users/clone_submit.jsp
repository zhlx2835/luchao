<%@ page import="java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/home/admin_checkUser.jspf" %>
<%
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
//
//validate
//
String sUserName = request.getParameter("username");
if( sUserName != null )
{

	String sNewUserName = null;
	sNewUserName = ("Copy of ") + sUserName;

	try
	{
		CurrentPortal.copyUser( sUserName, sNewUserName, false );
		//success
		CurrentUser.setAttribute("message", "User successfully cloned, you can now modify the new user" );
		response.sendRedirect("addedit.jsp?action=edit&username=" + URLEncoder.encode( sNewUserName ) );
		return;
	}
	catch(AciException acie)
	{
		CurrentUser.setAttribute("message", "There was an error cloning the user: " + acie.getMessage() );
		response.sendRedirect("clonedisplay.jsp" );
		return;
	}
}
%>
