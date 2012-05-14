<%@ page isErrorPage="true" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.aci.NotLicensedException" %>

<%
NotLicensedException nle = (NotLicensedException)exception;

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
				You are not licensed to use the functionality required for this portlet:<br />
				<%= nle.getMessage() %>
				<br />
				<br />
				Please make sure that your IDOL is correctly licensed.
			</td>
		</tr>
	</table>
</body>
</html>