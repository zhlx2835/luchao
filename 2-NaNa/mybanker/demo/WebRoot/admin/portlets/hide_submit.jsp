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
AllPortlets allPortlets = CurrentPortal.getAllPortletsObject();

String sRedirectHref = Functions.safeRequestGet(request, "redirecthref", "edit.jsp");
String sPortletName = request.getParameter("pane");

if( sPortletName != null )
{
	try
	{
		if( allPortlets.readString( sPortletName, "Visibility", "visible" ).equalsIgnoreCase("hidden") )
		{
			allPortlets.setString( sPortletName, "Visibility", "visible");
		}
		else
		{
			allPortlets.setString( sPortletName, "Visibility", "hidden");
		}
		allPortlets.write();
	}
	catch( Exception e)
	{
		CurrentPortal.Log("hide_submit: Could not write pane.cfg:");
		CurrentPortal.LogThrowable( e );
	}
}

response.sendRedirect(sRedirectHref);
%>
