<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
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
%>

<%
StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

// see if we came here from emailresult_submit.jsp with an error to display
String sErrorMessage 	= service.getSafeRequestParameter("error", "");
String sErrorDisplay 	= "";
String sBadToAddress	= "";
String sBadFromAddress	= null;
if(StringUtils.strValid(sErrorMessage))
{
	// wrap error message in font tag and read badly formed address
	sErrorDisplay 	= "<font class=\"warning\">" + sErrorMessage + "</font><br />";
	sBadToAddress 	= service.getSafeRequestParameter("badtoaddress", "");
	sBadFromAddress	= service.getSafeRequestParameter("badfromaddress", "");
}

String sReplyToAddress = null;
if(sBadFromAddress != null)
{
	sReplyToAddress = sBadFromAddress;
}
else
{
	// try to read user's email address. if this is not set on UAServer we will ask for a reply-to address and offer to
	// record that for use in futher emails
	String sUAHost 		= StringUtils.decryptString(service.getSafeRequestParameter("userhost", ""));
	String sUAPort 		= StringUtils.decryptString(service.getSafeRequestParameter("userport", ""));
	String sUsername 	= StringUtils.decryptString(service.getSafeRequestParameter("username", ""));

	if(StringUtils.strValid(sUAHost) && StringUtils.strValid(sUAPort) && StringUtils.strValid(sUsername))
	{
		sReplyToAddress = PortletUtils.getUsersEmail(sUAHost, sUAPort, sUsername);
	}
}
boolean bReplyToAddressInUAS = StringUtils.strValid(sReplyToAddress);

String sImageURL = service.makeLink("AutonomyImages");
%>

<html>
<head>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
		<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/portalinabox.css">
		<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/autonomyportlets.css">
	<script type="text/javascript" >
		<!--
		window.focus();
		//-->
	</script>
	<title>Email Results:</title>
<body>

<%= sErrorDisplay %>

<form action="./emailresult_submit.jsp" method="post" >
	<input type="hidden" name="url" value="<%= service.getSafeRequestParameter("url", "") %>" />
	<input type="hidden" name="username" value="<%= service.getSafeRequestParameter("username", "") %>" />
	<input type="hidden" name="refencoding" value="<%= service.getSafeRequestParameter("refencoding", "") %>" />
	<table class="pContainer" width="100%" cellspacing="0" cellpadding="0" align="center" >
		<tr>
			<td colspan="2">
				<font class="normal">
					<%=rb.getString("emailresult.sendAddr")%>
<%
					if(!bReplyToAddressInUAS)
					{
%>
						<br><%=rb.getString("emailresult.replyAddr")%>
<%
					}
%>
				</font>
			</td>
		</tr>
		<tr><td height="12"></td></tr>
		<tr>
			<td width="10%"align="right">
				<font class="normalbold">
					<%=rb.getString("emailresult.to")%>&nbsp;&nbsp;
				</font>
			</td>
			<td>
				<input type="text" name="toaddress" value="<%= sBadToAddress %>" tabindex="1" maxlength="256" size="45" />
			</td>
		</tr>
		<tr><td height="6"></td></tr>
		<tr>
			<td align="right">
				<font class="normalbold">
					<%=rb.getString("emailresult.replyTo")%>&nbsp;&nbsp;
				</font>
			</td>
			<td>
				<input type="text" name="fromaddress" value="<%= sReplyToAddress %>" maxlength="256" size="45" />
			</td>
		</tr>
		<tr><td height="6"></td></tr>
		<tr>
			<td></td>
			<td>
				<input type="submit" name="go" value="<%=rb.getString("emailresult.submit")%>" />
			</td>
		</tr>
	</table>
</form>

</body>
</html>
