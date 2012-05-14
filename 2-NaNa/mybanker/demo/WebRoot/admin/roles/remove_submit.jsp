<%@ page import="java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>


<%@ include file="/admin/functions/admin_functions.jspf" %>
<%@ include file="/admin/home/admin_checkUser.jspf" %>

<%
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
//
//validate
//

String[] asRoles = request.getParameterValues("rolesFromTree");
String sRedirectHref = "remove.jsp";
String sMessage = null;
boolean bWasError = false;
String sBaseRole = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");

if( asRoles == null )
{
	sMessage = "You must select a role to delete";
	bWasError = true;
}

int nRolesDeleted = 0;

if( !bWasError )
{
	sMessage = null;
	try
	{
		//
		//Remove role, all its users
		//Will not allow removal of non final roles
		//
		for( Enumeration e = StringUtils.deduplicate(asRoles); e.hasMoreElements(); )
		{
			String sThisRole = (String) e.nextElement();
			//There exists roles that cannot be deleted
			//
			if( sThisRole.equals(sBaseRole) || sThisRole.equals(CurrentPortal.getSecurityObject().getKeyByName("AdminRole", "portaladmin")) || sThisRole.equals(CurrentSecurity.getKeyByName("DefaultUserRole", "guest")) )
			{
				sMessage = "You cannot delete the base role or the guest role";
			}
			else
			{
				try
				{
					CurrentRoles.deleteRole(sThisRole);
					nRolesDeleted++;
				}
				catch(Exception e2)
				{
					sMessage = "Error deleting role " + sThisRole + ":";
					CurrentPortal.Log("roles_edit: Deleting role " + sThisRole + " failed:");
					CurrentPortal.LogThrowable( e2 );
				}
			}//end of undeletable role check
		}//end of role list nullity check
	}
	catch( Exception e )
	{
		sMessage = "There was an error removing the roles" ;
		CurrentPortal.LogThrowable( e );
	}
}

if( sMessage == null )
{
	sMessage = nRolesDeleted + " " + StringUtils.pluralise("role", "roles", nRolesDeleted) + " deleted";
}
CurrentUser.setAttribute("message", sMessage );
response.sendRedirect( sRedirectHref );

%>
