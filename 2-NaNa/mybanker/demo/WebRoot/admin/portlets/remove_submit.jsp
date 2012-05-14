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

RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
AllPortlets allPortlets = CurrentPortal.getAllPortletsObject();

String sWhatToDo = request.getParameter("action");
String sPortletName = request.getParameter("pane");
String sRedirectHref= Functions.safeRequestGet(request, "redirecthref", "edit.jsp");

if(!StringUtils.strValid(sPortletName))
{
	response.sendRedirect("edit.jsp?action=remove");
}

if(sWhatToDo == null)
{
	response.sendRedirect(sRedirectHref);
	return;
}
if(sWhatToDo.equals("deletePortlet"))
{
	//Remove from pane list
	//
	try
	{
		allPortlets.deletePortlet(sPortletName);
		allPortlets.save();
	}
	catch(Exception e)
	{
		CurrentPortal.Log("portlets/remove_submit: Could not remove pane section from portlet.cfg for pane " + sPortletName + " from role " + sPortletName + ":" );
		CurrentPortal.LogThrowable( e );
	}
	//
	//Remove privileges
	//

	String[] saRoles = CurrentRoles.getRoleList();
	for(int i = 0; i < saRoles.length; i++)
	{
		try
		{
			CurrentRoles.removePrivilegeFromRole("panes_viewable", sPortletName, saRoles[i]);
			CurrentRoles.removePrivilegeFromRole("panes_selectable", sPortletName, saRoles[i]);
			CurrentRoles.removePrivilegeFromRole("panes_editable", sPortletName, saRoles[i]);
		}
		catch(Exception e)
		{
			CurrentPortal.Log("portlets/remove_submit: Could not remove deleted pane privilege - " + e.toString() );
		}
	}
	//
	//If user chose to do so, delete all files as well
	//
	if(request.getParameter("erase.x") != null)
	{
		//
		//The pane directory
		//
		File filePortlet = new File( application.getRealPath("/portlets/" + sPortletName) );
		FileUtils.removeWithRecurse(filePortlet);
	}
	//
	//remove the pane privilege from all users
	//
	String[] saAllRoles  = CurrentRoles.getRoleList();
	for(int i = 0; i < saAllRoles.length; i++)
	{
		try
		{
			CurrentRoles.removePrivilegeFromRole("panes_viewable", sPortletName, saAllRoles[i]);
			CurrentRoles.removePrivilegeFromRole("panes_selectable", sPortletName, saRoles[i]);
			CurrentRoles.removePrivilegeFromRole("panes_editable", sPortletName, saAllRoles[i]);
		}
		catch(Exception e)
		{
			CurrentPortal.Log("portlets/remove_submit: Could not remove pane privilege for pane " + sPortletName + " from role " + saAllRoles[i] + " - " + e.toString() );
		}
	}
	response.sendRedirect(sRedirectHref);
	return;
}
%>
