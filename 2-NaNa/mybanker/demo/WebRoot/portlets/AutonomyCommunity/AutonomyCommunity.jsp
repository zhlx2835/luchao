<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.aci.*" %>
<%@ page import = "com.autonomy.aci.exceptions.AciException" %>
<%@ page import = "com.autonomy.aci.exceptions.UserNotFoundException" %>
<%@ page import = "com.autonomy.aci.businessobjects.User" %>
<%@ page import = "com.autonomy.aci.services.IDOLService" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import = "com.autonomy.portlet.constants.RetrievalConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

final String PORTLET_NAME = "Community";

// Set up services object
PortalService service = ServiceFactory.getService(request, response, PORTLET_NAME);

updateUserSessionInfo(service);
User user = (User)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER);

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));
%>
<html>
<head>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>"/>
</head>
<body STYLE="background-color:transparent;">
<table width="100%" class="pContainer"><tr><td>

<%

	if(service != null)
	{
		IDOLService idol = service.getIDOLService();
		AciConnection acicUser = new AciConnection(idol.getUserConnectionDetails());

		// Get user details
		String sUsername = service.getUser().getName();

		//
		// Display community results
		//
%>
		<!-- Output header -->
		<table width="90%" cellspacing="5" class="pResultList" align="center">
			<tr class="pResultTitle">
				<td align="left" nowrap="nowrap" width="20%">
					<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
						<b><%=rb.getString("autonomyCommunity.yourAgent")%></b>
					</font>
				</td>
				<td align="left" nowrap="nowrap" width="20%">
					<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
						<b><%=rb.getString("autonomyCommunity.SimilarTo")%></b>
					</font>
				</td>
				<td align="left" nowrap="nowrap" width="20%">
					<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
						<b><%=rb.getString("autonomyCommunity.ownBy")%></b>
					</font>
				</td>
				<td align="left" nowrap="nowrap" width="40%">
					<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
						<b><%=rb.getString("autonomyCommunity.options")%></b>
					</font>
				</td>
			</tr>
			<tr>
				<td height="6">
				</td>
			</tr>
<%
			if(sUsername != null)
			{
				// read and store agent names so that later we can use this list
				// to generate unique names for cloned agents
				ArrayList alAgentNames = idol.useAgentFunctionality().getAgentNames(user);
				// put the names in a String[] so we can pass it to
				// StringUtils.makeUniqueElement later
				String[] saAgentNames = (String[])alAgentNames.toArray(new String[alAgentNames.size()]);

				// get user's community and display similar agents for each of user's agents
				// the API doesn't have a function which does this, so construct AciAction manually

				AciAction aciaCommunity = new AciAction("Community");
				aciaCommunity.setParameter(new ActionParameter("Username", sUsername));
				aciaCommunity.setParameter(new ActionParameter("Agents", true));
				aciaCommunity.setParameter(new ActionParameter("Profile", false));
				aciaCommunity.setParameter(new ActionParameter("AgentsFindProfiles", false));
				aciaCommunity.setParameter(new ActionParameter("DeferLogin", true));
				aciaCommunity.setParameter(new ActionParameter("DREPrint", "all"));

				String sError = null;
				AciResponse acirResults = null;
				try
				{
					acirResults = acicUser.aciActionExecute(aciaCommunity);
					if (acirResults != null)
					{
						if (!acirResults.checkForSuccess())
						{
							sError = acirResults.getTagValue("errordescription");
						}
					}
					else // acirResults == null
					{
						sError = rb.getString("autonomyCommunity.error.UANotFound");
					}
				}
				catch (AciException acix)
				{
					sError = acix.getMessage();
				}

				if (sError == null) // query succeeded
				{
					// find first agent structure
					AciResponse acirSingleResult = acirResults != null ? acirResults.findFirstOccurrence("autn:agent") : null;

					while(acirSingleResult != null)
					{
						boolean bCommunityResult_sayNoResults = true;
						boolean bCommunityResult_textQuery = false;
%>
							<%@ include file = "communityResults_include.jspf" %>

									<tr>
										<td colspan="4">
											<table width="100%" class="seperator">
												<tr>
													<td>
													</td>
												</tr>
											</table>
										</td>
									</tr>
<%
						// move on to next current user agent
						AciResponse acirNext = acirSingleResult.next();
						acirSingleResult = acirNext != null ? acirNext.findFirstOccurrence("autn:agent") : null;
					} // while(acioSingleResult != null)
				}
				else // sError != null
				{
%>
					<font class="normal">
						<%=rb.getString("autonomy2DMap.error.internalError")%> <%= sError %><br/>
						<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
					</font>
<%
				}
			}
			else
			{
%>
				<tr>
					<td colspan="6">
						<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
							&nbsp;<%=rb.getString("autonomyCommunity.failEstablishUserDetails")%>
						</font>
					</td>
				</tr>
<%
			}
%>
		</table>
<%
	}
	else	// service == null
	{
%>
		<font class="normal">
			<%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("autonomy2DMap.error.internalError.erroMsg")%><br/>
			<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
		</font>
<%
	}
%>
<%!
private void updateUserSessionInfo(PortalService service)  throws AciException
{
	if(service != null)
	{
		// try to get user from session and check that it corresponds to the current user.
		// if not, read this user from Nore
		String sUsername = ((AutonomyPortalUser)service.getUser()).getName();
		User user = (User)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER);
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
				service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER, user);
			}
			else
			{
				setError(service, "No user information could be read from IDOL.");
			}
		}
	}
}

private void setError(PortalService service, String errorMessage)
{
	if(service != null && StringUtils.strValid(errorMessage))
	{
		// append any existing error message
		String sCurrentError = (String)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_ERROR_MESSAGE);
		if(StringUtils.strValid(sCurrentError))
		{
			errorMessage = sCurrentError + "<br />" + errorMessage;
		}
		service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_ERROR_MESSAGE, errorMessage);
	}
}
%>
</td></tr></table>
</body>
</html>