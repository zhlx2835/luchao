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
//Store the user security data to the portal config file
//
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
String sMessage = "Your changes have been saved";

String sLoginMethod = request.getParameter("loginmethod");
if(sLoginMethod != null)
{
	CurrentSecurity.setKeyByName("LoginMethod", sLoginMethod);
}

String sAuthMethod = request.getParameter("authmethod");
if(sAuthMethod != null)
{
	CurrentSecurity.setKeyByName("AuthenticationMethod", sAuthMethod );
}

String sNtMethod = request.getParameter("NTMethod");
if(sNtMethod != null)
{
	CurrentSecurity.setKeyByName("NTMethod", sNtMethod );
}

CurrentSecurity.save();
CurrentUser.setAttribute( "message", sMessage );
response.sendRedirect("setup_security.jsp");
%>
