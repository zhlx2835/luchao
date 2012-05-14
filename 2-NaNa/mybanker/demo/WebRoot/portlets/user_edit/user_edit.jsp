<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/include/getPortletVars_include.jspf"%>
<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

try
{
	String sWhatToDo = request.getParameter(CurrentPortlet.getPortletKey());

	if(sWhatToDo == null)
		sWhatToDo = "editDetails";

	String sFullName 					= CurrentUser.getFullName();
	String sLanguageType			= CurrentUser.getExtendedField("DRELanguageType");
	String sEmail 						= CurrentUser.getExtendedField("EmailAddress");
	String sAddress1 					= CurrentUser.getExtendedField("ADDRESS1");
	String sAddress2 					= CurrentUser.getExtendedField("ADDRESS2");
	String sAddress3 					= CurrentUser.getExtendedField("ADDRESS3");
	String sAddress4 					= CurrentUser.getExtendedField("ADDRESS4");
	String sDob 							= CurrentUser.getExtendedField("DOB");
	String sPhone 						= CurrentUser.getExtendedField("HOMENO");
	String sWorkPhone 				= CurrentUser.getExtendedField("WORKNO");
	String sFax 							= CurrentUser.getExtendedField("FAXNUMBER");
	String sSMS 							= CurrentUser.getExtendedField("SMSNUMBER");
	String[] asSecTypeNames 	= CurrentUser.getSecurityTypeNames();
	Vector[] avSecTypeFields	= CurrentUser.getSecurityTypeFields();

	String[] saLanguageOptions = StringUtils.split(CurrentPortal.readString(CurrentPortal.LANGUAGE_SECTION, "LanguageTypesDisplayNames", "english"), ",");

	// display error message if there is one
	String sMessage 	= (String)CurrentUser.getAttribute( CurrentPortlet.getPortletKey() + "message");
	if(StringUtils.strValid(sMessage))
	{
		CurrentUser.removeAttribute( CurrentPortlet.getPortletKey() + "message" );
%>
		<%=Functions.f_displayError(sMessage)%>
<%
	}

	if( sWhatToDo.equals("setFields") )
	{
		sFullName 	= StringUtils.nullToEmpty(request.getParameter("fullname"));
		sEmail 		= StringUtils.nullToEmpty(request.getParameter("email"));
		sLanguageType = StringUtils.nullToEmpty(request.getParameter("language"));
		sAddress1 	= StringUtils.nullToEmpty(request.getParameter("address1"));
		sAddress2 	= StringUtils.nullToEmpty(request.getParameter("address2"));
		sAddress3 	= StringUtils.nullToEmpty(request.getParameter("address3"));
		sAddress4 	= StringUtils.nullToEmpty(request.getParameter("address4"));
		sDob 		= StringUtils.nullToEmpty(request.getParameter("dob"));
		sPhone 		= StringUtils.nullToEmpty(request.getParameter("phone"));
		sWorkPhone 	= StringUtils.nullToEmpty(request.getParameter("workphone"));
		sFax 		= StringUtils.nullToEmpty(request.getParameter("fax"));
		sSMS 		= StringUtils.nullToEmpty(request.getParameter("sms"));
	}

	if( sWhatToDo.equals("chPassword") )
	{
%>
		<form action="<%= request.getContextPath() %>/portlets/user_edit/pwd_submit.jsp" method="post" name="pwdform" >
		<input type="hidden" name="paneKey" value="<%=CurrentPortlet.getPortletKey()%>" />
			<table width="98%" cellpadding="1" cellspacing="1" border="0"<%=Functions.f_getTableCenter(session)%> >
				<tr>
					<td colspan="2">
						<font class="normalbold">
							<%=rb.getString("user_edit.typeNewPW")%>
						</font>
					</td>
				</tr>
				<tr><td height="24" ></td></tr>
				<tr>
					<td>
						<font class="normalbold" >
							<%=rb.getString("user_edit.userName")%>
						</font>
					</td>
					<td>
						<input type="hidden" name="username" value="<%=CurrentUser.getUserName()%>" />
						<font class="normalbold" >
							<%=CurrentUser.getUserName()%>
						</font>
					</td>
				</tr>
				<tr>
					<td>
						<font class="normalbold" >
							<%=rb.getString("user_edit.oldPW")%>
						</font>
					</td>
					<td>
						<input type="password" maxlength="256" name="oldpassword" value="" />
					</td>
				</tr>
				<tr>
					<td>
						<font class="normalbold" >
							<%=rb.getString("user_edit.newPW")%>
						</font>
					</td>
					<td>
						<input type="password" maxlength="256" name="password1" value="" />
					</td>
				</tr>
				<tr>
					<td>
						<font class="normalbold" >
							<%=rb.getString("user_edit.retypePW")%>
						</font>
					</td>
					<td>
						<input type="password" maxlength="256" name="password2" value="" />
					</td>
				</tr>
				<tr>
					<td></td>
					<td>
						<br /><a href="javascript:document.pwdform.submit();" title="Submit" class="textButton"><%=rb.getString("user_edit.submit")%></a>&nbsp;
					</td>
				</tr>
			</table>
		</form>
<%
		out.flush();
		return;
	}
%>
	<br />
	<form action="<%= request.getContextPath() %>/portlets/user_edit/user_edit_submit.jsp" method="POST" name="userEditDetails">
		<input type="hidden" name="paneKey" value="<%=CurrentPortlet.getPortletKey()%>" />
		<input type="hidden" name="<%=CurrentPortlet.getPortletKey()%>" value="setFields" />
		<input type="hidden" name="username" value="<%=CurrentUser.getUserName()%>" />
		<table width="98%" cellpadding="1" cellspacing="1" style="margin-left:auto; margin-right:auto;">
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.userName")%>
					</font>
				</td>
				<td width="50%">
					<font class="normalbold" >
						<%=CurrentUser.getUserName()%>
					</font>
				</td>
			</tr>
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.name")%>
					</font>
				</td>
				<td width="50%">
					<input type="text" maxlength="64" name="fullname" value="<%=sFullName%>" />
				</td>
			</tr>
			<tr>
				<td width="50%" valign="top">
					<font class="normalbold" >
						<%=rb.getString("user_edit.haveRoles")%>
					</font>
				</td>
				<td width="50%">
					<font class="normal">
<%
						String[] saUserRoleList = CurrentRoles.getRoleList(CurrentUser.getUserName(), false);
						if(saUserRoleList != null && saUserRoleList.length > 0)
						{
							for(int i = 0; i < saUserRoleList.length; i++)
							{
								out.write(saUserRoleList[i].toLowerCase() + "<br />");
							}
						}
						else
						{
							out.write("None");
						}
%>
					</font>
				</td>
			</tr>
<%
			if( !CurrentPortal.getSecurityObject().getKeyByName("LoginMethod").equals("ntlm") )
			{
%>
				<tr>
					<td>
						<font class="normalbold" >
							<%=rb.getString("user_edit.password")%>
						</font>
					</td>
					<td>
						<!-- Need to change this to a button -->
						<a href="<%= request.getContextPath() %>/user/home/home.jsp?<%=CurrentPortlet.getPortletKey()%>=chPassword">
							<font class="normalbold" >
								<%=rb.getString("user_edit.change")%>
							</font>
						</a>
					</td>
				</tr>
<%
			}
%>
			<tr><td height="6"></td></tr>

			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.queryLang")%>
					</font>
				</td>
				<td width="50%">
					<%= HTMLUtils.createSelect("language", saLanguageOptions, lookupLanguageOptions(CurrentPortal, sLanguageType), false) %>
				</td>
			</tr>
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.emailAddr")%>
					</font>
				</td>
				<td width="50%">
					<input type="text" maxlength="512" name="email" value="<%=sEmail%>" />
					<img border="0" width="13" height="12" src="<%= request.getContextPath() %>/images/required.gif" alt="">
				</td>
			</tr>
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.homeAddr")%>
					</font>
				</td>
				<td width="50%">
					<input type="text" maxlength="128" name="address1" value="<%=sAddress1%>" />
				</td>
			</tr>
			<tr>
				<td width="50%"></td>
				<td width="50%">
					<input type="text" maxlength="128" name="address2" value="<%=sAddress2%>" />
				</td>
			</tr>
			<tr>
				<td width="50%"></td>
				<td width="50%">
					<input type="text" maxlength="128" name="address3" value="<%=sAddress3%>" />
				</td>
			</tr>
			<tr>
				<td width="50%"></td>
				<td width="50%">
					<input type="text" maxlength="128" name="address4" value="<%=sAddress4%>" />
				</td>
			</tr>
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.DOB")%>
					</font>
				</td>
				<td width="50%">
					<input type="text" size="10" maxlength="10" name="dob" value="<%=sDob%>" />
				</td>
			</tr>
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.homeNo")%>
					</font>
				</td>
				<td width="50%">
					<input type="text" maxlength="24" name="phone" value="<%=sPhone%>" />
				</td>
			</tr>
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.workNo")%>
					</font>
				</td>
				<td width="50%">
					<input type="text" maxlength="24" name="workphone" value="<%=sWorkPhone%>" />
				</td>
			</tr>
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.FaxNo")%>
					</font>
				</td>
				<td width="50%">
					<input type="text" maxlength="24" name="fax" value="<%=sFax%>" />
				</td>
			</tr>
			<tr>
				<td width="50%">
					<font class="normalbold" >
						<%=rb.getString("user_edit.MobileNo")%>
					</font>
				</td>
				<td width="50%">
					<input type="text" maxlength="24" name="sms" value="<%=sSMS%>" />
				</td>
			</tr>
<%
			// document repository info
			if(asSecTypeNames != null && avSecTypeFields != null && asSecTypeNames.length > 0)
			{
				int nTypeCnt = asSecTypeNames.length;
				for(int nTypeIdx = 0; nTypeIdx < nTypeCnt; nTypeIdx++)
				{
%>
					<tr><td colspan="2" height="6" /></tr>
					<tr>
						<td>
							<font class="normal" ><b><%=asSecTypeNames[nTypeIdx]%></b> <%=rb.getString("user_edit.securityType")%></font>
						</td>
						<td>
							<input type="hidden" name="securitytype" value="<%=asSecTypeNames[nTypeIdx]%>" />
							<br />
						</td>
					</tr>
<%
					if(avSecTypeFields[nTypeIdx] != null)
					{
						Enumeration enFields = avSecTypeFields[nTypeIdx].elements();
						while(enFields.hasMoreElements())
						{
							SecurityField sf = (SecurityField)enFields.nextElement();
%>
							<tr>
								<td>
									<font class="normal">&nbsp;&nbsp;<%= sf.getName() %></font>
									<input type="hidden" name="securitytypefieldnames<%= nTypeIdx %>" value="<%= sf.getName() %>" />
								</td>
								<td>
									<input type="text" name="securitytypefieldvalues<%= nTypeIdx %>" value="<%= sf.getValue() %>" />
									<br />
								</td>
							</tr>
<%
						}	// loop through security type fields
					}	// if security type has fields
				}	// loop through security types
			}	// if there are security fields to display
%>
			<tr>
				<td></td>
				<td>
					<br /><a href="javascript:document.userEditDetails.submit();" title="Submit" class="textButton"><%=rb.getString("user_edit.submit")%></a>&nbsp;
				</td>
				<td></td>
			</tr>
		</table>
	</form>
<%
}
catch( Exception e )
{
	CurrentPortal.LogThrowable( e );
}
%>

<%!
private String lookupLanguageOptions(PortalInfo portal, String sLanguageType)
{
	String sLanguageOption = "";

	String[] saLanguageDisplayNames = StringUtils.split(portal.readString(portal.LANGUAGE_SECTION, "LanguageTypesDisplayNames", "English"), ",");
	String[] saLanguageTypes = StringUtils.split(portal.readString(portal.LANGUAGE_SECTION, "LanguageTypes", "english"), ",");

	int nNameIdx = StringUtils.isStringInStringArray(saLanguageTypes, sLanguageType, false);
	if(nNameIdx != -1)
	{
		sLanguageOption = saLanguageDisplayNames[nNameIdx];
	}
	return sLanguageOption;
}
%>