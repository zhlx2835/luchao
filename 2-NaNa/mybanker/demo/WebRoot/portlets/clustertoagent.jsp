<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.autonomy.aci.businessobjects.*" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
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

String  stylesheetURL = service.makeLink("AutonomyImages");
%>
<html>
	<head>
		<script type="text/javascript" >
			<!--
			window.focus();
			-->
		</script>
		<link rel="stylesheet" type="text/css" href="<%= stylesheetURL %>/portalinabox.css">
		<link rel="stylesheet" type="text/css" href="<%= stylesheetURL %>/autonomyportlets.css">
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<%
	String sClusterName   = request.getParameter("clustername");
	String sTermStringEnc = request.getParameter("tnw");
	String sUsernameEnc   = request.getParameter("username");

	if ( !StringUtils.strValid(sClusterName)	||
		 !StringUtils.strValid(sUsernameEnc)	||
		 !StringUtils.strValid(sTermStringEnc)
		 )
	{
		out.print(rb.getString("clustertoagent.error.paramMissing") );
	}
	else
	{
		// decrypt/unencode parameters
		String sUsername	= StringUtils.decryptString(sUsernameEnc);
		String sTermString	= StringUtils.decryptString(sTermStringEnc);

		int nNumAgents		= 0;
		int nMaxAgentsA		= 0;
		User user			= null;
		ArrayList alAgents	= null;

		StandaloneService.markAsStandalone(session);
		String sError = null;

		try
		{
			// have to fetch the user's details to find maxagents
			user = service.getIDOLService().useUserFunctionality().getUser(sUsername);
			nMaxAgentsA = user.getMaxAgents();
			alAgents = service.getIDOLService().useAgentFunctionality().getAgentList(user);
		}
		catch (AciException acix)
		{
			sError = rb.getString("clustertoagent.error.createAgent");
		}

		nNumAgents = alAgents.size();
		if (nNumAgents >= nMaxAgentsA)
		{
			sError = rb.getString("clustertoagent.error.maxAllowed");
		}

		if (sError == null)
		{
			// make textual list of the user's agents to embed in checkForm()
			StringBuffer sbJavaScriptAgentNames = new StringBuffer("");

			Iterator iAgent = alAgents.iterator();
			while (iAgent.hasNext())
			{
				String sAgentName = ((Agent)iAgent.next()).getAgentname();
				sbJavaScriptAgentNames.append( "\"").append( sAgentName ).append( "\",");
			}

			// remove trailing comma
			try
			{
				sbJavaScriptAgentNames.deleteCharAt(sbJavaScriptAgentNames.length() -1);
			}
			catch(StringIndexOutOfBoundsException sioobe)
			{}
%>
			<title>Create Agent from Cluster</title>
		</head>
		<body>
			<script type="text/javascript">
				function checkForm()
				{
					js_saExistingAgents = new Array(<%= sbJavaScriptAgentNames %>);
					for (j=0; j< <%= nNumAgents %>; j++)
					{
						if (js_saExistingAgents[j] == document.createagentform.agentname.value)
						{
							alert("<%=rb.getString("clustertoagent.alert.rename")%>");
							return false;
						}
					}
					return true;
				}
			</script>
                        <form name="createagentform"
				 method="post"
				 action="./agentadd.jsp"
				 onSubmit="return checkForm()">
				<input type="hidden" name="tnw" 	 value="<%= sTermStringEnc %>">
				<input type="hidden" name="username" value="<%= sUsernameEnc %>">

				<table class="pContainer" width="100%">
					<tr>
						<td colspan="2" align="center">
						    <font class="normal">
							    <b><%=rb.getString("clustertoagent.createAgentFrom")%></b><br>
							    <br>
						    </font>
						</td>
					</tr>

					<tr>
						<td width="20%">
							<font class="normal">
								<%=rb.getString("clustertoagent.confirmName")%>
							</font>
						</td>
						<td width="80%" align="left">
							<font class="normal">
								<input type="text" size="50" name="agentname" value="<%= StringUtils.XMLEscape(sClusterName) %>">
							</font>
						</td>
					</tr>
					<tr>
						<td width="20%">
							<font class="normal">
								<%=rb.getString("clustertoagent.threshold")%>
							</font>
						</td>
						<td width="80%" align="left">
							<font class="normal">
								<select name="threshold">
									<option value="0">0</option>
									<option value="10">10</option>
									<option value="20">20</option>
									<option value="30" selected="selected">30</option>
									<option value="40">40</option>
									<option value="50">50</option>
									<option value="60">60</option>
									<option value="70">70</option>
									<option value="80">80</option>
									<option value="90">90</option>
									<option value="100">100</option>
								</select>%
							</font>
						</td>
					</tr>
					<tr>
						<td width="20%">
							<font class="normal">
								<%=rb.getString("clustertoagent.numOfResults")%>
							</font>
						</td>
						<td width="80%" align="left">
							<font class="normal">
								<select name="numresults">
								<option value="3">3</option>
									<option value="6" selected="selected">6</option>
									<option value="10">10</option>
									<option value="15">15</option>
									<option value="30">30</option>
								</select>
							</font>
						</td>
					</tr>

					<tr>
						<td width="20%">
							<font class="normal">
								<%=rb.getString("clustertoagent.addToCommunity")%>
							</font>
						</td>
						<td width="80%" align="left">
							<font class="normal">
								<input type="checkbox" name="addtocommunity" value="true" checked="checked">
							</font>
						</td>
					</tr>

					<tr><td height="6" /></tr>

					<tr>
						<td colspan="2" align="left">
							<a class="textButton" title="Cancel" href="javascript:window.close()">
								<font class="normal">
									<%=rb.getString("clustertoagent.cancel")%>
								</font>
							</a>
							&nbsp;
							<a class="textButton" title="Create agent" href="javascript:if(checkForm()){createagentform.submit()}">
								<font class="normal">
									<%=rb.getString("clustertoagent.createAgent")%>
								</font>
							</a>
						</td>
					</tr>
				</table>
			</form>
		</body>
<%
		}
		else // sError != null
		{
%>
			<title>Error</title>
		</head>
		<body>
			<font class="normal">
				<%= sError %> <br />
				<br />
				<a href="javascript:this.window.close();">
					<%=rb.getString("clustertoagent.click")%>
				</a>
				<%=rb.getString("clustertoagent.closeWin")%>
			</font>
		</body>
<%
		}
	}
%>
</html>
