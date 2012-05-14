<%@page import = "java.util.*" %>
<%@page import = "java.net.*" %>
<%@page import = "java.io.*" %>
<%@page import = "com.autonomy.portal4.*" %>
<%@page import = "com.autonomy.utilities.*" %>
<%@page import = "com.autonomy.client.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@include file = "/user/home/CheckUser.jspf" %>
<%
//add one to the template user rev
//
try
{
	String sXFieldName = CurrentUser.getUserName() + "TEMPLATEUSERREV";
	int nTemplateUserRev = StringUtils.atoi( CurrentUser.getExtendedField(sXFieldName), 1);
	CurrentUser.setExtendedField( sXFieldName, String.valueOf(++nTemplateUserRev) );
}
catch(Exception e)
{
	CurrentPortal.Log("update_templateUser: Could not update template user revision for user " + CurrentUser.getUserName() + " - " + e.toString() );
}
response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?headmessage=" + Functions.f_URLEncode("This template user has been updated to use this configuration"));
%>
