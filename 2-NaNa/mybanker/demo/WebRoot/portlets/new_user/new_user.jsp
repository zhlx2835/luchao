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
<%
try
{
	//Sign in a new user iff key is set in portal cfg
	//
	if(!StringUtils.isTrue(CurrentPortal.readString( CurrentPortal.ADMIN_SECTION, "AllowUserRegistration", "no")))
	{
%>
		<br />
		<%=Functions.f_displayError("This has been disabled by the site administrator")%>
<%
	}
	else
	{
		String sContextPath = request.getContextPath();

		String[] sa_roleList = CurrentRoles.getRoleList();
		if(sa_roleList == null || sa_roleList.length == 0)
		{
			//No roles
			//
			try
			{
				CurrentRoles.init();
			}
			catch(Exception e)
			{
				CurrentPortal.Log("new_user: Couldn't initialise roles!!");
				response.sendRedirect(sContextPath + "/error.jsp?error=Could+not+create+roles+information");
				return;
			}
			sa_roleList = StringUtils.quickSort( CurrentRoles.getRoleList() );
		}
		StringUtils.quickSort( sa_roleList );

		String[] saLanguageOptions = StringUtils.split(CurrentPortal.readString(CurrentPortal.LANGUAGE_SECTION, "LanguageTypesDisplayName", "english"), ",");

		String sWhatToDo = request.getParameter(CurrentPortlet.getPortletKey());
		//

		String sUserName      = StringUtils.nullToEmpty(request.getParameter("username"));
		String sPassword1     = "";
		String sPassword2     = "";
		String sLanguage      = StringUtils.nullToEmpty(request.getParameter("language"));
		String sEmail         = StringUtils.nullToEmpty(request.getParameter("email"));
		String sAuthorisation = StringUtils.nullToEmpty(request.getParameter("authorisation"));
		String sRoleName      = HTMLUtils.safeRequestGet(request,"role", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone"));
		//
		if(sWhatToDo == null)
		{
			sWhatToDo = "NewUser";
		}

		String sMessage = (String) CurrentUser.getAttribute( CurrentPortlet.getPortletKey() + "message" );
		if( sMessage != null)
		{
			CurrentUser.removeAttribute( CurrentPortlet.getPortletKey() + "message" );
%>
			<%=Functions.f_displayError( sMessage )%>
<%
		}
%>
		<br />
		<script type="text/javascript">

		function jf_isValidString(sString)
		{
			if(sString.length == 0)
			{
				return true;
			}

			for(i = 0; i < sString.length; i++)
			{
				var cToValidate = sString.charAt(i);

				if(cToValidate == '<' || cToValidate == '>' || cToValidate == '\"')
				{
					return false;
				}
			}
			return true;
		}

		function jf_<%=CurrentPortlet.getPortletKey()%>_validate(fForm)
		{
			for(i2 = 0; i2 < fForm.elements.length; i2++)
			{
				var elt = fForm.elements[i2];
				if(elt.type == "text" || elt.type == "password")
				{
					if(!jf_isValidString(elt.value))
					{
						alert("Please ensure that there are no \u003C, \u003E, or \\ symbols in your details and then resubmit");
						return false;
					}
				}
			}
			return true;
		}

		</script>

	<p align="left">
		<font class="normal">
			&nbsp;<%=rb.getString("new_user.createNewAccount")%>
		</font>
	</p>

	<form name="newuser_form" action="<%= sContextPath %>/portlets/new_user/new_user_submit.jsp" method="POST" onSubmit="return jf_<%=CurrentPortlet.getPortletKey()%>_validate(this);">
		<input type="hidden" name="paneKey" value="<%=sPortlet_key%>" />
		<table width="98%" style="margin-left:auto; margin-right:auto;" cellpadding="1" cellspacing="2">
			<tr>
				<td align="left" width="200"><font class="normal" ><%=rb.getString("new_user.userName")%> </font></td>
				<td align="left" width="160">
					<input type="text" name="username" value="<%=sUserName%>" maxlength="<%=CurrentPortal.readString(CurrentPortal.ADMIN_SECTION, "MaxUserNameLength", "1024" )%>" />
				</td>
				<td></td>
			</tr>

			<tr>
				<td align="left" width="200"><font class="normal" ><%=rb.getString("new_user.password")%> </font></td>
				<td align="left">
					<input type="password" name="password1" value="<%=sPassword1%>" maxlength="64" />
				</td>
				<td></td>
			</tr>

			<tr>
				<td align="left" width="200"><font class="normal" ><%=rb.getString("new_user.reenterPW")%> </font></td>
				<td align="left">
					<input type="password" name="password2" value="<%=sPassword2%>" maxlength="64" />
				</td>
				<td></td>
			</tr>

			<tr>
				<td align="left" width="200">
					<font class="normal" >
						<%=rb.getString("new_user.queryLang")%>
					</font>
				</td>
				<td align="left">
					<%= HTMLUtils.createSelect("language", saLanguageOptions, "english", false) %>
				</td>
				<td></td>
			</tr>

			<tr>
				<td  align="left" width="200">
					<font class="normal" >
						<%=rb.getString("new_user.email")%>
					</font>
				</td>
				<td align="left">
					<input type="text" name="email" value="<%=sEmail%>" maxlength="1024" />
				</td>
				<td></td>
			</tr>

			<tr>
				<td align="left" width="200">
					<font class="normal" >
						<%=rb.getString("new_user.initialRole")%>
					</font>
				</td>
				<td align="left">
					<%=Functions.f_createSelect("role", sa_roleList, sRoleName)%>
				</td>
				<td></td>
			</tr>

			<tr>
				<td align="left" width="200">
					<font class="normal" >
						<%=rb.getString("new_user.roleAuthorization")%>
					</font>
				</td>
				<td align="left">
					<input type="password" name="authorisation" value="<%=sAuthorisation%>" maxlength="64" />
				</td>
				<td align="left">
					<font class="note" >
						<%=rb.getString("new_user.contactPortalAdmin")%>
					</font>
				</td>
			</tr>

			<tr><td colspan="3" height="6"></td></tr>

			<tr>
				<td></td>
				<td colspan="2" align="left">
					<a class="textButton" title="Submit" href="javascript:newuser_form.submit();">
						<%=rb.getString("new_user.submit")%>
					</a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="textButton" title="Cancel" href="javascript:history.back()">
						<%=rb.getString("new_user.cancel")%>
					</a>
				</td>
				<td></td>
			</tr>
		</table>
	</form>
<%
	}//end of user registration allowed check

}
catch( Exception e )
{
	CurrentPortal.LogThrowable( e );
}
%>
