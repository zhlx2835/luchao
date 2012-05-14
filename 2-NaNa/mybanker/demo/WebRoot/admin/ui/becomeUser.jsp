<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sAdminHeader_title = "Log in as other user";
String sAdminHeader_image = "interface32.gif";
%>

<%@ include file="/admin/header/admin_header.jspf" %>
<%

String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone") );
String[] asParents = request.getParameterValues( "rolesFromTree" );
try
{
	%>
	<table width="40%" cellspacing="0" cellpadding="0" border="0" align="left" >
	<tr><td>
	<%
	boolean bDisplayRoles_incTemplateDetails = false;
	boolean bDisplayRoles_withCheckboxes = false;
	String sDisplayRoles_clickRoleCommand = "rolename=*";
	String sDisplayRoles_clickRoleHref = "becomeUser.jsp";
	String sDisplayRoles_startRoleName = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
	String[] asDisplayRoles_checkedRoles = null;
	{
		%>
		<%@ include file="/admin/include/displayRoles_include.jspf" %>
		<%
	}
	%>
	</td></tr>

	</table>
	&nbsp;&nbsp;
	<table width="60%" cellspacing="0" cellpadding="0" border="0" align="right" >
	<tr><td>
	<%
	boolean bDisplayUsers_withCheckboxes = false;
	String sDisplayUsers_listUsersCommand = "add";
	String sDisplayUsers_clickUserCommand = "username=*";
	String sDisplayUsers_noUsersErrorMessage = "There are no users to display";
	String sDisplayUsers_currentRole = sRoleName;
	String sDisplayUsers_listUserHref = "becomeUser.jsp";
	String sDisplayUsers_clickUserHref = "becomeUser_submit.jsp";
	String sDisplayUsers_templateUserName = "";
	String[] asDisplayUsers_checkedUsers = request.getParameterValues("user");
	String sDisplayUsers_formName = "";
	{
		%>
		<%@ include file="/admin/include/displayUsers_include.jspf" %>
		<%
	}
	%>
	</td></tr>
	</table>
	<%
}
catch( Exception e)
{
	CurrentPortal.LogThrowable( e );
}
%>
<%@ include file="/admin/header/admin_footer.jspf" %>
