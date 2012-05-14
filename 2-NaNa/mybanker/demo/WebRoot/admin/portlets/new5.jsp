<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Completed";
String sAdminHeader_image = "modules32.gif";
//
//Get portlet name
//
String sPortletName = request.getParameter("pane");
if(!StringUtils.strValid(sPortletName))
{
	response.sendRedirect(request.getContextPath() + "/admin/home/home.jsp");
	return;
}
%>
<%@ include file="/admin/header/admin_header.jspf" %>

<%
boolean bUpdatedRoles = true;
try
{
	//
	//Give user privilege to see this portlet
	//
	SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
	CurrentRoles.addPrivilegeToRole("panes_viewable", sPortletName, CurrentSecurity.getKeyByName("AdminRole"));
	CurrentRoles.addPrivilegeToRole("panes_editable", sPortletName, CurrentSecurity.getKeyByName("AdminRole"));
	CurrentRoles.addPrivilegeToRole("panes_selectable", sPortletName, CurrentSecurity.getKeyByName("AdminRole"));
}
catch(Exception e)
{
	CurrentPortal.Log("new5:  Could not give administrator new privilege for pane - " + e.toString() );
	bUpdatedRoles = false;
}


%>
<table width="600" border="0" <%=Functions.f_getTableCenter(session)%>>
<tr><td>
<%
String sAction = request.getParameter("action");
if(sAction == null)
	sAction = "";
%>
<p><font class="normalbold" >The portlet has been added to the active list
<%
if(bUpdatedRoles)
{
	%>
	and you have been given permission to view and edit it.</p>
	<%
}
else
{
	%>
	but I could not give you permission to view and edit it.</p>
	<%
}
%>
<p><font class="normal" >You still need to give any users (who need it) privilege to view this portlet.</p>

<p><font class="normal" >This you can do by going to the main portal site and selecting this portlet from the portlet layout section.</p>

<p><font class="normal" >Click on a menu option to continue. <br /><br /><br />
</td></tr>
</table>
<%@ include file="/admin/header/admin_footer.jspf" %>
