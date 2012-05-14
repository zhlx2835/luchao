<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "Delete Roles";
String sAdminHeader_image = "authentication32.gif";
%>

<%@ include file="/admin/header/admin_header.jspf" %>
<%
String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone") );

try
{
	boolean bDisplayRoles_incTemplateDetails = false;
	boolean bDisplayRoles_withCheckboxes = true;
	String sDisplayRoles_clickRoleCommand = "rolesFromTree=*";
	String sDisplayRoles_clickRoleHref = ""; 
	String sDisplayRoles_startRoleName = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
	String[] asDisplayRoles_checkedRoles = null; 
	
	%>
	
	
<table width="90%" cellspacing="0" cellpadding="0" border="0" align="center" >
<tr><td>
	
    <form name="remove_form" action="remove_submit.jsp" method="post" >
	<table width="60%" cellspacing="0" cellpadding="0" border="0" align="left" >
		<tr>
			<td width="100%" align="center" >
				<%@ include file="/admin/include/displayRoles_include.jspf" %>
			</td>
		</tr>
	</table>
	<table width="40%" cellspacing="0" cellpadding="0" border="0" align="right" >
		<tr>
			<td height="24"></td>
		</tr>
		<tr>
			<td colspan="1" align="left">
				<a class="textButton" title="Submit" href="javascript:remove_form.submit();">
					Submit
				</a>
			</td>
		</tr>
		<tr>
			<td width="100%" align="left" >
			<font class="adminwarning">WARNING: </font><br /></td>
		</tr>
		<tr>
			<td width="100%" align="left" >
			<font class="normal" > Clicking on Submit will permanently delete the selected roles - if you want to remove a role from another role instead, click
				<a href="editdisplay.jsp">here</a>.
			</font>
		</tr>
	</table>
    </form>
</td></tr></table>	
	<%
}
catch( Exception e)
{
	CurrentPortal.LogThrowable( e );
}
%>
<%@ include file="/admin/header/admin_footer.jspf" %>
