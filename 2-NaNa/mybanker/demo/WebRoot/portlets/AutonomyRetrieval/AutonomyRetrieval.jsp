<%@ page
    contentType="text/html; charset=utf-8"
         import="java.util.ArrayList,
                 java.util.Iterator,
                 java.util.List,

                 com.autonomy.aci.ActionParameter,
                 com.autonomy.aci.businessobjects.*,
                 com.autonomy.aci.exceptions.AciException,
                 com.autonomy.aci.exceptions.UserNotFoundException,
                 com.autonomy.aci.services.IDOLService,
                 com.autonomy.APSL.AutonomyPortalUser,
                 com.autonomy.APSL.PortalService,
                 com.autonomy.APSL.ServiceFactory,
                 com.autonomy.portlet.constants.RetrievalConstants,
                 com.autonomy.tree.TreeUtils,
                 com.autonomy.utilities.CSVTokenizer,
                 com.autonomy.utilities.StringUtils,
                 com.autonomy.webapps.utils.parametric.CSVFieldValueMapper,
                 com.autonomy.webapps.utils.parametric.FieldValueMapper,
                 com.autonomy.webapps.utils.parametric.ParametricFieldInfo,
                 com.autonomy.webapps.utils.parametric.ParametricUtils,
                 com.autonomy.webapps.utils.parametric.UnmodifiedFieldValueMapper,
                 com.autonomy.webapps.utils.queryexpansion.QueryExpansionQSWithCountUtils,
                 com.autonomy.webapps.utils.queryexpansion.QueryExpansionUtils,
                 com.autonomy.webapps.utils.resultclustering.ResultClusteringUtils"%><%

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

// Set up services
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)RetrievalConstants.PORTLET_NAME);

// update or create the User object /* will be replaced by PortalService.getUser */
updateUserSessionInfo(service);

// is there a 'do action but don't display anything' type page? /* will be replaced by PortalService.getActionPage */
String processPage = getActionPage(service);
if(StringUtils.strValid(processPage))
{
	pageContext.include(processPage);
}
else
{
	initialise(service);
}

%>
<html>
	<head>
		<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>">
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	</head>
	<body STYLE="background-color:transparent">
		<table class="pContainer">
			<tr>
				<!-- main page include -->
				<td>
					<table width="100%" border="0">
						<tr>
							<td colspan="2">
								<%@ include file="showError_include.jspf" %>
								<%@ include file="showMessage_include.jspf" %>
							</td>
						</tr>
						<tr>
							<td colspan="2">
<%
								out.flush();
								pageContext.include("displayQueryForm.jsp");
%>
							</td>
						</tr>
						<!-- This produces a simple seperator -->
						<tr>
							<td colspan="2">
								<a name="<%= service.makeFormActionLink(" ").substring(service.makeFormActionLink(" ").indexOf("#")+1) %>queryResultsTop"></a>
								<table width="100%" class="seperator">
									<tr><td/></tr>
								</table>
							</td>
						</tr>
						<tr>
							<td width="30%" align="left" valign="top">
<%
								out.flush();
								pageContext.include("displayTree.jsp");
%>
							</td>
							<td width="70%" align="left" valign="top">
<%
									out.flush();
									pageContext.include("displayResultPages.jsp");

									out.flush();
									pageContext.include("displayFederatedResults.jsp");
%>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</body>
</html>

<%!
/* will be replaced by PortalService.getActionPage */
private String getActionPage(PortalService service) throws Exception
{
	return service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PAGE), "");
}
/* will be replaced by PortalService.getUser */
private void updateUserSessionInfo(PortalService service)  throws AciException
{
	if(service != null)
	{
		// try to get user from session and check that it corresponds to the current user.
		// if not, read this user from Nore
		String sUsername = ((AutonomyPortalUser)service.getUser()).getName();
		User user = (User)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER);
		if(user == null || !user.getUsername().equals(sUsername))
		{
			// get the user functionality
			IDOLService idol = service.getIDOLService();
			if(idol != null)
			{
				try
				{
					user = idol.useUserFunctionality().getUser(sUsername);
				}
				catch(UserNotFoundException unfe)
				{
					setError(service, "Could not read user details for user " + sUsername + " as this user does not exist on IDOLServer.");
				}
			}
			else
			{
				setError(service, "No user functionality is available.");
			}
			// set on session or give warning that no user info could be loaded
			if(user != null)
			{
				service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER, user);
			}
			else
			{
				setError(service, "No user information could be read from IDOL.");
			}
		}
	}
}
/* will be a method on PortalService */
private void setError(PortalService service, String errorMessage)
{
	if(service != null && StringUtils.strValid(errorMessage))
	{
		// append any existing error message
		String sCurrentError = (String)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_ERROR_MESSAGE);
		if(StringUtils.strValid(sCurrentError))
		{
			errorMessage = sCurrentError + "<br />" + errorMessage;
		}
		service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_ERROR_MESSAGE, errorMessage);
	}
}

private void initialise(PortalService service) throws AciException
{
	checkForParametricInfo(service);
	checkForBrowsingUtils(service);
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_LAST_QUERY_PARAMS, null);
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_RESULT_HITS, null);
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_FEDERATED_RESULTS, null);
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_TREE, null);
	service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_SELECTED_CLUSTER, null);
	service.setSessionAttribute("QuerySummaryTree", null);
	service.setSessionAttribute("AQGTree", null);
	service.setSessionAttribute("IdeasCloud", null);
}

private void checkForParametricInfo(PortalService service) throws AciException
{
	if(service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO) == null)
	{
		service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO, loadParametricInfo(service));
	}
	else
	{
		resetParametricInfo(service);
	}
}
private void checkForBrowsingUtils(PortalService service)
{
	if(service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_UTIL) == null)
	{
		service.setSessionAttribute(RetrievalConstants.SESSION_ATTRIB_BROWSING_UTIL, loadBrowsingUtils(service));
	}
}

// Dynamic Clustering, Dynamic Thesaurus and AQG don't need this but Parametric Browsing does.
// Old style Query Suggestion and Result Clustering also use it.
private TreeUtils loadBrowsingUtils(PortalService service)
{
	TreeUtils treeUtility = null;

	String browsingType = service.readConfigParameter("QuerySummaryType", null);

	if(!StringUtils.strValid(browsingType))
	{
		// Old config parameter name
		browsingType = service.readConfigParameter("ResultBrowsingType", null);
	}

	if(StringUtils.strValid(browsingType))
	{
		if(browsingType.equalsIgnoreCase("QuerySuggestion"))
		{
			boolean countDocs = StringUtils.isTrue(service.readConfigParameter("QuerySuggestion.CountDocuments", ""));
			if(countDocs)
			{
				int numDocsToRetrieve = StringUtils.atoi(service.readConfigParameter("QuerySuggestion.NumResultToRetrieve", "500"), 500);
				int minDocsToCluster = StringUtils.atoi(service.readConfigParameter("QuerySuggestion.MinDocsToSubCluster", "3"), 3);
				int subClusterNumDocsThreshold = StringUtils.atoi(service.readConfigParameter("QuerySuggestion.SubClusterNumDocsThreshold", "60"), 60);
				int pDocsMultiplier = StringUtils.atoi(service.readConfigParameter("QuerySuggestion.PDocsMultiplier", "3"), 3);

				treeUtility = new QueryExpansionQSWithCountUtils(service.getIDOLService().useConceptRetrievalFunctionality(), minDocsToCluster, numDocsToRetrieve);
				((QueryExpansionQSWithCountUtils)treeUtility).setIsIncrementingThreshold(false);
				((QueryExpansionQSWithCountUtils)treeUtility).setSubClusterNumDocsThreshold(subClusterNumDocsThreshold);
				((QueryExpansionQSWithCountUtils)treeUtility).setPDocsMultiplier(pDocsMultiplier);
			}
			else
			{
				treeUtility = new QueryExpansionUtils(service.getIDOLService().useConceptRetrievalFunctionality());
			}
		}
		else if(browsingType.equalsIgnoreCase("ResultClustering"))
		{
			int numDocsToRetrieve = StringUtils.atoi(service.readConfigParameter("ResultClustering.NumResultToRetrieve", "500"), 500);
			int minDocsToCluster = StringUtils.atoi(service.readConfigParameter("ResultClustering.MinDocsToSubCluster", "3"), 3);

			treeUtility = new ResultClusteringUtils(service.getIDOLService().useConceptRetrievalFunctionality(), minDocsToCluster, numDocsToRetrieve);
		}
		else if(browsingType.equalsIgnoreCase("ParametricBrowsing"))
		{
			treeUtility = new ParametricUtils(service.getIDOLService().useParametricRetrievalFunctionality(), lookupBrowsingFieldInfo(service));
		}
	}

	return treeUtility;
}

private ParametricFieldInfo lookupBrowsingFieldInfo(PortalService service)
{
	ParametricFieldInfo browsingFieldInfo = null;

	String browsingFieldName = service.readConfigParameter("ParametricBrowsing.fieldname", "");
	List fieldInfoList = ((List)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO));
	if(fieldInfoList != null)
	{
		Iterator fieldInfoIt = fieldInfoList.iterator();
		while(fieldInfoIt.hasNext() && browsingFieldInfo == null)
		{
			ParametricFieldInfo fieldInfo = (ParametricFieldInfo)fieldInfoIt.next();
			if(fieldInfo.getIDOLFieldName().equals(browsingFieldName))
			{
				browsingFieldInfo = fieldInfo;
			}
		}
	}

	return browsingFieldInfo;
}

private ArrayList loadParametricInfo(PortalService service) throws AciException
{
	ArrayList parametricFields = null;

	int fieldCnt = StringUtils.atoi(service.readConfigParameter("ParametricField.number", null), 0);
	if(fieldCnt > 0)
	{
		parametricFields = new ArrayList();

		for(int fieldIdx = 0; fieldIdx < fieldCnt; fieldIdx++)
		{
			// must have a name for the parametric field in IDOL
			String idolFieldName = service.readConfigParameter("ParametricField." + fieldIdx + ".IDOLname", null);
			if(StringUtils.strValid(idolFieldName))
			{
				String displayFieldName = service.readConfigParameter("ParametricField." + fieldIdx + ".displayname", idolFieldName);

				ParametricFieldInfo fieldInfo = new ParametricFieldInfo(idolFieldName, displayFieldName);
				// do this field's values need processing?
				String fieldType = service.readConfigParameter("ParametricField." + fieldIdx + ".type", "IDOLvalue");
				if(fieldType.equalsIgnoreCase("mapped"))
				{
					List idolValues = new CSVTokenizer(service.readConfigParameter("ParametricField." + fieldIdx + ".mapped.IDOLvalues", null)).asList();
					List displayNames = new CSVTokenizer(service.readConfigParameter("ParametricField." + fieldIdx + ".mapped.displaynames", null)).asList();

					idolValues.add(0, service.readConfigParameter("ParametricField.topentry", "--- Select ---"));
					displayNames.add(0, service.readConfigParameter("ParametricField.topentry", "--- Select ---"));

					FieldValueMapper fieldMapper = new CSVFieldValueMapper(idolValues, displayNames);
					fieldInfo.addFieldValueMapper(fieldMapper);
					fieldInfo.setIDOLValues(idolValues);
				}
				// otherwise read initial field values i.e. all the values the field can take before any others are selected
				else
				{
					fieldInfo.addFieldValueMapper(new UnmodifiedFieldValueMapper());
					fieldInfo.setIDOLValues(queryForParametricValues(service, idolFieldName));
				}

				parametricFields.add(fieldInfo);
			}
		}
	}
	return parametricFields;
}

private void resetParametricInfo(PortalService service)
{
	ArrayList parametricFields = (ArrayList)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO);
	if(parametricFields != null && parametricFields.size() > 0)
	{
		Iterator fields = parametricFields.iterator();
		while(fields.hasNext())
		{
			((ParametricFieldInfo)fields.next()).setSelectedValue(service.readConfigParameter("ParametricField.topentry", "--- Select ---"));
		}
	}
}

private List queryForParametricValues(PortalService service, String idolFieldName) throws AciException
{
	// Action parameters for getquerytagvalues
	ArrayList parametricQueryParams = new ArrayList();
	parametricQueryParams.add(new ActionParameter("text", "*"));
	parametricQueryParams.add(new ActionParameter("sort", "Alphabetical"));

	List values = service.getIDOLService().useParametricRetrievalFunctionality().getQueryParametricFieldValues(idolFieldName, parametricQueryParams);
	values.add(0, service.readConfigParameter("ParametricField.topentry", "--- Select ---"));

	return values;
}

private void mylog(String s)
{
	System.out.println("AR.jsp: " + s);
}
%>