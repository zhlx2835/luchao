<%@ page import="com.autonomy.config.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%@ include file="/admin/header/adminmenu_header.jspf" %>
<%@ include file="/user/include/getBackendLocation_include.jspf" %>
<%
PortalInfo CurrentPortal = PortalDistributor.getInstance( BACKEND_LOCATION );
if( CurrentPortal == null )
{
	%>
	<font class="warning">Portal not instantiated.  Please try again</font>
	<%
}
else
{
	String[] asSections = CurrentPortal.getSectionNames();
	int nWidth = (int) Math.floor( 100 / asSections.length );
	String sth = "6";
	%>
	<tr height="<%=th2%>">
		<td width="100%" height="<%=th%>" bgcolor="<%=gc()%>"><font class="normalbold" ><%=f_adminDisplayIcon( "../../images/admin/administrator.gif" )%>
		Setup</font></td>
	</tr>
	<%
	for( int i = 0; i < asSections.length; i++ )
	{
		%>
		<tr height="<%=th%>">
			<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="setup_content.jsp#<%=asSections[i]%>" class="admin" >[<%=asSections[i]%>]</a></td>
		</tr>
		<%
	}
	%>
	<tr height="<%=th%>">
		<td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;<a target="mainFrame" href="setup_security.jsp" class="admin" >Setup Security</a></td>
	</tr>
	<%
}
%>
<%@ include file="/admin/header/adminmenu_footer.jspf" %>
