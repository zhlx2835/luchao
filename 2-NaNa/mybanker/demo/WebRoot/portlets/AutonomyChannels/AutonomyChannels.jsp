<%@ page import="java.util.*"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="com.autonomy.utilities.*"%>
<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.portlet.constants.*"%>
<%@ page import="com.autonomy.aci.businessobjects.*"%>
<%@ page import="com.autonomy.aci.services.IDOLService"%>
<%@ page import="com.autonomy.aci.services.UserFunctionality"%>
<%@ page import="com.autonomy.aci.services.ChannelsFunctionality"%>
<%@ page import="com.autonomy.aci.exceptions.UserNotFoundException"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

String PORTLET_NAME = "Channels";
	
	// Set up services object and set on session
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// update or create the IDOL object
updateIDOLSessionAttribute(session, service);
// update or create the User object 
updateUserSessionInfo(session, service);
// update or create the list of databases available to the user
updateDatabaseSessionInfo(session, service);

// what jsp page should be included/invoked
String sMainPage = ChannelsConstants.JSP_PAGE_CAT_VIEW;

%>

<html>
	<head>
		<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>">
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	</head>
	<body STYLE="background-color:transparent">
		<table class="pContainer" width="100%">
			<tr>
				<!-- hierarchy include -->
				<td  valign="top" width="25%">
					<%@ include file="categoryTree_include.jspf" %>
				</td>
				<!-- main page include -->
				<td>
					<table>
						<tr>
							<td>
								<%@ include file="showError_include.jspf" %>
								<%@ include file="showMessage_include.jspf" %>
							</td>
						</tr>
						<tr>
							<td>
<%
								out.flush();
								pageContext.include(sMainPage);
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
private void updateIDOLSessionAttribute(HttpSession session, PortalService service) throws UnsupportedEncodingException
{
	if(session != null && service != null)
	{
		// try to retrieve Laune attribute from session
		IDOLService idol = (IDOLService)session.getAttribute(CATConstants.SESSION_ATTRIB_LAUNE);
		// if attribute does not exists, read host and port info from config and create one
		if(idol == null)
		{
			idol = service.getIDOLService();
		}
		
		// set Laune attribute on session
		if(idol != null)
		{
			session.setAttribute(CATConstants.SESSION_ATTRIB_IDOL, idol);
		}
		else
		{
			setError(session, "No IDOL service was found and one could not be created.");
		}			
	}
}
private void updateUserSessionInfo(HttpSession session, PortalService service)  throws AciException
{
	if(session != null && service != null)
	{
		// try to get user from session. if not there, read username from portal service and read this user
		// from Nore 
		User user = (User)session.getAttribute(CATConstants.SESSION_ATTRIB_USER);
		if(user == null)
		{
			// get the user functionality
			IDOLService idol = (IDOLService)session.getAttribute(CATConstants.SESSION_ATTRIB_IDOL);
			if(idol != null)
			{
				String sUsername = ((AutonomyPortalUser)service.getUser()).getName();
				try
				{
					user = idol.useUserFunctionality().getUser(sUsername);				
				}
				catch(UserNotFoundException unfe)
				{
					setError(session, "Could not read user details for user " + sUsername + " as this user does not exist on IDOLServer.");
				}
			}
			else
			{
				setError(session, "No user functionality is available.");
			}			
			// set on session or give warning that no user info could be loaded
			if(user != null)
			{
				session.setAttribute(CATConstants.SESSION_ATTRIB_USER, user);
			}			
			else
			{
				setError(session, "No user information could be read from IDOL.");
			}			
		}		
	}
}
private void updateDatabaseSessionInfo(HttpSession session, PortalService service)
{
	if(session != null && service != null)
	{
		// read permitted databases for this user and set this and user object on session
		// try to get user database list from session
		ArrayList alDatabases = (ArrayList)session.getAttribute(ChannelsConstants.SESSION_ATTRIB_DATABASE_LIST);
		if(alDatabases == null)
		{
			// not set on session already so read from user object
			User user = (User)session.getAttribute(ChannelsConstants.SESSION_ATTRIB_USER);
			if(user != null)
			{
				String sDatabasePrivilegeName = (String)service.getParameter(PortalService.CONFIG_DATABASE_PRIVILEGE);
				// look for database privilege in all privileges
				Iterator itPrivileges = user.getPrivileges().iterator();
				while(itPrivileges.hasNext())
				{
					Privilege privilege = (Privilege)itPrivileges.next();
					if(privilege.getPrivilegeName().equalsIgnoreCase(sDatabasePrivilegeName))
					{
						// found database privilege
						alDatabases = privilege.getValues();					
						// no point carrying on 
						break;
					}
				}		
			}

			// set on session
			if(alDatabases != null)
			{
				session.setAttribute(ChannelsConstants.SESSION_ATTRIB_DATABASE_LIST, alDatabases);
			}
		}
	}
}

private void setError(HttpSession session, String sErrorMess)
{
	if(session != null && StringUtils.strValid(sErrorMess))
	{
		// append any existing error message
		String sCurrentError = (String)session.getAttribute(CATConstants.SESSION_ATTRIB_ERROR_MESSAGE);
		if(StringUtils.strValid(sCurrentError))
		{
			sErrorMess = sCurrentError + "<br />" + sErrorMess;
		}
		session.setAttribute(CATConstants.SESSION_ATTRIB_ERROR_MESSAGE, sErrorMess);
	}
}
%>