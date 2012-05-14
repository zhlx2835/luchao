<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ page import="com.autonomy.aci.ActionParameter" %>
<%@ page import="com.autonomy.aci.businessobjects.Agent" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.portlet.resultpages.BatchedResultPages"%>
<%@ page import="com.autonomy.portlet.resultpages.AgentResultPages"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>

<%
request.setCharacterEncoding("utf-8");

// Set up services 
PortalService service = ServiceFactory.getService(request, response, AgentConstants.PORTLET_NAME);

// find the agent to view from the agent list, set as the selected agent and read the agent's 
// matching documents from IDOL
List agents = (List)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_AGENT_LIST);
String sAgentIdx = service.getRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_IDX));
if(StringUtils.strValid(sAgentIdx) && agents != null)
{
	int agentIdx = StringUtils.atoi(sAgentIdx, -1);
	if(-1 < agentIdx && agentIdx < agents.size())
	{
		Agent agent = (Agent)agents.get(agentIdx);
		BatchedResultPages resultPages = new AgentResultPages(service, agent, extraParameters(service));

		// record selected agent and its results
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT, agent);	
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS, resultPages);
	}
}
%>

<%!
private static List extraParameters(PortalService service)
{
	List getAgentResultsParams = new ArrayList();
	getAgentResultsParams.add(new ActionParameter("DRECombine", 		"Simple"));
	getAgentResultsParams.add(new ActionParameter("DRESummary",			"context"));
	getAgentResultsParams.add(new ActionParameter("DRESentences", 	3));
	getAgentResultsParams.add(new ActionParameter("DRECharacters", 	300));
	getAgentResultsParams.add(new ActionParameter("DREOutputEncoding",	"utf8"));
	getAgentResultsParams.add(new ActionParameter("DREXMLMeta",				true));

	return getAgentResultsParams;	
}
%>