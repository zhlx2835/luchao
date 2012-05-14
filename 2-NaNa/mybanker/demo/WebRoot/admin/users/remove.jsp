<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sAdminHeader_title = "Delete a user";
String sAdminHeader_image = "users32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone") );

boolean bDisplayRoles_incTemplateDetails 	= false;
boolean bDisplayRoles_withCheckboxes 			= false;
String  sDisplayRoles_clickRoleCommand 		= "rolename=*";
String  sDisplayRoles_clickRoleHref 			= "remove.jsp";
String  sDisplayRoles_startRoleName 			= CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
String[] asDisplayRoles_checkedRoles 			= null;
%>

<form name="userdeleteForm" action="remove_submit.jsp" method="post" >
	<input type="hidden" name="rolename" value="<%=sRoleName%>" />
	<table width="100%" cellspacing="0" cellpadding="0" border="0" align="center" >
		<tr>
			<td width="40%" valign="top" >

				<%@ include file="/admin/include/displayRoles_include.jspf" %>

			</td>
			<td width="60%" valign="top">
<%
				{
					boolean bDisplayUsers_withCheckboxes = true;
					String sDisplayUsers_listUsersCommand = "";
					String sDisplayUsers_clickUserCommand = "action=edit&amp;username=*&amp;rolename=" + sRoleName;
					String[] asDisplayUsers_checkedUsers = null;

					String sDisplayUsers_noUsersErrorMessage = "There are no users to display";
					String sDisplayUsers_currentRole = sRoleName;
					String sDisplayUsers_listUserHref = "remove.jsp";
					String sDisplayUsers_clickUserHref = "remove_submit.jsp";
					String sDisplayUsers_templateUserName = "";
					String sDisplayUsers_formName = "userdeleteForm";
%>
					<%@ include file="/admin/include/displayUsers_include.jspf" %>
<%
				}
%>
			</td>
		</tr>
		<tr>
			<td></td>
			<td align="right">
				<a class="textButton" title="Submit" href="javascript:userdeleteForm.submit();">
					Submit
				</a>
			</td>
		</tr>
	</table>
	<br />
</form>

<%@ include file="/admin/header/admin_footer.jspf" %>
