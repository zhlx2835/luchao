<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//Allows editing of the portlet.cfg file remotely
//set var picked up by pre-compile include
//
boolean bEdit = Functions.safeRequestGet( request, "action", "edit").equals("edit");
String sAdminHeader_title = bEdit ? "Edit a portlet" : "Remove a portlet";
String sAdminHeader_image = "modules32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
String[] saPortletIDs = StringUtils.quickSort(allPortlets.getSectionNames());
String sRoleName = Functions.safeRequestGet(request, "role", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone"));
boolean bDark = false;

//Display portlet list
//
%>
<table align="center" style="margin-left:auto; margin-right:auto; padding:0px;" width="80%" cellspacing="3" cellpadding="0">
<tr>
    <td colspan="3" align="center" >
        <font class="normal">
            <%=bEdit ? "Edit a portlet's properties by clicking on the Edit button next to it" : "Remove a portlet by clicking on the Remove button next to it" %>
            <br />
        </font>
    </td>
</tr>
<tr>
	<td colspan="3" align="center" ><font class="normal">Portlets can be activated / deactivated by clicking on the <b>show/hide</b> button
	<br /><br /></font></td>
</tr>
<%
int nViewable, nEditable, nSelectable = 0;
int nCount = 0;

boolean bShowAll = StringUtils.isTrue(CurrentPortal.readString( CurrentPortal.ADMIN_SECTION, "AdminShowallPortlets", "no"));

for(int i = 0; i < saPortletIDs.length; i++)
{
	String sPortletID = saPortletIDs[i];
	String sEscapedPortletID = sPortletID.replace(' ', '+');
	if(bShowAll || !allPortlets.readString(sPortletID, "Type", "normal").equalsIgnoreCase("system"))
	{
		bDark = !bDark;
		%>
		<tr <%if(bDark){out.write("bgcolor=\"" + DARK_BGCOLOR + "\"");}%> >
                    <td width="50%"><font class="normalbold" >(<%=sPortletID%>)&nbsp;<%=allPortlets.getFullName(sPortletID)%></font><br /><font class="note" ><%=allPortlets.getDescription(sPortletID)%></font></td>
                    <td width="30%" align="center"><a href="portlet_adminedit.jsp?action=editDefaults&amp;pane=<%=sEscapedPortletID%>"><img alt="Edit this portlet" border="0" src="../../images/buttons/<%=ADMIN_BUTTON%>/b_editpane.gif"></a>&nbsp;&nbsp;&nbsp;
		<%
		if( allPortlets.readString( sPortletID, "Visibility", "visible" ).equalsIgnoreCase("hidden") )
		{
			%>
			<a href="hide_submit.jsp?pane=<%=sEscapedPortletID%>"><img border="0" src="../../images/buttons/<%=ADMIN_BUTTON%>/b_showpane.gif" alt="Activate this portlet" ></a>&nbsp;&nbsp;&nbsp;
			<%
		}
		else
		{
			%>
			<a href="hide_submit.jsp?pane=<%=sEscapedPortletID%>"><img border="0" src="../../images/buttons/<%=ADMIN_BUTTON%>/b_hidepane.gif" alt="Hide this portlet"></a>&nbsp;&nbsp;&nbsp;
			<%
		}
		%><a href="remove.jsp?pane=<%=sEscapedPortletID%>" ><img alt="Remove this portlet" border="0" src="../../images/buttons/<%=ADMIN_BUTTON%>/b_deletepane.gif"></a></td>
		</tr>
		<%
	}// end of pane type check
}//end of loop through panes
bDark=!bDark;
%>

<tr>
    <td colspan="5">
        <form name="showallPortletsForm" action="showAll_submit.jsp" method="POST">
            <input type="hidden" name="redirecthref" value="edit.jsp" >
            <font class="note" >Show all Portlets in the list? </font><input type="checkbox" onClick="this.form.submit();" name="showallPortlets" value="on" <%if(bShowAll){%>checked <%}%> />
            <%--<input type="image" src="../../images/buttons/<%=ADMIN_BUTTON%>/b_go_small.gif" border="0" />--%>
            <a class="normal" href="showAll_help.jsp" target="adminHelpWindow" >Whats This?</a>
        </form>
    </td>
</tr>
</table>
<script type="text/javascript" >
	<!--
		var bCheck = false;
	//-->
</script>
<%@ include file="/admin/header/admin_footer.jspf" %>
