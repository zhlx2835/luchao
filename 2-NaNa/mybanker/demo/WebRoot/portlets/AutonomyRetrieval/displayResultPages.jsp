<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.aci.businessobjects.User" %>
<%@ page import="com.autonomy.portlet.ResultListDisplayOptions" %>
<%@ page import="com.autonomy.portlet.constants.RetrievalConstants"%>
<%@ page import="com.autonomy.tree.TreeNode" %>
<%@ page import="com.autonomy.portlet.resultpages.BatchedResultPages"%>
<%@ page import="com.autonomy.portlet.resultpages.ResultPage"%>
<%@ page import="com.autonomy.portlet.resultpages.QueryResultPage"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

// Set up services
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)RetrievalConstants.PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(RetrievalConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(RetrievalConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(RetrievalConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// pull results from session
BatchedResultPages resultPages = (BatchedResultPages)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_RESULT_HITS);
if(resultPages == null)
{
	// no query performed - nothing to display
}
else
{
	ResultPage currentResultPage = resultPages.getCurrentPage();
	if(!StringUtils.strValid(currentResultPage.getErrorMessage()))
	{
		// these values are used by displayResultList_include.jspf
		ResultList resultList = null;

		if (currentResultPage instanceof QueryResultPage)
		{
			resultList = ((QueryResultPage)currentResultPage).getResultList();
		}
		else
		{
			resultList = new ResultList(new ArrayList(currentResultPage.getResults()));
		}

		String username = ((User)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER)).getUsername();
		String imageURL = service.makeLink("AutonomyImages");
		String threshold = service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_THRESHOLD), "40");
		String numResults = service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_NUM_RESULTS), "6");
		String spellingQuery = resultList.getSpellingQuery();
		// use default display options ...
		ResultListDisplayOptions displayOptions = new ResultListDisplayOptions();
%>
		<table class="pResultList" width="90%" cellpadding="0" border="0" align="center">
			<tr>
				<td align="left" colspan="4">
					<%@ include file = "displayNavigationBar_include.jspf" %>
				</td>
			</tr>
			<tr>
				<td height="5"  colspan="4"/>
			</tr>

<%		if (StringUtils.strValid(spellingQuery))
		{
%>
			<tr>
				<td align="left" colspan="4">
					<%@ include file="displaySpellingQuery_include.jspf" %>
				</td>
			</tr>
			<tr>
				<td height="5"  colspan="4"/>
			</tr>
<%
		}
%>
			<tr>
				<td align="left" colspan="4">
					<font class="normalbold">
						<%= resultPages.getTitle() %>
					</font>
				</td>
			</tr>
			<tr>
				<td height="5"  colspan="4"/>
			</tr>
			<tr>
				<td>
					<!-- form for suggesting further results: must repeat all the parameters that were used for the original query other than the query text -->
					<form name="<%= service.makeFormName(RetrievalConstants.SUGGEST_FORM_NAME) %>" action="<%= service.makeFormActionLink(" ") %>" method="post">
						<%= service.makeAbstractFormFields() %>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PAGE) %>"           value="<%= RetrievalConstants.JSP_PAGE_REFINE_QUERY %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_NUM_RESULTS) %>"    value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_NUM_RESULTS), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_THRESHOLD) %>"      value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_THRESHOLD), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_DATE) %>"       value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_DATE), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY) %>"   value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH) %>" value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR) %>"  value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY) %>"     value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH) %>"   value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR) %>"    value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SORT_BY) %>"        value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SORT_BY), "") %>"/>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_BATCH_START) %>"    value="<%= service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_BATCH_START), "") %>"/>
<%
						// write out selected info sources
						String[] infoSources = service.getRequestParameterValues(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES));
						for(int sourceIdx = 0; sourceIdx < infoSources.length; sourceIdx++)
						{
%>
						<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES) %>" value="<%= infoSources[sourceIdx] %>"/>
<%
						}
%>
						<table>
							<%@ include file="displayResultList_include.jspf" %>
						</table>
					</form>
				</td>
			</tr>
<%
			if(resultList.getDocumentCount() != 0)
			{
%>
				<tr>
					<td align="left" colspan="4">
						<a class="textButton" title="Refine the results" href="javascript:checkAndSubmitSuggestForm();">
							<%=rb.getString("displayResultPages.suggestMore")%>
						</a>
					</td>
				</tr>
<%
			}
%>
		</table>
			<script type="text/javascript">
			//<!-- script hiding
				function checkAndSubmitSuggestForm()
				{
					if(checkSuggestDocs())
					{
						document.<%= service.makeFormName(RetrievalConstants.SUGGEST_FORM_NAME) %>.submit();
					}
				}
				function checkSuggestDocs()
				{
					var docSelected = false;

					var suggestDocs = document['<%= service.makeFormName(RetrievalConstants.SUGGEST_FORM_NAME) %>']['<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SUGGEST_DOCS) %>'];
					if(suggestDocs != null)
					{
						if(suggestDocs.length > 0)
						{
							for(docIdx = 0; docIdx < suggestDocs.length && !docSelected; docIdx++)
							{
								docSelected = suggestDocs[docIdx].checked;
							}
						}
						else
						{
							docSelected = suggestDocs.checked;
						}
					}

					if(!docSelected)
					{
						alert("<%=rb.getString("displayResultPages.alert.selectDoc")%>");
					}

					return docSelected;
				}
			// finished Script hiding-->
			</script>
<%
	}
	else
	{
%>
		<table class="pResultList" width="90%" cellpadding="0" border="0" align="center">
			<tr>
				<td class="resultErrorMessage">
					<%= currentResultPage.getErrorMessage() %>
				</td>
			</tr>
		</table>
<%
	}
}
%>

<%!
private static void mylog(String s)
{
	System.out.println("displayResultPages: " + s);
}
%>

