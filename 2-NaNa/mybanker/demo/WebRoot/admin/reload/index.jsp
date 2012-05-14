<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/header/adminmenu_header.jspf" %>

	
<tr>
	<td width="100%" height="<%=th%>" bgcolor="<%=gc()%>"><font class="normalbold" ><%=f_adminDisplayIcon( "../../images/admin/plugins.gif" )%>
	Reload</font></td>
</tr>

<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../reload/reload_settings.jsp" class="admin" >Reinitialize Portal</a></td>
</tr>

<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../reload/reset_portlets.jsp" class="admin" >Reset Portlets</a></td>
</tr>

<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../reload/flush_cache.jsp" class="admin" >Flush Cache</a></td>
</tr>

<%@ include file="/admin/header/adminmenu_footer.jspf" %>
