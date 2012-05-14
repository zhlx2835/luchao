<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.aci.ActionParameter" %>
<%@ page import="com.autonomy.aci.businessobjects.ResultDocument" %>
<%@ page import="com.autonomy.aci.businessobjects.User" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
<%@ page import="com.autonomy.aci.services.IDOLService" %>
<%@ page import="com.autonomy.portlet.constants.RetrievalConstants"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>
<%@ page import="com.autonomy.portlet.resultpages.BatchedResultPages"%>
<%@ page import="com.autonomy.portlet.resultpages.SuggestResultPages"%>
<%@ page import="java.util.ArrayList"%>

<%
request.setCharacterEncoding("utf-8");

// Set up services 
PortalService service = ServiceFactory.getService(request, response, RetrievalConstants.PORTLET_NAME);

doIDOLSuggest(service);
%>

<%!
private void doIDOLSuggest(PortalService service) throws AciException
{
	IDOLService idol = service.getIDOLService();
	if(idol != null)
	{
		ArrayList suggestDocs = readSuggestDocsFromForm(service);
		ArrayList suggestParameters = convertSuggestFormToActionParameters(service);
		int batchSize = StringUtils.atoi(getRequestParam(service, RetrievalConstants.REQUEST_PARAM_NUM_RESULTS), 6);

		BatchedResultPages resultPages = new SuggestResultPages(service, suggestParameters, suggestDocs, batchSize);
		service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_RESULT_HITS, resultPages);
	}
	else
	{
		setError(service, "Could not perform suggestion as no IDOL service is available.");
	}
}

private ArrayList convertSuggestFormToActionParameters(PortalService service)
{
	ArrayList suggestParameters = new ArrayList();

	suggestParameters.add(new ActionParameter("MinScore", 			getRequestParam(service, RetrievalConstants.REQUEST_PARAM_THRESHOLD)));
	suggestParameters.add(new ActionParameter("Sort", 					getRequestParam(service, RetrievalConstants.REQUEST_PARAM_SORT_BY)));
	suggestParameters.add(new ActionParameter("SecurityInfo", 	((User)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER)).getSecurityInfo()));
	suggestParameters.add(new ActionParameter("Sentences", 			3));
	suggestParameters.add(new ActionParameter("Characters", 		300));
	suggestParameters.add(new ActionParameter("Print",					"all"));
	suggestParameters.add(new ActionParameter("XMLMeta", 				true));
	suggestParameters.add(new ActionParameter("Summary",				"context"));
	suggestParameters.add(new ActionParameter("Combine", 				"Simple"));			
	suggestParameters.add(new ActionParameter("OutputEncoding",	"utf8"));
	suggestParameters.add(new ActionParameter("AnyLanguage",		service.readConfigParameter("ResultsInAnyLanguage", "")));
	if(StringUtils.isTrue(getRequestParam(service, RetrievalConstants.REQUEST_PARAM_USE_DATE)))
	{
		suggestParameters.add(new ActionParameter("MinDate",		getMinDate(service)));
		suggestParameters.add(new ActionParameter("MaxDate",		getMaxDate(service)));
	}
    
    String[] infoSources = service.getRequestParameterValues(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES));
	if(infoSources != null && infoSources.length > 0)
	{
		suggestParameters.add(new ActionParameter("DatabaseMatch", StringUtils.combine(infoSources, "+")));
	}

	return suggestParameters;
}

private ArrayList readSuggestDocsFromForm(PortalService service)
{
	ArrayList suggestDocs = new ArrayList();
	
	// see if there is a result list stored on session.
	BatchedResultPages resultPages = (BatchedResultPages)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_RESULT_HITS);
	if(resultPages != null)
	{
		ArrayList resultDocuments = new ArrayList();
		resultDocuments.addAll(resultPages.getCurrentPage().getResults());
		
		// read the suggest doc indeces from the form
		String[] suggestDocsIndeces = service.getRequestParameterValues(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SUGGEST_DOCS));
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

private String getMinDate(PortalService service)
{
	StringBuffer minDate = new StringBuffer();
	minDate.append(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY), ""))
				 .append("/")
				 .append(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH), ""))
				 .append("/")
				 .append(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR), ""));
	return minDate.toString();
}
private String getMaxDate(PortalService service)
{
	StringBuffer maxDate = new StringBuffer();
	maxDate.append(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY), ""))
				 .append("/")
				 .append(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH), ""))
				 .append("/")
				 .append(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR), ""));
	return maxDate.toString();
}

private static String getRequestParam(PortalService service, String paramName)
{
	return service.getSafeRequestParameter(service.makeParameterName(paramName), "").trim();
}

/* will be a method on PortalService */
private void setError(PortalService service, String sErrorMess)
{
	if(service != null && StringUtils.strValid(sErrorMess))
	{
		// append any existing error message
		String sCurrentError = (String)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_ERROR_MESSAGE);
		if(StringUtils.strValid(sCurrentError))
		{
			sErrorMess = sCurrentError + "<br />" + sErrorMess;
		}
		service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_ERROR_MESSAGE, sErrorMess);
	}
}

private void mylog(String s)
{
	System.out.println("refineQuery: " + s);
}
%>