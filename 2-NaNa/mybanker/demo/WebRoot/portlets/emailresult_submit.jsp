<%@ page import = "java.util.*" %>
<%@ page import = "com.autonomy.aci.*" %>
<%@ page import = "com.autonomy.utilities.HTTPUtils" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.ServiceFactory" %>
<%@ page import = "com.autonomy.APSL.StandaloneService" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
// set up portlet service
StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");


// *** get form data
String encodedUsername = service.getSafeRequestParameter("username", "");
String docRef          = service.getSafeRequestParameter("url", 	"");
String refEncoding     = service.getSafeRequestParameter("refencoding", 	"");
String docID           = service.getSafeRequestParameter("id", 				"");
String fromAddress     = service.getSafeRequestParameter("fromaddress",	"");
String toAddress       = service.getSafeRequestParameter("toaddress",	"");
String message         = service.getSafeRequestParameter("message", 		"");

String username 	= StringUtils.decryptString(encodedUsername);

String contextPath = request.getContextPath();

String error = null;
// check recipient email address
if(toAddress != null && toAddress.length() > 0)
{
	if(toAddress.indexOf("@") == -1 || toAddress.length() < 5)
	{
		error = "You must give a valid email address for the person you wish to send this result to.";
	}
}
else
{
	error = "You must give the email address of the person you wish to send this result to.";
	// set to empty string for inclusion in return query string.
	toAddress = "";
}
// check reply-to email address and record on UAServer if necessary
if(fromAddress != null && fromAddress.length() > 0)
{
	if(fromAddress.indexOf("@") == -1 || fromAddress.length() < 5)
	{
		error = "You must give a valid reply-to email address.";
	}
}
else
{
	error = "You must give a reply-to email address.";
	// set to empty string for inclusion in return query string.
	fromAddress = "";
}

String messageToDisplay = null;
if(error == null)
{
	AciAction aciaSendEmail = new AciAction("Custom");
	aciaSendEmail.setParameter(new ActionParameter("Library", "Email"));
	aciaSendEmail.setParameter(new ActionParameter("Function", "email"));
	aciaSendEmail.setParameter(new ActionParameter("from", fromAddress));
	aciaSendEmail.setParameter(new ActionParameter("to", toAddress));
	if (!StringUtils.isTrue(service.readConfigParameter("UseDocumentIDs", "false")))
	{
		aciaSendEmail.setParameter(new ActionParameter("reference", HTTPUtils.URLEncode(docRef, refEncoding)));
	}
	else
	{
		aciaSendEmail.setParameter(new ActionParameter("id", docID));
	}
	aciaSendEmail.setParameter(new ActionParameter("subject", "Autonomy IDOL retrieval result"));
	aciaSendEmail.setParameter(new ActionParameter("username", username));

	AciConnectionDetails acicdUser = service.getIDOLService().getUserConnectionDetails();
	AciConnection acicUser = new AciConnection(acicdUser.getHost(), acicdUser.getPort());

	AciResponse acir = acicUser.aciActionExecute(aciaSendEmail);

	if (acir != null)
	{
		if (acir.checkForSuccess())
		{
			messageToDisplay = "Your email has been sent.";
		}
		else
		{
			messageToDisplay = acir.getTagValue("errordescription");
		}
	}
	else
	{
		messageToDisplay = "Your email was not sent because the server which is used to send it could not be contacted.";
	}
}
else
{
	// problem with email address given, return to form which will display error message
	response.sendRedirect("./emailresult.jsp?error=" + error + "&badtoaddress=" + toAddress+ "&badfromaddress=" + fromAddress);
	return;
}

// display successful email message or error
%>

<html>
<head>
	<script type="text/javascript" >
		<!--
		window.focus();
		//-->
	</script>
	<title>Email Results:</title>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="<%= contextPath %>/portalinabox.css">
</head>
<body>

<table width="100%" cellspacing="0" cellpadding="0" align="center">
	<tr>
		<td>
			<font class="normalbold">
				<%= messageToDisplay %>
			</font>
		</td>
	</tr>
	<tr height="6"></tr>
	<tr>
		<td>
			<a href="javascript:this.window.close();">
				<font class="normal">
				Close this window.
				<font class="normal">
			</a>
		</td>
	</tr>
</table>


