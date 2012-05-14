<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%@ include file="/admin/header/adminmenu_header.jspf" %>

<tr>
	<td width="100%" height="<%=th%>" bgcolor="<%=gc()%>"><font class="normalbold" ><%=f_adminDisplayIcon( "../../images/admin/users.gif" )%>
	Users</font></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../users/addedit.jsp?action=add" class="admin" >Add Users</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../users/remove.jsp" class="admin" >Delete Users</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../users/clonedisplay.jsp" class="admin" >Clone User</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../users/editdisplay.jsp" class="admin" >Edit User</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../users/initialize.jsp" class="admin" >Initialize All Users</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../users/addPortlet.jsp" class="admin" >Add a page to existing users</a></td>
</tr>

<%@ include file="/admin/header/adminmenu_footer.jspf" %>
