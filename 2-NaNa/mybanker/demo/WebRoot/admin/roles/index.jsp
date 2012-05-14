<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/header/adminmenu_header.jspf" %>

<tr>
	<td width="100%" height="<%=th%>" bgcolor="<%=gc()%>"><font class="normalbold" ><%=f_adminDisplayIcon( "../../images/admin/authentication.gif" )%>
	Roles</font></td>
</tr>

<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/addedit.jsp?action=add" class="admin" >Add Role</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/remove.jsp" class="admin" >Delete Role</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/editdisplay.jsp" class="admin" >Move Role</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/users.jsp?action=add" class="admin" >Add Users</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/users.jsp?action=remove" class="admin" >Remove Users</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/databases.jsp" class="admin" >Database Permissions</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/portlets.jsp" class="admin" >Portlet Permissions</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/roles_configure.jsp" class="admin" >Configure Roles</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../roles/pwd.jsp" class="admin" >Role Passwords</a></td>
</tr>

<%@ include file="/admin/header/adminmenu_footer.jspf" %>
