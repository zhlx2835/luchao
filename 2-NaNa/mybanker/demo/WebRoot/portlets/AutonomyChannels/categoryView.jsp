<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.portlet.ResultListDisplayOptions" %>
<%@ page import="com.autonomy.portlet.constants.ChannelsConstants"%>
<%@ page import="com.autonomy.aci.businessobjects.Category"%>
<%@ page import="com.autonomy.aci.businessobjects.ResultList"%>
<%@ page import="com.autonomy.aci.exceptions.InvalidCategoryException"%>
<%@ page import="com.autonomy.aci.services.IDOLService"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
response.setContentType("text/html; charset=utf-8");
%>

<%
// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)ChannelsConstants.PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(ChannelsConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(ChannelsConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(ChannelsConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

if(service == null)
{
	session.setAttribute(ChannelsConstants.SESSION_ATTRIB_ERROR_MESSAGE, rb.getString("categoryView.error.serviceInfoNotLoaded"));
}

// get category to view
Category category = null;
// read selected cat ID from request, get this category's entry from Laune and set on session
String sSelectedCatID	= service.getSafeRequestParameter(service.makeParameterName(ChannelsConstants.REQUEST_PARAM_SELECTED_ID), "");
if(StringUtils.strValid(sSelectedCatID))
{
	category = getCategoryDetailsAndSetOnSession(sSelectedCatID, session, service);
}
else
{
	// no cat ID in request, try to get selected category from session
	category = (Category)session.getAttribute(ChannelsConstants.SESSION_ATTRIB_SELECTED_CAT);
	if(category == null)
	{
		session.setAttribute(ChannelsConstants.SESSION_ATTRIB_ERROR_MESSAGE, rb.getString("categoryView.clickCatViewDoc"));
	}
}

// retrieve laune service from session
// retrieve IDOL service from session
IDOLService idol = (IDOLService)session.getAttribute(ChannelsConstants.SESSION_ATTRIB_IDOL);
if(idol == null)
{
	session.setAttribute(ChannelsConstants.SESSION_ATTRIB_ERROR_MESSAGE, rb.getString("categoryView.error.launeNotLoaded"));
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
	displayOptions.setShowingCheckboxes(false);

	// set up variables for results include
	String resultCheckBxs = "";
	String threshold = "";
	String numResults = "";

	String username = ((AutonomyPortalUser)service.getUser()).getName();
	String imageURL = service.makeLink("AutonomyImages");
%>

	<h4><%=rb.getString("categoryView.cat")%> <%= category.getName() %></h4>

	<table width="100%">
		<%@ include file="displayResultList_include.jspf" %>
	</table>

<%
}
%>

<%!
private Category getCategoryDetailsAndSetOnSession(String sSelectedCatID, HttpSession session, PortalService service) throws AciException
{
	Category category = new Category();
	// retrieve Laune service from session
	IDOLService idol = (IDOLService)session.getAttribute(ChannelsConstants.SESSION_ATTRIB_IDOL);
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
			session.setAttribute(ChannelsConstants.SESSION_ATTRIB_ERROR_MESSAGE, ice.getMessage() +" Please select another category.");
		}
	}
	else
	{
		session.setAttribute(ChannelsConstants.SESSION_ATTRIB_ERROR_MESSAGE, "The Laune service could not be found. Please try again.");
	}

	// set category entry on session
	if(category != null)
	{
		session.setAttribute(ChannelsConstants.SESSION_ATTRIB_SELECTED_CAT, category);
	}
	return category;
}
%>