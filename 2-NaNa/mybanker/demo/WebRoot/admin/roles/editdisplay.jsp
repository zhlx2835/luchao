<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "Move a Role";
String sAdminHeader_image = "authentication32.gif";
%>

<%@ include file="/admin/header/admin_header.jspf" %>
	<table width="90%" cellspacing="0" cellpadding="0" border="0" <%=Functions.f_getTableCenter(session)%> >
		<tr>
			<td width="40%" valign="top" >
			<%
				String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone") );

				boolean bDisplayRoles_incTemplateDetails = false;
				boolean bDisplayUsers_incTemplateDetails = false;
				boolean bDisplayRoles_withCheckboxes = false;
				String sDisplayRoles_clickRoleCommand = "rolename=*&amp;action=edit";
				String sDisplayRoles_clickRoleHref = "addedit.jsp";
				String sDisplayRoles_startRoleName = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
				String[] asDisplayRoles_checkedRoles = null; //request.getParameterValues( "rolesFromTree" );
			%>
			<%@ include file="/admin/include/displayRoles_include.jspf" %>
			</td>
				<form name="editdisplay_form" action="addedit.jsp" method="get" >
					<input type="hidden" name="action" value="edit" />
			<td width="60%" valign="top" >
				<font class="normal" >You can type a rolename here: <input type="text" name="rolename" value="" >
				<a class="textButton" title="Go" href="javascript:editdisplay_form.submit();">
					Go
				</a>
			</td>
		</tr>
	</table>


<%@ include file="/admin/header/admin_footer.jspf" %>
