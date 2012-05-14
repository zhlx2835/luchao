<%@ page import="com.autonomy.APSL.PortalService,
                 com.autonomy.APSL.ServiceFactory,
                 com.autonomy.portlet.constants.RetrievalConstants,
                 com.autonomy.tree.Tree,
                 com.autonomy.tree.TreePath,
                 com.autonomy.utilities.StringUtils,
                 com.autonomy.webapps.utils.querysummary.tree.*"%><%

// Set up services
PortalService service = ServiceFactory.getService(request, response, RetrievalConstants.PORTLET_NAME);

String contractionPath = service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_EXPANSION_PATH));

if((getBrowsingType(service).equalsIgnoreCase("DynamicClustering") || getBrowsingType(service).equalsIgnoreCase("DynamicThesaurus")) && contractionPath != null && contractionPath.startsWith("0"))
{
	QSClusterTree qsClusterTree = (QSClusterTree)service.getSessionAttribute("QuerySummaryTree");

	if(qsClusterTree != null)
	{
		QSCluster clusterToContract = qsClusterTree.findCluster(new QSClusterPath(contractionPath));

		if(clusterToContract != null)
		{
			clusterToContract.setExpanded(false);
		}
	}
}
else
{
	Tree tree = (Tree)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_TREE);
	if(StringUtils.strValid(contractionPath) && tree != null)
	{
		tree.findNode(new TreePath(contractionPath)).setExpanded(false);
	}
}
%><%!

private static String getBrowsingType(PortalService service)
{
	String browsingType = service.readConfigParameter("QuerySummaryType", null);

	if(browsingType == null)
	{
		// Old config parameter name
		browsingType = service.readConfigParameter("ResultBrowsingType", "");
	}

	return browsingType;
}

%>