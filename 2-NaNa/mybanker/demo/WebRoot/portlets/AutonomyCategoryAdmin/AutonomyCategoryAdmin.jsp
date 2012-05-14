<%@ page import="java.util.*"%>
<%@ page import="java.io.IOException"%>
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
%>

<%
	// Set up services object and set on session
	PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)CATConstants.PORTLET_NAME);

    //get Locale information from session
    String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
    if (sLocale==null)
    {
        sLocale = "en";
        session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
    }
    ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

	String sImageURL = service.makeLink("AutonomyImages");

	// update or create the IDOL object
	updateIDOLSessionAttribute(session, service, rb);
	// update or create the User object
	updateUserSessionInfo(session, service, rb);
	// update or create the list of databases available to the user
	updateDatabaseSessionInfo(session, service, rb);

	// what jsp page should be included/invoked
	String sMainPage = readMainPageFromRequest(request, service);

	// is jsp page a 'do action but don't display anything' type page?
	if(sMainPage.equals(CATConstants.JSP_PAGE_CAT_DELETE))
	{
%>
		<%@ include file="categoryDelete_include.jspf" %>
<%
	}
	else if(sMainPage.equals(CATConstants.JSP_PAGE_CAT_IMPORT_XML_2))
	{
%>
		<%@ include file="categoryImportXML2_include.jspf" %>
<%
	}
	else if(sMainPage.equals(CATConstants.JSP_PAGE_CAT_IMPORT_DIR_2))
	{
%>
		<%@ include file="categoryImportDir2_include.jspf" %>
<%
	}
	else if(sMainPage.equals(CATConstants.JSP_PAGE_CAT_CREATE_SUB_2))
	{
%>
		<%@ include file="categoryCreateSubCat2_include.jspf" %>
<%
	}
	else if(sMainPage.equals(CATConstants.JSP_PAGE_CAT_EDIT_3))
	{
%>
		<%@ include file="categoryEdit3_include.jspf" %>
<%
	}
	else if(sMainPage.equals(CATConstants.JSP_PAGE_CAT_EDIT_5))
	{
%>
		<%@ include file="categoryEdit5_include.jspf" %>
<%
	}
	else if(sMainPage.equals(CATConstants.JSP_PAGE_RELOAD_CATS))
	{
%>
		<%@ include file="categoryReload_include.jspf" %>
<%
	}
%>

<html>
	<head>
		<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/autonomyportlets.css">
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

<%@ page import="com.autonomy.aci.AciConnectionDetails"%>
<%!
/**
 *	Looks at content type of the request. If it is multi-part, it is assumed that the categoryEdit3_include.jsp
 *	page should be invoked. Otherwise, the page is read from the CATConstants.REQUEST_PARAM_PAGE request parameter.
 *	This is basically a hack to get around the impossibility of reading a parameter from a
 *	multi-part release using getParameter(String).
 */
private String readMainPageFromRequest(HttpServletRequest request, PortalService service) throws Exception
{
	String sMainPage = "";
	if (StringUtils.nullToEmpty(request.getHeader("Content-Type")).startsWith("multipart/form-data"))
	{
		// multi-part request from categoryEdit2.jsp so we need to go to categoryEdit3_include.jsp
		sMainPage = CATConstants.JSP_PAGE_CAT_EDIT_3;
	}
	else
	{
		sMainPage = service.getSafeRequestParameter(service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE), CATConstants.JSP_PAGE_MAIN);
	}
	return sMainPage;
}
private void updateIDOLSessionAttribute(HttpSession session, PortalService service, ResourceBundle rb) throws UnsupportedEncodingException
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
			setError(session, rb.getString("autonomyCategoryAdmin.noIDOLService"));
		}
	}
}
private void updateUserSessionInfo(HttpSession session, PortalService service, ResourceBundle rb)  throws AciException, UnsupportedEncodingException
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
					setError(session, (rb.getString("autonomyCategoryAdmin.notReadUserDetails")) + " " + sUsername + " " + (rb.getString("autonomyCategoryAdmin.userNotExist")));
				}
			}
			else
			{
				setError(session, rb.getString("autonomyCategoryAdmin.noUserFunc"));
			}
			// set on session or give warning that no user info could be loaded
			if(user != null)
			{
				session.setAttribute(CATConstants.SESSION_ATTRIB_USER, user);
			}
			else
			{
				setError(session, rb.getString("autonomyCategoryAdmin.noUserInfo"));
			}
		}
	}
}
private void updateDatabaseSessionInfo(HttpSession session, PortalService service, ResourceBundle rb) throws UnsupportedEncodingException
{
	if(session != null && service != null)
	{
		// read permitted databases for this user and set this and user object on session
		// try to get user database list from session
		ArrayList alDatabases = (ArrayList)session.getAttribute(CATConstants.SESSION_ATTRIB_DATABASE_LIST);
		if(alDatabases == null)
		{
			// not set on session already so read from user object
			User user = (User)session.getAttribute(CATConstants.SESSION_ATTRIB_USER);
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
				session.setAttribute(CATConstants.SESSION_ATTRIB_DATABASE_LIST, alDatabases);
			}

			// give warning if no databases where found
			if(alDatabases == null || alDatabases.size() == 0)
			{
				setError(session, rb.getString("autonomyCategoryAdmin.noDatabaseForUser"));
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