<%@ page import = "java.net.URLEncoder"%>
<%@ page import = "java.util.*" %>
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
String s = Functions.safeRequestGet(request, "showallPortlets", "no");
String sRedirectHref = Functions.safeRequestGet(request, "redirecthref", "edit.jsp");
if(!s.equals("no"))
{
	CurrentPortal.setString( CurrentPortal.ADMIN_SECTION, "AdminShowallPortlets", "yes");
}
else
{
	CurrentPortal.setString( CurrentPortal.ADMIN_SECTION, "AdminShowallPortlets", "no");
}
response.sendRedirect(sRedirectHref);
%>
