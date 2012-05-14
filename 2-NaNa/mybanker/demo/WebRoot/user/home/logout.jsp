<%@page import = "java.util.*" %>
<%@page import = "java.net.*" %>
<%@page import = "java.io.*" %>
<%@page import="com.autonomy.client.*" %>
<%@page import = "com.autonomy.portal4.*" %>
<%@page import = "com.autonomy.UAClient.*" %>
<%@page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
String CONTEXTPATH = request.getContextPath();
%>
<%@include file = "/user/home/CheckUser.jspf" %>
<%
//backup Locale info
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);   
   
// invalidate user's session
Functions.f_invalidateSession(session);

//reset the session locale info
session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);

// go to appropriate splash screen depending on whether user was admin or not
if( CurrentUser.getAttribute("IAmAdmin") != null )
{
	String sAdminUserName = (String) CurrentUser.getAttribute("IAmAdmin");
	CurrentPortal.LogFull("Admin User Found, is: " + sAdminUserName );
	CurrentUser = CurrentPortal.getUserInfo( sAdminUserName );
	session.setAttribute(CurrentPortal.PORTAL_BACKEND_LOCATION + "CurrentUser", CurrentUser);
	Functions.f_initUser(CurrentPortal, CurrentUser, false, "", session, request);
	response.sendRedirect(request.getContextPath() + "/admin/home/home.jsp");
	out.flush();
}
else
{
	response.sendRedirect(request.getContextPath() + "/user/home/home.jsp");
	out.flush();
}
%>