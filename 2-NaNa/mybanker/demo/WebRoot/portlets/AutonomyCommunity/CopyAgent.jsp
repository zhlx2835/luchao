<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.aci.businessobjects.Agent" %>
<%@ page import = "com.autonomy.aci.businessobjects.User" %>
<%@ page import = "com.autonomy.aci.exceptions.*" %>
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
String sAgentOwner  			= request.getParameter("agentowner");
String sAgentName  				= request.getParameter("agentname");
String sNewAgentName			= request.getParameter("newagentname");

String sUsername 	= StringUtils.decryptString(sEncodedUsername);

StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

String sError = null;

Agent agentToCopy = new Agent();
agentToCopy.setAgentname(sAgentName);
agentToCopy.setOwnername(sAgentOwner);
User uNewOwner = new User(sUsername);
try
{
	service.getIDOLService().useAgentFunctionality().copyAgent(agentToCopy, uNewOwner, sNewAgentName);
}
catch (MaximumAgentsException max)
{
	sError = "You have reached your maximum number of allowed agents. Please delete an existing agent and try again.";
}
catch (AciException acix)
{
	sError = acix.getMessage();
}

String sImageURL = service.makeLink("AutonomyImages");
%>
<!-- Output header -->
<html>
<head>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="<%=sImageURL%>/autonomyportlet.css">
	<link rel="stylesheet" type="text/css" href="<%=sImageURL%>/portalinabox.css">
	<title>Cloning Autonomy Agent</title>
</head>
<script type="text/javascript">
	<!--
	function refreshParentAndClose()
	{
		if(opener != null && opener.document != null && opener.document.forms != null)
		{
			for(iFormsIdx = 0; iFormsIdx < opener.document.forms.length; iFormsIdx++)
			{
				if(opener.document.forms[iFormsIdx].name == 'dummy')
				{
					opener.document.forms[iFormsIdx].submit();
				}
			}
		}
	}
	// -->
</script>
<%
if( sError == null )
{
%>
	<body onUnLoad="javascript:refreshParentAndClose()">
		<table class="pContainer" width="100%" border="0">
			<tr>
				<td>
					<center>
						<font class="normalbold">
								<%=rb.getString("createagent.created")%>
						</font>
					</center>
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal">
						<%=rb.getString("createagent.agent")%> "<%= StringUtils.XMLEscape(sNewAgentName) %>" <%=rb.getString("createagent.hasCreated")%>
					</font>
				</td>
			</tr>
		</table>
<%
}
else
{
%>
	<body>
		<table class="pContainer" width="100%" border="0">
			<tr>
				<td>
					<center>
						<font class="normalbold">
								<%=rb.getString("createagent.creationError")%>
						</font>
					</center>
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal">
						<%=rb.getString("createagent.sorry")%> "<%= StringUtils.XMLEscape(sNewAgentName) %>" <%=rb.getString("createagent.couldNotCreate")%>
					</font>
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal">
						<%=rb.getString("createagent.reason")%> - <%= StringUtils.XMLEscape(sError) %>
					</font>
				</td>
			</tr>
		</table>
<%
	}
%>

		&nbsp;<a href="javascript:window.close();"><b><%=rb.getString("copyAgent.closeWin")%></b></a>

	</body>
</html>
