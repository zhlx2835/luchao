<%@ page import = "com.autonomy.aci.businessobjects.Agent" %>
<%@ page import = "com.autonomy.aci.exceptions.AgentExistsException" %>
<%@ page import = "com.autonomy.aci.exceptions.MaximumAgentsException" %>
<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.ServiceFactory" %>
<%@ page import = "com.autonomy.APSL.StandaloneService" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>

<%
// set up portlet service
StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

// get form data
String numResults		= service.getSafeRequestParameter("agentNumResults", 	"");
String threshold		= service.getSafeRequestParameter("agentThreshold", 	"");
String trainingText	= service.getSafeRequestParameter("agentTraining", 	"");
String agentName		= service.getSafeRequestParameter("agentName", 	"");
String username			= StringUtils.decryptString(service.getSafeRequestParameter("username", 	""));	

Agent newAgent = new Agent();
newAgent.setAgentname(StringUtils.stripNonAlphaNum(agentName));
newAgent.setOwnername(username);
newAgent.setTraining(trainingText);
newAgent.setNumResults(StringUtils.atoi(numResults, 6));
newAgent.setThreshold(StringUtils.atoi(threshold, 30));
newAgent.setShownInCommunity(true);

String error = null;
try
{
	service.getIDOLService().useAgentFunctionality().createAgent(newAgent);
}
catch(MaximumAgentsException mae)
{
		error = "You have reached your maximum number of allowed agents. Please delete an existing agent and try again.";
}
catch(AgentExistsException aee)
{
		error = "You already have an agent with this name. Please try again with a different agent name.";
}

if( error == null )
{
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/portalinabox.css">
</head>
<script type="text/javascript">
	<!--
	function refreshParentAndClose()
	{
		for(iFormsIdx = 0; iFormsIdx < opener.document.forms.length; iFormsIdx++)
		{
			if(opener.document.forms[iFormsIdx].name = 'dummy')
			{
				opener.document.dummy.submit();				
			}
		}
		self.close();
	}
	// -->
</script>
<body onUnLoad="javascript:refreshParentAndClose()">
	<table class="pContainer" width="100%" border="0">
		<tr>
			<td>
				<center>
					<font class="normalbold">
						New Agent Created
					</font>
				</center>
			</td>
		</tr>
		<tr><td height="6"></td></tr>
		<tr>
			<td>
				<font class="normal">
					The Agent "<%= agentName %>" has been created.
				</font>
			</td>
		</tr>
		<tr><td height="6"></td></tr>		
		<tr>
			<td>
				<font class="normal">
					<a href="javascript:window.close();">Close window</a>
				</font>
			</td>
		</tr>		
	</table>
</body>
</html>
<%	
}
else
{
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages") %>/portalinabox.css">
	<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages") %>/autonomyportlets.css">
</head>
<body>
	<table class="pContainer" width="100%" border="0">
		<tr>
			<td>
				<center>
					<font class="normalbold">
						Agent creation error
					</font>
				</center>
			</td>
		</tr>
		<tr><td height="6"></td></tr>		
		<tr>
			<td>
				<font class="normal">
					Sorry, the Agent: "<%= agentName %>" could not be created.
				</font>
			</td>
		</tr>
		<tr>
			<td>
				<font class="normal">
					Reason - <%= StringUtils.XMLEscape(error) %>
				</font>
			</td>
		</tr>
		<tr><td height="6"></td></tr>		
		<tr>
			<td>
				<font class="normal">
					<a href="javascript:window.close();">Close window</a>
				</font>
			</td>
		</tr>				
	</table>
</body>
</html>
<%	
}
%>

