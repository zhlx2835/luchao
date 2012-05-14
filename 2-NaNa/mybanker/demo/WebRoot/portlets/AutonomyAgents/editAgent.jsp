<%@ page import="java.util.ArrayList"%>
<%@ page import="com.autonomy.aci.ActionParameter" %>
<%@ page import="com.autonomy.aci.businessobjects.Agent" %>
<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>

<%

// Set up services 
PortalService service = ServiceFactory.getService(request, response, AgentConstants.PORTLET_NAME);

// find the agent to edit from the agent list and set as the selected agent
ArrayList agents = (ArrayList)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_AGENT_LIST);
String sAgentIdx = service.getRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX));
if(StringUtils.strValid(sAgentIdx) && agents != null)
{
	int agentIdx = StringUtils.atoi(sAgentIdx, -1);
	if(-1 < agentIdx && agentIdx < agents.size())
	{
		// make sure we have all the info about this agent by reading from IDOL
		Agent selectedAgent = (Agent)agents.get(agentIdx);
		Agent updatedAgent = service.getIDOLService().useAgentFunctionality().getAgent(selectedAgent.getAgentname(), selectedAgent.getOwnername());
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT, updatedAgent);
	}
	
	// also set session flag to display the agent edit form
	service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SHOW_EDIT_FORM, Boolean.TRUE);
		
	// clear any matching documents being displayed
	service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS, null);
}
%>