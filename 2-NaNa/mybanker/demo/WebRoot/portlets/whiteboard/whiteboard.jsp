<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));
%>

<%@ include file="/user/include/getPortletVars_include.jspf" %>
<%
String sAction = Functions.safeRequestGet( request, "action", "normal" );

String sError = "";
String[] sViewList, sEditList, sSplitLine;
String sWhiteboardBorder, sWhiteboardBorderColor, sWhiteboardFolder, sDarkHeader, sDarkBorder, sDarkBackground;
String WHITEBOARD_PRIVILEGE_VIEW = "whiteboards_viewable";
String WHITEBOARD_PRIVILEGE_EDIT = "whiteboards_editable";
// get user whiteboard privileges
// get whiteboard folder
sWhiteboardFolder = CurrentPortal.PORTAL_BACKEND_LOCATION + "whiteboards";
// get darker colour for whiteboard header and border
sDarkHeader = CurrentPortlet.getPortletHeaderColor();
sDarkBorder = CurrentPortlet.getPortletBorderColor();
sDarkBackground = StringUtils.getHTMLColorFromString(CurrentPortlet.getPortletBackground());
try
{
	sDarkHeader 	= Functions.f_colorDarkener(sDarkHeader, 0.95);
	sDarkBorder 	= Functions.f_colorDarkener(sDarkBorder, 0.95);
	sDarkBackground = Functions.f_colorDarkener(sDarkBackground, 0.95);
}
catch(NumberFormatException e)
{
}
// determine which browser
if(Functions.f_browserIsIE(request))
{
	sWhiteboardBorder = "1";
	sWhiteboardBorderColor = "bordercolor=\"" + sDarkBorder + "\"";
}
else
{
	sWhiteboardBorder = "2";
	sWhiteboardBorderColor = "style=\"border-color: " + sDarkBorder + ";\"";
}


String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone") );
if( CurrentRoles.doesUserHaveRole( CurrentUser.getUserName(), CurrentPortal.getSecurityObject().getKeyByName("AdminRole", "portaladmin"), true ) )
{
	if(!"true".equals(request.getParameter("changeRole")) && "setPrivs".equals(sAction))
	{
		String[] asThisView = StringUtils.split( request.getParameter("viewable"), "," );
		String[] asThisEdit = StringUtils.split( request.getParameter("editable"), "," );

		CurrentRoles.setPrivilegeAbsolute( WHITEBOARD_PRIVILEGE_VIEW, asThisView, sRoleName, true );
		CurrentRoles.setPrivilegeAbsolute( WHITEBOARD_PRIVILEGE_EDIT, asThisEdit, sRoleName, true );
	}

	String[] asRoles = CurrentRoles.getRoleList();
	String[] asView  = CurrentRoles.getValuesForRole( sRoleName, WHITEBOARD_PRIVILEGE_VIEW, false );
	String[] asEdit  = CurrentRoles.getValuesForRole( sRoleName, WHITEBOARD_PRIVILEGE_EDIT, false );
	String sView = null, sEdit = null;

	if( asView != null && asEdit != null )
	{
		sEdit = StringUtils.combine( asEdit, "," );
		sView = StringUtils.combine( asView, "," );
	}
	else
	{
		sView = ""; sEdit = "";
	}
%>
	<table width="100%"><tr><td>
		<form name="submitform" action="<%= request.getContextPath() %>/user/home/home.jsp" method="post" style="margin:0; padding:0;">
			<input type="hidden" name="action" value="setPrivs" />
			<input type="hidden" name="changeRole" value="false" />
			<table width="33%" cellspacing="5" border="0" align="left">
				<tr>
					<td>
						<%=rb.getString("whiteboard.role")%>
					</td>
					<td align="right">
						<%=Functions.f_createSelect("rolename\" onChange=\"javascript:submitform['changeRole']['value']=true;submitform.submit()", asRoles, sRoleName)%>
					</td>
				</tr>
				<tr>
					<td nowrap="yes">
						<%=rb.getString("whiteboard.viewable")%>
						&nbsp;
					</td>
					<td align="right">
						<input type="text" name="viewable" value="<%=sView%>" />
					</td>
				</tr>
				<tr>
					<td nowrap="yes">
						<%=rb.getString("whiteboard.editable")%>
					</td>
					<td align="right">
						<input type="text" name="editable" value="<%=sEdit%>" />
					</td>
				</tr>
				<tr>
					<td colspan="2" align="right">
						<a class="textButton" href="javascript:submitform.submit();" title="Submit">
							<%=rb.getString("whiteboard.submit")%>
						</a>
					</td>
				</tr>
			</table>
		</form>
	</td></tr></table>
<%
}

// loop through view list
sViewList = CurrentRoles.getUserPrivilege(CurrentUser.getUserName(), WHITEBOARD_PRIVILEGE_VIEW, true);
sEditList = CurrentRoles.getUserPrivilege(CurrentUser.getUserName(), WHITEBOARD_PRIVILEGE_EDIT, true);
if(sViewList == null || sViewList.length == 0)
{
%>
	<br />
	<center>
		<font class="normal" >
			<%=rb.getString("whiteboard.noWhiteboard")%>
		</font>
	</center>
	<br /><br />
<%
}
else
{
	for (int i = 0; i < sViewList.length; i++)
	{
		String sWhiteboard = sViewList[i];
		String sContent = null;
		try
		{
			File fWhiteboard = new File(sWhiteboardFolder + File.separator + sWhiteboard + ".txt");

			FileInputStream fisWhiteboard = new FileInputStream(fWhiteboard);
			byte[] abWhiteboard = new byte[(int) fWhiteboard.length()];
			fisWhiteboard.read(abWhiteboard);
			fisWhiteboard.close();
			sContent = new String(abWhiteboard);
		}
		catch (Exception e)
		{
			CurrentPortal.Log("whiteboard: Could not load whiteboard " + sWhiteboard + " - " + e.toString() );
			sError = " The whiteboard " + sWhiteboard + " is currently disabled, please contact the system administrator";
		}
		if(!StringUtils.strValid( sError ) )
		{
			if (sWhiteboard != null)
			{
				//
				//Now a whiteboard is being displayed, don't display an error
				//
%>
				<table cellspacing="5" width="100%" border="<%=sWhiteboardBorder%>" <%=sWhiteboardBorderColor%>>
					<tr>
						<td bgcolor="<%=sDarkHeader%>" width="100%">
							<font class="genericbold" color="#ffffff">
								<%=sWhiteboard%>
							</font>
						</td>
					</tr>
					<tr>
						<td width="100%">
							<table border="0" width="100%" bgcolor="<%=sDarkBackground%>">
								<tr>
									<td>
										<font class="normalbold">
											<%=rb.getString("whiteboard.person")%>
										</font>
									</td>
									<td>
										<font class="normalbold">
											<%=rb.getString("whiteboard.date")%>
										</font>
									</td>
									<td>
										<font class="normalbold">
											<%=rb.getString("whiteboard.comment")%>
										</font>
									</td>
								</tr>
<%
								StringTokenizer st = new StringTokenizer(sContent, "\n");

								while (st.hasMoreElements() )
								{
									sSplitLine = StringUtils.split((String) st.nextElement(), ",");
									if (sSplitLine.length == 3)
									{
										try
										{
											sSplitLine[2] = Base64.decodeToString(sSplitLine[2]);
										}
										catch(Exception e)
										{
										}
%>
										<tr>
											<td>
												<font class="normal"><%=StringUtils.XMLEscape(sSplitLine[0])%></font>
											</td>
											<td>
												<font class="normal"><%=StringUtils.XMLEscape(sSplitLine[1])%></font>
											</td>
											<td>
												<font class="normal"><%=StringUtils.XMLEscape(sSplitLine[2])%></font>
											</td>
										</tr>
<%
									}
								}
								// if user has permission to edit, include edit section
								if (isInArray(sWhiteboard, sEditList))
								{
%>
								<tr>
									<td colspan="3">
									<form name="okform<%=i%>" action="<%= request.getContextPath() %>/portlets/whiteboard/whiteboard_add.jsp" method="POST">
										<input name="paneKey" 		type="hidden" 	value="<%=CurrentPortlet.getPortletKey()%>" />
										<input name="whiteboard" 	type="hidden" 	value="<%=sWhiteboard%>">
										<input name="whiteboardfolder" type="hidden" value="<%=sWhiteboardFolder%>">
											<hr><br>
											<font class="normalbold">
												<%=rb.getString("whiteboard.newNotice")%>
											</font>
											<br />
											<input name="newinput" type="text" size="33" maxlength="160">
											<a class="textButton" title="Ok" href="javascript:okform<%=i%>.submit();">
												<%=rb.getString("whiteboard.ok")%>
											</a>
									</form>
									</td>
								</tr>
<%
								}//end of permission test
%>
							</table>
						</td>
					</tr>
				</table>
<%
			}//end of whiteboard nullity test
		}//end of loop thru view list
	}
	//
	//If no whiteboards to display, say so.
	//
	if(StringUtils.strValid(sError))
	{
%>
		<br />
		<center>
			<font class="normal" >
				<%=sError%>
			</font>
		</center>
		<br /><br />
<%
	}
}//end of no whiteboards test

%><%!

public boolean isInArray(String sCheck, String[] sList)
{
	if(sCheck != null)
	{
		for(int i = 0 ; i < sList.length ; i++)
		{
			if(sCheck.equals(sList[i]))
			{
				return true;
			}
		}
	}
	return false;
}

%>