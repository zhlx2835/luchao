<%@ page import = "java.net.URLEncoder"%>
<%@ page import="java.util.*" %>
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


<%@ include file="/admin/home/admin_checkPortal.jspf" %>
<%
try
{
CurrentPortal.Log("admin_login_submit: start");	
//
//Fill in session vars allowing users to log in
//
RolesInfo CurrentRoles 			= CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity 	= CurrentPortal.getSecurityObject();

String sError = "";

String sUserName = request.getParameter("username");
if( !StringUtils.strValid(sUserName, CurrentPortal.readInt( CurrentPortal.ADMIN_SECTION, "MaxUserNameLength", 256) ) )
{
	CurrentPortal.Log("admin_login_submit: No username given");
	response.sendRedirect("login.jsp");
	return;
}
else
{
	sUserName = sUserName.trim();
	String sPassword = HTMLUtils.safeRequestGet(request, "password", "").trim();
	UserInfo UserToLogIn = null;
	if(!StringUtils.strValid(sUserName))
	{
		sError = "Please give a username";
	}
	else
	{
		CurrentPortal.LogFull("admin_login_submit: Logging in to admin as " + sUserName + ".");
		
		String sAuthMethod = CurrentSecurity.getKeyByName("AdminAuthenticationMethod", null );
		
		boolean bAuthenticate = CurrentPortal.authenticate( sUserName, sPassword, null, sAuthMethod, false );

		if( !bAuthenticate )
		{
			sError = "The username / password you gave has not been recognized";
			CurrentPortal.Log("admin_login_submit: An attempt was made to log into administration by the user " + sUserName + " and the authentication failed");
		}
		else
		{
			//
			//User details read, check roles and compare passwords
			//
			if(!CurrentRoles.doesUserHaveRole(sUserName, CurrentPortal.getSecurityObject().getKeyByName( "AdminRole", "portaladmin"), true))
			{
				sError = "The username / password you gave has not been recognized";
				CurrentPortal.Log("admin_login_submit: An attempt was made to log into administration by the user " + sUserName + " who does not have permission to access the admin area");
			}		
		}
		
		if( !StringUtils.strValid( sError ) )
		{
			try
			{
			
				UserToLogIn = CurrentPortal.getUserInfo(sUserName);
				//Success - log user in
				Functions.f_initUser(CurrentPortal, UserToLogIn, false, "", session, request);
				UserToLogIn.removeAttribute( "CurrentPage" );
				session.setAttribute(CurrentPortal.PORTAL_BACKEND_LOCATION + "CurrentUser", UserToLogIn );	
			}
			catch(Exception e)
			{
				//
				//Display error
				//
				sError = "The username / password you gave has not been recognized";
				
				CurrentPortal.LogThrowable( e );
			}
		}

	}//end of empty username given check
	//
	//go home
	//
	if(sError.length() == 0)
	{
		response.sendRedirect("menuFrameset.jsp");
	}
	else
	{
		//
		//Show login pane with error
		//
		session.setAttribute( "message", sError );
		response.sendRedirect("login.jsp?action=showMessage&");
		
		return;	
	}
}//end of username validity check

}
catch(Exception e)
{
	CurrentPortal.LogThrowable( e );
}
%>
