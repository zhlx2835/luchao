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
String sRoleName 		= request.getParameter("role");
if(sRoleName != null)
{
	RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
	String sMessage = "Your changes were saved";

	try
	{
		String[] saViewable 	= safeRequestGetParameterValues(request, "viewable");
		CurrentRoles.setPrivilegeAbsolute(RolesInfo.PRIVILEGE_PANES_VIEWABLE, saViewable, sRoleName, true);
	}
	catch(Exception e)
	{
	 	sMessage = "Failed to edit portlet viewable permission for role " + sRoleName + " - " + e.toString();
		CurrentPortal.Log("portlet admin submit: Couldn't edit portlet viewable permission for role " + sRoleName + " - " + e.toString());
	}
	try
	{
		String[] saSelectable = safeRequestGetParameterValues(request, "selectable");
		CurrentRoles.setPrivilegeAbsolute(RolesInfo.PRIVILEGE_PANES_SELECTABLE, saSelectable, sRoleName, true);
	}
	catch(Exception e)
	{
	 	sMessage = "Failed to edit portlet selectable permission for role " + sRoleName + " - " + e.toString();
		CurrentPortal.Log("portlet admin submit: Couldn't edit portlet selectable permission for role " + sRoleName + " - " + e.toString());
	}
	try
	{
		String[] saEditable 	= safeRequestGetParameterValues(request, "editable");
		CurrentRoles.setPrivilegeAbsolute(RolesInfo.PRIVILEGE_PANES_EDITABLE, saEditable, sRoleName, true);
	}
	catch(Exception e)
	{
	 	sMessage = "Failed to edit portlet editable permission for role " + sRoleName + " - " + e.toString();
		CurrentPortal.Log("portlet admin submit: Couldn't edit portlet editable permission for role " + sRoleName + " - " + e.toString());
	}

	CurrentUser.setAttribute( "message", sMessage );
	response.sendRedirect("portlets.jsp?rolename=" + Functions.f_URLEncode(sRoleName) );
	out.flush();
	return;
}
else
{
	response.sendRedirect("portlets.jsp?role=" + Functions.f_URLEncode(sRoleName) + "&message=No+role+name+given");
}
%>

<%!
private static String[] safeRequestGetParameterValues(HttpServletRequest request, String sParameterName)
{
	String[] saParamValues = null;
	if(request != null && sParameterName != null)
	{
		saParamValues = request.getParameterValues(sParameterName);
	}
	if(saParamValues == null)
	{
		saParamValues = new String[]{};
	}
	return saParamValues;
}
%>