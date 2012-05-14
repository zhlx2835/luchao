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
<h4><%=rb.getString("categoryImport.importing")%> <%= category.getName() %> </h4>

<p>
	<%=rb.getString("categoryImportXML1.importCatInfo")%>
</p>
<p>
	<%=rb.getString("categoryImportXML1.xmlFileSaved")%>
</p>
<script name="JavaScript" type="text/javascript">
<!--
	function cancel()
	{
		document.importcat['<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>']['value'] = '<%= CATConstants.JSP_PAGE_CAT_SELECTED %>';
		document.importcat.submit();
	}
-->
</script>
<table>
<form name="importcat" action="<%= service.makeFormActionLink("") %>" method="POST">
	<%= service.makeAbstractFormFields() %>
	<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_IMPORT_XML_2 %>" />
	<tr>
		<td>
			<input type="text" size="50" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_IMPORT_FILE) %>" value="" />
		</td>
	</tr>
	<tr>
		<td align="right">
			<a class="textButton" href="javascript:cancel();" title="Cancel">
				<%=rb.getString("categoryEdit1.cancel")%>
			</a>
			&nbsp;
			<a class="textButton" href="javascript:document.importcat.submit();" title="Import">
				<%=rb.getString("categoryImportXML1.import")%>
			</a>
		</td>
	</tr>
</form>
</table>
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