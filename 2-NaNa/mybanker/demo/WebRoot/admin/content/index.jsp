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
%>
    <tr>
        <td width="100%" height="<%=th%>" bgcolor="<%=gc()%>">
            <font class="normalbold" >
                <%=f_adminDisplayIcon( request.getContextPath() + "/images/admin/database.gif" )%>Content
            </font>
        </td>
    </tr>
    <tr>
        <td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;
            <a target="mainFrame" href="../content/permissions.jsp" class="admin" >Database Permissions</a>
        </td>
    </tr>
    <tr>
        <td height="<%=th%>" bgcolor="<%=gc()%>">&nbsp;&nbsp;&nbsp;&nbsp;
            <a target="mainFrame" href="../content/categories.jsp" class="admin" >Category Permissions</a>
        </td>
    </tr>
<%
}
%>
<%@ include file="/admin/header/adminmenu_footer.jspf" %>
