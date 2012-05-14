<%-- federated includes, will go once federated functionality has its own api --%>
<%@ page import="java.io.IOException,
                 java.net.HttpURLConnection,
                 java.net.MalformedURLException,
                 java.net.URL,

                 com.autonomy.utilities.ByteArrayBuffer,
                 com.autonomy.utilities.HTTPUtils,
                 com.autonomy.webapps.utils.federated.FederatedResult"%>

<%@ page import="java.util.ArrayList,
                 java.util.Iterator,
                 java.util.List,
                 java.util.Properties,

                 com.autonomy.aci.ActionParameter,
                 com.autonomy.aci.businessobjects.ResultList,
                 com.autonomy.aci.businessobjects.User,
                 com.autonomy.aci.constants.AciConstants,
                 com.autonomy.aci.constants.IDOLConstants,
                 com.autonomy.aci.exceptions.AciException,
                 com.autonomy.aci.exceptions.SecurityInfoExpiredException,
                 com.autonomy.aci.services.IDOLService,
                 com.autonomy.aci.services.ParametricRetrievalFunctionality,
                 com.autonomy.APSL.PortalService,
                 com.autonomy.APSL.ServiceFactory,
                 com.autonomy.portlet.constants.RetrievalConstants,
                 com.autonomy.portlet.resultpages.BatchedResultPages,
                 com.autonomy.portlet.resultpages.QueryResultPages,
                 com.autonomy.portlet.PortletUtils,
                 com.autonomy.tree.Tree,
                 com.autonomy.tree.TreeUtils,
                 com.autonomy.utilities.StringUtils,
                 com.autonomy.webapps.utils.parametric.ParametricFieldInfo,
                 com.autonomy.webapps.utils.querysummary.tree.QSClusterTree,
                 com.autonomy.webapps.utils.queryexpansion.QueryExpansionUtils,
                 com.autonomy.webapps.utils.queryexpansion.QueryExpansionWithCountUtils"%><%

request.setCharacterEncoding("utf-8");

// Set up services
PortalService service = ServiceFactory.getService(request, response, RetrievalConstants.PORTLET_NAME);

// Perform the main search
doIDOLQuery(service);

// Generate the query summary
doBrowsingQuery(service);

// Perform the federated search
doFederatedQuery(service);

%>

<%!
// Routine for the main query
private static void doIDOLQuery(PortalService service)
{
	// Clear session variable from the previous query
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS, null);

	// See queryUtils_include.jspf for doQuery
	doQuery(service);
}

// Routine to generate the query summary tree
private static void doBrowsingQuery(PortalService service)
{
	// Clear session variables from previous browsing queries
	service.setSessionAttribute("QuerySummaryActionParameters", null);
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_SELECTED_CLUSTER, null);

	try
	{
		if(getBrowsingType(service).equalsIgnoreCase("DynamicClustering"))
		{
			// See queryUtils_include.jspf for getInitialDynamicClusteringTree
			service.setSessionAttribute("QuerySummaryTree", getInitialDynamicClusteringTree(service));
		}
		else if(getBrowsingType(service).equalsIgnoreCase("DynamicThesaurus"))
		{
			// See queryUtils_include.jspf for getInitialDynamicClusteringTree
			service.setSessionAttribute("QuerySummaryTree", getInitialDynamicThesaurusTree(service));
		}
		else if(getBrowsingType(service).equalsIgnoreCase("AQG"))
		{
			// See queryUtils_include.jspf for getInitialAQGTree
			service.setSessionAttribute("AQGTree", getInitialAQGTree(service));
		}
		else if(getBrowsingType(service).equalsIgnoreCase("IdeasCloud"))
		{
			// See queryUtils_include.jspf for getInitialIdeasCloud
			service.setSessionAttribute("IdeasCloud", getInitialIdeasCloud(service));
		}
		else
		{
			// Old style summary (QuerySuggestion/ResultClustering) or ParametricBrowsing
			Tree tree = null;

			TreeUtils treeUtility = (TreeUtils)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_UTIL);
			if(treeUtility != null)
			{
				// need to do this for performance reasons but ugly
				if(treeUtility instanceof QueryExpansionUtils)
				{
					QueryResultPages batchedPages = (QueryResultPages)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_RESULT_HITS);
					if(batchedPages != null)
					{
						if(treeUtility instanceof QueryExpansionUtils)
						{
							((QueryExpansionUtils)treeUtility).setInitialQuerySummaryTerms(batchedPages.getInitialQuerySummaries());

							if(treeUtility instanceof QueryExpansionWithCountUtils)
							{
								int numDocsToCluster = StringUtils.atoi(getRequestParam(service, RetrievalConstants.REQUEST_PARAM_NUM_CLUSTERED_DOCS), 200);
								((QueryExpansionWithCountUtils)treeUtility).setNumInitialDocsToCluster(numDocsToCluster);
							}
						}
					}
				}

                try
                {
                    tree = treeUtility.buildInitialTree((ArrayList)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS));

                    tree.getRoot().setExpanded(true);
                }
                catch (SecurityInfoExpiredException sieex)
                {
                    String sSecString = PortletUtils.getUserSecurityString(service.getUAServer(), (service.getUser()).getName());
                    service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS, updateSecurityInfo((ArrayList)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS), sSecString));
                    try
                    {
                        tree = treeUtility.buildInitialTree((ArrayList)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS));
                        tree.getRoot().setExpanded(true);
                    }
                    catch (Exception ex)
                    {
                        mylog("WARNING: buildInitialTree returns null");
                    }
                }
                catch(Exception e)
                {
                    mylog("WARNING: buildInitialTree returns null");
                }
            }
			service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_TREE, tree);
		}
	}
	catch(AciException acie)
	{
		// We assume that any error handling is already being done in the main query
	}
}

private static ArrayList updateSecurityInfo(ArrayList alQueryParameters, String sSecurityInfo)
{
    ArrayList _updatedQueryParameters = new ArrayList();
    ActionParameter requiredParam = null;
    if(alQueryParameters != null)
    {
        for(int paramIdx = 0; paramIdx < alQueryParameters.size() && requiredParam ==  null; paramIdx++)
        {
            ActionParameter param = (ActionParameter)alQueryParameters.get(paramIdx);
            if(param.getName().equalsIgnoreCase(IDOLConstants.QUERY_SECURITY_INFO_PARAM_NAME))
            {
                //requiredParam = param;
                _updatedQueryParameters.add(new ActionParameter(IDOLConstants.QUERY_SECURITY_INFO_PARAM_NAME, sSecurityInfo));
                continue;
            }
            _updatedQueryParameters.add(param);
        }
    }
    alQueryParameters = _updatedQueryParameters;
    return alQueryParameters;
}


private static void doFederatedQuery(PortalService service)
{
	// Clear the results of any previous search
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_FEDERATED_RESULTS, null);

	if(StringUtils.isTrue(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FEDERATED), "false")))
	{
		String[] selectedFedEngines = service.getRequestParameterValues(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_FED_ENGINES));
		if(selectedFedEngines != null && selectedFedEngines.length > 0)
		{
			ArrayList allFedEngineResults = new ArrayList();
			// read the query and URL encode so we can support any character
			String queryText = getRequestParam(service, RetrievalConstants.REQUEST_PARAM_QUERY_TEXT);
			queryText = HTTPUtils.URLEncode(queryText, "utf-8");
			// send query to each selected engine and extract hits from responses
			for (int selectedFedEngineIdx = 0; selectedFedEngineIdx < selectedFedEngines.length; selectedFedEngineIdx++)
			{
				String fedEngineName = selectedFedEngines[selectedFedEngineIdx];
				// look up the url to send the query to
				String queryUrl = service.readConfigParameter("FederatedEngine." + fedEngineName + ".url", "");
				try
				{
					// send federated query request
					String fedEngineResponse = getURLContents(service, queryUrl + queryText);
					// parse and store response
					allFedEngineResults.add(extractFederatedResults(service, fedEngineName, fedEngineResponse));
				}
				catch(MalformedURLException murle)
				{
					setError(service, "The federated query for the " + fedEngineName + " engine could not be sent. This is probably due to an incorrect configuration of the engine's query URL, FederatedEngine." + fedEngineName + ".url=" + queryUrl);
				}
				catch(IOException ioe)
				{
					setError(service, "An error occured when sending the federated query to the " + fedEngineName + " engine:<br/> " + ioe.getMessage());
				}
			}
			// save federated results on session
			service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_FEDERATED_RESULTS, allFedEngineResults);
		}
	}
}

public static ArrayList extractFederatedResults(PortalService service, String engineName, String engineResponse)
{
	ArrayList alDocList = new ArrayList();

	// read document and result delimiter tags from config
	String sStartTag       = service.readConfigParameter("FederatedEngine." + engineName + ".start", "");
	String sEndTag         = service.readConfigParameter("FederatedEngine." + engineName + ".end", "");
	String sRefStart       = service.readConfigParameter("FederatedEngine." + engineName + ".refstart", "");
	String sRefEnd         = service.readConfigParameter("FederatedEngine." + engineName + ".refend", "");
	String sRefPrefix      = service.readConfigParameter("FederatedEngine." + engineName + ".refprefix", "");
	String sTitleStart     = service.readConfigParameter("FederatedEngine." + engineName + ".titlestart", "");
	String sTitleEnd       = service.readConfigParameter("FederatedEngine." + engineName + ".titleend", "");
	String sSummaryStart   = service.readConfigParameter("FederatedEngine." + engineName + ".summarystart", "");
	String sSummaryEnd     = service.readConfigParameter("FederatedEngine." + engineName + ".summaryend", "");
	String sEngineIconName = service.readConfigParameter("FederatedEngine." + engineName + ".iconname", "");
	String sDocSeparator   = service.readConfigParameter("FederatedEngine." + engineName + ".docseparator", "");

	int nPositionOfStart 	= (engineResponse).indexOf(sStartTag);
	int nPositionOfEnd 		= (engineResponse).lastIndexOf(sEndTag);

	if(nPositionOfStart != -1 && nPositionOfEnd != -1)
	{
		String sParsedString 	= engineResponse.substring(nPositionOfStart, nPositionOfEnd);
		Iterator itDocumentEntries = StringUtils.tokenise(sParsedString, sDocSeparator);
		while(itDocumentEntries.hasNext())
		{
			String sDocumentEntry = ((String)itDocumentEntries.next()).trim();
			if(StringUtils.strValid(sDocumentEntry))
			{
				String sTitleString     = getStringBetween(sDocumentEntry, sTitleStart, sTitleEnd);
				String sSummaryString   = getStringBetween(sDocumentEntry, sSummaryStart, sSummaryEnd);
				String sReferenceString = getStringBetween(sDocumentEntry, sRefStart, sRefEnd);
				if (StringUtils.strValid(sReferenceString))
				{

					sReferenceString = sRefPrefix + sReferenceString;
				}

				if(StringUtils.strValid(sTitleString) &&
					 StringUtils.strValid(sSummaryString) &&
					 StringUtils.strValid(sReferenceString)
					 )
				{
					FederatedResult result =  new FederatedResult();
					result.title = sTitleString;
					result.summary = sSummaryString;
					result.reference = sReferenceString;
					if(StringUtils.strValid(sEngineIconName))
					{
						result.image = "/" + sEngineIconName;
					}

					alDocList.add(result);
				}
			}
		}
	}

	return alDocList;
}

private static String getStringBetween(String s, String sStart, String sEnd)
{
	String sSubString = "";
	if(s != null && sStart != null && sEnd != null)
	{
		int nStartIdx = s.indexOf(sStart) + sStart.length();
		int nEndIdx = s.indexOf(sEnd, nStartIdx);

		if(nStartIdx > -1 && nEndIdx > 0 && nStartIdx < nEndIdx)
		{
			sSubString = s.substring(nStartIdx, nEndIdx);
		}
	}
	return sSubString;
}

public static String getURLContents(PortalService service, String sURL) throws MalformedURLException, IOException
{
	String proxyHost = service.readConfigParameter("ProxyHost", "");
	String proxyPort = service.readConfigParameter("ProxyPort", "");
	if(StringUtils.strValid(proxyHost) && StringUtils.strValid(proxyPort))
	{
			Properties systemSettings = System.getProperties();
			systemSettings.put("http.proxyHost", proxyHost);
			systemSettings.put("http.proxyPort", proxyPort);
    		System.setProperties(systemSettings);
    }
	URL url = new URL(sURL);
	HttpURLConnection connection = (HttpURLConnection)url.openConnection();;
	// must set the user-agent header or some engines will return a 403 - forbidden error
	connection.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; T312461)" );
	ByteArrayBuffer byb = new ByteArrayBuffer(connection.getInputStream(), 4096);
	byb.setEncoding("UTF-8");

	return byb.toString();
}

private static void mylog(String s)
{
	System.out.println("doQuery: " + s);
}

%><%@ include file="queryUtils_include.jspf" %>
