<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
//set var picked up by pre-compile include
//
boolean bEditUser = Functions.safeRequestGet(request, "action", "add").equals("edit"); // set to true if new user
String sAdminHeader_title = (bEditUser ? "Edit" : "Add") + " a user";
String sAdminHeader_image = "users32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%

String sEditAction = Functions.safeRequestGet( request, "editaction", "normal" );
String sError = "";
String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName( "BaseRole", "everyone") );
UserInfo EditUser = null;
//
//Default form values - empty if new user.
String sPassword1 = "";
String sPassword2 = "";
String sEmail = "";
String sFullName = "";
String sMaxAgents = "";
String sMaxProfiles = "";

String sDob = "";
String sAddress1 = "";
String sAddress2 = "";
String sAddress3 = "";
String sAddress4 = "";
String sHomeNo = "";
String sWorkNo = "";
String sSMS = "";
String sImpersonate = "";
String sFax = "";
String sStartLetter = Functions.safeRequestGet(request, "startLetter", "");
String sStartNo = Functions.safeRequestGet(request, "startNo", "0");
//
String sUserName = StringUtils.nullToEmpty(request.getParameter("username"));

String[] asSecTypeNames = null;
Vector[] avSecTypeFields = null;


//
if(bEditUser)
{
	try
	{
		//
		//
		EditUser = CurrentPortal.getUserInfo(sUserName);
		bEditUser = true;
		//
		//read user details
		//
		sPassword1 	= "";
		sPassword2 	= "";
		sFullName 	= EditUser.getExtendedField("FullName");
		sEmail 		= EditUser.getExtendedField("EmailAddress");
		sAddress1 	= EditUser.getExtendedField("ADDRESS1");
		sAddress2 	= EditUser.getExtendedField("ADDRESS2");
		sAddress3 	= EditUser.getExtendedField("ADDRESS3");
		sAddress4 	= EditUser.getExtendedField("ADDRESS4");
		sDob 		= EditUser.getExtendedField("DOB");
		sHomeNo 	= EditUser.getExtendedField("HOMENO");
		sWorkNo 	= EditUser.getExtendedField("WORKNO");
		sFax 		= EditUser.getExtendedField("FAXNUMBER");
		sSMS 		= EditUser.getExtendedField("SMSNUMBER");

		asSecTypeNames = EditUser.getSecurityTypeNames();
		avSecTypeFields= EditUser.getSecurityTypeFields();
	}
	catch(Exception e)
	{
		sError = "Could not read user";
		CurrentPortal.Log("addedit:  Could not retrieve user details - creating new user " + e.toString());
	}
}
else
{
	//Get values from request
	//
	sEmail			= StringUtils.nullToEmpty(request.getParameter("email"));
	sFullName 		= StringUtils.nullToEmpty(request.getParameter("fullname"));
	sMaxAgents 		= StringUtils.nullToEmpty(request.getParameter("maxagents"));
	if(sMaxAgents.equals(""))
		sMaxAgents 	= "10";
	sMaxProfiles 	= StringUtils.nullToEmpty(request.getParameter("maxprofiles"));
	if(sMaxProfiles.equals(""))
		sMaxProfiles= "5";
	sDob 			= StringUtils.nullToEmpty(request.getParameter("dob"));
	sAddress1 		= StringUtils.nullToEmpty(request.getParameter("address1"));
	sAddress2 		= StringUtils.nullToEmpty(request.getParameter("address2"));
	sAddress3 		= StringUtils.nullToEmpty(request.getParameter("address3"));
	sAddress4 		= StringUtils.nullToEmpty(request.getParameter("address4"));
	sHomeNo 		= StringUtils.nullToEmpty(request.getParameter("homeno"));
	sWorkNo 		= StringUtils.nullToEmpty(request.getParameter("workno"));
	sSMS 			= StringUtils.nullToEmpty(request.getParameter("sms"));
	sFax 			= StringUtils.nullToEmpty(request.getParameter("fax"));
	sImpersonate 	= StringUtils.nullToEmpty(request.getParameter("calendarimpersonation"));

	// read security type info
	asSecTypeNames = request.getParameterValues("securitytype");
	if(asSecTypeNames != null)
	{
		avSecTypeFields = new Vector[asSecTypeNames.length];
		for(int nSecTypeIdx = 0; nSecTypeIdx < asSecTypeNames.length; nSecTypeIdx++)
		{
			avSecTypeFields[nSecTypeIdx] = new Vector();
			String[] asSecTypeFieldNames  = request.getParameterValues("securitytypefieldnames" + nSecTypeIdx);
			String[] asSecTypeFieldValues = request.getParameterValues("securitytypefieldvalues" + nSecTypeIdx);
			if(asSecTypeFieldNames != null)
			{
				for(int nSecTypeFieldIdx = 0; nSecTypeFieldIdx < asSecTypeFieldNames.length ;nSecTypeFieldIdx++)
				{
					avSecTypeFields[nSecTypeIdx].add(new SecurityField(asSecTypeFieldNames[nSecTypeFieldIdx], asSecTypeFieldValues[nSecTypeFieldIdx]));
				}
			}
		}
	}
	else
	{
		// no security fields so read them from the default user
		UserInfo defaultUser = CurrentPortal.getDefaultUser( true );
		asSecTypeNames = defaultUser.getSecurityTypeNames();
		avSecTypeFields= defaultUser.getSecurityTypeFields();
	}
}

if(sError.length() == 0)
{
	if( bEditUser && sEditAction.equals("chPassword") )
	{
%>
	    <form action="pwd_submit.jsp" method="post" name="pwdform" >
		    <table width="98%" cellpadding="1" cellspacing="1" border="0" <%=Functions.f_getTableCenter(session)%> >
			<tr>
				<td colspan="2"><font class="normal">Type in a new password in both boxes to reset this user's password</font></td>
			</tr>
			<tr><td height="24" ></td></tr>
			<tr>
				<td>
					<font class="normal" >Username</font>
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
				<td><a class="textButton" title="Confirm" href="javascript:void(document.forms[0].submit());" >Confirm</a>&nbsp;<a class="textButton" title="Cancel" href="javascript:history.back();" >Cancel</a></td>
			</tr>
		    </table>
	    </form>
<%
		out.flush();
		return;
	}
%>
		<table border="0" <%=Functions.f_getTableCenter(session)%> cellpadding="0" cellspacing="0" width="90%">
		<tr><td>
		<form action="addedit_submit.jsp" method="POST" name="userEditDetails">
		    <input type="hidden" name="startNo" value="<%=sStartNo%>" />
		    <input type="hidden" name="startLetter" value="<%=sStartLetter%>" />
		    <table width="60%" cellpadding="1" cellspacing="1" border="0" align="left" style="text-align:left" >
			<%
			//Don't want to use action in input tag above - otherwise it will be returned in the querystring twice
			//on return here due to failure
			//
			if(!bEditUser)
			{
%>
				<tr>
					<td align="left" colspan="2">
					    <font class="normalbold" >
							Please fill in the details for the new user <br /><br />
					    </font>
					</td>
				</tr>
<%
			}
%>
			<tr>
				<td>
					<font class="normal" >Username</font>
				</td>
				<td>
<%
					if(bEditUser)
					{
%>
						<input type="hidden" name="action" value="edit" />
						<input type="hidden" name="oldusername" value="<%=EditUser.getUserName()%>" />
						<input type="text" maxlength="<%=CurrentPortal.readString(CurrentPortal.ADMIN_SECTION, "MaxUserNameLength", "256")%>" name="username" value="<%=sUserName%>" /><img src="../../images/admin/required.gif" border="0" hspace="2" alt="" />
<%
					}
					else
					{
%>
						<input type="hidden" name="action" value="add" />
						<input type="text" maxlength="<%=CurrentPortal.readString(CurrentPortal.ADMIN_SECTION, "MaxUserNameLength", "256")%>" name="username" value="<%=sUserName%>" /><img src="../../images/admin/required.gif" border="0" hspace="2" alt="" />
<%
					}
%>
				</td>
			</tr>
<%
			if(bEditUser)
			{
%>
			    <tr>
				<td valign="top">
				    <input type="hidden" name="rolename" value="<%=sRoleName%>" />
				    <font class="normal" >Has roles:</font>
				</td>
				<td>
				    <font class="normal">
					<%
					String[] saUserRoleList = StringUtils.quickSort(CurrentRoles.getRoleList(EditUser.getUserName(), false));
					if(saUserRoleList != null && saUserRoleList.length > 0)
					{
						for(int i = 0; i < saUserRoleList.length; i++)
						{
							if(i != 0)
							{
								%>, <%
							}
							%><%= saUserRoleList[i] %><%
						}
					}
					else
					{
						%>None<%
					}
					%>
				    </font>
				</td>
			    </tr>
<%
			}
			else
			{
%>
			    <tr>
				    <td valign="top">
					    <font class="normal" >Initial role:</font>
				    </td>
				    <td>
					    <%=Functions.f_createSelect("rolename", StringUtils.quickSort(CurrentRoles.getRoleList()), sRoleName )%><br /><br />
				    </td>
			    </tr>
<%
			}

			if(bEditUser)
			{
%>
			    <tr>
				    <td>
					    <font class="normal" >Password</font>
				    </td>
				    <td>
					    <font><a class="normal" href="addedit.jsp?username=<%=sUserName%>&amp;action=edit&amp;editaction=chPassword">Change</a></font>
				    </td>
			    </tr>
<%
			}
			else
			{
%>
				<tr>
					<td>
						<font class="normal" >Password</font>
					</td>
					<td>
						<input type="password" maxlength="256" name="password1" value="<%=sPassword1%>" /><img src="../../images/admin/required.gif" border="0" hspace="2" alt="" />
					</td>
				</tr>
				<tr>
					<td>
						<font class="normal" >Re-type password</font>
					</td>
					<td>
						<input type="password" maxlength="256" name="password2" value="<%=sPassword2%>" /><img src="../../images/admin/required.gif" border="0" hspace="2" alt="" />
					</td>
				</tr>
<%
			}
%>
			<tr>
				<td>
					<font class="normal" >Name</font>
				</td>
				<td>
					<input type="text" maxlength="64" name="fullname" value="<%=sFullName%>" />
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Email address</font>
				</td>
				<td>
					<input type="text" maxlength="512" name="email" value="<%=sEmail%>" /><img src="../../images/admin/required.gif" border="0" hspace="2" alt="" />
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Home address</font>
				</td>
				<td>
					<input type="text" maxlength="128" name="address1" value="<%=sAddress1%>" />
				</td>
			</tr>
			<tr>
				<td></td>
				<td>
					<input type="text" maxlength="128" name="address2" value="<%=sAddress2%>" />
				</td>
			</tr>
			<tr>
				<td></td>
				<td>
					<input type="text" maxlength="128" name="address3" value="<%=sAddress3%>" />
				</td>
			</tr>
			<tr>
				<td></td>
				<td>
					<input type="text" maxlength="128" name="address4" value="<%=sAddress4%>" />
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Date of birth</font>
				</td>
				<td>
					<input type="text" size="10" maxlength="10" name="dob" value="<%=sDob%>" />
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Home number</font>
				</td>
				<td>
					<input type="text" maxlength="24" name="homeno" value="<%=sHomeNo%>" />
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Work number</font>
				</td>
				<td>
					<input type="text" maxlength="24" name="workno" value="<%=sWorkNo%>" />
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Fax number</font>
				</td>
				<td>
					<input type="text" maxlength="24" name="fax" value="<%=sFax%>" />
				</td>
			</tr>
			<tr>
				<td>
					<font class="normal" >Mobile (SMS) number</font>
				</td>
				<td>
					<input type="text" maxlength="24" name="sms" value="<%=sSMS%>" />
					<br />
				</td>
			</tr>
<%
			if(asSecTypeNames != null && avSecTypeFields != null && asSecTypeNames.length > 0)
			{
				int nTypeCnt = asSecTypeNames.length;
				for(int nTypeIdx = 0; nTypeIdx < nTypeCnt; nTypeIdx++)
				{
%>
					<tr><td colspan="2" height="6" /></tr>
					<tr>
						<td>
							<font class="normal" ><b><%=asSecTypeNames[nTypeIdx]%></b> security type details:</font>
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
						}
					}
				}
			}
%>
			<tr><td colspan="2" height="6" /></tr>
			<tr><td height="12" /></tr>
			<tr>
				<td colspan="2" align="center">
					<a class="textButton" title="Cancel" href="javascript:void(document.forms[0].submit());" >Confirm</a>&nbsp;<%=f_admin_displayCancelButton()%>
				</td>
				<td></td>
			</tr>
		</table>
	</form>
	<table width="40%" cellpadding="1" cellspacing="1" align="left" style="text-align:left;" >
<%
		if(bEditUser)
		{
%>
			<tr><td colspan="2"><font class="normalbold" >Options:</font></td></tr>
			<tr><td></td><td><a class="normal" href="../ui/becomeUser_submit.jsp?username=<%=sUserName%>" >Log in as this user</a></td></tr>
			<tr>
				<td>
					<form method="post" name="eraseForm" action="remove_submit.jsp" >
					<input type="hidden" name="username" value="<%=EditUser.getUserName()%>" />
<%
					if( sStartLetter != null )
					{
%>
						<input type="hidden" name="startLetter" value="<%=sStartLetter%>" />
<%
					}
					if( sStartNo != null )
					{
%>
						<input type="hidden" name="startNo" value="<%=sStartNo%>" />
<%
					}
%>
					</form>
				</td>
				<td>
					<a href="javascript:if(confirm('Are you sure you want to completely erase this user?')){document.eraseForm.submit();}" >
						<font class="normal" >Completely erase this user</font>
					</a>
				</td>
			</tr>
<%
			boolean bIsChecked = EditUser.isTemplateUser( sRoleName );
%>
			<tr>
			    <td>
				    <form name="templateUserYesNo" action="../ui/makeTemplateUser.jsp" >
					    <input type="hidden" name="username" value="<%=sUserName%>" />
					    <input type="checkbox" onClick="this.form.submit();" name="tuyn" value="on" <%= bIsChecked ? "checked" : "" %> />
				    </form>
			    </td>
			    <td>
				    Check to make this the template user for the <%=sRoleName%> role
			    </td>
			</tr>
<%

		}
%>
	</table>
	</td></tr>
	</table>
<%
} // end of user validity test
else
{
%>
	<%=f_adminDisplayError( sError )%>
<%
}
%>
<%@ include file="/admin/header/admin_footer.jspf" %>
