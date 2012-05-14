<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.Locale" %>
<%@ page import = "java.util.ResourceBundle" %>
<%@ page import = "com.autonomy.aci.ActionParameter" %>
<%@ page import = "com.autonomy.aci.businessobjects.Document" %>
<%@ page import = "com.autonomy.aci.businessobjects.ResultList" %>
<%@ page import = "com.autonomy.aci.exceptions.AciException" %>
<%@ page import = "com.autonomy.aci.exceptions.NotLicensedException" %>
<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.ServiceFactory" %>
<%@ page import = "com.autonomy.APSL.StandaloneService" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants" %>
<%@ page import = "com.autonomy.portlet.PortletUtils" %>
<%@ page import = "com.autonomy.portlet.ResultListDisplayOptions" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
// set up portlet service
StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// read those form parameter needed for building html
String url               = service.getSafeRequestParameter("url", "");
String threshold         = service.getSafeRequestParameter("threshold", "");
String numResults        = service.getSafeRequestParameter("numresult", "");
String displayParameters = service.getSafeRequestParameter("display", "");
String encryptedUsername = service.getSafeRequestParameter("username", "");
String refEncoding       = getRefEncoding(service);
String username          = StringUtils.decryptString(encryptedUsername);


// Decode the display parameters
ResultListDisplayOptions displayOptions = new ResultListDisplayOptions(displayParameters);
// won't ever want to show checkboxes in hyperlink results list
displayOptions.setShowingCheckboxes(false);
// if the user clicks on a result in the suggestions frame, the new document and further suggestions
// should be displayed in the same browser window.
displayOptions.setRecyclingWindows(true);

String mResultCheckBxs = "";

String imageURL = service.makeLink("AutonomyImages");
String cssURL = service.makeLink("AutonomyImages");
String[] saDatabaseNames = readUserDBNames(service);

ResultList resultList = null;
// get the list of similar documents
try
{
	resultList = doSuggest(service);
}
catch(NotLicensedException e)
{
	throw new Exception("You do not appear to be licensed for hyperlinking. Please disable hyperlinking in your configuration or update your license.");
}

%>
<html>
	<head>
		<title></title>
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
		<link rel="stylesheet" type="text/css" href="<%= cssURL %>/portalinabox.css">
		<link rel="stylesheet" type="text/css" href="<%= cssURL %>/autonomyportlets.css">
	</head>
	<body>
		<form name="suggestfromdatabase" action="./autosuggest_suggest.jsp">
			<input type="hidden" name="url"         value="<%= url %>" />
			<input type="hidden" name="refencoding" value="<%= refEncoding %>" />
			<input type="hidden" name="threshold"   value="<%= threshold %>" />
			<input type="hidden" name="numresult"   value="<%= numResults %>" />
			<input type="hidden" name="display"     value="<%= displayParameters %>" />
			<input type="hidden" name="username"    value="<%= encryptedUsername %>" />
			<input type="hidden" name="dbmatch"     value="" />
		</form>

		<table width="100%" border="0" cellpadding="0" >
			<tr>
				<td align="center" valign="middle" bgcolor="#DFDFDF">
					<font class="normalbold">
						<%=rb.getString("autosuggest_suggest.reading")%>
					</font>
				</td>
				<td align="right">
					<table width="100%" border="0" cellpadding="0">
						<tr>
							<td valign="bottom" align="center">
									<a href="javascript:document.suggestfromdatabase.dbmatch.value='all';document.suggestfromdatabase.submit();" title="All">
										<img src="<%= imageURL %>/all.gif" alt="All" border="0" />
										<br/>
										<%=rb.getString("autosuggest_suggest.all")%>
									</a>
								&nbsp;
							</td>
<%
							for(int nDBIdx = 0; nDBIdx < saDatabaseNames.length; nDBIdx++)
							{
								StringBuffer sbDBImageURL = new StringBuffer(imageURL);
								if(databaseImageExists(saDatabaseNames[nDBIdx], application) )
								{
									sbDBImageURL.append("/").append(saDatabaseNames[nDBIdx]).append(".gif");
								}
								else
								{
									sbDBImageURL.append("/unknowndb.gif");
								}
%>
								<td valign="bottom" align="center"  class="normal">
									<a href="javascript:document.suggestfromdatabase.dbmatch.value='<%= saDatabaseNames[nDBIdx] %>';document.suggestfromdatabase.submit();" title="<%= saDatabaseNames[nDBIdx] %>">
										<img src="<%= sbDBImageURL.toString() %>" alt="<%= saDatabaseNames[nDBIdx] %>" border="0" />
										<br/>
										<%= saDatabaseNames[nDBIdx] %>
									</a>
									&nbsp;
								</td>
<%
							}
%>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<table>
			<%@ include file = "displayResultList_include.jspf" %>
		</table>
	</body>
</html>


<%!
private String[] readUserDBNames(PortalService service)
{
	// databases that this user is allowed to access
	return PortletUtils.getDatabaseList(service.getUAServer(),
																			StringUtils.decryptString(service.getSafeRequestParameter("username", 	"")),
																			service.readConfigParameter("DatabasePrivilegeName", "Databases"));

}
private ResultList doSuggest(PortalService service) throws AciException
{
	// read form data
	String threshold = service.getSafeRequestParameter("threshold", "");
	String numResults = service.getSafeRequestParameter("numresult", "");
	String sDBMatch	= service.getSafeRequestParameter("dbmatch", "all");
	String sEncryptedUsername = service.getSafeRequestParameter("username", "");
	String url = service.getSafeRequestParameter("url", "");
	String refEncoding = getRefEncoding(service);
	String sID = service.getSafeRequestParameter("id", "");

	String sSecString = PortletUtils.getUserSecurityString(service.getUAServer(),
	StringUtils.decryptString(sEncryptedUsername));

	// prepare suggest doc - must set the reference encoding as read from the document entry
	// for the URL encoding to work
	ResultDocument suggestDoc = new ResultDocument(url);
	suggestDoc.setReferenceEncoding(refEncoding);
	suggestDoc.setDocID(sID);
	ArrayList suggestDocs = new ArrayList();
	suggestDocs.add(suggestDoc);
	// suggest parameters
	ArrayList alSuggestParams = new ArrayList();
	alSuggestParams.add(new ActionParameter("MinScore", threshold));
	alSuggestParams.add(new ActionParameter("MaxResults", numResults));
	alSuggestParams.add(new ActionParameter("SecurityInfo",	sSecString));
	alSuggestParams.add(new ActionParameter("DatabaseMatch", formDBMatchString(sDBMatch, readUserDBNames(service))));
	alSuggestParams.add(new ActionParameter("Summary", "context"));
	alSuggestParams.add(new ActionParameter("print", "all"));
	alSuggestParams.add(new ActionParameter("OutputEncoding", "utf8"));
	alSuggestParams.add(new ActionParameter("Combine", "Simple"));

	// execute suggest
	return service.getIDOLService().useHyperlinkingFunctionality().doSuggest(suggestDocs, alSuggestParams);
}
private String formDBMatchString(String sDBMatch, String[] saDatabaseNames)
{
	String sDatabaseMatch = "";
	// if a database match is given, the suggest results are being filtered using a particular database
	if(!sDBMatch.equals("all"))
	{
		sDatabaseMatch = sDBMatch;
	}
	else
	{
		// use all the databases the user has access to (set via roles in IDOL)
		// (otherwise, if no databasematch is given or if it is empty, ALL databases are used)
		sDatabaseMatch = StringUtils.combine(saDatabaseNames, "+");
	}
	return sDatabaseMatch;
}
private boolean databaseImageExists(String sDatabaseName, ServletContext application)
{
	// see if a file corresponding to the extension exists - the path to the image files depends on where this file
	// has been included.
	boolean bImageExists = false;

	if(StringUtils.strValid(sDatabaseName))
	{
		String sFilePath = new StringBuffer("/portlets/AutonomyImages/")
									  .append(sDatabaseName)
									  .append(".gif")
							 .toString();

		// work out URL to image file
		bImageExists = new File(application.getRealPath(sFilePath)).exists();
	}

	return bImageExists;
}
private String getRefEncoding(PortalService service)
{
	// attempt to get reference encoding from URL
	String refEncoding = service.getSafeRequestParameter("refencoding", "");
	// if empty string (ie was null or empty string) get from config file
	if(refEncoding.equals(""))
	{
		refEncoding = service.readConfigParameter(CommonConstants.REFERENCE_ENCODING, CommonConstants.DEFAULT_REF_ENCODING );
	}
	return refEncoding;
}
%>
