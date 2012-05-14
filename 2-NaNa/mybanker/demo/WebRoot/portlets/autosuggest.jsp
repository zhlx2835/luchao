<%@ page import = "com.autonomy.aci.businessobjects.ResultDocument" %>
<%@ page import = "com.autonomy.aci.businessobjects.User" %>
<%@ page import = "com.autonomy.aci.exceptions.NotLicensedException" %>
<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.ServiceFactory" %>
<%@ page import = "com.autonomy.APSL.StandaloneService" %>
<%@ page import = "com.autonomy.utilities.HTTPUtils" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>


<%
request.setCharacterEncoding("utf-8");
%>

<%
// set up portlet service
StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

boolean bProfiling   = service.readConfigParameter("Profiling", "true").equalsIgnoreCase("true"); // check whether profiling is enabled
boolean bHyperlinking = service.readConfigParameter("Hyperlinking", "true").equalsIgnoreCase("true"); // check whether hyperlinking is enabled

// get form data
String sUrl               = service.getSafeRequestParameter("url", "");
String sID                = service.getSafeRequestParameter("id", "");
String sRefEncoding       = service.getSafeRequestParameter("refencoding", "UTF-8");
String sThreshold         = service.getSafeRequestParameter("threshold", "");
String sNumResults        = service.getSafeRequestParameter("numresult", "");
String sDisplayParameters = service.getSafeRequestParameter("display", "");
String sCommand           = service.getSafeRequestParameter("command", "");
String sLinks             = service.getSafeRequestParameter("links", "");
String sEncryptedUsername = service.getSafeRequestParameter("username", "");


//
// do profiling
//

if(StringUtils.strValid(sUrl) && bProfiling)
{
	String sUsername = StringUtils.decryptString(sEncryptedUsername);
	ResultDocument profileDoc = new ResultDocument(sUrl);
	profileDoc.setReferenceEncoding(sRefEncoding);
	profileDoc.setDocID(sID);

	try
	{
		service.getIDOLService().useProfilingFunctionality().addDocumentToProfile(new User(sUsername), profileDoc);
	}
	catch(NotLicensedException e)
	{
		throw new Exception("You do not appear to be licensed for profiling. Please disable profiling in your configuration or update your license.");
	}
}


// URL string common to all operations
StringBuffer sbAutoSuggestParams = new StringBuffer();
// add request info
sbAutoSuggestParams.append("?").append(request.getQueryString());

String sDisplayURL;
String displayEncoding = "utf-8";
if(sCommand.equals("ShowDocManDoc"))
{
	// no need to url encode sUrl, docman doc urls are just numbers
	sDisplayURL = "ShowDocManDoc.jsp" + sbAutoSuggestParams.toString();
}
else if(sCommand.equals("getcontent") || sCommand.equals("getsummary") || sCommand.equals("gethighlights") )
{
	sDisplayURL = "./getcontent.jsp" + sbAutoSuggestParams.toString();
}
else
{
	sDisplayURL = sUrl;
	//if the URL doesn't begin with http:// or file:// then set it to be a file.
	//If it is a local document that is not being displayed correctly in Netscape
	//type browsers, type: about:config and ensure security.checkloaduri is set to false.
	//N.B security.checkloaduri should be set to true, this is only a temporary fix,
	//documents shouldn't have an absolute path as a reference, so consider re-indexing
	//if this is the cause of the problem.
	if(!sDisplayURL.startsWith("http://") && !sDisplayURL.startsWith("https://") && !sDisplayURL.startsWith("file://"))
	{
		sDisplayURL = "file:///" + sDisplayURL;
	}

	// must use character encoding of the document's reference otherwise some browsers will
	// not interpret the URL correctly
	displayEncoding = sRefEncoding;
}

response.setContentType("text/html; charset=" + displayEncoding);

// if hyperlinking isn't enabled then only show the document
if (!bHyperlinking)
{
	response.sendRedirect(sDisplayURL);
}

%>
<html>
<head>
	<title> Autonomy Results </title>
	<meta http-equiv="content-type" content="text/html;charset=<%= displayEncoding %>" />
</head>

	<frameset rows="70%,*">
		<!-- Display original document or summary/content -->
		<frame name="main_contents" frameborder="0" scrolling="auto" src="<%= StringUtils.XMLEscape(sDisplayURL) %>" >
		<!-- Display more suggestions -->
		<frame name="main_suggestion" frameborder="1" scrolling="auto" src="./autosuggest_suggest.jsp<%= StringUtils.XMLEscape(sbAutoSuggestParams.toString()) %>" >
	</frameset>
</html>

