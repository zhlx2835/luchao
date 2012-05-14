<%@ page import = "java.net.URLEncoder"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>


<%@ include file="/admin/home/admin_checkUser.jspf" %>
<%
AllPortlets allPortlets = CurrentPortal.getAllPortletsObject();
String sPortletName = request.getParameter("identifier");
String sFullName = request.getParameter("fullname");
String sDescription = request.getParameter("description");

//
//Generic querystring in case of error
//
String sQueryString = "?identifier=" + Functions.f_URLEncode(sPortletName) + "&fullname=" + Functions.f_URLEncode(sFullName) + "&description=" + Functions.f_URLEncode(sDescription);
if(StringUtils.strValid(sPortletName) )
{
	sPortletName = sPortletName.trim().replace(' ', '_');//.toLowerCase();
	if( !StringUtils.containsNonAlphaNumericChars(sPortletName) )
	{
		if(StringUtils.isStringInStringArray(allPortlets.getSectionNames(), sPortletName, true) == -1 && !sPortletName.equalsIgnoreCase("pane") )
		{
			if(!StringUtils.strValid(sFullName))
				sFullName = sPortletName;
			else
				sFullName = StringUtils.stripDangerousChars(sFullName);

			if(!StringUtils.strValid(sDescription))
				sDescription = "None";
			else
				sDescription = StringUtils.stripDangerousChars(sDescription);

			allPortlets.createPortlet(sPortletName);
			allPortlets.setFullName(sPortletName, sFullName);
			allPortlets.setDescription(sPortletName, sDescription);

			allPortlets.save();
			response.sendRedirect("new3.jsp?pane=" + sPortletName);
		}
		else
		{
			response.sendRedirect("new2.jsp" + sQueryString + "&message=" + Functions.f_URLEncode("This pane already exists - please choose another name") );
		}
	}
	else
	{
		response.sendRedirect("new2.jsp" + sQueryString + "&message=" + Functions.f_URLEncode("Please only use a-z or 0-9 or '_' in your pane identifiers") );
	}
}
else
{
	response.sendRedirect("new2.jsp");
}
%>
