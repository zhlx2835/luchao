<%@ page import="java.util.List"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.aci.businessobjects.Agent"%>
<%@ page import="com.autonomy.aci.businessobjects.User"%>
<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>

<%
response.setContentType("text/html; charset=utf-8");

// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)AgentConstants.PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(AgentConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(AgentConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(AgentConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// see if an agent has been selected
Agent selectedAgent = (Agent)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT);

// read list of users agents from IDOL
User user = (User)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_USER);
List agents = service.getIDOLService().useAgentFunctionality().getAgentList(user);

// save agents on session for use later if one is edited, retrained or deleted
service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_AGENT_LIST, agents);

String imageURL = service.makeLink("AutonomyImages");

// display agents with view results, edit and delete links
if(!agents.isEmpty())
{
	// user has agents, display list of agent names and delete, edit,... options
%>
	<script type="text/javascript" defer="defer">
		function confirmDeleteAgent()
		{
			bCnfrm = confirm('<%=rb.getString("displayAgentList.deleteAgent.confirm")%>');
			return bCnfrm;
		}
		function submitEditForm(agentIDX)
		{
			document['<%= service.makeFormName(AgentConstants.EDIT_AGENT_FORM_NAME) %>']['<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX) %>']['value']=agentIDX;
			document['<%= service.makeFormName(AgentConstants.EDIT_AGENT_FORM_NAME) %>'].submit();
		}
		function submitDeleteForm(agentIDX)
		{
			document['<%= service.makeFormName(AgentConstants.DELETE_AGENT_FORM_NAME) %>']['<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX) %>']['value']=agentIDX;
			document['<%= service.makeFormName(AgentConstants.DELETE_AGENT_FORM_NAME) %>'].submit();
		}
		function submitViewForm(agentIDX)
		{
			document['<%= service.makeFormName(AgentConstants.VIEW_AGENT_RESULTS_FORM_NAME) %>']['<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX) %>']['value']=agentIDX;
			document['<%= service.makeFormName(AgentConstants.VIEW_AGENT_RESULTS_FORM_NAME) %>'].submit();
		}
	</script>
	<form name="<%= service.makeFormName(AgentConstants.EDIT_AGENT_FORM_NAME) %>" action="<%= service.makeFormActionLink(" ") %>" method="post">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE) %>" value="<%= AgentConstants.JSP_PAGE_EDIT_AGENT %>"/>
		<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX) %>" value="">
	</form>
	<form name="<%= service.makeFormName(AgentConstants.DELETE_AGENT_FORM_NAME) %>" action="<%= service.makeFormActionLink(" ") %>" method="post">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE) %>" value="<%= AgentConstants.JSP_PAGE_DELETE_AGENT %>"/>
		<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX) %>" value="">
	</form>
	<form name="<%= service.makeFormName(AgentConstants.VIEW_AGENT_RESULTS_FORM_NAME) %>" action="<%= service.makeFormActionLink(" ") %>" method="post">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE) %>" value="<%= AgentConstants.JSP_PAGE_SHOW_AGENT %>"/>
		<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX) %>" value="">
	</form>

	<table width="320" cellpadding="0" border="0" cellspacing="5">
		<tr>
			<td nowrap="yes">
				<font class="<%=service.getCSSClass(service.TEXT_1)%>">
					<b><%=rb.getString("displayAgentList.yourAgents")%></b>
				</font>
			</td>
			<td align="center" nowrap="yes">
				<font class="<%=service.getCSSClass(service.TEXT_1)%>">
					<b><%=rb.getString("displayAgentList.editAgent")%></b>
				</font>
			</td>
            <td align="center" nowrap="yes">
				<font class="<%=service.getCSSClass(service.TEXT_1)%>">
					<b><%=rb.getString("displayAgentList.deleteAgent")%></b>
				</font>
			</td>
		</tr>
		<tr>
			<td colspan="2" height="6" />
		</tr>
<%
		for(int agentIdx = 0; agentIdx < agents.size(); agentIdx++)
		{
			Agent agent = (Agent)agents.get(agentIdx);
			String agentFormName = service.makeFormName(agent.getAgentname());
%>
			<tr>
				<td width="55%">
					<font class="<%=service.getCSSClass(service.TEXT_2)%>">
<%
						if(selectedAgent != null && agent.getAgentname().equals(selectedAgent.getAgentname()))
						{
%>
							<%= StringUtils.XMLEscape(agent.getAgentname()) %>
<%
						}
						else
						{
%>
							<a href="javascript:submitViewForm(<%= agentIdx %>);">
								<%= StringUtils.XMLEscape(agent.getAgentname()) %>
							</a>
<%
						}
%>
						<%= agent.isRetrained() ? (rb.getString("displayAgentList.retrained")) : "" %>
					</font>
				</td>
				<td align="center" width="45%">
					<a href="javascript:submitEditForm(<%= agentIdx %>);">
						<img alt="Edit the properties of this agent" src="<%= imageURL %>/b_editpane.gif" hspace="2" vspace="2" border="0">
					</a>
				</td>
                <td>
					&nbsp;
					<a href="javascript:submitDeleteForm(<%= agentIdx %>);" onClick="return confirmDeleteAgent()">
						<img alt="Completely erase this agent" src="<%= imageURL %>/b_delete.gif" hspace="2" vspace="2" border="0" >
					</a>
				</td>
			</tr>
<%
		}
%>
	</table>
<%
}
else
{
%>
	<table>
		<tr>
			<td>
				<font class="<%=service.getCSSClass(service.TEXT_1)%>">
					<%=rb.getString("displayAgentList.noAgents")%>
				</font>
			</td>
		</tr>
	</table>
<%
}

if(user.getNumAgents() < user.getMaxAgents())
{
	// user can create more agents so display button
%>
	<script type="text/javascript">
		function newAgent()
		{
			document['<%= service.makeFormName(AgentConstants.NEW_AGENT_FORM_NAME) %>'].submit();
		}
	</script>

	<table>
		<tr>
			<td height="6"></td>
		</tr>
		<tr>
			<td colspan="4" align="left">
				<!-- Create new agent form - submitted by javascript:checkMaxAgents() -->
				<form name="<%= service.makeFormName(AgentConstants.NEW_AGENT_FORM_NAME) %>" action="<%= service.makeFormActionLink(" ") %>" method="POST">
					<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE) %>" value="<%= AgentConstants.JSP_PAGE_NEW_AGENT %>"/>
					<%= service.makeAbstractFormFields() %>
					<a class="textButton" title="Create a new agent" href="javascript:newAgent();">
						<%=rb.getString("displayAgentList.createAgent")%>
					</a>
				</form>
			</td>
		</tr>
	</table>
<%
}
%>


<%!
private static void mylog(String s)
{
	System.out.println("displayAgentForm.jsp " + s);
}
%>