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
<%@ page import="java.util.List"%>

<%
request.setCharacterEncoding("utf-8");

// Set up services 
PortalService service = ServiceFactory.getService(request, response, AgentConstants.PORTLET_NAME);

// get the agent to retrain
Agent selectedAgent = (Agent)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT);

// do retraining
service.getIDOLService().useAgentFunctionality().retrainAgent(selectedAgent, readSuggestDocsFromForm(service));

// set retrained flag directly on agent object to avoid having to do an agent read on IDOL
selectedAgent.setRetrained(true);

// retrieve the modified agent's results
BatchedResultPages resultPages = new AgentResultPages(service, selectedAgent, extraParameters(service));
service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS, resultPages);
%>

<%!
private ArrayList readSuggestDocsFromForm(PortalService service)
{
	ArrayList suggestDocs = new ArrayList();
	
	// see if there is a result list stored on session.
	BatchedResultPages resultPage = (BatchedResultPages)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS);
	if(resultPage != null)
	{
		List resultDocuments = resultPage.getCurrentPage().getResults();
		
		// read the suggest doc indeces from the form
		String[] suggestDocsIndeces = service.getRequestParameterValues(service.makeParameterName(AgentConstants.REQUEST_PARAM_SUGGEST_DOCS));
		if(suggestDocsIndeces != null && suggestDocsIndeces.length > 0)
		{
			for(int docIdx = 0; docIdx < suggestDocsIndeces.length; docIdx++)
			{
				int suggestDocIdx = StringUtils.atoi(suggestDocsIndeces[docIdx], -1);
				if(-1 < suggestDocIdx && suggestDocIdx < resultDocuments.size())
				{
					ResultDocument suggestDoc = (ResultDocument)resultDocuments.get(suggestDocIdx);
					suggestDocs.add(suggestDoc);
				}
			}
		}
	}

	return suggestDocs;
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
	System.out.println("retrainAgent.jsp: " + s);
}
%>