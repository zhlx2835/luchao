<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/header/style_header.jspf" %>
	<table width="100%" cellpadding="0" cellspacing="4" align="center" border="0">
		<tr>
			<td colspan="2"><%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%><font style="font-size=4px"><br /></font></td>
		</tr>
		<tr>
			<td valign="top" width="50%">
				<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
				<font style="font-size=4px"><br /></font>
				<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
			</td>
			<td width="50%" valign="top">
				<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
				<font style="font-size=4px"><br /></font>
				<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
			</td>
		</tr>
	</table>
<%@ include file = "/user/header/style_footer.jspf" %>
