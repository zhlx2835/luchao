<%@ page import="java.util.ArrayList,

                 com.autonomy.aci.ActionParameter,
                 com.autonomy.aci.exceptions.SecurityInfoExpiredException,
                 com.autonomy.APSL.PortalService,
                 com.autonomy.APSL.ServiceFactory,
                 com.autonomy.portlet.constants.RetrievalConstants,
                 com.autonomy.portlet.PortletUtils,
                 com.autonomy.tree.Tree,
                 com.autonomy.tree.TreeNode,
                 com.autonomy.tree.TreePath,
                 com.autonomy.tree.TreeUtils,
                 com.autonomy.utilities.StringUtils" %><%

request.setCharacterEncoding("utf-8");

// Set up services
PortalService service = ServiceFactory.getService(request, response, RetrievalConstants.PORTLET_NAME);

String expansionPathValue = service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_EXPANSION_PATH));

if(getBrowsingType(service).equalsIgnoreCase("DynamicClustering") && expansionPathValue != null && expansionPathValue.startsWith("0"))
{
	// See queryUtils_include.jspf for expandCluster
	expandCluster(service, expansionPathValue);
}
else if(getBrowsingType(service).equalsIgnoreCase("DynamicThesaurus") && expansionPathValue != null && expansionPathValue.startsWith("0"))
{
	// See queryUtils_include.jspf for expandThesaurus
	expandThesaurus(service, expansionPathValue);
}
else
{
	Tree tree = (Tree)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_TREE);
	if(StringUtils.strValid(expansionPathValue) && tree != null)
	{
		TreePath expansionPath = new TreePath(expansionPathValue);
		TreeNode nodeToExpand = tree.findNode(expansionPath);
		if(nodeToExpand != null)
		{
			// record chosen browsingNode so we can refer to it in other pages
			service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_SELECTED_CLUSTER, nodeToExpand);

			nodeToExpand.setExpanded(true);

			// read in the subnodes of the chosen node
			TreeUtils treeUtility = (TreeUtils)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_UTIL);
			if(treeUtility != null)
			{
				try
				{
					treeUtility.populateSubNodes(tree, expansionPath);
				}
				catch (SecurityInfoExpiredException sieex)
        		{
					String sSecString = PortletUtils.getUserSecurityString(service.getUAServer(), (service.getUser()).getName());
					treeUtility.updateSecurityInfo(sSecString);
					try
					{
						treeUtility.populateSubNodes(tree, expansionPath);
					}
					catch (SecurityInfoExpiredException newsieex)
        			{
	        			
        			}
        		}
			}
		}
	}
}

%><%@ include file="queryUtils_include.jspf" %>

