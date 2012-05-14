<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "";
String sAdminHeader_image = null;
%>
<%@ include file="/admin/header/adminhome_header.jspf" %>
<%=f_adminDisplayBigIcon(request.getContextPath() + "/images/admin/database.gif")%><br /><br />
<font class="normalbold">Content / Database Administration<br /><br />
Click on an option on the left menu to:</font><br>
<table><tr>
<td valign=top><ul>
<li><p><font class="normal"><a target="mainFrame" href="../content/permissions.jsp" class="admin">allocate</a> database access to roles</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../content/categories.jsp" class="admin">set</a> category permissions to roles</font></p></li>
</ul></td>
</tr></table>

<%@ include file="/admin/header/adminhome_footer.jspf" %>
