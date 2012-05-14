<%@ page import = "java.util.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "java.io.*"%>
<%@ page import = "com.autonomy.portal4.*"%>
<%@ page import = "com.autonomy.utilities.*"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/include/getBackendLocation_include.jspf"%>
<%
/*
	This file is the container which holds each portlet
*/

//
//recall objects
PortalInfo CurrentPortal = PortalDistributor.getInstance(BACKEND_LOCATION);
UserInfo CurrentUser = (UserInfo) session.getAttribute(CurrentPortal.PORTAL_BACKEND_LOCATION + "CurrentUser");

String sContextPath = request.getContextPath();
//
try
{
	if(CurrentPortal != null && CurrentUser != null)
	{
		PortletInfo ParentPortlet = (PortletInfo) CurrentUser.getAttribute("ParentPortlet");
		UserPageInfo CurrentPage = (UserPageInfo) CurrentUser.getAttribute("CurrentPage");
		PortletInfo CurrentPortlet = (PortletInfo) CurrentUser.getAttribute("CurrentPortlet");

		if(CurrentPortlet == null)
		{
			//In the unlikely event that the session or application dies
			//In the short time this takes to load, reinit it
			//
			CurrentPortal.Log("portlet_container:  CurrentPortlet was null on arrival here");
			return;
		}
		else
		{
			UserPageInfo ParentPage = (UserPageInfo) CurrentUser.getAttribute("ParentPage");

			RolesInfo CurrentRoles = (RolesInfo) CurrentPortal.getRolesObject();
			AllPortlets allPortlets = (AllPortlets) CurrentPortal.getAllPortletsObject();
			//
			CurrentPortal.LogFull("portlet_container: Processing pane");
			//
			//Can't be sure which case the USER_AGENT header will take - this function checks
			//
			boolean bIsIE = Functions.f_browserIsIE(request);
			String sBorder = "1";
			//
			//Get a ridged table - IE does not allow this if you use the bordercolor HTML attribute
			//
			String sBorderColor = "style=\"border-color: " + CurrentPortlet.getPortletBorderColor() + ";\"";
			if(!bIsIE)
				sBorderColor = "bordercolor=\"" + CurrentPortlet.getPortletBorderColor() + "\"";


			if(ParentPortlet != null)
			{
				//
				//Here:
				//ParentPage / Portlet is the object containing the page / pane which this is being included in
				//while CurrentPage / Portlet is the one that were are displaying the details for.
				//
				//
				if(ParentPage == null)
				{
					//Shouldn't happen
					//
					CurrentPortal.Log("Lost contact with Parent Page in pane_layout");
				}
				else
				{
					String sBgColor = "#FFFFFF";
					String sHighlightBgColor = "#FFFFFF";
					try
					{
						sHighlightBgColor = Functions.f_colorDarkener(StringUtils.getHTMLColorFromString(CurrentPortlet.getPortletBackground()), 1);
						sBgColor = StringUtils.getHTMLColorFromString(CurrentPortlet.getPortletBackground());
					}
					catch(Exception e)
					{
						CurrentPortal.Log("pane header:  color darkener failed - " + e.toString());
					}
					//Highlight pane being edited
					//
					boolean bHighlightPortlet = false;
					try
					{
						bHighlightPortlet = request.getParameter(ParentPortlet.getPortletKey()).equals("editPortlet") && String.valueOf(CurrentPage.PORTLET_NUMBER).equals(request.getParameter("paneNo"));
					}
					catch(NullPointerException nfe)
					{
					}

					if(bHighlightPortlet)
					{
%>
						<table border="<%=sBorder%>" class="pane1"<%=sBorderColor%> style="width:100%; height:48px;" cellspacing="0" cellpadding="0">
							<tr>
								<td bgcolor="<%=sBgColor%>" align="center" valign="middle">
									<font class="normalbold" >
										<%=allPortlets.getFullName( CurrentPortlet.getPortletName() )%>
									</font>
								</td>
							</tr>
						</table>
<%
					}
					else
					{
						//If user has not privilege to edit the pane, grey the edit button
						//
						String sGreyed = "";
						if(!CurrentRoles.hasUserGotPrivilege(CurrentUser.getUserName(), "panes_editable", CurrentPortlet.getPortletName(), true) &&
						   !CurrentPortlet.getPortletName().equals("disallowed"))
						{
							sGreyed = "_grey";
						}
%>
						<!-- This bit is used in the portlet layout page -->

						<table border="<%=sBorder%>" class="pane1" style="width:100%; height:48px;" cellspacing="0" cellpadding="0">
							<tr align="center">
								<td>
									<table>
										<tr align="center">
											<td nowrap="yes">
												<font class="normalbold" >
													<%=allPortlets.getFullName( CurrentPortlet.getPortletName() )%>
												</font>
											</td>
										</tr>
										<tr align="center">
											<td>
												<a href="<%= sContextPath %>/user/home/home.jsp?<%=ParentPortlet.getPortletKey()%>=editPortlet&amp;pageNo=<%=CurrentPage.PAGE_NUMBER%>&amp;paneNo=<%=CurrentPortlet.PORTLET_NUMBER%>#<%=ParentPortlet.getPortletKey()%>_2">
													<img alt="Change this portlet" src="../../images/buttons/blue_slant/b_editpane.gif" hspace="2" vspace="2" border="0">
												</a>
											</td>

										</tr>
									</table>
								</td>
							</tr>
						</table>


<%
					}
				}
			}
			else
			{
				CurrentPortal.LogFull("portlet_container: Getting current pane states");

				//
				//Get Portlet states
				//
				String gsPortletToMinimise = request.getParameter("minimise");
				if(gsPortletToMinimise != null)
				{
					if(gsPortletToMinimise.equals(CurrentPortlet.getPortletKey()) && !CurrentUser.isDefaultUser())
						CurrentPortlet.minimise();
				}

				String gsPortletToRestore = request.getParameter("restore");
				if(gsPortletToRestore != null)
				{
					if(gsPortletToRestore.equals(CurrentPortlet.getPortletKey()) && !CurrentUser.isDefaultUser())
						CurrentPortlet.restore();
				}

				String sPortletHeadHeight = "height=\"12\"";

%>
				<a name="<%=CurrentPortlet.getPortletKey()%>"><img src="<%= sContextPath %>/images/blank.gif" width="1" height="1" alt=""></a>
				<form name="<%=CurrentPortlet.getPortletKey()%>_deleteForm"
				      action="<%= sContextPath %>/user/home/home.jsp"
				      method="POST"
				      style="margin:0px; padding:0px;">
					<input type="hidden" name="delete" value="<%=CurrentPortlet.getPortletIndex()%>"/>
				</form>
				<table class="pContainer" style="border-spacing:0px; width:100%;" cellspacing="0" cellpadding="0" align="center">
					<tr align="center">
						<td width="100%" colspan="2">
							<table class="pTitlebar" width="100%" cellspacing="0" cellpadding="0" align="center">
								<tr>

									<!-- This bit is where the portlet header is added -->
									<td class="pTitle" width="100%" <%=sPortletHeadHeight%> align="left">
											<span><%=allPortlets.readString(CurrentPortlet.getPortletName(), "NAME", "").replace('_', ' ')%>&nbsp;</span>
									</td>
<%
									//
									//System pane - popped up by user to perform login or sign up, perhaps.
									//Display no buttons.  As normal, start <td>
									//
									if(!CurrentPortlet.isSystemPortlet())
									{
										//Check if pane is minimised
										//
										if(!CurrentPortlet.isMinimised())
										{

											if(CurrentUser.isDefaultUser())
											{
%>
												<!-- They need to be replaced by greyed out buttons with no functionality -->

												<td><a class="pCtrlEdit" title="Edit This Portlet">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>
												<td width="10">&nbsp;</td>

												<td><a class="pCtrlMinimise" title="Minimize This Portlet">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>
												<td width="10">&nbsp;</td>

<%
											}
											else
											{

												//Display edit and minimise buttons

												if(CurrentRoles.hasUserGotPrivilege(CurrentUser.getUserName(), "panes_editable", CurrentPortlet.getPortletName(), true ))
												{
%>
													<td><a class="pCtrlEdit" title="Edit This Portlet" href="<%= sContextPath %>/user/home/open_pane_layout.jsp">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>
													<td width="10">&nbsp;</td>

<%
												}
												else
												{
													// Need greyed out button here
%>
													<td><a class="pCtrlEdit" title="Edit This Portlet" href="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>
													<td width="10">&nbsp;</td>

<%
												}
%>
												<td><a class="pCtrlMinimise" title="Minimize This Portlet" href="<%= sContextPath %>/user/home/home.jsp?minimise=<%=CurrentPortlet.getPortletKey()%>&amp;maximise=&amp;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td><!-- Minimise -->
												<td width="10">&nbsp;</td>


<%
											}
										}
										else
										{
											//Display edit and restore buttons
											//
%>
<%
												if(CurrentRoles.hasUserGotPrivilege(CurrentUser.getUserName(), "panes_editable", CurrentPortlet.getPortletName(), true ))
												{
%>
													<td><a class="pCtrlEdit" title="Edit This Portlet" href="<%= sContextPath %>/user/home/open_pane_layout.jsp">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>
													<td width="10">&nbsp;</td>


<%
												}
												else
												{
													// Need greyed out button here
%>
													<td><a class="pCtrlEdit" title="Edit This Portlet" href="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>
													<td width="10">&nbsp;</td>

<%
												}
%>
											<td><a class="pCtrlMaximise" title="Restore This Portlet" href="<%= sContextPath %>/user/home/home.jsp?restore=<%=CurrentPortlet.getPortletKey()%>&amp;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td><!-- Maximise (Restore)-->
											<td width="10">&nbsp;</td>

<%
										}
										//
										//Grey out the delete button if the user is the default user or doesn't have the selectable privilege
										//
										if(CurrentUser.isDefaultUser() || !CurrentPortlet.isSelectable() )
										{
%>
											<td><a class="pCtrlClose" title="Remove This Portlet">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>
<%
										}
										else
										{
%>
											<td><a class="pCtrlClose" title="Remove This Portlet" href="javascript:jf_confirmDeletePortlet(document.<%=CurrentPortlet.getPortletKey()%>_deleteForm)">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>

<%
										}
									}
%>
								</tr>

							</table>

<%
							if(!CurrentPortlet.isMinimised())
							{
								//Visibility check for this portlet
								//
								if( allPortlets.readString( CurrentPortlet.getPortletName(), "Visibility", "visible" ).equalsIgnoreCase("hidden") )
								{
%>
									<br /><br />
									<font class="normalbold" >
										This portlet is temporarily unavailable.  Please try again later.
									</font>
									<br /><br /><br />
<%
								}
								else
								{
									//getOriginalName makes sure the name is in the correct case
									String sPortletName = allPortlets.getOriginalName( CurrentPortlet.getPortletName() );

									String sIncludeName = new StringBuffer()
																   .append("/portlets/")
																   .append(sPortletName)
																   .append("/")
																   .append(sPortletName)
																   .append(".jsp")
														  .toString();

									CurrentPortal.LogFull("portlet_container: Getting include file " + sIncludeName);

									//
									//Check existence of panes
									//
									if(!new File(application.getRealPath(sIncludeName)).exists())
									{
										CurrentPortal.Log("portlet_container: no " + sPortletName + " portlet");
										CurrentPortal.LogFull("portlet_container: removed pane '" + CurrentPortlet.getPortletName() + "' found for user " + CurrentUser.getUserName() );
										//
										//Clear the pane info and set to null
										//
										CurrentPortlet.setPortletName("");
										CurrentPortlet = null;
%>
										<br /><br />
										<font class="warning" >
											This portlet is no longer available:<%= sIncludeName%>(<%= application.getRealPath(sIncludeName)%>)
										</font>
										<br /><br /><br />
<%
									}
									else
									{
										session.setAttribute( "APSLTransferPortlet", CurrentPortlet );
										pageContext.getOut().flush();
										pageContext.include(sIncludeName);
									}
								}//if( allPortlets.readString( CurrentPortlet.getPortletName(), "Visibility", "visible" ).equalsIgnoreCase("hidden") )

							}//end if isMinimised test
%>
						</td>
					</tr>
				</table>
				<!-- This creates the footer on the bottom of the portlets -->
				<table class="pFooter">
					<tr>
						<td class="pFooterLeft"></td>
						<td>&nbsp;</td>
						<td class="pFooterRight"></td>
					</tr>
				</table>
<%
			}//end of ParentPortlet is null test
		}// end of CurrentPortlet is null test
	}
	else
	{
		//redirect home to re-initialise
		//
		response.sendRedirect(request.getContextPath() + "/user/home/home.jsp");
	}// CurrentPortal is Null test
}
catch(Exception e)
{
	CurrentPortal.Log("portlet_container: Uncaught error  - " + e.toString() );
	CurrentPortal.LogThrowable( e );
%>
	<br />An internal error occurred while displaying this portlet<br /><br /></td></tr></table>
<%
}

%>
