<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "Set a Role Signup Password";
String sAdminHeader_image = "authentication32.gif";
%>

<%@ include file="/admin/header/admin_header.jspf" %>
<table width="90%" cellspacing="0" cellpadding="0" border="0" <%=Functions.f_getTableCenter(session)%> >
<tr>
<td width="40%">
<%
String sPwdR = request.getParameter("pwd");
String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone") );

String errMessage = null;

if( sPwdR != null )
{
	try {
            CurrentRoles.setPrivilegeForRole("signup_password", sPwdR, sRoleName, true );
            errMessage = "";
        }
        catch (AciException ae) {
            errMessage = ae.getMessage();
        }
}

boolean bDisplayRoles_incTemplateDetails = false;
boolean bDisplayUsers_incTemplateDetails = false;
boolean bDisplayRoles_withCheckboxes = false;
String sDisplayRoles_clickRoleCommand = "rolename=*&amp;action=edit";
String sDisplayRoles_clickRoleHref = "pwd.jsp";
String sDisplayRoles_startRoleName = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
String[] asDisplayRoles_checkedRoles = null; //request.getParameterValues( "rolesFromTree" );
%>
<%@ include file="/admin/include/displayRoles_include.jspf" %>
</td>
<td width="60%" valign="top" >
<input type="hidden" name="action" value="edit" />
	<%
	String sPwd = "";
	try
	{
		sPwd = CurrentRoles.getValuesForRole( sRoleName, "signup_password", false )[0];
	}
	catch( AciException ae)
	{
            errMessage = ae.getMessage();
	}
	%>
	<table width="50%" cellspacing="0" cellpadding="0" border="0">
		<tr>
			<td>
				<form name="pwd_form" action="pwd.jsp" method="post" >
					<input type="hidden" name="rolename" value="<%=sRoleName%>" />
					Enter the signup password: <input type="text" name="pwd" value="<%=sPwd%>" />
					<a class="textButton" title="Enter" href="javascript:pwd_form.submit();">
						Enter
					</a>

				</form>
			</td>
		</tr>

		<tr>
			<td >
				<%
				if (errMessage != null && errMessage == "")
				{
					errMessage = "Password successfully changed";
				}

				if(StringUtils.strValid(errMessage)){
				%>

				<%=f_adminDisplayError(errMessage)%>
<%
				}
%>
                        </td>
		</tr>

	</table>
</td>
</tr>
</table>


<%@ include file="/admin/header/admin_footer.jspf" %>
