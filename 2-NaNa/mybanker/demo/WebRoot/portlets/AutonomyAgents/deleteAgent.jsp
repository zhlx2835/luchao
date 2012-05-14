<%@ page import="java.util.List"%>
<%@ page import="com.autonomy.aci.ActionParameter" %>
<%@ page import="com.autonomy.aci.businessobjects.Agent" %>
<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>

<%
// Set up services 
PortalService service = ServiceFactory.getService(request, response, AgentConstants.PORTLET_NAME);

// find the agent to edit from the agent list and delete
List agents = (List)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_AGENT_LIST);
String sAgentIdx = service.getRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX));
if(StringUtils.strValid(sAgentIdx) && agents != null)
{
	int agentIdx = StringUtils.atoi(sAgentIdx, -1);
	if(-1 < agentIdx && agentIdx < agents.size())
	{
		Agent agentToDelete = (Agent)agents.get(agentIdx);
		service.getIDOLService().useAgentFunctionality().deleteAgent(agentToDelete);
		
		// invalidate result list for deleted agent
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS, null);
	}
}
%>