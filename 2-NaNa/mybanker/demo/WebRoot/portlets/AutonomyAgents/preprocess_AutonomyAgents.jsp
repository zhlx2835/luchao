<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.utilities.StringUtils"%>

<%@ page contentType="text/html; charset=utf-8" %>
<%
response.setContentType("text/html; charset=utf-8");
%>

<%
// Set up services 
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)AgentConstants.PORTLET_NAME);
 
// what action do we need to take  /* will be replaced by PortalService.getActionPage */
String processPage = getActionPage(service);
if(StringUtils.strValid(processPage))
{
	// some pages do not need to be preprocessed
	if(!processPage.equals(AgentConstants.JSP_PAGE_SHOW_AGENT))
	{
		pageContext.include(processPage);

		// set flag on session to allow communication with AutonomyAgents.jsp	
		service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_PREPROCESS_FLAG, new Boolean(true));
	}
}
%>

<%!
/* will be replaced by PortalService.getActionPage */
private String getActionPage(PortalService service) throws Exception
{
	return service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE), "");
}

private void mylog(String s)
{
	System.out.println("preprocess_AutonomyAgent.jsp: " + s);
}
%>