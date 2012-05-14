<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAction = request.getParameter( "action" );
if( sAction != null )
	session.setAttribute( "roleuseraction", sAction );
	
sAction = (String) HTMLUtils.safeSessionGet( session, "roleuseraction", "add" );

boolean bAdd = sAction.equals("add");
String sAdminHeader_title = bAdd ? "Add Users to Roles" : "Remove Users From Roles";
String sAdminHeader_image = "authentication32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%

String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone") );
String[] asParents = request.getParameterValues( "rolesFromTree" );
try
{
	%>
	<form name="users_form" action="users_submit.jsp" method="post" >
	<input type="hidden" name="startNo" value="<%=Functions.safeRequestGet(request, "startNo", "0")%>" />
	<input type="hidden" name="startLetter" value="<%=Functions.safeRequestGet(request, "startLetter", "A")%>" />
	<table width="40%" cellspacing="0" cellpadding="0" border="0" align="left" >
	<tr><td>
	<%
	boolean bDisplayRoles_incTemplateDetails = false;
	boolean bDisplayRoles_withCheckboxes = true;
	String sDisplayRoles_clickRoleCommand = "rolename=*&amp;action=" + sAction;
	String sDisplayRoles_clickRoleHref = "users.jsp";
	String sDisplayRoles_startRoleName = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
	String[] asDisplayRoles_checkedRoles = request.getParameterValues("rolesFromTree");
	{
		%>
		<%@ include file="/admin/include/displayRoles_include.jspf" %>
		<%
	}
	%>
	</td></tr>
	</table>

	<table width="60%" cellspacing="0" cellpadding="0" border="0" align="right" >
	<tr><td>
	<%
	if( bAdd )
	{
		%><input type="hidden" name="action" value="add" /><%
	}
	else
	{
		%><input type="hidden" name="action" value="remove" /><%
	}
	
	boolean bDisplayUsers_withCheckboxes = true;
	String sDisplayUsers_listUsersCommand = sAction;
	String sDisplayUsers_clickUserCommand = "action=edit&amp;username=*";
	String sDisplayUsers_noUsersErrorMessage = "There are no users to display";
	String sDisplayUsers_currentRole = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
	String sDisplayUsers_listUserHref = "users.jsp";
	String sDisplayUsers_clickUserHref = "../users/addedit.jsp";
	String sDisplayUsers_templateUserName = "";
	String[] asDisplayUsers_checkedUsers = request.getParameterValues("username");
	String sDisplayUsers_formName = "users_form";
	{
		%>
		<%@ include file="/admin/include/displayUsers_include.jspf" %>
		<%
	}
	%>
	</td></tr>

        <tr><td><font class="normal">&nbsp;</font></td></tr>
	<tr>
		<td colspan="2" align="center">
			<a class="textButton" title="Submit" href="javascript:users_form.submit();">
				Submit
			</a>
			&nbsp;
			<%=f_admin_displayCancelButton()%>
		</td>
	</tr>
	</table>
	</form>
	
	<%
}
catch( Exception e)
{
	CurrentPortal.LogThrowable( e );
}
%>
<%@ include file="/admin/header/admin_footer.jspf" %>
