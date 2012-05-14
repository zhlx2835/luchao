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

<%@ include file="/admin/home/admin_checkUser.jspf" %>
<%
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
//
//validate
//
String sRoleName = request.getParameter("rolename");
String[] asParents = request.getParameterValues("rolesFromTree");
String sMessage = "Role Successfully added";
String sRedirectHref = "../roles/addedit.jsp";
boolean bWasError = false;
boolean bEditRole = Functions.safeRequestGet( request, "action", "true" ).equals("edit");

if( asParents == null )
{
	sMessage = "This role must be a child of at least one other";
	bWasError = true;
}

if( !bEditRole )
{
	//adding
	//
	if( !StringUtils.strValid(sRoleName)  )
	{
		sMessage = "Please give a role name";
		bWasError = true;
	}
}


if(!bWasError)
{
	//
	//Add new child to current role
	//
	try
	{
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
					CurrentRoles.addRoleToRole(sRoleName, asParents[i]);
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
	catch(Exception e)
	{
		sMessage = "Some of your changes could not be made:<br />" + e.getMessage();
		CurrentPortal.Log("roles/addedit_submit: Add/Removing role failed:");
		CurrentPortal.LogThrowable( e );
	}
}
CurrentUser.setAttribute( "message", sMessage );

response.sendRedirect( sRedirectHref + Functions.f_requestToQueryString( request, true ) );

%>
