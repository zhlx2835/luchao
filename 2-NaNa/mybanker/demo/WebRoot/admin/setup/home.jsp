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
<%=f_adminDisplayBigIcon("../../images/admin/administrator.gif")%><br /><br />
<font class="normalbold">Setup Administration<br/><br/>
Click on an option on the left menu to:</font><br/><br/>
<table><tr>
<td valign=top><ul>

<%
	String[] asSections = CurrentPortal.getSectionNames();

	for(int nSection=0; nSection<asSections.length; nSection++)
	{
%>
	<li>
		<p>
		    <font class="normal">
			    <a target="mainFrame" href="setup_content.jsp#<%=asSections[nSection]%>" class="admin" >
			    configure</a> the Portal's [<%=asSections[nSection]%>] section
		    </font>
		</p>
	</li>
<%
	}
%>
<li><p><a target="mainFrame" href="setup_security.jsp" class="admin" >configure </a>user authentication</p></li>
</ul></td>
</tr></table>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
