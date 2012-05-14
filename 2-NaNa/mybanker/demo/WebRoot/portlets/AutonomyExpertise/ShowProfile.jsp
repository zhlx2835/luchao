<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.aci.*" %>
<%@ page import = "com.autonomy.aci.exceptions.AciException" %>
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
String sProfileOwner		= HTMLUtils.safeRequestGet(request, "profileowner", "");

String sUsername 	= StringUtils.decryptString(sEncodedUsername);

StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

AciAction aciaProfile = new AciAction("ProfileGetResults");
aciaProfile.setParameter(new ActionParameter("Username", sProfileOwner));
aciaProfile.setParameter(new ActionParameter("ViewingUsername", sUsername));
aciaProfile.setParameter(new ActionParameter("ProfileDetails", true));
aciaProfile.setParameter(new ActionParameter("DREMaxResults", 5));
aciaProfile.setParameter(new ActionParameter("DREPrint", "all"));
aciaProfile.setParameter(new ActionParameter("DREOutputEncoding", "utf8"));
aciaProfile.setParameter(new ActionParameter("DREAnyLanguage", (String)service.getParameter("ResultsInAnyLanguage")));

AciConnectionDetails acicdUser = service.getIDOLService().getUserConnectionDetails();
AciConnection acicUser = new AciConnection(acicdUser.getHost(), acicdUser.getPort());

AciResponse acirProfileResults = acicUser.aciActionExecute(aciaProfile);

boolean		bSuccess		= false;
boolean 	bGotResults 	= false;

try
{
	AciResponseChecker.check(acirProfileResults);
	bSuccess = true;
	if (acirProfileResults.findFirstOccurrence("autn:hit") != null)
	{
		bGotResults = true;
	}
}
catch (AciException e)
{
	// bSuccess = false
}

// set up parameters for standardResults_include.jsp
boolean bStandardResults_sayNoResults		= false;
boolean bStandardResults_withCheckboxes		= false;
boolean bStandardResults_withImages			= true;
boolean bStandardResults_withWeight			= false;
boolean bStandardResults_withSummary 		= true;
boolean bStandardResults_withDatabase		= false;
boolean bStandardResults_withContent 		= true;
boolean bStandardResults_withHighlights		= true;
boolean bStandardResults_withTitle			= true;
boolean bStandardResults_withConceptSummary	= true;
boolean bStandardResults_withMail			= true;
boolean bStandardResults_withAgent			= true;
boolean bStandardResults_withSimilar		= true;
boolean bUsingService						= false;
String  mResultCheckBxs 					= null;
String sDefaultLogoName 					= null;
String svNumResults 						= "6";
String svThreshold  						= "25";
String contextPath = request.getContextPath();

String sImageURL = service.makeLink("AutonomyImages");
String sCSSURL = service.makeLink("AutonomyImages") + "/portalinabox.css";

// output named profile deletion form and table header
%>
<!-- Output header -->
<html>
<head>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="<%= sCSSURL %>">
	<title> Autonomy Profile Results</title>
</head>
<body>
	<table class="pResultList" width="100%" cellspacing="0">
		<tr><td height="10"></td></tr>
		<tr>
			<td colspan="3">
				<font class="normalbold">
					<%= StringUtils.XMLEscape(sProfileOwner) %><%=rb.getString("showProfile.results")%>
				</font>
			</td>
		</tr>
		<tr><td colspan="3" height="6"></td></tr>
<%
	// output display
	if(bGotResults)
	{
		// locate first result set
		AciResponse acirProfile = acirProfileResults.findFirstOccurrence("autn:profile");
		// loop through profiles, displaying profile title and list of hits for each
		while( acirProfile != null )
		{
			String sResultSetTitle = acirProfile.getTagValue("autn:namedarea", "");
			String sProfileID = acirProfile.getTagValue("autn:pid", "");
%>
			<tr >
				<td colspan="3" height="6">
				</td>
			</tr>
			<tr class="normal">
			</tr>
			<tr >
				<td colspan="3" height="3"></td>
			</tr>
<%
			// display results from this named profile
			AciResponse acirResult = acirProfile;
%>
			<%@ include file="standardResults_include.jspf" %>
<%
			// move on to next result set
			AciResponse acirNext = acirProfile.next();
			acirProfile = acirNext != null ? acirNext.findFirstOccurrence("autn:profile") : null;
		}	// while( acirProfile != null )
	}
	else if(bSuccess)
	{
		// if profile succesfully read but no hits
%>
		<tr>
			<td></td>
			<td>
				<font class="normal">
					<%=rb.getString("showProfile.noResults")%>
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
					<%=rb.getString("showProfile.unableReadProfile")%>
				</font>
			</td>
		</tr>
<%
	}
%>
	<!-- Finish off table -->
	</table>
</body>
</html>
