<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sAdminHeader_title = "";
String sAdminHeader_image = "";
%>
<%@ include file="/admin/header/adminhome_header.jspf" %>
<%=f_adminDisplayBigIcon("../../images/admin/users.gif")%><br /><br />
<font class="normalbold">User Administration<br /><br />
Click on an option on the left menu to:</font><br />
<table><tr>
<td valign="top"><ul>
<li><p><font class="normal"><a target="mainFrame" href="../users/addedit.jsp?action=add" class="admin">add</a> users to the Portal</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../users/remove.jsp" class="admin">delete</a> users from the Portal</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../users/clonedisplay.jsp" class="admin">clone</a> a user</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../users/editdisplay.jsp" class="admin">edit</a> a user</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../users/initialize.jsp" class="admin">initialize</a> all users</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../users/addPortlet.jsp" class="admin">add a portlet</a> to all users</font></p></li>
</ul></td>
</tr></table>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
