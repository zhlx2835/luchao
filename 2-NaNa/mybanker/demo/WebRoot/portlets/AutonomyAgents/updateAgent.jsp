<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.aci.ActionParameter" %>
<%@ page import="com.autonomy.aci.businessobjects.Agent" %>
<%@ page import="com.autonomy.aci.businessobjects.ResultDocument" %>
<%@ page import="com.autonomy.aci.businessobjects.ResultList" %>
<%@ page import="com.autonomy.aci.businessobjects.User" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
<%@ page import="com.autonomy.aci.services.IDOLService" %>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.portlet.resultpages.BatchedResultPages"%>
<%@ page import="com.autonomy.portlet.resultpages.AgentResultPages"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Arrays"%>

<%
request.setCharacterEncoding("utf-8");

// Set up services
PortalService service = ServiceFactory.getService(request, response, AgentConstants.PORTLET_NAME);

// get the agent to update. if there is no agent set on the session, then we are creating a new agent
Agent agentToUpdate = (Agent)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT);
if(agentToUpdate != null)
{
	// have to have the old name to update the agent without using ID
	String sOldName = agentToUpdate.getAgentname();

	// read agent edit form parameters and set on agent
	updateAgentFromEditForm(service, agentToUpdate);

	/*
	 * 	if agentName does not change then this allows aci api not to append newAgentName parameter
	 *  in the agentEdit command otherwise 7.3.9 or above version community component will
	 *  just ignore this command. Better to move this check into aci api in the future.
	 *
	 */
	if(agentToUpdate.getAgentname().equals(sOldName))
	{
		agentToUpdate.setAgentname("");
	}

	try
	{
	// update agent in IDOL
	service.getIDOLService().useAgentFunctionality().updateAgent(agentToUpdate, sOldName);
	}
	catch(AciException acie)
	{
		setError(service, acie.getMessage());
	}
}
else
{
	agentToUpdate = new Agent();
	agentToUpdate.setOwnername(service.getUser().getName());

	// read agent edit form parameters and set on agent
	updateAgentFromEditForm(service, agentToUpdate);

	try
	{
	// add agent in IDOL
	service.getIDOLService().useAgentFunctionality().createAgent(agentToUpdate);
	}
	catch(AciException acie)
	{
		setError(service, acie.getMessage());
	}
}

// set agent as selected agent
service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT, agentToUpdate);

// retrieve the modified agent's results
BatchedResultPages resultPages = new AgentResultPages(service, agentToUpdate, extraParameters(service));
service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS, resultPages);
%>

<%!
private void updateAgentFromEditForm(PortalService service, Agent agent)
{
	agent.setAgentname(service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_NAME), ""));
	agent.setTraining(service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_TRAINING_TEXT), ""));
	agent.setNumResults(StringUtils.atoi(service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_NUM_RESULTS), null), 6));
	agent.setThreshold(StringUtils.atoi(service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_THRESHOLD), null), 40));
	agent.setMaxAgeOfResults(StringUtils.atoi(service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_MAX_AGE), null), 0));
	agent.setShownInCommunity(StringUtils.atob(service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_SHOWN_IN_COMMUNITY), "false"),false));
	agent.setAgentField("DRELanguageType", service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_QUERY_LANGUAGE), getUsersDefaultQueryLanguage(service)));
	agent.setAgentField("DRESort", service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_SORT_BY), "relevence"));

	String[] infoSources = service.getRequestParameterValues(service.makeParameterName(AgentConstants.REQUEST_PARAM_INFO_SOURCES));
	agent.setDatabases(new ArrayList(Arrays.asList(infoSources)));

	String[] asTrainingFiles = service.getRequestParameterValues(service.makeParameterName(AgentConstants.REQUEST_PARAM_TRAINING_FILES));
	// remove unchecked training files from those set on agent
	agent.setTrainingDocs(filterCheckedFiles(asTrainingFiles, agent));
}

private static ArrayList extraParameters(PortalService service)
{
	ArrayList getAgentResultsParams = new ArrayList();
	getAgentResultsParams.add(new ActionParameter("DRECombine", 		"Simple"));
	getAgentResultsParams.add(new ActionParameter("DRESummary",			"context"));
	getAgentResultsParams.add(new ActionParameter("DRESentences", 	3));
	getAgentResultsParams.add(new ActionParameter("DRECharacters", 	300));
	getAgentResultsParams.add(new ActionParameter("DREOutputEncoding",	"utf8"));
	getAgentResultsParams.add(new ActionParameter("DREXMLMeta",				true));

	return getAgentResultsParams;
}

private ArrayList filterCheckedFiles(String[] asFilesFromRequest, Agent agent)
{
	ArrayList alCheckedTrainingDocs = new ArrayList();
	if(asFilesFromRequest != null && agent != null)
	{
		ArrayList alOrigTrainingDocs = agent.getTrainingDocs();
		for(int nOrigDocIdx = 0; nOrigDocIdx < alOrigTrainingDocs.size(); nOrigDocIdx++)
		{
			ResultDocument doc = (ResultDocument)alOrigTrainingDocs.get(nOrigDocIdx);
			if(StringUtils.isStringInStringArray(asFilesFromRequest, doc.getDocReference(), false) != -1)
			{
				alCheckedTrainingDocs.add(doc);
			}
		}
	}
	return alCheckedTrainingDocs;
}


private String getUsersDefaultQueryLanguage(PortalService service)
{
	return ((User)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_USER)).getUserFieldValue("drelanguagetype", "");
}
/* will be a method on PortalService */
private void setError(PortalService service, String sErrorMess)
{
	if(service != null && StringUtils.strValid(sErrorMess))
	{
		// append any existing error message
		String sCurrentError = (String)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_ERROR_MESSAGE);
		if(StringUtils.strValid(sCurrentError))
		{
			sErrorMess = sCurrentError + "<br />" + sErrorMess;
		}
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_ERROR_MESSAGE, sErrorMess);
	}
}

private void mylog(String s)
{
	System.out.println("updateAgent.jsp: " + s);
}
%>