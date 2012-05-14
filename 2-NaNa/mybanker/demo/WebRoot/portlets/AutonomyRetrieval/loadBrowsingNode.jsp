<%@ page import="java.util.ArrayList,
                 java.util.Iterator,
                 java.util.List,

                 com.autonomy.aci.ActionParameter,
                 com.autonomy.aci.businessobjects.ResultList,
                 com.autonomy.aci.exceptions.SecurityInfoExpiredException,
                 com.autonomy.APSL.PortalService,
                 com.autonomy.APSL.ServiceFactory,
                 com.autonomy.portlet.constants.RetrievalConstants,
                 com.autonomy.portlet.resultpages.BatchedResultPages,
                 com.autonomy.portlet.resultpages.ParametricResultPages,
                 com.autonomy.portlet.resultpages.QueryExpansionResultPages,
                 com.autonomy.portlet.resultpages.ResultClusterResultPages,
                 com.autonomy.portlet.PortletUtils,
                 com.autonomy.tree.Tree,
                 com.autonomy.tree.TreeNode,
                 com.autonomy.tree.TreePath,
                 com.autonomy.tree.TreeUtils,
                 com.autonomy.utilities.NameValuePair,
                 com.autonomy.utilities.StringUtils,
                 com.autonomy.webapps.utils.parametric.ParametricNode,
                 com.autonomy.webapps.utils.queryexpansion.QueryExpansionNode,
                 com.autonomy.webapps.utils.resultclustering.ResultCluster" %>

<%
request.setCharacterEncoding("utf-8");

// Set up services
PortalService service = ServiceFactory.getService(request, response, RetrievalConstants.PORTLET_NAME);

String browsePathValue = service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_EXPANSION_PATH));

if(getBrowsingType(service).equalsIgnoreCase("DynamicClustering") && browsePathValue != null && browsePathValue.startsWith("0"))
{
	// See queryUtils_include.jspf

	// Expand and display results
	expandCluster(service, browsePathValue);
	BatchedResultPages clusterResults = retrieveQSClusterDocuments(service, browsePathValue);

	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_RESULT_HITS, clusterResults);
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_SELECTED_CLUSTER, browsePathValue);
}
else if(getBrowsingType(service).equalsIgnoreCase("DynamicThesaurus") && browsePathValue != null && browsePathValue.startsWith("0"))
{
	// See queryUtils_include.jspf

	// Expand the node
	expandThesaurus(service, browsePathValue);

	// Alter the query parameters to have the correct query text for this node
	ArrayList queryParameters = (ArrayList)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS);
	replaceActionParameter(queryParameters, IDOLConstants.TEXT_PARAM_NAME, buildThesaurusQueryText(service, browsePathValue));

	// Redo the query
	doQuery(service);

	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_SELECTED_CLUSTER, browsePathValue);
}
else if(getBrowsingType(service).equalsIgnoreCase("AQG") && browsePathValue != null && browsePathValue.startsWith("0"))
{
	// See queryUtils_include.jspf

	// Alter the query parameters to have the correct query text for this node
	ArrayList queryParameters = (ArrayList)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS);
	replaceActionParameter(queryParameters, IDOLConstants.TEXT_PARAM_NAME, buildAQGQueryText(service, browsePathValue));

	// Redo the query
	doQuery(service);

	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_SELECTED_CLUSTER, browsePathValue);
}
else if(getBrowsingType(service).equalsIgnoreCase("IdeasCloud"))
{
	// See queryUtils_include.jspf
	
	// Alter the query paramaters to have the correct text for this droplet
	ArrayList queryParameters = (ArrayList)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS);
	replaceActionParameter(queryParameters, IDOLConstants.TEXT_PARAM_NAME, buildIdeasCloudQueryText(service, browsePathValue));
	
	// Redo the query
	doQuery(service);
	
	// Don't need to set SESSION_ATTRIB_SELECTED_CLUSTER here, since we don't use it in display
	}
else
{
	Tree tree = (Tree)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_TREE);
	if(StringUtils.strValid(browsePathValue) && tree != null)
	{
		TreePath browsingPath = new TreePath(browsePathValue);
		TreeNode browsingNode = tree.findNode(browsingPath);
		if(browsingNode != null)
		{
			// record chosen browsingNode so we can refer to it in other pages
			service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_SELECTED_CLUSTER, browsingNode);

			// display sub nodes
			browsingNode.setExpanded(true);

			// read in the subnodes of the chosen node
			TreeUtils treeUtility = (TreeUtils)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_UTIL);
			if(treeUtility != null)
			{
				try
				{
					treeUtility.populateSubNodes(tree, browsingPath);
				}
				catch (SecurityInfoExpiredException sieex)
        		{
					String sSecString = PortletUtils.getUserSecurityString(service.getUAServer(), (service.getUser()).getName());
					treeUtility.updateSecurityInfo(sSecString);
					try
					{
						treeUtility.populateSubNodes(tree, browsingPath);
					}
					catch (SecurityInfoExpiredException newsieex)
        			{
        			}
        		}
			}

			// generate batched result pages for the node and set on session
			BatchedResultPages pages  = null;
			if(browsingNode instanceof ParametricNode)
			{
				NameValuePair browsingField = new NameValuePair();
				browsingField.setName(service.readConfigParameter("ParametricBrowsing.fieldname", ""));
				browsingField.setValue(getRequestParam(service, RetrievalConstants.REQUEST_PARAM_EXPANSION_PATH));

				pages = new ParametricResultPages(service, browsingField);
			}
			else if(browsingNode instanceof QueryExpansionNode)
			{
				pages = new QueryExpansionResultPages(service, (QueryExpansionNode)browsingNode);
			}
			else if(browsingNode instanceof ResultCluster)
			{
				pages = new ResultClusterResultPages(service, (ResultCluster)browsingNode);
			}
			service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_RESULT_HITS, pages);
		}
	}
}
%>

<%!

private void mylog(String s)
{
	System.out.println("loadBrowsingNode: " + s);
}

%><%@ include file="queryUtils_include.jspf" %>