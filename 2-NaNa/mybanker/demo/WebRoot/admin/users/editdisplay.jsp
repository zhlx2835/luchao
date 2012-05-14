<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sAdminHeader_title = "Edit a user";
String sAdminHeader_image = "users32.gif";
%>

<%@ include file="/admin/header/admin_header.jspf" %>


<table width="40%" cellspacing="0" cellpadding="0" border="0" align="left" >
<tr><td>
<%
String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone") );

boolean bDisplayRoles_incTemplateDetails = false;
boolean bDisplayRoles_withCheckboxes = false;
String sDisplayRoles_clickRoleCommand = "rolename=*";
String sDisplayRoles_clickRoleHref = "editdisplay.jsp";
String sDisplayRoles_startRoleName = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
String[] asDisplayRoles_checkedRoles = null;
{
	%>
	<%@ include file="/admin/include/displayRoles_include.jspf" %>
	<%
}
%>
</td></tr>
<input type="hidden" name="rolename" value="<%=sRoleName%>" />
</table>
<table width="60%" cellspacing="0" cellpadding="0" border="0" align="right" >
<tr><td>
<%
{
	boolean bDisplayUsers_withCheckboxes = false;
	String sDisplayUsers_listUsersCommand = "";
	String sDisplayUsers_clickUserCommand = "action=edit&amp;username=*";
	String[] asDisplayUsers_checkedUsers = null;
	String sDisplayUsers_listUserHref = "editdisplay.jsp";
	String sDisplayUsers_noUsersErrorMessage = "There are no users to display";
	String sDisplayUsers_currentRole = sRoleName;
	String sDisplayUsers_clickUserHref = "addedit.jsp";
	String sDisplayUsers_templateUserName = "";
	String sDisplayUsers_formName = "";
	%>
	<%@ include file="/admin/include/displayUsers_include.jspf" %>
	<%
}
%>
</td></tr>
</table>
<%@ include file="/admin/header/admin_footer.jspf" %>
