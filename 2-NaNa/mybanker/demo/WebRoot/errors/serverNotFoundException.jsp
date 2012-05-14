<%@ page isErrorPage="true" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>

<%
ServerNotFoundException snfe = (ServerNotFoundException)exception;

//log exception
String BACKEND_LOCATION = FileUtils.correctSeparators(StringUtils.ensureSeparatorAtEnd(getServletConfig().getServletContext().getInitParameter("ConfigLocation")));
PortalInfo portal = PortalDistributor.getInstance(BACKEND_LOCATION);
if(portal != null)
{
	portal.LogThrowable(exception);
}
else
{
	System.err.println("Autonomy Portal-In-A-Box 4 exception:");
	exception.printStackTrace(System.err);
}
%>

<html>
<head>
	<title>Portal-In-A-Box 4 server not found</title>
	<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/portalinabox.css">
</head>
<body bgcolor="#ffffff">
	<br/>
	<table align="center" width="60%" cellpadding="1" cellspacing="0" border="1">
		<tr>
			<td class="normal" bgcolor="#cccccc" align="center" width="100%" >
				The required server, <%= snfe.getServerName() %>, could not be contacted on <%= snfe.getHost() %>:<%= snfe.getPort() %>.
				<br />
				<br />
				Please contact a system administrator or 
				<a href="<%= request.getContextPath() %>/user/home/home.jsp">
					try again
				</a>
				.
			</td>
		</tr>
	</table>
</body>
</html>