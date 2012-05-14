<%@ page import="com.autonomy.aci.AciResponse"%>
<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.portlet.constants.CATConstants"%>
<%@ page import="com.autonomy.aci.businessobjects.Category"%>
<%@ page import="com.autonomy.aci.businessobjects.Document"%>
<%@ page import="com.autonomy.aci.businessobjects.TermsNWeights"%>
<%@ page import="com.autonomy.aci.businessobjects.ResultList"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
response.setContentType("text/html; charset=utf-8");
%>

<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CATConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CATConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CATConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)CATConstants.PORTLET_NAME);
if(service == null)
{
	setError(session, rb.getString("categorySelected.error.notLoaded"));
}

// get category being edited from session
Category category = (Category)session.getAttribute(CATConstants.SESSION_ATTRIB_SELECTED_CAT);
if(category == null)
{
	setError(session, rb.getString("categoryView.error.noCatSelected"));
}
%>

<%@ include file="showError_include.jspf" %>

<%
if(service != null && category != null)
{
	String imageURL = service.makeLink("AutonomyImages");
%>
	<h4><%=rb.getString("categoryEdit1.editingCat")%> <%= category.getName()%></h4>
	<h5><%=rb.getString("categoryEdit4.testResults")%></h5>

	<form name="cattestresults" action="<%= service.makeFormActionLink("") %>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_SELECTED %>" />
		<table>
			<!-- sample documents -->
			<tr>
				<td>
					<strong><%=rb.getString("categoryEdit4.matchingDoc")%></strong>:
				</td>
			</tr>
			<tr>
				<td valign="top">
<%
					// set up the display options for viewing category results
					ResultListDisplayOptions displayOptions = new ResultListDisplayOptions();
					// not allowing agent creation, document emailing or showing similar docs pop-up
					displayOptions.setShowingAgentLink(false);
					displayOptions.setShowingEmailLink(false);
					displayOptions.setShowingSimilar(false);


					// set up variables for results include
					String resultCheckBxs = service.makeParameterName(CATConstants.REQUEST_PARAM_RETRAIN_DOC_REFS);
					String threshold = "";
					String numResults = "";

					String username = ((AutonomyPortalUser)service.getUser()).getName();

					// retrieve result set from session
					ResultList resultList = (ResultList)session.getAttribute(CATConstants.SESSION_ATTRIB_SAMPLE_RESULTS);
%>
					<table align="center" class="pResultList" width="90%">
						<%@ include file="displayResultList_include.jspf" %>
					</table>

				</td>
			</tr>
			<tr>
				<td align="right">
					<a class="textButton" href="javascript:updateDocs();" title="Add to training">
						<%=rb.getString("categoryEdit4.retrain")%>
					</a>
				</td>
			</tr>

			<!-- This produces a simple seperator -->

			<tr>
				<td>
					<table width="370" class="seperator">
						<tr>
							<td>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<!-- This bit lowers the sorting stuff so everything looks in place -->
			<tr>
				<td height="5">
				</td>
			</tr>
			<tr>
				<td valign="top">
					<%@ include file="termsAndWeights_include.jspf" %>
				</td>
			</tr>
			<tr>
				<td align="right">
					<a class="textButton" href="javascript:updateTNW();" title="Update terms">
						<%=rb.getString("categoryEdit4.updateTerms")%>
					</a>
				</td>
			</tr>
			<!-- This produces a simple seperator -->

			<tr>
				<td colspan="2">
					<table width="370" class="seperator">
						<tr>
							<td>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<!-- This bit lowers the sorting stuff so everything looks in place -->
			<tr>
				<td colspan="2" height="5">
				</td>
			</tr>
			<!-- back, continue, cancel -->

			<script name="JavaScript" type="text/javascript">
			<!--
			function updateDocs()
			{
				document.cattestresults['<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>']['value'] = '<%= CATConstants.JSP_PAGE_CAT_EDIT_5 %>';
				document.cattestresults.submit();
			}
			function updateTNW()
			{
				document.cattestresults['<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>']['value'] = '<%= CATConstants.JSP_PAGE_CAT_EDIT_5 %>';
				submitModifiedTerms();
			}
			function cancel()
			{
				document.cattestresults['<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>']['value'] = '<%= CATConstants.JSP_PAGE_CAT_SELECTED %>';
				document.cattestresults.submit();
			}
			function back()
			{
				document.cattestresults['<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>']['value'] = '<%= CATConstants.JSP_PAGE_CAT_EDIT_2 %>';
				document.cattestresults.submit();
			}
			-->
			</script>
			<tr>
				<td colspan="2" align="right">
					<a class="textButton" href="javascript:back();" title="Back to previous step">
						<%=rb.getString("categoryEdit2.back")%>
					</a>
					&nbsp;
					<a class="textButton" href="javascript:cancel();" title="Cancel">
						<%=rb.getString("categoryEdit1.cancel")%>
					</a>
					&nbsp;
					<a class="textButton" href="javascript:document.cattestresults.submit();" title="Finish">
						<%=rb.getString("categoryEdit4.finish")%>
					</a>
				</td>
			</tr>

		</table>
	</form>
<%
}
%>

<%!
private void setError(HttpSession session, String sErrorMess)
{
	if(session != null && StringUtils.strValid(sErrorMess))
	{
		// append any existing error message
		String sCurrentError = (String)session.getAttribute(CATConstants.SESSION_ATTRIB_ERROR_MESSAGE);
		if(StringUtils.strValid(sCurrentError))
		{
			sErrorMess = sCurrentError + "<br />" + sErrorMess;
		}
		session.setAttribute(CATConstants.SESSION_ATTRIB_ERROR_MESSAGE, sErrorMess);
	}
}
%>