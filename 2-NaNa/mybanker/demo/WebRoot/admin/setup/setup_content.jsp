<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sAdminHeader_title = "Setup";
String sAdminHeader_image = "administrator32.gif";
%>
<%@ page import = "com.autonomy.config.*" %>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
String[] asSections = CurrentPortal.getSectionNames();
int nWidth = (int) Math.floor( 100 / asSections.length );
String sth = "6";
%>
<form name="setup_content_form" action="setup_submit.jsp" method="post" >
<table width="90%" cellpadding="0" cellspacing="0" border="0" align="center" style="margin-left:auto; margin-right:auto;" >
	<tr><td height="<%=sth%>" ></td></tr>
	<%
	String[] asKeys = null;
	ConfigSection section = null;
	String sKeyValue = null;

	for( int i = 0; i < asSections.length; i++ )
	{
		section = CurrentPortal.readSection( asSections[i] );
		asKeys = section.getKeyNames();
		%>
		<tr>
			<td colspan="2" bgcolor="<%=DARK_BGCOLOR%>" height="19" >
				<font class="normalbold">
					[<a name="<%=asSections[i]%>" ></a><%=asSections[i]%>] section
				</font>
			</td>
			<td></td>
		</tr>
		<tr><td colspan="2" height="<%=sth%>" ></td></tr>
		<%
		for( int j = 0; j < asKeys.length; j++ )
		{
			sKeyValue = StringUtils.stringReplace(section.readString(asKeys[j], ""), "\"", "&quot;");
			%>
		<tr>
			<td>
				<font class="normal"><%=asKeys[j]%>:</font>
				<input type="hidden" size="40" name="section<%=asKeys[j]%>" value="<%=asSections[i]%>">
			</td>
			<td>
				<input type="text" size="40" name="<%=asKeys[j]%>" value="<%=sKeyValue%>">
			</td>
		</tr>
		<tr><td colspan="2" height="<%=sth%>" ></td></tr>
			<%
		}
	}
	%>
	<tr>
		<td colspan="1" >
			<a class="textButton" title="Submit" href="javascript:setup_content_form.submit()">
				Submit
			</a>
		</td>
		<td></td>
	</tr>
</table>
</form>
<%@ include file="/admin/header/admin_footer.jspf" %>
