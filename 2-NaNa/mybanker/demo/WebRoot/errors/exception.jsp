<%@ page isErrorPage="true" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="java.io.*" %>

<%
try
{
	//N.B. JRun4 is able to invoke this page with a null exception.
    if(exception == null)
	{
		exception = new Exception("");
	}
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
	<title>Portal-in-a-box 4</title>
	<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/portalinabox.css">
</head>
<body bgcolor="#ffffff">
	<br/>
	<table align="center" width="60%" cellpadding="1" cellspacing="0" border="1">
		<tr>
			<td class="normal" bgcolor="#cccccc" align="center" width="100%" >
				An error occurred while this page was being initialized. 
<%					 
				if(StringUtils.strValid(exception.getMessage()))
				{
%>
					The error message is:
					<br/>
					<br/>
					<%= exception.getMessage() %>
					<br />
					<br />
<%
				}
%>
				You may find information useful to resolving this error in the Portal-In-A-Box log and application server's 'standard out' log .
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
<%
}
catch(Exception e)
{
	e.printStackTrace();
}
%>

