<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.RetrievalConstants"%>
<%@ page import="com.autonomy.utilities.StringUtils"%>
<%@ page import="com.autonomy.portlet.resultpages.BatchedResultPages"%>

<%
response.setContentType("text/html; charset=utf-8");

// Set up services 
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)RetrievalConstants.PORTLET_NAME);

// pull results from session
BatchedResultPages resultPages = (BatchedResultPages)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_RESULT_HITS);
if(resultPages != null)
{
	String batchParamValue = service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_BATCH_START), null);
	int batchToShow = StringUtils.atoi(batchParamValue, -1);
	if(batchToShow > 0)
	{
		resultPages.moveToPage(batchToShow - 1);
	}
}
%>