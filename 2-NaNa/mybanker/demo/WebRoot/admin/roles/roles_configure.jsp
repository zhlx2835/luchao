<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "Configure Roles";
String sAdminHeader_image = "authentication32.gif";
%>
<%@ include file="/admin/header/adminhome_header.jspf" %>
<%
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();

String sAdminRole = CurrentSecurity.getKeyByName("AdminRole", "portal_admin");
String sBaseRole = CurrentSecurity.getKeyByName("BaseRole", "people");
String sGuestRole = CurrentSecurity.getKeyByName("GuestRole", "guest");

String sAuthMethod = CurrentSecurity.getKeyByName("AuthenticationMethod", "autonomy_security"); 
String sAuthType = CurrentSecurity.getKeyByName("LoginMethod", "standard");
String sNtMethod = CurrentSecurity.getKeyByName("NtMethod", "none");

String sDBPriv = CurrentSecurity.getKeyByName( "DatabasePrivilege", "databases" );

%>
<form name="roles_configure_form" action="conf_submit.jsp" method="POST">

<table class="normal" width="80%" align="center">
	<tr>
		<td width="40%">
                    <font class="normal" >
                        Please enter the name of the database privilege:
                    </font>
		</td>
		<td width="40%">
			<input type="text" name="dbpriv" value="<%=sDBPriv%>" />
		</td>
	</tr>
	<tr><td></td><td colspan="1" >
	<font class="note" >This must match the equivalent setting in IDOL Server</font>
	</td></tr>
	<tr><td></td><td colspan="2" height="8" ></td></tr>
	
	<tr>
		<td width="50%">
                    <font class="normal" >
                        Please select the base role:
                    </font>
		</td>
		<td width="50%">
			<%
			String[] asRoles = StringUtils.quickSort(CurrentRoles.getRoleList());
			%>
			<select name="baseRole">
				<%
				if (asRoles !=null)
				{
					for(int i = 0; i<asRoles.length; i++)
					{
						String sThisRole = asRoles[i].toLowerCase();
						%>
						<option value="<%=sThisRole%>" <%=Functions.f_isSelectedString(sThisRole, sBaseRole)%>><%=asRoles[i].replace('_', ' ').toLowerCase()%></option>
						<%
					}
				}
				%>
			</select>
		</td>
	</tr>
	<tr><td colspan="2" ><font class="note" >This is the root role that contains all portal users </font></td></tr>
	<tr><td height="6"></td></tr>

	<tr>
		<td width="50%">
                    <font class="normal" >
                        Please select the guest role:
                    </font>
		</td>
		<td width="50%">
			<select name="guestRole">
				<%
				if (asRoles !=null)
				{
					for(int i = 0; i<asRoles.length; i++)
					{
						String sThisRole = asRoles[i].toLowerCase();
						%>
						<option value="<%=sThisRole%>" <%=Functions.f_isSelectedString(sThisRole, sGuestRole)%>><%=asRoles[i].replace('_', ' ').toLowerCase()%></option>
						<%
					}
				}
				%>
			</select>
		</td>
	</tr>
	<tr><td colspan="2" ><font class="note" >This is the role for the default user</font></td></tr>
	<tr><td height="6"></td></tr>

	<tr>
		<td width="50%">
                    <font class="normal" >
                        Please select the Administration role:
                    </font>
		</td>
		<td width="50%">
			<select name="adminRole">
				<%
				if (asRoles !=null)
				{
					for(int i = 0; i<asRoles.length; i++)
					{
						String sThisRole = asRoles[i].toLowerCase();
						%>
						<option value="<%=sThisRole%>" <%=Functions.f_isSelectedString(sThisRole, sAdminRole)%>><%=asRoles[i].replace('_', ' ').toLowerCase()%></option>
						<%
					}
				}
				%>
			</select>
		</td>
	</tr>
	<tr><td colspan="2" ><font class="note" >This is the role that is given access to the administration pages of Portal-in-a-Box</font></td></tr>
	<tr>
		<td align="center" colspan="6">
			<a class="textButton" title="Submit" href="javascript:roles_configure_form.submit();">
				Submit
			</a>
			&nbsp;
		</td>
	</tr>
</table>
</form>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
