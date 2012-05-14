<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.aci.businessobjects.Agent" %>
<%@ page import = "com.autonomy.aci.exceptions.*" %>
<%@ page import = "com.autonomy.aci.ActionParameter" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

//
// Retrieve form parameters
//
String sEncodedUsername		= HTMLUtils.safeRequestGet(request, "username", "");
String sAgentOwner  		= request.getParameter("agentowner");
String sAgentName  			= request.getParameter("agentname");

String sUsername	= StringUtils.decryptString(sEncodedUsername);

StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

// Create agent and query parameter objects for getAgentResults call
Agent agentToQuery = new Agent();
agentToQuery.setAgentname(sAgentName);
agentToQuery.setOwnername(sAgentOwner);

ArrayList alAgentResultParams = new ArrayList();
alAgentResultParams.add(new ActionParameter("ViewingUsername", sUsername));
alAgentResultParams.add(new ActionParameter("DREOutputEncoding", "utf8"));
alAgentResultParams.add(new ActionParameter("DREAnyLanguage", (String)service.getParameter("ResultsInAnyLanguage")));

boolean bSuccess = false;
boolean bGotResults = false;
ResultList rlAgentResults = null;

try
{
	rlAgentResults = service.getIDOLService().useAgentFunctionality().getAgentResults(agentToQuery, alAgentResultParams);
}
catch (AciException e)
{
	// bSuccess = false
}

if (rlAgentResults != null)
{
	bGotResults = rlAgentResults.getDocumentCount() > 0;
}

// set up parameters for displayResultList_include.jsp
ResultListDisplayOptions displayOptions = new ResultListDisplayOptions();
displayOptions.setShowingNoResults(false);
displayOptions.setShowingCheckboxes(false);
displayOptions.setShowingWeight(false);
displayOptions.setShowingSummary(true);
displayOptions.setShowingIcons(false);
displayOptions.setShowingContentOptions(true);
displayOptions.setShowingTitle(true);
displayOptions.setShowingAgentLink(true);
displayOptions.setShowingEmailLink(true);
displayOptions.setShowingSimilar(true);
displayOptions.setRecyclingWindows(true);
// boolean bUsingService						= false;
String numResults = "6";
String threshold = "25";
String imageURL = service.makeLink("AutonomyImages");
%>
<!-- Output header -->
<html>
<head>
	<title> Autonomy Agent Results</title>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="<%=imageURL%>/autonomyportlet.css">
	<link rel="stylesheet" type="text/css" href="<%=imageURL%>/portalinabox.css">
</head>
<body>
	<table class="pResultList" width="100%" border="0" cellpadding="1">
		<tr><td height="10"></td></tr>
		<tr>
			<td colspan="3">
				<font class="normalbold">
					<%=rb.getString("showAgent.results")%> <%= StringUtils.XMLEscape(sAgentName) %>
				</font>
			</td>
		</tr>
		<tr><td colspan="3" height="6"></td></tr>
<%
		// output display
		if(bGotResults)
		{
			ResultList resultList = rlAgentResults;
			String username = sUsername;
%>
			<%@ include file="displayResultList_include.jspf" %>
<%
		}
		else if(bSuccess)
		{
			// if agent succesfully read but no hits
%>
			<tr>
				<td></td>
				<td>
					<font class="normal">
						<%=rb.getString("showAgent.noResults")%>
					</font>
				</td>
			</tr>
<%
		}
		else
		{
%>
			<tr>
				<td></td>
				<td>
					<font class="normal">
						<%=rb.getString("showAgent.unableReadAgent")%>
					</font>
				</td>
			</tr>
<%
		}
%>
	</table>
</body>
</html>
