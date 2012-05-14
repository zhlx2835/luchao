<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sPortlet_name = "disallowed";
%>
<%@ include file = "/user/include/getPortletVars_include.jspf" %>
<%
//Check the roles again.  If the privilege has since reappeared, regrant the pane
//Old pane name is in a key called formerly...
//
boolean bDenied = true;
String sOldPortletName = CurrentPortlet.getFormerPortletName();
if( CurrentRoles.hasUserGotPrivilege(CurrentUser.getUserName(), "panes_viewable", sOldPortletName, true))
{
	//portlet is no longer disallowed
	CurrentPortlet.restoreFormerPortlet();

	bDenied = false;
	%>
	<center><br />
		<font class="warning" >
			Your permission to view this portlet has been restored and you will be able to view it from the next time you refresh this page.<br /><br />
		</font>
	</center>
	<%
}

if(bDenied)
{
	String as[] = CurrentRoles.getUserPrivilege(CurrentUser.getUserName(), "panes_viewable", true);
	%>
	<center><br />
		<font class="warning" >
			You do not have permission to view this portlet<br /><br />
		</font>
	</center>
	<%
}
%>
