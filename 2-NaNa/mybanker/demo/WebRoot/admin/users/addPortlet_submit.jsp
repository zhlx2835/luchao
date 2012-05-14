<%@ page import="java.util.*" %>
<%@ page import="com.autonomy.aci.AciConnection" %>
<%@ page import="com.autonomy.aci.AciConnectionDetails" %>
<%@ page import="com.autonomy.aci.businessobjects.Role" %>
<%@ page import="com.autonomy.aci.businessobjects.User" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
<%@ page import="com.autonomy.aci.services.IDOLService" %>
<%@ page import="com.autonomy.aci.services.UserFunctionality" %>
<%@ page import="com.autonomy.utilities.StringUtils" %>

<%@ include file="/user/include/getPortletVars_include.jspf" %>

<%
// read info from form
String newPageName = request.getParameter("pagename");
String pageStyle = request.getParameter("pagestyle");
String portletName = request.getParameter("portletName");
String roleName = request.getParameter("role");

if(StringUtils.strValid(newPageName) 	&&
	 StringUtils.strValid(pageStyle) 		&&
	 StringUtils.strValid(portletName) 	&&
	 StringUtils.strValid(roleName) 
	 )
{
	CurrentPortal.Log("Adding page " + newPageName + " (style " + pageStyle + ") with portlet " + portletName + " to all users in role " + roleName);

	// obtain UserFunctionality interface for user updates
	AciConnection aciUserConnection = CurrentPortal.getDefaultConnection();
	AciConnectionDetails userConnectionDetails = new AciConnectionDetails();
	userConnectionDetails.setHost(aciUserConnection.getAciHost());
	userConnectionDetails.setPort(aciUserConnection.getAciPort());
	UserFunctionality userFun = new IDOLService(userConnectionDetails).useUserFunctionality();

	// update each user in turn
	Iterator userNamesToUpdate = userFun.getUsernamesInRole(new Role(roleName)).iterator();
	while(userNamesToUpdate.hasNext())
	{
		User userToUpdate = userFun.getUser((String)userNamesToUpdate.next());
		try
		{
			int nNewPageIdx = addPageToPageMask(userToUpdate);
			if(nNewPageIdx != -1)
			{
				addPageFields(userToUpdate, newPageName, pageStyle, nNewPageIdx);
				addPortletFields(userToUpdate, portletName, nNewPageIdx);

				userFun.updateUser(userToUpdate);
				CurrentPortal.Log("Updated user " + userToUpdate.getUsername() + " with new page");
			}
			else
			{
					CurrentPortal.Log("Cannot update user " + userToUpdate.getUsername() + " with new page - all the user's pages are already in use.");
					CurrentUser.setAttribute( "message", "Could not add page to some users. Please see portal log for details");
			}
		}
		catch(AciException acie)
		{
			CurrentPortal.Log("User update for " + userToUpdate.getUsername() + " failed due to a server/connection error:");
			CurrentPortal.LogThrowable(acie);
			CurrentUser.setAttribute( "message", "Could not add new page to some users due to a communication error. Please see portal log for details");
		}
	}
	CurrentUser.setAttribute( "message", "New pages successfully added to all users in role " + roleName);
}
else
{
	CurrentPortal.Log("Could not add page to users as some required data is missing -");
	CurrentPortal.Log("Page name: " + newPageName);
	CurrentPortal.Log("Page style: " + pageStyle);
	CurrentPortal.Log("Portlet name: " + portletName);
	CurrentPortal.Log("Role: " + roleName);
	CurrentUser.setAttribute( "message", "Could not add page to any users as some required data is missing. Please see portal log for details");
}

response.sendRedirect( request.getContextPath() + "/admin/users/addPortlet.jsp");
%>

<%!
private int addPageToPageMask(User userToUpdate)
{
	int nNewPageIdx = -1;
	String pageMask = userToUpdate.getUserFieldValue("pagemask");
	if(StringUtils.strValid(pageMask))
	{
		int nCurrentLastPage = pageMask.lastIndexOf("1");
		if(nCurrentLastPage < pageMask.length() - 1)
		{
			nNewPageIdx = nCurrentLastPage + 1;

			char[] pageMaskArray = pageMask.toCharArray();
			pageMaskArray[nNewPageIdx] = '1';

			userToUpdate.setUserField("pagemask",  new String(pageMaskArray));
		}
	}
	return nNewPageIdx;
}

private void addPageFields(User userToUpdate, String newPageName, String newPageStyle, int nNewPageIdx)
{
	userToUpdate.setUserField("p" + nNewPageIdx + "_name", newPageName);
	userToUpdate.setUserField("p" + nNewPageIdx + "_style", newPageStyle);
}

private void addPortletFields(User userToUpdate, String portletName, int nNewPageIdx)
{
	userToUpdate.setUserField("p" + nNewPageIdx + "_1_name", portletName);
}


%>







