<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/home/admin_checkUser.jspf" %>
<%
String sUserName = request.getParameter("username");
if(sUserName != null)
{
	try
	{
		String sAdminUserName = CurrentUser.getUserName();
		CurrentUser = CurrentPortal.getUserInfo(sUserName);
		if(CurrentUser != null)
		{
			CurrentUser.setAttribute("IAmAdmin", sAdminUserName );
			Functions.f_initUser(CurrentPortal, CurrentUser, false, request.getRemoteUser(), session, request);
			response.sendRedirect("../../user/home/home.jsp");
			out.flush();
			
			return;
		}
	}
	catch(Exception e)
	{
		CurrentUser.setAttribute("message", "Could not log in as " + sUserName + ": " + e.getMessage() );
		CurrentPortal.Log("becomeUser: Could not log in as " + sUserName + ":" );
		CurrentPortal.LogThrowable( e );
	}
}
//failed to log in
//
response.sendRedirect("becomeUser.jsp" + Functions.f_requestToQueryString( request, true ) );
%>
