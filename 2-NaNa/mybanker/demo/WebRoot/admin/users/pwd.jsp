<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%@ include file="/user/include/getBackendLocation_include.jspf" %>
<%@ include file="/admin/functions/admin_functions.jspf" %>

<%
PortalInfo CurrentPortal = PortalDistributor.getInstance(BACKEND_LOCATION);
UserInfo CurrentUser = null;
String sUserName = null;
try
{
	if( CurrentPortal != null )
	{
		CurrentUser = (UserInfo) session.getAttribute(CurrentPortal.PORTAL_BACKEND_LOCATION+"CurrentUser");
		if( CurrentUser == null)
			throw new NullPointerException("No user logged in");

		if( !CurrentPortal.getRolesObject().doesUserHaveRole(
			CurrentUser.getUserName(), 
			CurrentPortal.getSecurityObject().getKeyByName("AdminRole", "portal_admin" ),
			true) )
		{
			throw new NullPointerException("Logged in user not administrative user");
		}
		
		sUserName = request.getParameter("username");
		if( sUserName == null )
			throw new NullPointerException("Cannot change password, user not given");
		
		String sMessage = (String) CurrentUser.getAttribute("message");
		%>
		<html>
		<head>
		<meta http-equiv="pragma" content="no-cache">
		<meta http-equiv="expires" content="-1">
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />	

		<title>Change Password</title>
		<link rel="stylesheet" type="text/css" href="../../portalinabox.css">
		</head>
		<body topmargin="0" leftmargin="0" rightmargin="0" marginwidth="0" marginheight="0">
		<table width="98%" cellpadding="1" cellspacing="1" border="0" <%=Functions.f_getTableCenter(session)%> >
			<form action="pwd_submit.jsp" method="post" name="pwdform" >
			<tr>
				<td colspan="2"><font class="normal">Type in a new password twice in both boxes to reset this user's password</font></td>
			</tr>
			<tr><td height="24" ></td></tr>
			<%
			if( sMessage != null )
			{
				%>
				<tr>
					<td colspan="2"><font class="adminwarning"><%=sMessage%></font></td>
				</tr>
				<tr><td height="24" ></td></tr>
				<%
			}
			%>
			<tr>
				<td>
					<font class="normal" >Username
				</td>
				<td>
					<input type="hidden" name="username" value="<%=sUserName%>" />
					<font class="normalbold" ><%=sUserName%> </font>
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Password
				</td>
				<td>
					<input type="password" maxlength="256" name="password1" value="" />
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Re-type password
				</td>
				<td>
					<input type="password" maxlength="256" name="password2" value="" />
				</td>
			</tr>
			<tr>
				<td></td>
				<td>
					<a class="textButton" title="Submit" href="javascript:pwdform.submit();" >
						Submit
					</a>					
					&nbsp;
					<a class="textButton" title="Cancel" href="javascript:window.close();" >
						Cancel
					</a>
				</td>
			</tr>
			</form>
		</table>
		</body>
		</html>
		<%
	}
}
catch( Exception e )
{
	if( CurrentPortal != null )
	{
		CurrentPortal.Log("pwd.jsp:  Failed attempt to access this page - " + e);
	}
	%>
	<script type="text/javascript" >window.close()</script>
	<%
}
%>
