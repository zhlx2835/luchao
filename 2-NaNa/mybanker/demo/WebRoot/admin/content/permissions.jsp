<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Database permissions";
String sAdminHeader_image = "database32.gif";
//
//Allows close up administration as to which roles can see which databases
//
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
String[] asDBs 		= CurrentPortal.getDatabaseNames();
String[] asAvailableRoles = CurrentRoles.getRoleList();
String sAvailableRoleCnt = "" + asAvailableRoles.length;

String sWhatToDo = request.getParameter("action");
if(sWhatToDo == null)
	sWhatToDo = "listRoles";
String sRoleName = request.getParameter("role");
if(sRoleName == null)
	sRoleName = CurrentSecurity.getKeyByName("BaseRole", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone"));

String sDatabase = StringUtils.nullToEmpty(request.getParameter("database"));
String sMessage = "";

if(sWhatToDo.equals("setDatabases"))
{
	sMessage = "Your changes have been saved";
	if( request.getParameter("subp") != null )
	{
		//Removing positive roles
		String[] asAllowed = request.getParameterValues("allowed");
		if(asAllowed != null)
		{
			for(int i = 0; i < asAllowed.length; i++)
			{
				try  {
                                    CurrentRoles.removePrivilegeFromRole(RolesInfo.PRIVILEGE_DATABASES, sDatabase, asAllowed[i], true);
                                }
				catch (AciException ae) {
					CurrentPortal.Log("database_admin: Could not remove DRE database privilege " + sDatabase + " from role " + asAllowed[i] + " - " + ae.getMessage());
				}
			}
		}
		else
		{
			sMessage = "Please choose the roles you wish to remove from the 'allowed' list";
		}
	}
	if( request.getParameter("addp") != null )
	{
		//Adding positive roles
		String[] asAllRoles = request.getParameterValues("allRoles");
		if(asAllRoles != null)
		{
			for(int i = 0; i < asAllRoles.length; i++)
			{
				try {
                                    CurrentRoles.addPrivilegeToRole(RolesInfo.PRIVILEGE_DATABASES, sDatabase, asAllRoles[i]);
                                }
				catch (AciException ae) {
					CurrentPortal.Log("database_admin: Could not add DRE database privilege " + sDatabase + " to role " + asAllRoles[i] + " - " + ae.getMessage());
				}
			}
		}
		else
		{
			sMessage = "Please choose the roles you wish to allow access to this database from the list of all roles";
		}
	}
}//end of submit check

if(StringUtils.strValid(sMessage))
{
	%>
        <table border="0" align="center" width="100%" cellpadding="0" cellspacing="0">
            <tr>
                <td height="24" colspan="2" align="center">
                    <font class="adminwarning" color="#aa4444">
                        <%=sMessage%>
                    </font>
                </td>
            </tr>
        </table>
	<%
}

//List DRE databases down the side:
%>
<br /><br />
<table width="98%" align="center" border="0" cellspacing="0" cellpadding="0">
<tr>
    <td width="35%" valign="top">
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td>
				<font class="normalbold" >Click on a database to view Role information</font>
			</td>
		</tr>
	<%
	for (int i = 0; i < asDBs.length; i++ )
	{
		if(sDatabase.equals( asDBs[i] ))
		{
%>
			<tr>
				<td height="24">
					<font class="normalbold" >
						<img style="vertical-align:middle" width="32" height="32" hspace="2" vspace="2" border="0" src="<%= CONTEXTPATH %>/images/admin/database32.gif" alt="" />
						<%=asDBs[i]%>
					</font>
				</td>
			</tr>
<%
		}
		else
		{
%>
			<tr>
				<td height="24">
					<a class="normal" href="permissions.jsp?database=<%=asDBs[i]%>">
						<img style="vertical-align:middle" height="32" vspace="2" hspace="2" border="0" src="<%= CONTEXTPATH %>/images/admin/database32.gif" alt="" />
						<font class="normal" >
							<%=asDBs[i]%>
						</font>
					</a>
				</td>
			</tr>
<%
		}
	}
	%>
	</table>
    </td>
    <td width="75%" valign="top">
<%

//Display boxes if database selected
//
if(StringUtils.strValid(sDatabase))
{
    String[] asSetRoles = CurrentRoles.getRoleListWithPrivileges(RolesInfo.PRIVILEGE_DATABASES, sDatabase, false, "resolved" );
    %>
    <form action="permissions.jsp" method="post">
        <input type="hidden" name="action" value="setDatabases" />
        <input type="hidden" name="database" value="<%=sDatabase%>" />
        <table style="margin-left:auto; margin-right:auto" width="95%" align="center" border="0" cellspacing="0" cellpadding="0" >
            <tr>
                <td nowrap="nowrap" align="left" width="100">
                    <font class="normalbold">
                        All Roles
                    </font>
                </td>
                <td width="150" ></td>
                <td nowrap="nowrap" align="left">
                    <font class="normalbold">
                        Access
                    </font>
                </td>
            </tr>
            <tr>
                <td valign="top" width="100">
                    <%=Functions.f_createMultipleSelect("allRoles", StringUtils.quickSort(asAvailableRoles), null, sAvailableRoleCnt)%>
                </td>
                <td width="150" align="center">
                    <img src="<%= CONTEXTPATH %>/images/admin/blank.gif" width="16" height="1" alt="" />
                    <font class="normal">
                        &nbsp;<input style="font-face: verdana; font-size: 8pt" type="submit" name="addp" value="    Add     " />
                        &nbsp;<img src="<%= CONTEXTPATH %>/images/admin/arrowr.gif" alt="" />
                        <br />
                        <img src="<%= CONTEXTPATH %>/images/admin/arrowld.gif" alt="" />
                        &nbsp;<input style="font-face: verdana; font-size: 8pt" type="submit" name="subp" value=" Remove " />
                    </font>
                    &nbsp;<img border="0" src="<%= CONTEXTPATH %>/images/admin/blank.gif" width="16" height="1" alt="" />
                </td>
                <td nowrap="nowrap" valign="top">
                    <%=Functions.f_createMultipleSelect("allowed", StringUtils.quickSort(asSetRoles), null, sAvailableRoleCnt)%>
                </td>
            </tr>
            <tr><td height="24"></td></tr>
        </table>
    </form>
    <%
}
%>

    </td>
</tr>
</table>

<%@ include file="/admin/header/admin_footer.jspf" %>
