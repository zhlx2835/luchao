<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.Iterator" %>
<%@ page import = "java.util.Locale"%>
<%@ page import = "java.util.ResourceBundle"%>
<%@ page import = "com.autonomy.aci.AciResponse" %>
<%@ page import = "com.autonomy.aci.ActionParameter" %>
<%@ page import = "com.autonomy.aci.businessobjects.ResultDocument" %>
<%@ page import = "com.autonomy.aci.businessobjects.ResultList" %>
<%@ page import = "com.autonomy.aci.services.ConceptRetrievalFunctionality" %>
<%@ page import = "com.autonomy.utilities.HTTPUtils" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>
<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.StandaloneService" %>
<%@ page import = "com.autonomy.APSL.ServiceFactory" %>
<%@ page import = "com.autonomy.portlet.PortletUtils" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import="com.autonomy.portal4.ConfigNotReadException" %>
<%@ page import="com.autonomy.portal4.UserInfo" %>
<%@ page import="com.autonomy.portal4.PortalDistributor" %>
<%@ page import="com.autonomy.portal4.PortalInfo" %>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));
%>

<%
StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

String refCharacterEncoding = service.readConfigParameter(CommonConstants.REFERENCE_ENCODING, CommonConstants.DEFAULT_REF_ENCODING );

// *** get form data
String encodedUsername = service.getSafeRequestParameter("username", "");
String command = service.getSafeRequestParameter("command", "getcontent");
String url = service.getSafeRequestParameter("url", "");
String refEncoding = service.getSafeRequestParameter("refencoding", "");
String sID = service.getSafeRequestParameter("id", "");
String links = service.getSafeRequestParameter("links", "");

String username = StringUtils.decryptString(encodedUsername);
String secString = PortletUtils.getUserSecurityString(service.getUAServer(), username);

String displayTitle = "";
String displayContent = "";

// prepare list (of one) of documents
ResultDocument getContentDoc = new ResultDocument(url);
getContentDoc.setReferenceEncoding(refEncoding);
getContentDoc.setDocID(sID);
ArrayList getContentDocs = new ArrayList();
getContentDocs.add(getContentDoc);

// parameters common to all types of getcontent
ArrayList getContentParams = new ArrayList();
getContentParams.add(new ActionParameter("SecurityInfo", secString));
getContentParams.add(new ActionParameter("OutputEncoding", "utf8"));

ConceptRetrievalFunctionality retrievalFun = service.getIDOLService().useConceptRetrievalFunctionality();

if(command.equals("gethighlights"))
{
	getContentParams.add(new ActionParameter("Highlight", "terms"));
	getContentParams.add(new ActionParameter("Links", links));
	getContentParams.add(new ActionParameter("StartTag", "<AUTN_HIGH>"));
    getContentParams.add(new ActionParameter("LanguageType", "genericUTF8"));

	ResultList result = retrievalFun.getContent(getContentDocs, getContentParams);

	if(result.getDocumentCount() != 0)
	{
		ArrayList documents = result.getDocuments();

		// read title from first document
		displayTitle = ((ResultDocument)documents.get(0)).getTitle();
		// escape everything and then replace the escaped HTML colour title tags with unescaped ones
		// so they are picked up as html tags, not content
		displayTitle = StringUtils.XMLEscape(displayTitle);
		displayTitle = StringUtils.stringReplace(displayTitle, "&lt;AUTN_HIGH&gt;", "<font color='red'>");
		displayTitle = StringUtils.stringReplace(displayTitle, "&lt;/AUTN_HIGH&gt;", "</font>");

		// concatenate all the sections of the document into the content
		StringBuffer sbContent = new StringBuffer();


				AciResponse target = result.getMetaDataField("autn:numhits");
				if(target!=null)
				{
					while(target.next()!=null)
					{
						AciResponse hit = target.next();
						AciResponse content = hit.findFirstEnclosedOccurrence("DRECONTENT");
						if(content!=null)
						{
							sbContent.append(content.getValue());
						}
						target = target.next();
					}
				}
		displayContent = StringUtils.XMLEscape(sbContent.toString());



		//Iterator docIterator = documents.iterator();
		//while(docIterator.hasNext())
		//{
		//	sbContent.append(((ResultDocument)docIterator.next()).getContentFieldValue("DRECONTENT", ""));
		//}
		// escape everything and then replace the escaped HTML colour title tags with unescaped ones
		// so they are picked up as html tags, not content
		displayContent = StringUtils.XMLEscape(sbContent.toString());
		displayContent = StringUtils.stringReplace(displayContent, "&lt;AUTN_HIGH&gt;", "<font color='red'>");
		displayContent = StringUtils.stringReplace(displayContent, "&lt;/AUTN_HIGH&gt;", "</font>");
	}
	else
	{
		displayTitle = rb.getString("getcontent.noHighlighted");
	}
}
else if(command.equals("getsummary"))
{
	getContentParams.add(new ActionParameter("Summary", "Concept"));

	ResultList result = retrievalFun.getContent(getContentDocs, getContentParams);

	if(result.getDocumentCount() != 0)
	{
		ArrayList documents = result.getDocuments();
		// read title from first document
		displayTitle = ((ResultDocument)documents.get(0)).getTitle();
		displayTitle = StringUtils.XMLEscape(displayTitle);

		// read summary from first document
		displayContent = ((ResultDocument)documents.get(0)).getSummary();
		displayContent = StringUtils.XMLEscape(displayContent);
	}
	else
	{
		displayTitle = rb.getString("getcontent.noSummary");
	}
}
else // show normal content as default
{
	ResultList result = retrievalFun.getContent(getContentDocs, getContentParams);
	//out.println("<br>entered else section.<br>");
	//out.println("<br>getContentDocs size = " + getContentDocs.size() + "<br>");
	//out.println("<br>result.getDocumentCount = " + result.getDocumentCount() + "<br>");


	if(result.getDocumentCount() != 0)
	{
		ArrayList documents = result.getDocuments();
		displayTitle = ((ResultDocument)documents.get(0)).getTitle();
		displayTitle = StringUtils.XMLEscape(displayTitle);

		StringBuffer sbContent = new StringBuffer();


		AciResponse target = result.getMetaDataField("autn:numhits");
		if(target!=null)
		{
			while(target.next()!=null)
			{
				AciResponse hit = target.next();
				AciResponse content = hit.findFirstEnclosedOccurrence("DRECONTENT");
				if(content!=null)
				{
					sbContent.append(content.getValue());
				}
				target = target.next();
			}
		}
		displayContent = StringUtils.XMLEscape(sbContent.toString());
	}
	else
	{
		displayTitle = rb.getString("getcontent.noContent");
	}
}



// create autosuggest and get various content urls
StringBuffer sbAutoSuggestURL = new StringBuffer(service.makeLink("autosuggest.jsp"));
// add request info
sbAutoSuggestURL.append("?").append(removeCommand(request.getQueryString()));

String sAutoSuggestURL =  sbAutoSuggestURL.toString();
String sGetContenturl = sAutoSuggestURL + "&command=getcontent";
String sGetHighlighturl = sAutoSuggestURL + "&command=gethighlights";
String sGetSummaryURL = sAutoSuggestURL + "&command=getsummary";

String sEncodedURL = HTTPUtils.URLEncode(url, refCharacterEncoding);
// create agent url
StringBuffer sbCreateAgentActURL = new StringBuffer(service.makeLink("createagent.jsp"));
sbCreateAgentActURL.append("?url=");
sbCreateAgentActURL.append(sEncodedURL);
sbCreateAgentActURL.append("&refencoding=");
sbCreateAgentActURL.append(refEncoding);
sbCreateAgentActURL.append("&username=");
sbCreateAgentActURL.append(encodedUsername);

// email result url
StringBuffer sbEmailResultActURL = new StringBuffer( service.makeLink("emailresult.jsp") );
sbEmailResultActURL.append("?url=");
sbEmailResultActURL.append(sEncodedURL);
sbEmailResultActURL.append("&refencoding=");
sbEmailResultActURL.append(refEncoding);
sbEmailResultActURL.append("&username=");
sbEmailResultActURL.append(encodedUsername);


String sImageURL = service.makeLink("AutonomyImages");
%>
<html>
	<head>
		<title></title>
		<meta http-equiv="pragma" content="no-cache">
		<meta http-equiv="expires" content="-1">
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
		<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/autonomyportlets.css">
		<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/portalinabox.css">
	</head>

<center>
	<font class="normalbold">
		<%= displayTitle %>
	</font>
	<a href="<%= StringUtils.XMLEscape(sGetContenturl) %>" target="_parent"
		><img src="<%=sImageURL%>/content_normal.gif" border="0" width="9" height="12" alt="Contents"
	/></a>

	<a href="<%= StringUtils.XMLEscape(sGetHighlighturl) %>" target="_parent"
		><img src="<%=sImageURL%>/content_highlighted.gif" border="0" width="9" height="12" alt="Highlights"
	/></a>

	<a href="<%= StringUtils.XMLEscape(sGetSummaryURL) %>" target="_parent"
		><img src="<%=sImageURL%>/content_summary.gif" border="0" width="9" height="12" alt="Summary"
	/></a>

<%
        if(!isDefaultUser(service))
	{
%>
	<a href="<%= StringUtils.XMLEscape(sbCreateAgentActURL.toString()) %>" target="_blank"
		><img src="<%=sImageURL%>/monitorstory.gif" border="0" alt="Create agent based on this story"
	/></a>
	<a href="<%= StringUtils.XMLEscape(sbEmailResultActURL.toString()) %>" target="_blank"
		><img alt="Email this link" src="<%= sImageURL %>/maillink2friend.gif" border="0"
	/></a>
<%
	}
%>
</center>

<table border="0" align="center" width="90%">
	<tr>
		<td>
			<font class=normal>
				<%= StringUtils.stringReplace(displayContent, "\n", "<br/>") %>
			</font>
		</td>
	</tr>
</table>

</html>

<%!
private static String removeCommand(String queryString)
{
	StringBuffer ret = new StringBuffer();
	if(StringUtils.strValid(queryString))
	{
		int nCommandStartIdx = queryString.indexOf("&command");
		if(nCommandStartIdx != -1)
		{
			int nCommandEndIdx = queryString.indexOf("&", nCommandStartIdx+1);
			if(nCommandEndIdx != -1)
			{
				ret.append(queryString.substring(0, nCommandStartIdx));
				ret.append(queryString.substring(nCommandEndIdx, queryString.length()));
			}
			else
			{
				ret.append(queryString.substring(0, nCommandStartIdx));
			}
		}
		else
		{
			ret.append(queryString);
		}
	}

	return ret.toString();
}
//Check whether the current user is the default
private boolean isDefaultUser(PortalService service)
{
	return StringUtils.isTrue((String)service.getSafeSessionAttribute(CommonConstants.SESSION_ATTRIB_ISDEFAULTUSER ,"false"));

}
%>