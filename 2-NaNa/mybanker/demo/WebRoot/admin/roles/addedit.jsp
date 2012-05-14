<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
boolean bEdit = Functions.safeRequestGet( request, "action", "add").equals("edit");
String sAdminHeader_title = bEdit ? "Move a Role" : "Add a Role";
String sAdminHeader_image = "authentication32.gif";
%>

<%@ include file="/admin/header/admin_header.jspf" %>
<%

String sRoleName = null;
if ( !bEdit )
{
	sRoleName = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
}
else
{
	sRoleName = Functions.safeRequestGet( request, "rolename", "" );
}

String[] asParents = request.getParameterValues( "rolesFromTree" );
if( asParents == null )
{
	if( bEdit )
	{
		asParents = CurrentRoles.getParentalRoleList( sRoleName, false );
	}
	else
	{
		asParents = new String[]{CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone")};
	}
}
	
boolean bDisplayRoles_incTemplateDetails 	= false;
boolean bDisplayRoles_withCheckboxes 			= true;
String  sDisplayRoles_clickRoleCommand 		= "action=add&amp;rolesFromTree=*";
String  sDisplayRoles_clickRoleHref 			= "addedit.jsp";
String  sDisplayRoles_startRoleName 			= CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
String[] asDisplayRoles_checkedRoles 			= asParents;
if( bEdit )
{
	CurrentUser.setAttribute( "parentrolesofthis", asDisplayRoles_checkedRoles );
}
else
{
	CurrentUser.removeAttribute( "parentrolesofthis" );
}
%>
<form name="addedit_form" action="addedit_submit.jsp" method="post" >
    <table width="90%" <%=Functions.f_getTableCenter( session )%> >
	<tr>
	    <td>
		<table width="50%" cellspacing="0" cellpadding="0" border="0" align="left" >
		    <tr>
			<td>
			    <%@ include file="/admin/include/displayRoles_include.jspf" %>
			</td>
		    </tr>
		</table>
		
		<table width="50%" cellspacing="0" cellpadding="0" border="0" align="right" >
		    <tr>
			<td>
			    <font class="normal" >
				Role Name:
			    </font>
			</td>
			
			<td>
<%
			if( bEdit ) 
			{
%>
			    <font class="normalbold">
				<%=sRoleName%>
			    </font>
			    <input type="hidden" name="action" value="edit" />
			    <input type="hidden" name="rolename" value="<%=sRoleName%>" />
<%
			} 
			else
			{
%>
			    <input type="hidden" name="action" value="add" />
			    <input type="text" name="rolename" value="" />
<%
			}
%>
			</td>
		    </tr>
		    <tr><td><font class="normal">&nbsp;</font></td></tr>
		    <tr>
			<td colspan="2" align="center">
			    <a class="textButton" title="Submit" href="javascript:addedit_form.submit();">
				Submit
			    </a>
			</td>
		    </tr>
		</table>
	    </td>
	</tr>
    </table>
</form>

<%@ include file="/admin/header/admin_footer.jspf" %>
