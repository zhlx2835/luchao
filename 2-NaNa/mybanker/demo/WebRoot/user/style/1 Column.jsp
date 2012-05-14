<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/header/style_header.jspf" %>
<table border="0" cellspacing="0" cellpadding="4" width="100%" <%=Functions.f_getTableCenter(session)%> >
	<tr>	
		<td>
			<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
			<font style="font-size=4px">
				<br />
			</font>
			<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
			<font style="font-size=4px">
				<br />
			</font>
			<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
			<font style="font-size=4px">
				<br />
			</font>
			<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
			<font style="font-size=4px">
				<br />
			</font>
			<%Functions.getPortlet_include(CurrentPortal, CurrentUser, CurrentPage, application, pageContext, request);%>
			<font style="font-size=4px">
				<br />
			</font>
		</td>
	</tr>
</table>
<%@ include file = "/user/header/style_footer.jspf" %>
