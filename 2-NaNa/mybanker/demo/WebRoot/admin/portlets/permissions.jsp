<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Portlet permissions";
String sAdminHeader_image = "modules32.gif";
//
//Allows close up administration as to which roles can see which portlets
//
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();

String sWhatToDo 	= HTMLUtils.safeRequestGet(request, "action", "listPortlets");
String sRoleName 	= HTMLUtils.safeRequestGet(request, "role", CurrentSecurity.getKeyByName("BaseRole", "everyone"));
String sPortlet 	= HTMLUtils.safeRequestGet(request, "pane", "");
String sPortletPrivilege = (String) HTMLUtils.safeSessionGet(session, "admin_panePrivilege", RolesInfo.PRIVILEGE_PANES_VIEWABLE);

if(sWhatToDo.equals("setPrivilege"))
{
	sPortletPrivilege = request.getParameter("privilege");
	if(sPortletPrivilege != null)
	{
		session.setAttribute("admin_panePrivilege", sPortletPrivilege);
		sWhatToDo = "listPortlets";
	}
}

String[] asAvailableRoles = CurrentRoles.getRoleList();
String sAvailableRoleCnt = "" + asAvailableRoles.length;

boolean bShowAll = StringUtils.isTrue(CurrentPortal.readString( CurrentPortal.ADMIN_SECTION, "AdminShowallPortlets", "no"));

String sMessage = "";
if(sWhatToDo.equals("setPortlets"))
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
				try{
					CurrentRoles.removePrivilegeFromRole(sPortletPrivilege, sPortlet, asAllowed[i], true);
				}
				catch(AciException acie)
				{
					CurrentPortal.Log("portlets/permissions: Could not remove pane privilege " + sPortlet + " from role " + asAllowed[i] + " - " + acie.getMessage());
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
					CurrentRoles.addPrivilegeToRole(sPortletPrivilege, sPortlet, asAllRoles[i]);
				}
				catch(AciException acie)
				{
					CurrentPortal.Log("portlets/permissions: Could not add pane privilege " + sPortlet + " to role " + asAllRoles[i] + " - " + acie.getMessage());
				}
			}
		}
		else
		{
			sMessage = "Please choose the roles you wish to allow access to this pane from the list of all roles";
		}
	}
}//end of submit check
%>
<table border="0" align="center" width="100%" cellpadding="0" cellspacing="0">
<%
	if(StringUtils.strValid(sMessage))
	{
%>
		<tr>
			<td height="24" colspan="2" align="center">
				<font class="adminwarning" color="#aa4444">
					<%=sMessage%>
				</font>
			</td>
		</tr>
<%
	}
%>
</table>
<br />
<%

//List portlets down the side:
%>
<table width="98%" align="center" border="0" cellspacing="0" cellpadding="0" >
	<tr>
		<td width="25%">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td>
						<font class="normalbold">Click on portlet name to view role information</font>
					</td>
				</tr>
<%
				String[] asPortlets = allPortlets.getSectionNames();
				if(asPortlets != null)
				{
					StringUtils.quickSort(asPortlets);
					for (int i = 0; i < asPortlets.length; i++)
					{
						asPortlets[i] = asPortlets[i].toLowerCase();
						if(bShowAll || !allPortlets.readString(asPortlets[i], "Type", "normal").equalsIgnoreCase("system"))
						{
							String sEscapedPortletID = asPortlets[i].replace(' ', '+');
							if( sPortlet.equals("") ){ sPortlet = asPortlets[i]; }
%>
							<tr>
<%
								if(sPortlet.equals(asPortlets[i]))
								{
%>
									<td height="24"><img hspace="4" style="vertical-align:middle;" border="0" src="<%=CONTEXTPATH%>/images/admin/portlet.gif" alt="" /><font class="normalbold" ><%=StringUtils.toSentenceCase(asPortlets[i])%></font></td>
<%
								}
								else
								{
%>
									<td height="24"><a class="normal" href="<%=CONTEXTPATH%>/admin/portlets/permissions.jsp?pane=<%=asPortlets[i]%>"><img style="vertical-align:middle" border="0" src="<%=CONTEXTPATH%>/images/admin/portlet.gif" hspace="4" alt="" /><font class="normal" ><%=StringUtils.toSentenceCase(asPortlets[i])%></font></a></td>
<%
								}
%>
							</tr>
<%
						}//end of showAll check
					}//end of pane loop

					//display add new pane button
%>
					<tr >
						<td colspan="1">
							<img hspace="4" style="vertical-align:middle;" border="0" src="<%=CONTEXTPATH%>/images/admin/portlet.gif" alt="" />
							<a href="new1.jsp">
								<font class="adminwarning" >
									Add New Portlet
								</font>
							</a>
						</td>
					</tr>
<%
				}//end of pane list nullity check
%>
			</table>
		</td>

		<td width="75%" valign="top">
                    <table style="margin-left:auto; margin-right:auto; padding:0px;" width="70%" align="center" border="0" cellspacing="0" cellpadding="0" >
                        <tr>
                            <td width="90%" align="left" bgcolor="<%=BODY_BGCOLOR%>" height="12" nowrap="nowrap" colspan="3">
                                <form action="<%=CONTEXTPATH%>/admin/portlets/permissions.jsp" method="post">
                                    <input type="hidden" name="action" value="setPrivilege" />
                                    <input type="hidden" name="pane" value="<%=sPortlet%>" />
                                    <font class="normalbold" >
                                        Portlet privilege:
                                    </font>
                                    <font class="normal" >
                                        <input type="radio" <%if(sPortletPrivilege.equals(RolesInfo.PRIVILEGE_PANES_VIEWABLE))  {%>checked<%}%> name="privilege" value="panes_viewable" onClick="this.form.submit();" />&nbsp;Viewable&nbsp;
                                        <input type="radio" <%if(sPortletPrivilege.equals(RolesInfo.PRIVILEGE_PANES_SELECTABLE)){%>checked<%}%> name="privilege" value="panes_selectable" onClick="this.form.submit();"  />&nbsp;Selectable&nbsp;
                                        <input type="radio" <%if(sPortletPrivilege.equals(RolesInfo.PRIVILEGE_PANES_EDITABLE))  {%>checked<%}%> name="privilege" value="panes_editable" onClick="this.form.submit();"  />&nbsp;Editable&nbsp;
                                    </font>
                                </form>
                            </td>
                        </tr>
                    </table>
<%
                //Display boxes if portlet is selected
                if(StringUtils.strValid(sPortlet))
                {
                    String[] asSetRoles = CurrentRoles.getRoleListWithPrivileges(sPortletPrivilege, sPortlet, false, "resolved");
%>
                    <form action="<%=CONTEXTPATH%>/admin/portlets/permissions.jsp" method="post">
                        <input type="hidden" name="action" value="setPortlets" />
                        <input type="hidden" name="pane" value="<%=sPortlet%>" />
                        <table style="margin-left:auto; margin-right:auto; padding:0px;" width="70%" align="center" border="0" cellspacing="0" cellpadding="0" >
                            <tr>
                                <td align="left" width="80" height="22"><font class="normalbold">All Roles</font></td>
                                <td align="center" width="150" ></td>
                                <td width="100"><font class="normalbold">Access</font></td>
                            </tr>
                            <tr>
                                <td valign="top" width="80">
                                    <%=Functions.f_createMultipleSelect("allRoles", StringUtils.quickSort(asAvailableRoles), null, sAvailableRoleCnt)%>
                                </td>
                                <td align="center">
                                    <font class="normal">
                                        <img src="<%=CONTEXTPATH%>/images/admin/blank.gif" width="16" height="1" alt="" />
                                        &nbsp;
                                        <input style="font-face: verdana; font-size: 8pt" type="submit" name="addp" value="    Add     " />
                                        &nbsp;
                                        <img src="<%=CONTEXTPATH%>/images/admin/arrowr.gif" alt="" />
                                        <br />
                                        <img src="<%=CONTEXTPATH%>/images/admin/arrowld.gif" alt="" />
                                        &nbsp;
                                        <input style="font-face: verdana; font-size: 8pt" type="submit" name="subp" value=" Remove " />
                                        &nbsp;
                                        <img src="<%=CONTEXTPATH%>/images/admin/blank.gif" width="16" height="1" alt="" />
                                    </font>
                                </td>
                                <td nowrap="nowrap" valign="top"  height="144">
                                    <%=Functions.f_createMultipleSelect("allowed", StringUtils.quickSort(asSetRoles), null, sAvailableRoleCnt)%>
                                </td>
                            </tr>
                        </table>
                    </form>
<%
                }
%>
		</td>
	</tr>
	<tr><td height="24" ></td></tr>
	<tr>
		<td colspan="4">
			<form name="showallPortletsForm" action="showAll_submit.jsp" method="POST">
				<input type="hidden" name="redirecthref" value="<%=CONTEXTPATH%>/admin/portlets/permissions.jsp" />
				<font class="note">
					Show all portlets in the list?
					<input type="checkbox" onClick="this.form.submit();" name="showallPortlets" value="on" <%if(bShowAll){%>checked <%}%> />
					<a class="normal" href="showAll_help.jsp" target="adminHelpWindow" >Whats This?</a>
				</font>
			</form>
		</td>
	</tr>
</table>
<%@ include file="/admin/header/admin_footer.jspf" %>
