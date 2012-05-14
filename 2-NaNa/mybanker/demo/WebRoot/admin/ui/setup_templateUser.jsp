<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sAdminHeader_title = "Set up Template User";
String sAdminHeader_image = "interface32.gif";
%>

<%@ include file="/admin/header/admin_header.jspf" %>
<%

String sRoleName = Functions.safeRequestGet( request, "rolename", "" );
String[] asParents = request.getParameterValues( "rolesFromTree" );
try
{
	%>

	
	<table width="50%" cellspacing="0" cellpadding="0" border="0" align="center" >
	<tr><td>
	<%
	boolean bDisplayRoles_incTemplateDetails = true;
	boolean bDisplayRoles_withCheckboxes = false;
	String sDisplayRoles_clickRoleCommand = "rolename=*&amp;action=edit";
	String sDisplayRoles_clickRoleHref = "choose_templateUser.jsp";
	String sDisplayRoles_startRoleName = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
	String[] asDisplayRoles_checkedRoles = null;
	%>
	<%@ include file="/admin/include/displayRoles_include.jspf" %>
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
