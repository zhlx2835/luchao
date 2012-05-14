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
<%=f_adminDisplayBigIcon("../../images/admin/plugins.gif")%><br /><br />
<font class="normalbold">Reload Settings<br /><br />
Click on an option on the left menu to:</font><br>
<table><tr>
<td valign=top><ul>
<li><p><font class="normal"><a target="mainFrame" href="../reload/reload_settings.jsp" class="admin" >reinitialize</a> the Portal</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../reload/reset_portlets.jsp" class="admin" >reset</a> the portlets</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../reload/flush_cache.jsp" class="admin" >flush</a> the Portal's cache</font></p></li>
</ul></td>
</tr></table>

<%@ include file="/admin/header/adminhome_footer.jspf" %>
