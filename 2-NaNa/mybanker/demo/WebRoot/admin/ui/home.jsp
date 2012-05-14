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

<%

// in case user has entered portlet administration section and changed current pib service to admin service. Needs switching back.
if(session.getAttribute("APSLTransferIAmPiB4Admin") != null)
{
	session.removeAttribute("APSLTransferIAmPiB4Admin");

	if(session.getAttribute("APSLTransferIAmPiB4Backup") == null)
	{
		Integer NPiB4Version = new Integer(CurrentPortal.getVersionNumber());
		session.setAttribute("APSLTransferIAmPiB4",  NPiB4Version);
	}
	else
	{
		session.setAttribute("APSLTransferIAmPiB4", session.getAttribute("APSLTransferIAmPiB4Backup"));
	}
	session.removeAttribute( "APSLTransferIAmPiB4Backup" );

	session.setAttribute("APSLTransferPortlet", session.getAttribute("APSLTransferPortletBackup"));
	session.removeAttribute( "APSLTransferPortletBackup" );
}

%>

<%=f_adminDisplayBigIcon("../../images/admin/interface.gif")%><br /><br />
<font class="normalbold">User Interface Administration<br /><br />
Click on an option on the left menu to:</font><br /><br />
<table><tr>
<td valign=top><ul>
<li><p><font class="normal"><a href="../../user/home/home.jsp" target="_top" class="admin" >display</a> the User Interface</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../ui/becomeUser.jsp" class="admin" >log in</a> as another user</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../ui/setup_defaultUser.jsp" class="admin" >set up</a> the default user</font></p></li>
<li><p><font class="normal"><a target="mainFrame" href="../ui/setup_templateUser.jsp" class="admin" >set up</a> a template user</font></p></li>
</ul></td>
</tr></table>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
