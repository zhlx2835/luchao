<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "IDOL database administration";
String sAdminHeader_image = "authentication32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
//Allows close up administration as to which roles can see which databases
//
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();

String sWhatToDo = request.getParameter("action");
if(sWhatToDo == null)
	sWhatToDo = "listRoles";

String sRoleName = request.getParameter("rolename");
String sPrivilege = CurrentSecurity.getKeyByName( "DatabasePrivilege", "databases" );

if(sWhatToDo.equals("setDatabases"))
{
	if(sRoleName != null)
	{
		String[] asDBs = Functions.safeRequestValuesGet(request, "dbs", new String[]{} );
		CurrentRoles.setPrivilegeAbsolute(CurrentSecurity.getKeyByName( "DatabasePrivilege", "databases" ), asDBs, sRoleName, true);
	}//end of rolename nullity check

	sWhatToDo = "listRoles";
}

if(sWhatToDo.equals("listRoles"))
{
	//List the database names and a role list
	//
	if(sRoleName == null)
		sRoleName = CurrentSecurity.getKeyByName("BaseRole", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone"));

	// database and privilege values
	String[] asDBs 		= CurrentPortal.getDatabaseNames();
	String[] sRoleList 	= CurrentRoles.getRoleList();
	String[] saDBsForRole = CurrentRoles.getValuesForRole(sRoleName, RolesInfo.PRIVILEGE_DATABASES, false, "resolved" );

	// roles display parameters
	boolean bDisplayRoles_incTemplateDetails 	= false;
	boolean bDisplayRoles_withCheckboxes 		= false;
	String  sDisplayRoles_clickRoleCommand 		= "rolename=*";
	String  sDisplayRoles_clickRoleHref 		= "databases.jsp";
	String 	sDisplayRoles_startRoleName 		= CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
	String[] asDisplayRoles_checkedRoles 		= null; //request.getParameterValues( "rolesFromTree" );
	//Display, role category style header and two sided table - one with the role tree and and one with users/privileges
%>
	<table border="0" cellspacing="0" cellpadding="0" width="100%" align="center">
		<tr>
				<td colspan="2" width="40%" align="left" valign="top">
					<%@ include file="/admin/include/displayRoles_include.jspf" %>
				</td>
				<td valign="top" width="60%" >
<%
					if(!StringUtils.strValid(sRoleName))
					{
						out.write("<br />" + f_adminDisplayError("Click on a role name to continue"));
					}
					else
					{
						//Enumerate through the databases, stripping out the existant ones:
%>
						<font class="normal" >
							To change the databases for the current role, (un)check the boxes and click submit:
							<br /><br />
						</font>
						<form name="form_action_dbForm" method="post" action="databases.jsp" >
							<input type="hidden" name="action" value="setDatabases" />
							<input type="hidden" name="rolename" value="<%=sRoleName%>" />
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr>
<%
								//
								//Loop through DRE databases
								//
								int nDBColumnCnt = 2;

								for(int nDBIdx = 0; nDBIdx < asDBs.length; nDBIdx++ )
								{
									if(nDBIdx % nDBColumnCnt == 0 && nDBIdx != 0)
									{
										%></tr><tr><%
									}
									String sDBName = asDBs[nDBIdx];
%>
									<td align="left" width="50%">
<%
									String sChecked = "false";
									if (saDBsForRole != null && saDBsForRole.length > 0)
									{
										sChecked = StringUtils.isStringInStringArray(saDBsForRole, asDBs[nDBIdx], true ) > -1 ? "checked=\"checked\"" : "";
									}
%>
									<input type="checkbox" value="<%=sDBName%>" name="dbs" <%=sChecked%> />
									<font class="normal" >
										<%=sDBName%>
									</font>
									</td>
<%
								}//end of loop through databases
%>
							</tr>
							<tr>
								<td colspan="2">
									<img border="0" width="8" height="8" src="<%= CONTEXTPATH %>/images/admin/blank.gif" alt="" />
								</td>
							</tr>
<%
						if (asDBs.length > 1)
						{
%>
							<tr>
								<td colspan="2">
									<input type="checkbox" name="pselectAll" onClick="selectAll( this.form.dbs, checked )" />
									<font class="note">
										&nbsp; select all
									</font>
								</td>
							</tr>
<%
						}
%>

						</table>
						<br />
						<a class="textButton" title="Submit changes" href="javascript:form_action_dbForm.submit();">
							Submit
						</a>
					</form>
<%
				}
%>
			</td>
		</tr>
	</table>
<%
}//What to do cases
%>
<%@ include file="/admin/header/admin_footer.jspf" %>
