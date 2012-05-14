<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "";
String sAdminHeader_image = "";
%>
<%@ include file = "/admin/header/adminhome_header.jspf" %>
<%=f_adminDisplayBigIcon("../../images/admin/authentication.gif")%><br /><br />
<font class="normalbold">Role Administration<br /><br />
Click on an option on the left menu to continue</font><br />
<table><tr>
<td valign="top"><ul>
<li><p><font class="normal"><a target="mainFrame" href="./addedit.jsp?action=add" class="admin" >add</a> a role to the Portal</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="./remove.jsp" class="admin" >delete</a> a role from the Portal</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="./editdisplay.jsp" class="admin" >move</a> a role</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="./users.jsp?action=add" class="admin" >include</a> users in roles</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="./users.jsp?action=remove" class="admin" >exclude</a> users from roles</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="./databases.jsp" class="admin" >set</a> database permissions for roles</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="./portlets.jsp" class="admin" >set</a> portlet permissions for roles</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="./roles_configure.jsp" class="admin" >configure</a> roles</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="./pwd.jsp" class="admin" >set</a> role passwords</font></p></li>
</ul></td>
</tr></table>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
