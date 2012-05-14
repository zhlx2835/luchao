<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<html>
<head>
	<title>Portal-in-a-box administration</title>
	<link rel="stylesheet" type="text/css" href="../../portalinabox.css" />
</head>
<body>
	<p><font class="normal">This box, if checked will enable the showing of all portlets in the portlet list.</p>
	<p><font class="normal">By default, the ones that are not shown are the ones that perform the core functions that Portal-in-a-Box uses, 
	such as logging users in, portlet layouts, editing details.  In general, users should not ever need to use and select these portlets
	from the portlet list - they are accessed through the menu at the top of the users' home pages.</p>
	<p><font class="normal">Should your portal customisations require use of these portlets in a more general situation, for example - if you wish to set up the default user with a login portlet to allow users quicker access to their personalized areas, you can choose this option and give the "guest" role viewable permissions for the login portlet.</p>
</body>
</html>
