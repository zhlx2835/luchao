<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Portlet administration - deleting a portlet";
String sAdminHeader_image = "modules32.gif";
String sPortletName = request.getParameter("pane");
String sRedirectHref= Functions.safeRequestGet(request, "redirecthref", "edit.jsp");

%>
<%@ include file="/admin/header/admin_header.jspf" %>

<script name="JavaScript" type="text/javascript">
//<!-- script hiding
function disableportlet()
{
	deleteForm.disable.value="true";
	deleteForm.submit();
}
function eraseportlet()
{
	deleteForm.erase.value="true";
	deleteForm.submit();
}
// finished Script hiding-->
</script>


<table width="600" <%=Functions.f_getTableCenter(session)%> border="0">
	<form name="deleteForm" action="remove_submit.jsp" method="POST">
		<tr>
			<td colspan="2">
				<input type="hidden" name="pane" value="<%=sPortletName%>" />
				<input type="hidden" name="action" value="deletePortlet" />
				<input type="hidden" name="redirecthref" value="<%=sRedirectHref%>" />
				<input type="hidden" name="erase" />
				<input type="hidden" name="disable" />

				<p><font class="normalbold" >You are about to delete the &quot;<%=sPortletName%>&quot; portlet.  This involves removing the portlet privilege from all the roles, removing the entry from the portlet list.  You also have the option of deleting the files as well.</p>
				<p><font class="normal" >Do you want to:</p>
				<p><font class="normalbold" >Disable this portlet:  Remove this portlet from the portlet list and remove the role from the portal that allows users to view this portlet.<br />
				<font class="normal" > This will allow you to re-create this portlet using the New Portlet wizard later on.</p>
			</td>
		</tr>
		<tr><td height="6"></td></tr>
		<tr>
			<td width="20%">
				<font class="normal" >Disable this portlet:
			</td>
			<td>
				<a class="textButton" title="Disable this portlet" href="javascript:disableportlet();">
					Ok
				</a>
			</td>
		</tr>
		<tr><td height="12"></td></tr>
		<tr><td colspan="2"><p><font class="normalbold" >Completely remove this portlet:<br />
				<font class="normal" > Erase this portlet:  Remove all references to this portlet and all its files.</p></td></tr>
		<tr><td height="6"></td></tr>
		<tr>
			<td width="20%">
				<font class="normal" >Erase this portlet:
			</td>
			<td>
				<a class="textButton" title="Erase this portlet" href="javascript:eraseportlet();">
					Ok
				</a>
			</td>
		</tr>
	</form>
</table>

<%@ include file="/admin/header/admin_footer.jspf" %>
