<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/functions/admin_functions.jspf" %>

<%@ include file="/admin/home/admin_checkPortal.jspf" %>
<%
String sWhatToDo = request.getParameter("action");
if(sWhatToDo == null)
	sWhatToDo = "showLogin";
//
//Display login screen
//
%>
<html>
<head>
	<title>Portal-in-a-box Administration</title>
	<link rel="stylesheet" type="text/css" href="../../portalinabox.css" />
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="expires" content="-1">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<script type="text/javascript" >
		if(top != self)
		{
			top.location = self.location;
		}
	</script>
</head>

<body bgcolor="<%=BODY_BGCOLOR%>" >
	<br />
	<div align="center">
		<img src="../../images/admin/adminlogo.gif"><br />
		<font class="normalbold">Administration</font><br />
		<br />

		<form action="login_submit.jsp" method="POST" name="admin_login" >
			<input type="hidden" name="action" value="login" />
			<table align="center" cellspacing="0" cellpadding="0" border="0" width="450">
<%
				String sMessage = (String) session.getAttribute("message");
				if( sMessage != null )
				{
					session.removeAttribute( "message" );
%>
					<tr>
						<td bgcolor="<%=DARK_BGCOLOR%>" colspan="2" height="34" align="center">
							<font class="normal" color="#aa4444" /><%=sMessage%></font>
						</td>
					</tr>
<%
				}
				else
				{
%>
					<tr>
						<td bgcolor="<%=DARK_BGCOLOR%>" colspan="2" height="34" align="center">
							<font class="normal" >Please enter your username and password to enter Portal-in-a-Box:</font>
						</td>
					</tr>
<%
				}
%>
				<tr>
					<td bgcolor="<%=DARK_BGCOLOR%>" width="40%" align="right">
						<font class="normal" >Username:&nbsp;</font>
					</td>
					<td bgcolor="<%=DARK_BGCOLOR%>" >
						<input type="text" name="username" style="width:150px;" value="" maxlength="<%=CurrentPortal.readString( CurrentPortal.ADMIN_SECTION, "MaxUserNameLength", "256" )%>" />
						<script type="text/javascript" >
						//<!--
							document.admin_login.username.focus();

							function checkForEnter(e)
							{
								var vSgImage = document.getElementById("sgimage");

								var code;

								// Browser IE/Opera
								if(window.event)
								{
									code=window.event.keyCode;
								}
								else
								{
									code= e.which;
								}

								if(code == '13')
									document.admin_login.submit();
							}
						//-->
						</script>
					</td>
				</tr>
				<tr>
					<td bgcolor="<%=DARK_BGCOLOR%>" width="40%" align="right">
						<font class="normal" >Password:&nbsp;</font>
					</td>
					<td bgcolor="<%=DARK_BGCOLOR%>">
						<input onkeyup='checkForEnter(event)' style="width:150px;" type="password" name="password" value="" maxlength="20" />
					</td>
				</tr>
				<tr>
					<td bgcolor="<%=DARK_BGCOLOR%>" height="34">
						<font class="normal" >&nbsp;</font>
					</td>
					<td bgcolor="<%=DARK_BGCOLOR%>" align="left">
						<a class="textButton" title="Login" href="javascript:document.admin_login.submit();">
							Login
						</a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a class="textButton" title="Home" href="../../user/home/home.jsp">
							Home
						</a>
					</td>
				</tr>
			</table>
		</form>
	</div>
	<br />

</body>

</html>