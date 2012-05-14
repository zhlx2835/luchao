<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="com.autonomy.utilities.StringUtils"%>
<%@ page import="com.autonomy.APSL.AutonomyPortalUser"%>
<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.aci.businessobjects.*"%>
<%@ page import="com.autonomy.aci.exceptions.AciException"%>
<%@ page import="com.autonomy.aci.services.IDOLService"%>
<%@ page import="com.autonomy.aci.services.UserFunctionality"%>
<%@ page import="com.autonomy.aci.services.ConceptRetrievalFunctionality"%>
<%@ page import="com.autonomy.aci.exceptions.UserNotFoundException"%>

<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");


// Set up services 
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)AgentConstants.PORTLET_NAME);
 
// update or create the User object /* will be replaced by PortalService.getUser */
updateUserSessionInfo(service);

// is there a 'do action but don't display anything' type page? /* will be replaced by PortalService.getActionPage */
String processPage = getActionPage(service);
if(StringUtils.strValid(processPage))
{
	if(service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_PREPROCESS_FLAG) == null)
	{
		pageContext.include(processPage);
	}
	else
	{
			// flag has served its purpose so clear it
			service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_PREPROCESS_FLAG, null);
	}
}
else
{
	initialise(service);
}

%>
<html>
	<head>
		<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>">
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	</head>
	<body>
		<table class="pContainer">
			<tr>
				<!-- main page include -->
				<td>
					<table width="100%" border="0">
						<tr>
							<td colspan="2">
								<%@ include file="showError_include.jspf" %>
								<%@ include file="showMessage_include.jspf" %>
							</td>
						</tr>
						<tr>
							<td colspan="2">
<%
								out.flush();
								if(service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_SHOW_EDIT_FORM) != null)
								{
									pageContext.include("displayAgentForm.jsp");
								}
								else
								{
									pageContext.include("displayAgentList.jsp");
								}
%>
							</td>
						</tr>
						<!-- This produces a simple seperator -->
						<tr>
							<td colspan="2">
								<table width="100%" class="seperator">
									<tr><td/></tr>
								</table>
							</td>
						</tr>
						<tr>
							<td width="100%" align="left" valign="top">
<%
									out.flush();
									if(sErrorMessage != null && sErrorMessage.indexOf("already exists") != -1)
									{
										pageContext.include("newAgent.jsp");
									}
									else
									{
										pageContext.include("displayResultPages.jsp");
									}
%>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</body>
</html>

<%!
/* will be replaced by PortalService.getActionPage */
private String getActionPage(PortalService service) throws Exception
{
 	return service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE), "");
}
/* will be replaced by PortalService.getUser */
private void updateUserSessionInfo(PortalService service)  throws AciException
{
	if(service != null)
	{
		// try to get user from session and check that it corresponds to the current user. 
		// if not, read this user from Nore 
		String sUsername = ((AutonomyPortalUser)service.getUser()).getName();
		User user = (User)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_USER);
		if(user == null || !user.getUsername().equals(sUsername))
		{
			// get the user functionality
			IDOLService idol = service.getIDOLService();
			if(idol != null)
			{
				try
				{
					user = idol.useUserFunctionality().getUser(sUsername);				
				}
				catch(UserNotFoundException unfe)
				{
					setError(service, "Could not read user details for user " + sUsername + " as this user does not exist on IDOLServer.");
				}
			}
			else
			{
				setError(service, "No user functionality is available.");
			}			
			// set on session or give warning that no user info could be loaded
			if(user != null)
			{
				service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_USER, user);
			}			
			else
			{
				setError(service, "No user information could be read from IDOL.");
			}			
		}		
	}
}
/* will be a method on PortalService */
private void setError(PortalService service, String errorMessage)
{
	if(service != null && StringUtils.strValid(errorMessage))
	{
		// append any existing error message
		String sCurrentError = (String)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_ERROR_MESSAGE);
		if(StringUtils.strValid(sCurrentError))
		{
			errorMessage = sCurrentError + "<br />" + errorMessage;
		}
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_ERROR_MESSAGE, errorMessage);
	}
}

private void initialise(PortalService service)
{
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT, null);
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_CLUSTER, null);
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_AGENT_LIST, null);
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS, null);
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_QUERY_EXPANSION, null);
}

private void mylog(String s)
{
	System.out.println("AutonomyAgent.jsp: " + s);
}
%>