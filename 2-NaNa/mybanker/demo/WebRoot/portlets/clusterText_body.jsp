<%@ page import = "com.autonomy.client.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.util.Locale"%>
<%@ page import = "java.util.ResourceBundle"%>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import = "com.autonomy.aci.AciResponse"%>
<%@ page contentType="text/html; charset=utf-8" %>
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

StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

String refCharacterEncoding = service.readConfigParameter(CommonConstants.REFERENCE_ENCODING, CommonConstants.DEFAULT_REF_ENCODING );

String  sImageURL = service.makeLink("AutonomyImages");
%>
<html>
<head>
	<title></title>
	<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/portalinabox.css">
	<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/autonomyportlets.css">
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
</head>
<body style="background-color:transparent; margin:0px;">
	<table class="pResultList" style="margin:0px;" width="99%" border="0" cellspacing="0" align="center">

<%
	// build up autosuggest URL. .
	StringBuffer sbAbsSuggestURL = new StringBuffer(service.makeLink("autosuggest.jsp?"));
	sbAbsSuggestURL.append( request.getQueryString() );
	sbAbsSuggestURL.append("&threshold=");
	sbAbsSuggestURL.append(40);
	sbAbsSuggestURL.append("&numresult=");
	sbAbsSuggestURL.append(6);
	sbAbsSuggestURL.append("&refencoding=");
	sbAbsSuggestURL.append(refCharacterEncoding);

	// grab cluster aciObject from session
	AciResponse acioClusterResult = (AciResponse)session.getAttribute("acioClusterResult");

	if(acioClusterResult != null)
	{
		// remove cluster aciObject from session
		session.removeAttribute("acioClusterResult");

		// grab first document in cluster list and loop through all entries, displaying entry
		// details as we go, one entry per table row.

		AciResponse acioClusterDoc = acioClusterResult.findFirstOccurrence("autn:doc");

		while( acioClusterDoc != null )
		{
			String sTitle 	= acioClusterDoc.getTagValue("autn:title", "Unknown");
			String sScore 	= acioClusterDoc.getTagValue("autn:score", "0");
			String sSummary	= acioClusterDoc.getTagValue("autn:summary", "");
			String sURL		= acioClusterDoc.getTagValue("autn:ref", "");

			int nScore = StringUtils.atoi(sScore, 0)/2;

			StringBuffer sbAutoSuggestURL = new StringBuffer( sbAbsSuggestURL.toString() );
			sbAutoSuggestURL.append("&url=");
			sbAutoSuggestURL.append(HTTPUtils.URLEncode(sURL, refCharacterEncoding));

%>

			<tr>
				<td width="75" align="left">
<%
				for(int nStarCnt = 0; nStarCnt < nScore; nStarCnt++)
				{
%>
					<img src="<%= sImageURL %>/star.gif" border=0 alt="<%=nScore%> star document">
<%
				}
%>
				</td>
				<td width="10"></td>
				<td>

					<a class="normal" href="<%= StringUtils.XMLEscape(sbAutoSuggestURL.toString()) %>" target="_blank">
						<font>
							<b><%= StringUtils.XMLEscape(sTitle) %></b>
						</font>
					</a>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<%=StringUtils.XMLEscape(sSummary)%>
				</td>
			</tr>
<%
			acioClusterDoc = acioClusterDoc.next();

		}	//while( acioClusterDoc != null )
	}
	else
	{
%>
		<tr>
			<td>
				<font class="normal">
					<%=rb.getString("clusterText_body.unableRetrieveList")%>
				</font>
			</td>
		</tr>
<%
	}
%>
	</table>

</body>

</html>