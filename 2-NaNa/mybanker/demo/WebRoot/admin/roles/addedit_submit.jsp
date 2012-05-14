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


<%@ include file="/admin/home/admin_checkUser.jspf" %><%
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
//
//validate
//
String sRoleName = request.getParameter("rolename");
String[] asParents = request.getParameterValues("rolesFromTree");
boolean bWasError = false;
boolean bEditRole = Functions.safeRequestGet( request, "action", "true" ).equals("edit");

String sMessage = bEditRole ? "Role successfully moved" : "Role successfully added";

// check inputs
if( asParents == null )
{
	sMessage = "You must select a parent role for the new role";
	bWasError = true;
}
if( !bEditRole )
{
	//adding
	if( !StringUtils.strValid(sRoleName)  )
	{
		sMessage = "Please enter a role name";
		bWasError = true;
	}
}

if(!bWasError)
{
	//
	//Add new child to current role
	//
	if( !bEditRole )
	{
		CurrentRoles.createRole( sRoleName );
	}
	String[] asOldRoles = (String[]) CurrentUser.getAttribute( "parentrolesofthis" );
	CurrentUser.removeAttribute( "parentrolesofthis" );

	if( asOldRoles == null ) asOldRoles = new String[]{};

	//Basically:
	//If a role appears in asParents, but not in asOldRoles, add it
	//If a role appears in asOldRoles, but not in asParents, remove it
	for(int i = 0; i < asParents.length; i++)
	{
		try
		{
			if( StringUtils.isStringInStringArray( asOldRoles, asParents[i], false ) < 0 )
			{
				CurrentRoles.addRoleToRoleWithPrivileges(sRoleName, asParents[i]);
			}
			CurrentPortal.Log("roles/addedit_submit: Child role " + sRoleName + " added to parent " + asParents[i]);
		}
		catch(Exception e2)
		{
			sMessage = "At least one role could not be added to another:<br />" + e2.getMessage() ;
			CurrentPortal.Log("roles/addedit_submit: Adding role " + sRoleName + " to " + asParents[i] + " failed:");
			CurrentPortal.LogThrowable( e2 );
		}
	}

	for(int i = 0; i < asOldRoles.length; i++)
	{
		try
		{
			if( StringUtils.isStringInStringArray( asParents, asOldRoles[i], false) < 0 )
			{
				CurrentRoles.removeRoleFromRole(sRoleName, asOldRoles[i]);
			}
			CurrentPortal.Log("roles_edit: Role " + sRoleName + " removed from parent " + asOldRoles[i]);
		}
		catch(Exception e2)
		{
			sMessage = "At least one role could not be removed from another:<br />" + e2.getMessage() ;
			CurrentPortal.Log("roles/addedit_submit: Removing role " + sRoleName + " to " + asOldRoles[i] + " failed:");
			CurrentPortal.LogThrowable( e2 );
		}
	}
}
CurrentUser.setAttribute( "message", sMessage );

response.sendRedirect( request.getContextPath() + "/admin/roles/addedit.jsp" + Functions.f_requestToQueryString( request, true ) );

%>
