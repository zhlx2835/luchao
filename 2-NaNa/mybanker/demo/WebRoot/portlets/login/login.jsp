<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

//get locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));
%>

<%@ include file = "/user/include/getPortletVars_include.jspf" %>

<br/>
<%
String sMessage = request.getParameter("message");
//if there is no message don't display it
if(StringUtils.strValid(sMessage))
{
	%><%= Functions.f_displayError(sMessage) %><%
}
%>

<form name="<%=sPortlet_key%>_login" action="<%= request.getContextPath() %>/portlets/login/login_submit.jsp" style="margin: 0px; padding: 0px;">
	<input type="hidden" name="redirecthref" value="<%=sPortlet_formHref%>" />
	<input type="hidden" name="paneKey" value="<%=sPortlet_key%>" />
	<input type="hidden" name="<%=sPortlet_key%>" value="login" />
	<table class="pane2" cellspacing="4" cellpadding="1" border="0" width="400" style="margin-left:auto; margin-right:auto;">

		<tr>
			<td colspan="2" class="normalbold">
				<%=rb.getString("login.loginHere")%>
			</td>
		</tr>
		<tr>
			<td width="70"  class="normal">
				<%=rb.getString("login.username")%>
			</td>
			<td>
				<input type="text" name="username" value="" maxlength="<%=CurrentPortal.readString(CurrentPortal.ADMIN_SECTION, "MaxUserNameLength", "1024" )%>" />
				<script type="text/javascript">
					<!--
					document.<%=sPortlet_key%>_login.username.focus();

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
							document.<%=sPortlet_key%>_login.submit();
					}
					//-->
				</script>
			</td>
		</tr>
		<tr>
			<td width="70"  class="normal">
					<%=rb.getString("login.password")%>
			</td>
			<td>
				<input type="password" name="password" value="" maxlength="64" onkeyup='checkForEnter(event)'/>
			</td>
		</tr>
		<tr>
			<td></td>
			<td align="left">
				<a class="textButton" title="Login" href="javascript:document.<%=sPortlet_key%>_login.submit();">
					<%=rb.getString("login.login")%>
				</a>
			</td>
		</tr>
<%
		if(StringUtils.isTrue(CurrentPortal.readString(CurrentPortal.ADMIN_SECTION, "AllowUserRegistration", "no")))
		{
%>
			<tr>
				<td></td>
				<td align="left" class="normalbold">
					<%=rb.getString("login.newuser")%>
				</td>
			</tr>
			<tr>
				<td></td>
				<td align="left" class="normal">
					<a href="<%= request.getContextPath() %>/user/home/New_User.jsp">
						<%=rb.getString("login.register")%>
					</a>
				</td>
			</tr>
<%
		}
%>
	</table>
</form>
