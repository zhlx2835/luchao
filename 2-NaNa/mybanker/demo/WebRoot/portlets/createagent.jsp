<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.ServiceFactory" %>
<%@ page import = "com.autonomy.APSL.StandaloneService" %>
<%@ page import = "com.autonomy.utilities.HTMLUtils" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>
<%@ page import = "com.autonomy.aci.ActionParameter" %>
<%@ page import = "com.autonomy.aci.businessobjects.Agent" %>
<%@ page import = "com.autonomy.aci.businessobjects.ResultDocument" %>
<%@ page import = "com.autonomy.aci.businessobjects.ResultList" %>
<%@ page import = "com.autonomy.aci.exceptions.MaximumAgentsException" %>
<%@ page import = "com.autonomy.aci.exceptions.AgentExistsException" %>
<%@ page import = "com.autonomy.aci.exceptions.IDOLException" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import = "java.util.ArrayList" %>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
// force utf-8 encoding
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

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

// *** get form data
String encodedUsername 	= service.getSafeRequestParameter("username", "");
String docRef = service.getSafeRequestParameter("url", "");
String refEncoding = service.getSafeRequestParameter("refencoding", "");
String sID = service.getSafeRequestParameter("id", "");

String agentName = "";
String errorMessage = null;
if(StringUtils.strValid(docRef))
{
	ResultDocument agentTrainingDoc = new ResultDocument(docRef);
	agentTrainingDoc.setReferenceEncoding(refEncoding);
	agentTrainingDoc.setDocID(sID);
	ArrayList trainingDocs = new ArrayList();
	trainingDocs.add(agentTrainingDoc);

	// get content parameters
	ArrayList getContentParams = new ArrayList();
	getContentParams.add(new ActionParameter("OutputEncoding", "utf8"));

	// get document title for use as new agent name
	try
	{
		ResultList resultList = service.getIDOLService().useConceptRetrievalFunctionality().getContent(trainingDocs, getContentParams);
		ArrayList alDocs = resultList.getDocuments();
		if(!alDocs.isEmpty())
		{
			agentName = ((ResultDocument)alDocs.get(0)).getTitle();
		}
		else
		{
			errorMessage = "Document reference not found in IDOL";
		}
	}
	catch(IDOLException idole)
	{
		errorMessage = idole.getMessage();
	}

	// add agent using the document as training
	if(StringUtils.strValid(agentName))
	{
		Agent newAgent = new Agent();
		newAgent.setAgentname(agentName);
		newAgent.setOwnername(StringUtils.decryptString(encodedUsername));
		newAgent.addTrainingDoc(agentTrainingDoc);

		try
		{
			service.getIDOLService().useAgentFunctionality().createAgent(newAgent);
		}
		catch(MaximumAgentsException mae)
		{
			errorMessage = "You already have the maximum number of agents allowed. Delete some of your existing agents before trying to save this search again.";
		}
		catch(AgentExistsException aee)
		{
			errorMessage = "You already have an agent called " + agentName + ". Please modify the name of the existing agent and try again.";
		}
	}
	else
	{
		// don't overwrite existing error message if there is one
		if(errorMessage == null)
		{
			errorMessage = "Could not read the document's title to use as the agent name.";
		}
	}
}
else
{
	errorMessage = "No document reference given";
}

String  stylesheetURL = service.makeLink("AutonomyImages");
%>
<html>
	<head>
		<title>
			Create Autonomy Agent
		</title>
		<link rel="stylesheet" type="text/css" href="<%= stylesheetURL %>/portalinabox.css">
		<link rel="stylesheet" type="text/css" href="<%= stylesheetURL %>/autonomyportlets.css">
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	</head>
<%
	if( errorMessage == null )
	{
%>
		<script type="text/javascript">
			<!--
			function refreshParentAndClose()
			{
				if(opener != null && opener.document != null && opener.document.forms != null)
				{
					for(iFormsIdx = 0; iFormsIdx < opener.document.forms.length; iFormsIdx++)
					{
						if(opener.document.forms[iFormsIdx] != null && opener.document.forms[iFormsIdx].name == 'dummy')
						{
							opener.document.forms[iFormsIdx].submit();
						}
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
								<%=rb.getString("createagent.created")%>
							</font>
						</center>
					</td>
				</tr>
				<tr><td height="10"></td></tr>
				<tr>
					<td>
						<font class="normal">
							<%=rb.getString("createagent.agent")%> "<%= StringUtils.XMLEscape(agentName) %>" <%=rb.getString("createagent.hasCreated")%>
						</font>
					</td>
				</tr>
				<tr><td height="6" /></tr>
				<tr>
					<td>
						<font class="normal">
							<a href="javascript:window.close();"><%=rb.getString("createagent.closeWindow")%></a>
						</font>
					</td>
				</tr>
			</table>
		</body>
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
				<tr><td height="10"></td></tr>
				<tr>
					<td>
						<font class="normal">
							<%=rb.getString("createagent.sorry")%> "<%= StringUtils.XMLEscape(agentName) %>" <%=rb.getString("createagent.couldNotCreate")%>
						</font>
					</td>
				</tr>
				<tr>
					<td>
						<font class="normal">
							<%=rb.getString("createagent.reason")%> - <%= StringUtils.XMLEscape(errorMessage) %>
						</font>
					</td>
				</tr>
			</table>
		</body>
<%
	}
%>
</html>
