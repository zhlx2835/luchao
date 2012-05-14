<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Portlet permissions";
String sAdminHeader_image = "authentication32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
//Allows editing of the portlet.cfg file remotely
//
String[] saPortletIDs = StringUtils.quickSort(allPortlets.getSectionNames());
String[] saRoleList 	= StringUtils.quickSort(CurrentRoles.getRoleList());
String sRoleName 			= Functions.safeRequestGet(request, "rolename", "");

String[] asViewable 	= CurrentRoles.getValuesForRole(sRoleName, RolesInfo.PRIVILEGE_PANES_VIEWABLE, 	 false, "resolved" );
String[] asSelectable = CurrentRoles.getValuesForRole(sRoleName, RolesInfo.PRIVILEGE_PANES_SELECTABLE, false, "resolved" );
String[] asEditable 	= CurrentRoles.getValuesForRole(sRoleName, RolesInfo.PRIVILEGE_PANES_EDITABLE, 	 false, "resolved" );

//Role display options
boolean  bDisplayRoles_incTemplateDetails	= false;
boolean  bDisplayRoles_withCheckboxes 		= false;
String   sDisplayRoles_clickRoleCommand 	= "rolename=*";
String   sDisplayRoles_clickRoleHref 			= "portlets.jsp";
String   sDisplayRoles_startRoleName 			= CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
String[] asDisplayRoles_checkedRoles 			= null; 

%>
<p>
	<font class="normal" >
		To edit a role's portlet permissions, click on the role and select values
		for each privilege (viewable, selectable and editable). 
	</font>
</p>
<table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" >
	<tr>
		<td width="40%" valign="top">
			<%@ include file="/admin/include/displayRoles_include.jspf" %>
		</td>		
		<td width="60%" >
			<form name="portlets_form" action="portlets_submit.jsp" method="POST">
                            <input type="hidden" name="role" value="<%=sRoleName%>" />
				<table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" >
					<tr>
						<td width="10%">
							<font class="normalbold">
								viewable?&nbsp;
							</font>
						</td>
						<td width="10%">
							<font class="normalbold">
								selectable?&nbsp;
							</font>
						</td>
						<td width="10%">
							<font class="normalbold">
								editable?&nbsp;
							</font>
						</td>
						<td width="10%">
							<font class="normalbold">
								pane name
							</font>
						</td>
						<td width="30%" class="normal "align="center"></td>
					</tr>
					<tr>
						<td colspan="4" height="6">
						</td>
					</tr>
<%
					for(int nPortletIdx = 0; nPortletIdx < saPortletIDs.length; nPortletIdx++)
					{
						String sPortletID = saPortletIDs[nPortletIdx].toLowerCase();
						// don't show 'system' type portlets
						if(!allPortlets.readString(sPortletID, "Type", "normal").equalsIgnoreCase("system"))
						{
							boolean bIsViewable 	= StringUtils.isStringInStringArray(asViewable, 	sPortletID, true ) > -1;
							boolean bIsEditable		= StringUtils.isStringInStringArray(asEditable, 	sPortletID, true ) > -1;
							boolean bIsSelectable = StringUtils.isStringInStringArray(asSelectable, sPortletID, true ) > -1;
							String sRowBGColor = nPortletIdx % 2 == 0 ? "bgcolor=\"" + DARK_BGCOLOR + "\"" : "";
%>
							<tr <%= sRowBGColor %> >								
								<td width="10%" >
									<input type="hidden" name="panelist" value="<%=sPortletID%>" />
									<input type="checkbox" 
												 name="viewable" 
												 value="<%=sPortletID%>" 
												 <%if(bIsViewable){out.write("checked=\"checked\"");}%> 
									/>
								</td>
								<td width="10%" >
									<input type="checkbox" 
												 name="selectable" 
												 value="<%=sPortletID%>" 
												 <%if(bIsSelectable){out.write("checked=\"checked\"");}%> 
									/>
								</td>
								<td width="10%" >
									<input type="checkbox" 
												 name="editable" 
												 value="<%=sPortletID%>" 
												 <%if(bIsEditable){out.write("checked=\"checked\"");}%> 
									/>
								</td>
								<td width="50%">
									<font class="normalbold" >
										<%=sPortletID%>
									</font>
									<br />
									<font class="normal">
										<%=allPortlets.getFullName(sPortletID)%>
									</font>
								</td>
							</tr>
<%
						}// end of system type portlet check
					}//end of loop through portlets
%>
					<tr>
						<td nowrap="nowrap" width="70" class="note">
							<input type="checkbox" name="viewSelectall" onClick="selectAll(this.form.viewable, checked)">
							all
						</td>
						<td nowrap="nowrap" width="70" class="note">
							<input type="checkbox" name="selectSelectall" onClick="selectAll(this.form.selectable, checked)">
							all
						</td>
						<td nowrap="nowrap" width="70" class="note">
							<input type="checkbox" name="selectSelectall" onClick="selectAll(this.form.editable, checked)">
							all
						</td>
						<td class="normal">
						</td>
					</tr>
					<tr><td colspan="4" height="6" ></td></tr>
					<tr>
						<td colspan="4">
							<a class="textButton" title="Submit" href="javascript:portlets_form.submit();">
								Submit
							</a>
						</td>
					</tr>
				</table>
			</form>	
		</td>
	</tr>
</table>

<%@ include file="/admin/header/admin_footer.jspf" %>
