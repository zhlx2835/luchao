<%@ page import="java.util.*"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="com.autonomy.utilities.*"%>
<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.portlet.constants.*"%>
<%@ page import="com.autonomy.aci.businessobjects.Category"%>
<%@ page import="com.autonomy.aci.services.IDOLService"%>
<%@ page import="com.autonomy.aci.exceptions.InvalidCategoryException"%>
<%@ page import="com.autonomy.aci.exceptions.AciException"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
response.setContentType("text/html; charset=utf-8");
%>

<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

Category category = null;

// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)CATConstants.PORTLET_NAME);
if(service != null)
{
	// read selected cat ID from request, get this category's entry from Laune and set on session
	String sSelectedCatID	= service.getSafeRequestParameter(service.makeParameterName(CATConstants.REQUEST_PARAM_SELECTED_ID), "");
	if(StringUtils.strValid(sSelectedCatID))
	{
		category = getCategoryDetailsAndSetOnSession(sSelectedCatID, session, service, rb);
	}
	else
	{
		// no cat ID in request, try to get selected category from session
		category = (Category)session.getAttribute(CATConstants.SESSION_ATTRIB_SELECTED_CAT);
		if(category != null)
		{
			sSelectedCatID = category.getUID();
		}
		else
		{
			setError(session, rb.getString("categorySelected.error.tryAgain"));
		}
	}
}
else
{
	setError(session, rb.getString("categorySelected.error.notLoaded"));
}
%>

<%@ include file="showError_include.jspf" %>

<%
if(category != null && service != null)
{
	StringBuffer sbCatActionURL = new StringBuffer();
	sbCatActionURL.append(service.makeFormActionLink("")).append("?").append(service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE)).append("=");
%>
	<p>
	</p>

	<p>
		<%=rb.getString("categorySelected.haveSelected")%> <%= category.getName() %> <%=rb.getString("categorySelected.canNow")%>
		<ul>
<%
			if(!category.getUID().equals(Category.HOME_CATEGORY_ID))
			{
%>
				<li><a href="javascript:document.categoryView.submit();"><%=rb.getString("categorySelected.view")%></a> <%=rb.getString("categorySelected.view.results")%></li>
				<li><a href="javascript:document.categoryEdit.submit();"><%=rb.getString("categorySelected.edit")%></a> <%=rb.getString("categorySelected.edit.details")%></li>
				<li><a href="javascript:document.categoryDelete.submit();" onClick="return confirmDeleteCategory()"><%=rb.getString("categorySelected.delete")%></a> <%=rb.getString("categorySelected.delete.cat")%></li>
<%
			}
%>
			<li><a href="javascript:document.categoryCreate.submit();"><%=rb.getString("categorySelected.create")%></a> <%=rb.getString("categorySelected.create.subcat")%></li>
			<li><a href="javascript:document.categoryImport.submit();"><%=rb.getString("categorySelected.import")%></a> <%=rb.getString("categorySelected.import.subcat")%></li>
		</ul>
	</p>

	<script type="text/javascript" defer="defer">
	<!--
		function confirmDeleteCategory()
		{
			bCnfrm = confirm('<%=rb.getString("categorySelected.confirmDelete")%>');
			return bCnfrm;
		}
	-->
	</script>

	<form name="categoryView" action="<%= service.makeFormActionLink("") %>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_VIEW %>" />
	</form>
	<form name="categoryEdit" action="<%= service.makeFormActionLink("") %>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_EDIT_1 %>" />
	</form>
	<form name="categoryDelete" action="<%= service.makeFormActionLink("") %>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_DELETE %>" />
	</form>
	<form name="categoryCreate" action="<%= service.makeFormActionLink("") %>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_CREATE_SUB_1 %>" />
	</form>
	<form name="categoryImport" action="<%= service.makeFormActionLink("") %>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<!--<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_IMPORT %>" />-->
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_IMPORT_XML_1 %>" />
	</form>
<%
}
%>

<%!
private Category getCategoryDetailsAndSetOnSession(String sSelectedCatID, HttpSession session, PortalService service, ResourceBundle rb) throws AciException, UnsupportedEncodingException
{
	Category category = new Category();
	// get IDOL Service from session
	IDOLService idol = (IDOLService)session.getAttribute(CATConstants.SESSION_ATTRIB_IDOL);
     // Get user details
    String sUsername = (service.getUser()).getName();
	if(idol != null)
	{
		try
		{
			category = idol.useChannelsFunctionality().getCategory(sSelectedCatID, sUsername);

		}
		catch(InvalidCategoryException ice)
		{
			setError(session, ice.getMessage() + rb.getString("categoryView.error.selectAnotherCat"));
		}
	}
	else
	{
		setError(session, rb.getString("categoryView.error.noChFuncAvailable"));
	}

	// set category entry on session
	if(category != null)
	{
		session.setAttribute(CATConstants.SESSION_ATTRIB_SELECTED_CAT, category);
	}
	return category;
}

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