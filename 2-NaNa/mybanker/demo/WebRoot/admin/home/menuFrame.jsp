<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/functions/admin_functions.jspf" %>
<%
String th = "36px";
String tw = "11%";
%>
<html>
<head>
    <title>Menu Frame</title>
    <link rel="stylesheet" type="text/css" href="../../portalinabox.css" />
</head>
<body style="margin-top:0px; margin-left:2px; margin-right:0px;" bgcolor="<%=gc()%>" >

<table cellspacing="0" cellpadding="0"  width="100%"  style="height:<%=th%>;">
<tr>
	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="User Interface Settings" target="menuFrame" class="head" href="../ui/index.jsp" ><%=f_adminDisplaySmallIcon( "../../images/admin/interface.gif" )%>&nbsp;UI</a></td>

	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="User Settings" target="menuFrame" class="head" href="../users/index.jsp"  ><%=f_adminDisplaySmallIcon( "../../images/admin/users.gif" )%>&nbsp;Users</a></td>

	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="Role Settings" target="menuFrame" class="head" href="../roles/index.jsp"  ><%=f_adminDisplaySmallIcon( "../../images/admin/authentication.gif" )%>&nbsp;Roles</a></td>

	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="Portlet Settings" target="menuFrame" class="head" href="../portlets/index.jsp" ><%=f_adminDisplaySmallIcon( "../../images/admin/modules.gif" )%>&nbsp;Portlets</a></td>

	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="Content Source / Database Settings" target="menuFrame" class="head" href="../content/index.jsp" ><%=f_adminDisplaySmallIcon( "../../images/admin/database.gif" )%>&nbsp;Content</a></td>

	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="Reload All Settings" target="menuFrame" class="head" href="../reload/index.jsp" ><%=f_adminDisplaySmallIcon( "../../images/admin/plugins.gif" )%>&nbsp;Reload</a></td>

	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="Setup &amp; Configuration Settings" target="menuFrame" class="head" href="../setup/index.jsp" ><%=f_adminDisplaySmallIcon( "../../images/admin/administrator.gif" )%>&nbsp;Setup</a></td>

	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="Help &amp; Support" target="menuFrame" class="head" href="../support/index.jsp"  ><%=f_adminDisplaySmallIcon( "../../images/admin/server.gif" )%>&nbsp;Help</a></td>

	<td align="center" width="<%=tw%>" bgcolor="<%=gc()%>"><a title="Logout" target="mainFrame" class="head" href="../home/logout.jsp"  ><%=f_adminDisplaySmallIcon( "../../images/admin/logout.gif" )%>&nbsp;Logout</a></td>

</tr>
</table>

</body>
</html>
