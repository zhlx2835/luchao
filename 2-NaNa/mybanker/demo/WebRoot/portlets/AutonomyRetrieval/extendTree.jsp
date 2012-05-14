<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.RetrievalConstants"%>
<%@ page import="com.autonomy.tree.Tree"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>
<%@ page import="com.autonomy.webapps.utils.queryexpansion.QueryExpansionTree" %>

<%
request.setCharacterEncoding("utf-8");

// Set up services 
PortalService service = ServiceFactory.getService(request, response, RetrievalConstants.PORTLET_NAME);

Tree tree = (Tree)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_TREE);
if(tree != null)
{
	if(tree instanceof QueryExpansionTree)
	{
		((QueryExpansionTree)tree).showMoreBranches();
	}
}
%>