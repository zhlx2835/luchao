<%@ page import="java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
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
//
//validate
//
String sUserName = request.getParameter("username");
String sPassword1 = Functions.safeRequestGet( request, "password1", "");
String sPassword2 = Functions.safeRequestGet( request, "password2", "");
String sRedirectHref="addedit.jsp";

if(sUserName == null)
{
	response.sendRedirect( sRedirectHref );
	out.flush();

	return;
}

if(!sPassword1.equals(sPassword2))
{
	//Show error on pane
	CurrentUser.setAttribute("message", "Your two passwords did not match" );
	response.sendRedirect(sRedirectHref + "?action=edit&editaction=chPassword&username=" + sUserName );
	out.flush();

	return;
}

try 
{
    CurrentPortal.setPasswordFor( sUserName, null, sPassword1, CurrentUser );
    CurrentUser.setAttribute("message", "Password set successfully" );
    response.sendRedirect(sRedirectHref + "?action=edit&username=" + sUserName );
}
catch (AciException err)
{
	CurrentUser.setAttribute("message", err.getMessage() );
	response.sendRedirect(sRedirectHref + "?action=edit&editaction=chPassword&username=" + sUserName );
	out.flush();

	return;
}
catch (Exception err) 
{
    CurrentUser.setAttribute("message", "Could not contact UAServer" );
    response.sendRedirect(sRedirectHref + "?action=edit&editaction=chPassword&username=" + sUserName );
    out.flush();
    return;
}
%>
