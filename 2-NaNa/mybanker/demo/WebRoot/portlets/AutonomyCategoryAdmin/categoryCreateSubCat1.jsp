<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.portlet.constants.CATConstants"%>
<%@ page import="com.autonomy.aci.businessobjects.Category"%>
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

// get parent category from session
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
%>
	<h4><%=rb.getString("categoryCreateSubCat1.creating")%> <%= category.getName() %> </h4>

	<script name="JavaScript" type="text/javascript">
	<!--
		function cancel()
		{
			document.newcatname['<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>']['value'] = '<%= CATConstants.JSP_PAGE_CAT_SELECTED %>';
			document.newcatname.submit();
		}
	-->
	</script>
	<form name="newcatname" action="<%= service.makeFormActionLink("") %>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_CREATE_SUB_2 %>" />
		<table cellspadding="0" cellsapcing="0">
			<tr>
				<td>
					<%=rb.getString("categoryCreateSubCat1.subCatName")%>
				</td>
				&nbsp;
				<td>
					<input type="text" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_SUB_CAT_NAME) %>" value="" size="30" />
				</td>
			</tr>
			<tr><td colspan="2" height="6"></td></tr>
			<tr>
				<td colspan="2" align="right">
					<a class="textButton" href="javascript:cancel();" title="Cancel">
						<%=rb.getString("categoryEdit1.cancel")%>
					</a>
					&nbsp;
					<a class="textButton" href="javascript:document.newcatname.submit();" title="Continue">
						<%=rb.getString("categoryEdit1.continue")%>
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