<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.aci.businessobjects.Agent" %>
<%@ page import="com.autonomy.aci.businessobjects.User" %>
<%@ page import="com.autonomy.portlet.ResultListDisplayOptions" %>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.portlet.resultpages.BatchedResultPages"%>
<%@ page import="com.autonomy.portlet.resultpages.ResultPage"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>

<%
response.setContentType("text/html; charset=utf-8");

// Set up services
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)AgentConstants.PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(AgentConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(AgentConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(AgentConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// pull results from session
BatchedResultPages resultPages = (BatchedResultPages)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_RESULT_HITS);
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
		ResultList resultList = new ResultList();
		resultList.setDocuments(new ArrayList(currentResultPage.getResults()));

		// these values are used by displayResultList_include.jspf
		String username = ((User)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_USER)).getUsername();
		String imageURL = service.makeLink("AutonomyImages");
		String threshold = service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_THRESHOLD), "40");
		String numResults = service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_NUM_RESULTS), "6");
		// use default display options ...
		ResultListDisplayOptions displayOptions = new ResultListDisplayOptions();
		%>
		<!-- form for suggesting further results: must repeat all the parameters that were used for the original query other than the query text -->
		<form name="<%= service.makeFormName(AgentConstants.RETRAIN_FORM_NAME) %>" action="<%= service.makeFormActionLink(" ") %>" method="post">
			<%= service.makeAbstractFormFields() %>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE) %>"           value="<%= AgentConstants.JSP_PAGE_RETRAIN_AGENT %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_NUM_RESULTS) %>"    value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_NUM_RESULTS), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_THRESHOLD) %>"      value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_THRESHOLD), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_DATE) %>"       value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_DATE), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_FROM_DAY) %>"   value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_FROM_DAY), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_FROM_MONTH) %>" value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_FROM_MONTH), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_FROM_YEAR) %>"  value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_FROM_YEAR), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_TO_DAY) %>"     value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_TO_DAY), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_TO_MONTH) %>"   value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_TO_MONTH), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_TO_YEAR) %>"    value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_TO_YEAR), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_SORT_BY) %>"        value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_SORT_BY), "") %>"/>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_BATCH_START) %>"    value="<%= service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_BATCH_START), "") %>"/>

			<table class="pResultList" width="90%" cellpadding="0" border="0" align="center">
				<tr>
					<td height="5" colspan="4"/>
				</tr>
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

				<%@ include file="displayResultList_include.jspf" %>
				<%
				if(resultList.getDocumentCount() != 0)
				{
					%>
					<tr>
						<td align="left" colspan="4">
							<a class="textButton" title="Add documents to the agent's training" href="javascript:<%= service.makeFormName(AgentConstants.RETRAIN_FORM_NAME) %>.submit();">
								<%=rb.getString("displayResultPages.retrainAgent")%>
							</a>
						</td>
					</tr>
					<%
				}
				%>
			</table>
		</form>
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


