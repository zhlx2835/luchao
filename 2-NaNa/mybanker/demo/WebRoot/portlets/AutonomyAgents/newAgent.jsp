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

// set session flag to display the agent edit form
service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SHOW_EDIT_FORM, Boolean.TRUE);
		
// clear the selected agent so it is not used to populated the agent form
service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT, null);

// clear any matching documents being displayed
service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS, null);
%>

<%!
private static void mylog(String s)
{
	System.out.println("newAgent.jsp " + s);
}
%>