<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.Iterator" %>
<%@ page import = "com.autonomy.aci.ActionParameter" %>
<%@ page import = "com.autonomy.aci.businessobjects.Document" %>
<%@ page import = "com.autonomy.aci.businessobjects.ResultDocument" %>
<%@ page import = "com.autonomy.aci.businessobjects.ResultList" %>
<%@ page import = "com.autonomy.aci.exceptions.AciException" %>
<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.ServiceFactory" %>
<%@ page import = "com.autonomy.APSL.StandaloneService" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>
<%@ page import = "com.autonomy.utilities.HTTPUtils" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import = "com.autonomy.portlet.PortletUtils" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
// set up portlet service
StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

String refCharacterEncoding = service.readConfigParameter(CommonConstants.REFERENCE_ENCODING, CommonConstants.DEFAULT_REF_ENCODING );

// get form data needed to produce html
String sEncodedUsername 	= service.getSafeRequestParameter("username", 	"");
String sThreshold 				= service.getSafeRequestParameter("threshold", 	"");
String sNumResults 				= service.getSafeRequestParameter("numresult", 	"");
String sDisplayParameters	= service.getSafeRequestParameter("display", 		"");

//
// get similar documents
//
ResultList resultList = doSuggest(service);

String sImageURL = service.makeLink("AutonomyImages");
%>
<html>
	<head>
		<title>
			Autonomy Similar Documents
		</title>
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
		<link rel="stylesheet" type="text/css" href="<%=sImageURL%>/autonomyportlet.css">
		<link rel="stylesheet" type="text/css" href="<%=sImageURL%>/portalinabox.css">
	</head>
	<body>
		<table class="pResultList" border="0" cellpadding="0">

<%
			if(resultList != null && resultList.getDocumentCount() > 0)
			{
				Iterator itResultDocuments = resultList.getDocuments().iterator();
				while(itResultDocuments.hasNext())
				{
					ResultDocument resultDocument = (ResultDocument)itResultDocuments.next();

					// grab info from result document
					int nRelevence 					= (int)resultDocument.getWeight();
					String sTitle 					= resultDocument.getTitle();
					String sURL 						= resultDocument.getDocReference();
					String sLinks 					= StringUtils.combine(resultDocument.getLinks(), ",");
					String sQuickSummary		= resultDocument.getContentFieldValue("SUMMARY", "");
					String sRefEncoding = resultDocument.getReferenceEncoding();
					String sID = resultDocument.getDocID();

					// build up link to the full result displaying page
					StringBuffer sbAutoSuggestLink = new StringBuffer(service.makeLink("autosuggest.jsp"));
					sbAutoSuggestLink.append("?username=");
					sbAutoSuggestLink.append(sEncodedUsername );
					sbAutoSuggestLink.append("&threshold=");
					sbAutoSuggestLink.append(sThreshold);
					sbAutoSuggestLink.append("&numresult=");
					sbAutoSuggestLink.append(sNumResults);
					sbAutoSuggestLink.append("&display=");
					sbAutoSuggestLink.append(sDisplayParameters);
					sbAutoSuggestLink.append("&url=");
					sbAutoSuggestLink.append(HTTPUtils.URLEncode(sURL, refCharacterEncoding));
					sbAutoSuggestLink.append("&refencoding=");
					sbAutoSuggestLink.append(sRefEncoding);
					sbAutoSuggestLink.append("&id=");
					sbAutoSuggestLink.append(sID);
					sbAutoSuggestLink.append("&links=");
					sbAutoSuggestLink.append(sLinks);
%>
					<tr>
						<td width="5"></td>
						<td align="left" width="30">
							<font class="normal" >
								<%=nRelevence %>%&nbsp;&nbsp;
							</font>
						</td>
						<td width="10"></td>
						<td align="left">
							<a title="<%= StringUtils.XMLEscape(sQuickSummary) %>" href="<%= StringUtils.XMLEscape(sbAutoSuggestLink.toString()) %>" class="normal" target="_blank">
								<font class="normal" >
									<b><%= sTitle %></b>&nbsp;
								</font>
							</a>
						</td>
					</tr>
					<tr><td height="6"></td></tr>
<%
				}
			}
			else
			{
%>
				<tr>
					<td>
						<font class="normal">
							No results were found.
						</font>
					</td>
				</tr>
<%
			}
%>
		</table>
	</body>
</html>

<%!
private ResultList doSuggest(PortalService service) throws AciException
{
	// read form data
	String sThreshold = service.getSafeRequestParameter("threshold", "");
	String sNumResults = service.getSafeRequestParameter("numresult", "");
	String sEncryptedUsername = service.getSafeRequestParameter("username", "");
	String sUrl = service.getSafeRequestParameter("url", "");
	String sRefEncoding = service.getSafeRequestParameter("refencoding", "");

	String sSecString = PortletUtils.getUserSecurityString(service.getUAServer(),
	StringUtils.decryptString(sEncryptedUsername));
	//
	// now do suggest
	//
	ResultDocument suggestDoc = new ResultDocument(sUrl);
	suggestDoc.setReferenceEncoding(sRefEncoding);
	ArrayList alDocRefs = new ArrayList();
	alDocRefs.add(suggestDoc);
	// suggest parameters
	ArrayList alSuggestParams = new ArrayList();
	alSuggestParams.add(new ActionParameter("MinScore",       sThreshold));
	alSuggestParams.add(new ActionParameter("MaxResults",     10));
	alSuggestParams.add(new ActionParameter("SecurityInfo",   sSecString));
	alSuggestParams.add(new ActionParameter("DatabaseMatch",  getUserDatabaseCSV(service)));
	alSuggestParams.add(new ActionParameter("Summary",        "context"));
	alSuggestParams.add(new ActionParameter("print",          "all"));
	alSuggestParams.add(new ActionParameter("OutputEncoding", "utf8"));
	alSuggestParams.add(new ActionParameter("Combine",        "Simple"));

	// execute suggest
	return service.getIDOLService().useHyperlinkingFunctionality().doSuggest(alDocRefs, alSuggestParams);
}
private String getUserDatabaseCSV(PortalService service)
{
	// databases that this user is allowed to access
	String[] saDBs =  PortletUtils.getDatabaseList(service.getUAServer(),
	                                               StringUtils.decryptString(service.getSafeRequestParameter("username", "")),
	                                               service.readConfigParameter("DatabasePrivilegeName", "Databases"));
	return StringUtils.combine(saDBs, "+");
}

%>