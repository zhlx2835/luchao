<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.aci.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portlet.constants.CommonConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
final String PORTLET_NAME = "HotNews";
final String IMAGE_NAME = "flame.gif";

PortalService service = ServiceFactory.getService((Object)request, (Object)response, PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

String  sImageURL = service.makeLink("AutonomyImages");
%>

<html>
<head>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>">
</head>
<body STYLE="background-color:transparent">
	<table width="100%" class="pContainer">
		<tr>
			<td>
				<%@ include file = "clusterDisplay_include.jspf" %>
			</td>
		</tr>
	</table>
</body>
</html>
