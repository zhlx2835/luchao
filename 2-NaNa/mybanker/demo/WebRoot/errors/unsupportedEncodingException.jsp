<%@ page isErrorPage="true" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="java.io.*" %>

<%
UnsupportedEncodingException uee = (UnsupportedEncodingException)exception;

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
				The character encoding specified by the CharacterEncoding parameter in the [Language] section of the portal configuration is not supported by this application server.
				<br />
				<br />
				Please modify this parameter and 
				<a href="<%= request.getContextPath() %>/user/home/home.jsp">
					try again
				</a>
				.
			</td>
		</tr>
	</table>
</body>
</html>