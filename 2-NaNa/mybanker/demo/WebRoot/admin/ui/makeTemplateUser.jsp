<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/home/admin_checkUser.jspf" %>
<%
String sUserName = request.getParameter("username");
String sRoleName = request.getParameter("rolename");
String sMessage = null;
if(sUserName != null && sRoleName != null)
{
	try
	{
		String[] asOldTemplateUsers = CurrentPortal.getRolesObject().getValuesForRole(sRoleName, "templateuser", false);
		
		UserInfo TemplateUser = CurrentPortal.getUserInfo(sUserName);
		if(TemplateUser != null)
		{
			
			if( asOldTemplateUsers != null )
			{
				for(int i = 0; i < asOldTemplateUsers.length; i++)
				{
					//For each template user (there should be only one) remove the revision extended field
					//
					try
					{
						UserInfo OldTemplateUser = CurrentPortal.getUserInfo(asOldTemplateUsers[i]);
						OldTemplateUser.deleteExtendedField(asOldTemplateUsers[i] + "TEMPLATEUSERREV" );
					}
					catch(Exception e2)
					{
						CurrentPortal.Log("Could not remove template user revision extended field from user " + asOldTemplateUsers[i] + " - " + e2.toString() );
					}
					CurrentPortal.getRolesObject().removePrivilegeFromRole("templateuser", asOldTemplateUsers[i], sRoleName);
				}
			}
			
			if( request.getParameter("tuyn") != null )
			{
				TemplateUser.setExtendedField(sUserName + "TEMPLATEUSERREV", "1");
				//
				//Set new template user privilege
				//

				CurrentPortal.getRolesObject().addPrivilegeToRole("templateuser", TemplateUser.getUserName(), sRoleName);
				sMessage = "User " + sUserName + " has successfully been set as the template user for the " + sRoleName + " role.";
			}
			else
			{
				CurrentPortal.getRolesObject().setPrivilegeAbsolute("templateuser", new String[]{}, sRoleName, false);
				CurrentPortal.getRolesObject().setPrivilegeAbsolute("templateuserrev", new String[]{}, sRoleName, false);
				TemplateUser.deleteExtendedField(sUserName + "TEMPLATEUSERREV");
				sMessage = "The user " + TemplateUser.getUserName() + " is no longer the template user for the " + sRoleName + " role.";
			}
		}
	}
	catch(Exception e)
	{
		CurrentPortal.Log("becomeUser: Could not log in as " + sUserName + " - " + e.toString() );
	}
}
if( StringUtils.strValid(sMessage) )
{
	CurrentUser.setAttribute("message", sMessage );
}
response.sendRedirect("setup_templateUser.jsp");
%>
