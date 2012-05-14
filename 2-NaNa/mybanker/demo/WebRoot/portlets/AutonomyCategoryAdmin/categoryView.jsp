<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.portlet.ResultListDisplayOptions" %>
<%@ page import="com.autonomy.portlet.constants.CATConstants"%>
<%@ page import="com.autonomy.aci.businessobjects.Category"%>
<%@ page import="com.autonomy.aci.businessobjects.ResultList"%>
<%@ page import="com.autonomy.aci.services.IDOLService"%>
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

// get category to view from session
Category category = (Category)session.getAttribute(CATConstants.SESSION_ATTRIB_SELECTED_CAT);
if(category == null)
{
	setError(session, rb.getString("categoryView.error.noCatSelected"));
}

// retrieve IDOL service from session
IDOLService idol = (IDOLService)session.getAttribute(CATConstants.SESSION_ATTRIB_IDOL);
if(idol == null)
{
	setError(session, rb.getString("categoryView.error.noChFuncAvailable"));
}

%>

<%@ include file="showError_include.jspf" %>

<%

// retrieve category results
if(service != null && category != null && idol != null)
{
	ResultList resultList = null;
%>
	<%@ include file="queryCategory_include.jspf" %>
<%

	// set up the display options for viewing category results
	ResultListDisplayOptions displayOptions = new ResultListDisplayOptions();
	// just viewing the results, not improving training etc
	displayOptions.setShowingCheckboxes(false);

	// these variables need to be declared before including displayResultList_include.jspf
	String resultCheckBxs = service.makeParameterName(CATConstants.REQUEST_PARAM_RETRAIN_DOC_REFS);
	String threshold 			= "";
	String numResults 			= "";

    String username = ((AutonomyPortalUser)service.getUser()).getName();
	String imageURL = service.makeLink("AutonomyImages");
%>

	<h4><%=rb.getString("categoryView.viewingResults")%> <%= category.getName() %></h4>

	<table width="100%">
		<%@ include file="displayResultList_include.jspf" %>
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