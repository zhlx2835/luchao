<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/header/adminmenu_header.jspf" %>

	
<tr>
	<td width="100%" height="<%=th%>" bgcolor="<%=gc()%>"><font class="normalbold" ><%=f_adminDisplayIcon( request.getContextPath() + "/images/admin/modules.gif" )%>
	Portlets</font></td>
</tr>

<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="<%= request.getContextPath() %>/admin/portlets/new1.jsp" class="admin" >Add Portlet</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="<%= request.getContextPath() %>/admin/portlets/edit.jsp?action=remove" class="admin" >Remove Portlet</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="<%= request.getContextPath() %>/admin/portlets/edit.jsp?action=edit" class="admin" >Edit Portlet Details</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="<%= request.getContextPath() %>/admin/portlets/permissions.jsp" class="admin" >Portlet Permissions</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="<%= request.getContextPath() %>/admin/portlets/one_portlet.jsp?portlet=AutonomyPortletAdmin" class="admin" >Administer Portlets</a></td>
</tr>

<%@ include file="/admin/header/adminmenu_footer.jspf" %>
