<%@ page import="com.autonomy.APSL.PortalService" %>
<%@ page import="com.autonomy.APSL.ServiceFactory" %>
<%@ page import="com.autonomy.portlet.constants.RetrievalConstants" %>
<%@ page import="com.autonomy.tree.Tree" %>
<%@ page import="com.autonomy.tree.TreeNode" %>
<%@ page import="com.autonomy.utilities.JavaScriptUtils" %>
<%@ page import="com.autonomy.webapps.utils.queryexpansion.QueryExpansionTree" %>
<%@ page import="com.autonomy.webapps.utils.resultclustering.ResultClusterTree" %>
<%@ page import="com.autonomy.webapps.utils.parametric.ParametricTree" %>
<%@ page import="com.autonomy.webapps.utils.querysummary.tree.QSClusterTree" %>
<%@ page import="com.autonomy.webapps.utils.querysummary.cloud.QSIdeasCloud" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ResourceBundle" %>

<%
response.setContentType("text/html; charset=utf-8");

//get Locale information from session
String sLocale =(String)session.getAttribute(RetrievalConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(RetrievalConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(RetrievalConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// Set up services
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)RetrievalConstants.PORTLET_NAME);

// AQS
QSClusterTree qsClusterTree = (QSClusterTree)service.getSessionAttribute("QuerySummaryTree");

if(qsClusterTree != null)
{
	%><%@ include file="displayQuerySummary_include.jspf" %><%
}
else
{
	qsClusterTree = (QSClusterTree)service.getSessionAttribute("AQGTree");

	if(qsClusterTree != null)
	{
		%><%@ include file="displayAQG_include.jspf" %><%
	}
}

QSIdeasCloud qsIdeasCloud = (QSIdeasCloud)service.getSessionAttribute("IdeasCloud");

if(qsIdeasCloud != null)
{
	%><%@ include file="displayIdeasCloud_include.jspf" %><%
}

// pull query expansion tree from session
Tree tree = (Tree)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_TREE);
if(tree != null)
{
	// see if there is a node already selected
	TreeNode selectedNode = (TreeNode)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_SELECTED_CLUSTER);

	if(tree instanceof ResultClusterTree)
	{
%>
		<%@ include file="displayResultClusters_include.jspf" %>
<%
	}
	else if(tree instanceof QueryExpansionTree)
	{
%>
		<%@ include file="displayQueryExpansion_include.jspf" %>
<%
	}
	else if(tree instanceof ParametricTree)
	{
%>
		<%@ include file="displayParametricExpansion_include.jspf" %>
<%
	}

	// navigate to selected node anchor
	if(selectedNode != null)
	{
		%>
		<script type="text/javascript">
			document.location.hash = '<%= JavaScriptUtils.escape(selectedNode.getName()) %>';
		</script>
		<%
	}
}

%><%!

private static void mylog(String s)
{
	System.out.println("displayTree: " + s);
}

%>