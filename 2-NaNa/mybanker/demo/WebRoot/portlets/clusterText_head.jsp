<%@ page import = "java.net.*" %>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

String sTitle 		= request.getParameter("title");
String sStartDate 	= request.getParameter("startdate");
String sEndDate 	= request.getParameter("enddate");
String sNumDocs 	= request.getParameter("numdocs");
String sTerms		= request.getParameter("terms");
String sUsername	= request.getParameter("username");
String sClusterMode	= request.getParameter("mode");

if( sClusterMode == null )
	sClusterMode = "";

StringBuffer sbClusterToAgentURL = new StringBuffer(service.makeLink("clustertoagent.jsp"));
sbClusterToAgentURL.append("?username=");
sbClusterToAgentURL.append( sUsername );
sbClusterToAgentURL.append("&clustername=");
sbClusterToAgentURL.append(URLEncoder.encode(sTitle, "UTF8"));
sbClusterToAgentURL.append("&tnw=");
sbClusterToAgentURL.append( sTerms );

String  sImageURL = service.makeLink("AutonomyImages");
%>
<html>
<head>
	<title></title>
	<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/portalinabox.css">
	<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/autonomyportlets.css">
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
</head>
<body style="background-color:transparent; margin:0px;">
<table class="pResultList" style="margin:0px;" width="100%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<%=rb.getString("clusterText_head.name")%>
		</td>
		<td>
			<b><%= sTitle %></b>
		</td>
		<td>
			&nbsp;
		</td>
		<td rowspan="3" valign="middle" align="center">
			<a class="textButton" target="_blank" title="Create agent from this cluster" href="<%= StringUtils.XMLEscape(sbClusterToAgentURL.toString()) %>">
				<span style="white-space:nowrap;"><%=rb.getString("clusterText_head.createAgent")%></span>
			</a>
			<br>
		</td>
	</tr>
	<%
		if( sClusterMode.equalsIgnoreCase("SG") )
		{
	%>
	<tr>
		<td>
			<%=rb.getString("clusterText_head.date")%>
		</td>
		<td>
			<b><%= sStartDate %> - <%= sEndDate %></b>
		</td>
	</tr>
	<%
		}
	%>
	<tr>
		<td>
			<%=rb.getString("clusterText_head.docs")%>
		</td>
		<td>
			<b><%= sNumDocs %></b>
		</td>
	</tr>
</table>
</body>
</html>