<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%@ include file="/admin/header/adminmenu_header.jspf" %>

<tr>
	<td width="100%" style="height:<%=th%>px;" bgcolor="<%=gc()%>"><font class="normalbold" ><%=f_adminDisplayIcon( "../../images/admin/interface.gif" )%>
	UI</font></td>
</tr>

<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a href="../../user/home/home.jsp" target="_top" class="admin" >Display</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../ui/becomeUser.jsp" class="admin" >Log in as other user</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../ui/setup_defaultUser.jsp" class="admin" >Set up default user</a></td>
</tr>
<tr>
	<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="../ui/setup_templateUser.jsp" class="admin" >Set up template user</a></td>
</tr>

<%@ include file="/admin/header/adminmenu_footer.jspf" %>
