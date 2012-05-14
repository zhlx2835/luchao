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
<%=f_adminDisplayBigIcon("../../images/admin/modules.gif")%><br /><br />
<font class="normalbold">Portlet Administration<br /><br />
Click on an option on the left menu to:</font><br />
<table><tr>
<td valign="top"><ul>
<li><p><font class="normal"><a target="mainFrame" href="../portlets/new1.jsp" class="admin" >create </a>a custom portlet</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../portlets/edit.jsp?action=remove" class="admin" >remove </a>a portlet from the portal</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../portlets/edit.jsp?action=edit" class="admin" >edit </a>portlets</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../portlets/permissions.jsp" class="admin" >set </a>portlet permissions for roles</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../portlets/one_portlet.jsp?portlet=AutonomyPortletAdmin" class="admin" >administer</a> portlets</font></p></li>
</ul></td>
</tr></table>

<%@ include file="/admin/header/adminhome_footer.jspf" %>
