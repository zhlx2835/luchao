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
try
{
	RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
	SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
	//
	//validate
	//

	String[] asRoles = request.getParameterValues("rolesFromTree");
	String[] asUsers = request.getParameterValues("username");

	String sRedirectHref = "users.jsp";
	String sMessage = "";
	boolean bWasError = false;
	boolean bAddUser = Functions.safeRequestGet( request, "action", "remove").equals("add");
	String sBaseRole = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");

	if( asRoles == null )
	{
		sMessage = "You must select at least one role";
		bWasError = true;
	}

	if( asUsers == null )
	{
		sMessage = "You must select at least one user ";
		bWasError = true;
	}

	if( !bWasError )
	{
		//
		//Loop through each role and add / remove each user
		//
		int nNumUsers = 0;
		int nNumRoles = 0;

		errorLabel:
		for(int i = 0; i < asUsers.length; i++)
		{
			String sCurrentUser = asUsers[i];

			if( !StringUtils.strValid( sCurrentUser ) )
			{
				continue;
			}

			nNumUsers++;
			nNumRoles = 0;

			if(asRoles == null) asRoles = new String[]{};

			Enumeration eRoles = StringUtils.deduplicate( asRoles );
			for(; eRoles.hasMoreElements() ;)
			{
				String sThisRole = (String) eRoles.nextElement();
				nNumRoles++;

				try
				{
					if(bAddUser)
					{
						CurrentRoles.addUserToRole(asUsers[i], sThisRole);
					}
					else
					{
						//An admin user using this functionality should not be able to self-remove from the
						//PORTALADMIN role
						//
						if(CurrentUser.getUserName().equals(sCurrentUser) && sThisRole.equals(CurrentPortal.getSecurityObject().getKeyByName("AdminRole")) )
						{
							sMessage = "You cannot remove yourself from the admin role - only a replacement administrator can remove you from this role<br />";
							nNumRoles--;
							nNumUsers--;
						}
						else
						{
							if( !sThisRole.equals(CurrentSecurity.getKeyByName("BaseRole", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone"))) )
							{
								CurrentRoles.deleteUserFromRole(CurrentPortal.getUserInfo(sCurrentUser).getUserName(), sThisRole);
							}
							else
							{
								sMessage = "You cannot erase users from the " + CurrentSecurity.getKeyByName("BaseRole", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone")) + " role<br />";
								nNumUsers--;
							}
						}
					}
				}
				catch(Exception e)
				{
					sMessage = e.getMessage();
					CurrentPortal.Log("users_submit: Could not update roles:");
					CurrentPortal.LogThrowable( e );
				}
			}//end of role count
		}//end of user count
		if(bAddUser)
		{
			sMessage = nNumUsers + " user(s) were added to " + nNumRoles + " role(s)";
		}
		else
		{
			sMessage = nNumUsers + " user(s) were removed from " + nNumRoles + " role(s)";
		}

	}
	CurrentUser.setAttribute("message", sMessage );
	response.sendRedirect( sRedirectHref + Functions.f_requestToQueryString( request, true) );
}
catch( Exception e )
{
	out.println("There was an error - see the log file for details");
	CurrentPortal.LogThrowable( e );
}
%>
