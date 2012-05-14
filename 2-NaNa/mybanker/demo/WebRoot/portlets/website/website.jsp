<%@ page import="com.autonomy.utilities.StringUtils" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>


<%@ include file="/user/include/getPortletVars_include.jspf" %>
<%
String sURL= CurrentPortal.readString(CurrentPortal.CONTENT_SECTION, "URLToDisplay", "");

if(StringUtils.strValid(sURL))
{
%>
	<iframe
		src="<%= sURL %>"
		width="100%"
		height="100%"
		frameborder="0"
	></iframe>
<%
}
%>