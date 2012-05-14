<%@ page import = "com.autonomy.config.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

String sAdminHeader_title = "General Setup";
String sAdminHeader_image = "";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
String sth = "6";
String sth2 = "12";
String sin = "96";
String protocol = CurrentPortal.readString( CurrentPortal.SERVERS_SECTION, "IDOLProtocol", "http" );
String sUAServerURL = protocol + "://" +
							CurrentPortal.readString( CurrentPortal.SERVERS_SECTION, "UserHost", "" ) +
							":" +
							CurrentPortal.readString( CurrentPortal.SERVERS_SECTION, "UserPort", "" ) +
							"/";

String sClassServerURL = protocol + "://" +
							CurrentPortal.readString( CurrentPortal.SERVERS_SECTION, "CategoryHost", "" ) +
							":" +
							CurrentPortal.readString( CurrentPortal.SERVERS_SECTION, "CategoryPort", "" ) +
							"/";

String sDREURL = protocol + "://" +
							CurrentPortal.readString( CurrentPortal.SERVERS_SECTION, "QueryHost", "" ) +
							":" +
							CurrentPortal.readString( CurrentPortal.SERVERS_SECTION, "QueryPort", "" ) +
							"/";

%>

<table width="90%" cellpadding="0" cellspacing="0" border="0" <%=Functions.f_getTableCenter( session )%> >
<tr bgcolor="<%=DARK_BGCOLOR%>" >
	<td colspan="3" ><font class="normalbold">IDOL Server</font></td>
</tr>
<tr><td height="<%=sth2%>" ></td></tr>

<tr bgcolor="<%=DARK_BGCOLOR%>" >
	<td bgcolor="<%=BODY_BGCOLOR%>" width="<%=sin%>"><font class="normal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
	<td colspan="2" ><font class="normal">User:</font></td>
</tr>

<tr><td height="<%=sth%>" ></td></tr>
<tr>
	<td></td>
	<td width="50%"><a class="admin" href="<%=sUAServerURL%>action=Help" target="helpwin">View IDOL User Help</a></td>
	<td width="50%"><a class="admin" href="<%=sUAServerURL%>action=GetRequestLog" target="logwin">View IDOL User Request Log</a></td>
</tr>
<tr><td height="<%=sth2%>" ></td></tr>

<tr bgcolor="<%=DARK_BGCOLOR%>" >
	<td bgcolor="<%=BODY_BGCOLOR%>" width="<%=sin%>"><font class="normal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
	<td colspan="2" ><font class="normal">Category:</font></td>
</tr>
<tr><td height="<%=sth%>" ></td></tr>

<tr>
	<td></td>
	<td width="50%"><a class="admin" href="<%=sClassServerURL%>action=Help" target="helpwin">View IDOL Category Help</a></td>
	<td width="50%"><a class="admin" href="<%=sClassServerURL%>action=GetRequestLog" target="logwin">View IDOL Category Request Log</a></td>
</tr>
<tr><td height="<%=sth2%>" ></td></tr>

<tr bgcolor="<%=DARK_BGCOLOR%>" >
	<td bgcolor="<%=BODY_BGCOLOR%>" width="<%=sin%>"><font class="normal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
	<td colspan="2" ><font class="normal">Query:</font></td>
</tr>

<tr><td height="<%=sth%>" ></td></tr>
<tr>
	<td></td>
	<td width="50%"><a class="admin" href="<%=sDREURL%>action=Help" target="helpwin">View IDOL Query Help</a></td>
	<td width="50%"><a class="admin" href="<%=sDREURL%>action=GetRequestLog" target="logwin">View IDOL Query Request Log</a></td>
</tr>
<tr><td height="<%=sth2%>" ></td></tr>
<tr><td height="<%=sth2%>" ></td></tr>

<tr bgcolor="<%=DARK_BGCOLOR%>" ><td colspan="3" ><font class="normalbold">Support</font></td></tr>
<tr><td height="<%=sth2%>" ></td></tr>

<tr bgcolor="<%=DARK_BGCOLOR%>" >
	<td bgcolor="<%=BODY_BGCOLOR%>" width="<%=sin%>"><font class="normal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
	<td colspan="2" ><font class="normal">Helpdesk:</font></td>
</tr>

<tr><td height="<%=sth%>" ></td></tr>
<tr>
	<td width="<%=sin%>"><font class="normal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td><td width="50%"><a class="admin" href="http://automater.autonomy.com">Browse Helpdesk</a></td><td width="50%" ></td>
</tr>
<tr>
	<td colspan="1" ><font class="note">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td><td colspan="2"><font class="note">(You will need a log in.  If you have a support agreement, you can obtain a log in by contacting Autonomy Support)</font></td>
</tr>
<tr><td height="<%=sth2%>" ></td></tr>
</table>


<%@ include file="/admin/header/admin_footer.jspf" %>
