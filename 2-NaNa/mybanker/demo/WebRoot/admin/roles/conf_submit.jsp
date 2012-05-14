<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*" %>
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
//Store the user security data to the portal config file
//
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
String sNewAdminRole = request.getParameter("adminRole");
String sNewBaseRole = request.getParameter("baseRole");
String sNewGuestRole = request.getParameter("guestRole");

String sAdminRole = CurrentSecurity.getKeyByName("AdminRole", "portal_admin");
String sBaseRole = CurrentSecurity.getKeyByName("BaseRole", "people");
String sGuestRole = CurrentSecurity.getKeyByName("GuestRole", "guest");
	
String sMessage = "Your changes have been saved";

if(sNewAdminRole != null)
{
	try
	{
		CurrentSecurity.setKeyByName("BaseRole", sNewBaseRole);
		sBaseRole = sNewBaseRole;

		CurrentSecurity.setKeyByName("GuestRole", sNewGuestRole);
		sGuestRole = sNewGuestRole;

		CurrentSecurity.setKeyByName("AdminRole", sNewAdminRole);

		CurrentRoles.addUserToRole(CurrentUser.getUserName(), sNewAdminRole);
		if( !sAdminRole.equals(sNewAdminRole) )
		{
			sAdminRole = sNewAdminRole;
			sMessage = "Your changes have been saved and you have been added to the " + sNewAdminRole + " role";
		}
	}
	catch(Exception e)
	{
		CurrentPortal.Log("security_admin: Could not change roles:" );
		CurrentPortal.LogThrowable( e );
		//
		//Change roles back to the old one
		//
		CurrentSecurity.setKeyByName("AdminRole", sAdminRole);
		sMessage = "The administration role could not be changed: " + StringUtils.nullToEmpty(e.getMessage()) ;
	}
}

String sDBPriv = request.getParameter("dbpriv");
if( sDBPriv != null)
{
	CurrentSecurity.setKeyByName("DatabasePrivilege", sDBPriv );
}

CurrentSecurity.save();
CurrentUser.setAttribute( "message", sMessage );
response.sendRedirect("roles_configure.jsp");
%>
