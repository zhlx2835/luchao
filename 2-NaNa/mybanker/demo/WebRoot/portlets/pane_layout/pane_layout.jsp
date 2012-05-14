<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/include/getPortletVars_include.jspf" %>
<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

AllPortlets allPortlets = CurrentPortal.getAllPortletsObject();
if(ParentPortlet == null)
{
	//This portlet is being displayed, not included within another so store the portlet number since
	//This actions of this portlet will shred up all the variables given to it
	Integer IPortletNum = new Integer(CurrentPage.PORTLET_NUMBER);
	CurrentUser.setAttribute("PortletNumber", IPortletNum);
}

CurrentPortal.LogFull("pane_layout:  Start of Layout Portlet");
String sWhatToDo = request.getParameter(CurrentPortlet.getPortletKey());

boolean bEditPortlet = true;
if(sWhatToDo == null)
{
	sWhatToDo = "showLayout";
	bEditPortlet = false;

}

//Get page name to edit, if editing
int iPageNo = StringUtils.atoi(request.getParameter("pageNo"), CurrentPage.PAGE_NUMBER);

UserPageInfo EditPage = CurrentUser.getPageByNumber(iPageNo);
boolean bWasError = false;
String[] asPageNames = null;
try
{
	asPageNames = CurrentUser.getAllPageNames();
}
catch(Exception e)
{
	CurrentPortal.Log("Portlet Layout: Could not read user " + CurrentUser.getUserName() + " page names - " + e.toString());
	//
	//Cannot recover
	bWasError = true;
}

if(bWasError)
{
	out.write(Functions.f_displayError("Could not read page information, please contact the system administrator"));
}
else
{
	//
	//Display page menu
	//
	String sShadedColor = "#AAAAAA";
	try
	{
		sShadedColor = Functions.f_colorDarkener(StringUtils.getHTMLColorFromString(CurrentPortlet.getPortletBackground()), 0.85);
	}
	catch(NumberFormatException nfe)
	{
		CurrentPortal.LogThrowable(nfe);
	}
%>
	<!-- This table contains the links to the other pages -->
	<table style="width:100%; height:16px;" cellspacing="0" cellpadding="0">
		<tr>
<%
			for(int i = 1; i < asPageNames.length; i++)
			{
				boolean bIsSelectedPage = (i == iPageNo);
				String sCellColour = "#ffffff";
				if(bIsSelectedPage)
				{
					sCellColour = "#FFFFC0";
				}
%>
				<td align="center" bgcolor="<%=sCellColour%>">
					<font class="normal" >
<%
					//Only display href if user is not editing this page
					//Do this test by number to differentiate between two pages of the same name
					if(bIsSelectedPage)
					{
%>
						<%=asPageNames[i]%>
<%
					}
					else
					{
%>
						<a href="home.jsp?<%=CurrentPortlet.getPortletKey()%>=editPage&amp;pageNo=<%=i%>#<%=CurrentPortlet.getPortletKey()%>">
							<%=asPageNames[i]%>
						</a>
<%
					}
%>
					</font>
				</td>
<%
			}
%>
		</tr>
		<tr><td height="6"></td></tr>
	</table>
<%
	//Check for messages
	String sMessage = (String) CurrentPortal.getAttribute("message");
	if( sMessage != null )
	{
		CurrentPortal.removeAttribute( "message" );
		out.println(Functions.f_displayError(sMessage));
		out.println("<br />");
	}
	if( request.getParameter("oldaction") != null )
		sWhatToDo = request.getParameter("oldaction");

	//show overall portlet layout...
	//...Put these in the session NOT only to tell the include to display edit portlet buttons and not the whole page
	//but will give me the portletKey when I display the edit buttons
	CurrentUser.setAttribute("ParentPortlet", CurrentPortlet);
	CurrentUser.setAttribute("ParentPage", CurrentPage);
	CurrentPage = CurrentUser.getPageByNumber(iPageNo);
	CurrentUser.setAttribute("CurrentPage", CurrentPage);

	//Am including the style file again to display edit buttons
	//Store the actual current page / portlet values and pass in the ones to be displayed for editing
	String sIncludeName = "/user/style/" + CurrentPage.getStyleFileName();

	if(!new File(application.getRealPath(sIncludeName)).exists())
	{
		//Opt for a default and recalculate the include path to this one
		CurrentPage.setStyleFileName( CurrentPortal.readString( CurrentPortal.DEFAULTSTYLE_SECTION, "DefaultPageStyle", "1 Then 2 Columns.jsp") );
		sIncludeName = "/user/style/" + CurrentPage.getStyleFileName();
	}

	//Check that this new one exists
	if(new File(application.getRealPath(sIncludeName)).exists())
	{
%>
		<table style="margin-left:auto; margin-right:auto;" width="70%" cellpadding="1" cellspacing="0">
			<tr>
				<td>
<%
					out.flush();
					pageContext.include(sIncludeName);
%>
				</td>
			</tr>
		</table>
<%
	}

	//restore to defaults
	CurrentPage = (UserPageInfo) CurrentUser.getAttribute("ParentPage");
	CurrentPortlet = (PortletInfo) CurrentUser.getAttribute("ParentPortlet");

	CurrentUser.setAttribute("CurrentPage", CurrentPage);
	CurrentUser.removeAttribute("ParentPage");
	CurrentUser.setAttribute("CurrentPortlet", CurrentPortlet);
	CurrentUser.removeAttribute("ParentPortlet");

	if(sWhatToDo.equals("editPortlet"))
	{
		// placeholder for any error messages
		String lsError = "";

		//Get number of portlet to be edited and display info, and portlet list as per users role
		int iPortletNo = 0;
		try
		{
			iPortletNo = new Integer(request.getParameter("paneNo")).intValue();
		}
		catch(NumberFormatException e)
		{
			iPortletNo = 1;
			CurrentPortal.Log("pane_layout: Missing paneNo in edit pane request");
		}

		//Define portlet from fresh to ensure it cannot be null
		PortletInfo SelectedPortlet = null;
		try
		{
			SelectedPortlet = new PortletInfo(CurrentUser, EditPage, iPortletNo);
			CurrentUser.setAttribute("SelectedPortlet", SelectedPortlet);
		}
		catch(Exception e)
		{
			CurrentPortal.Log("Portlet Layout: User asked to edit a non-existent porlet - " + e.toString());
			lsError = "Could not find portlet to edit!";
		}
		String[] asPortletList = null;
		try
		{
			asPortletList = CurrentRoles.getUserPrivilege(CurrentUser.getUserName(), "panes_selectable", true);
		}
		catch(Exception e)
		{
			lsError = "Failed To read user portlet list";
			CurrentPortal.Log("Portlet Layout: Failed to get user privilege list");
		}
		if(asPortletList == null)
		{
			lsError = "This user has a role which does not exist";
			CurrentPortal.Log("Portlet Layout: User had non-existent role");
		}

		if(lsError.length() == 0)
		{
			StringUtils.quickSort(asPortletList);
			//Generate list of full names to be sorted
%>
			&nbsp;<a name="<%=CurrentPortlet.getPortletKey()%>_2" />
			<form action="<%= request.getContextPath() %>/portlets/pane_layout/pane_layout_submit.jsp" method="POST" name="form_<%=CurrentPortlet.getPortletKey()%>_editPortletDefaults" onSubmit="if(this.newPortletName[this.newPortletName.selectedIndex].value.indexOf('---') != -1){alert('Please choose a portlet from the portlet list'); return false;}">
				<input type="hidden" name="panekey" value="<%=CurrentPortlet.getPortletKey()%>" />
				<input type="hidden" name="<%=CurrentPortlet.getPortletKey()%>" value="saveDetails" />
				<input type="hidden" name="pageNo" value="<%=iPageNo%>" />
				<input type="hidden" name="paneNo" value="<%=iPortletNo%>" />

				<table width="98%" border="0" cellpadding="0" cellspacing="0">
<%
					// No error - get portlet name. if empty, use "no_portlet" instead
					// and set var for include file to tell it to display "---Choose Portlet---"
					// if select list
					//
					String sSelectedPortletName = SelectedPortlet.getPortletName();
					String sSelectMessage = rb.getString("pane_layout.selectAPortletGoHere");
					String sNoPortletOption = rb.getString("pane_layout.noPortletOption");

					if(StringUtils.strValid(sSelectedPortletName) && SelectedPortlet.isSelectable())
					{
						sSelectMessage = rb.getString("pane_layout.selectAPortlet");
						sNoPortletOption = rb.getString("pane_layout.noPortlet");
					}

%>
					<tr>
						<td colspan="2" align="center">
							<font class="normalbold" >
								<%= sSelectMessage %>
							</font>

							&nbsp;

							<select name="newPortletName" onChange="this.form.submit()" >
								<option value="no_pane"><%= sNoPortletOption %></option>
<%
								for(int i = 0; i < asPortletList.length; i++)
								{
%>
									<option value="<%=allPortlets.getOriginalName( asPortletList[i] )%>" <%if(SelectedPortlet.getPortletName().equalsIgnoreCase(asPortletList[i])){%>selected<%}%> >
										<%=allPortlets.getFullName( asPortletList[i] )%>
									</option>
<%
								}
%>
							</select>
						</td>
					</tr>
				</table>
			</form>
			&nbsp;<a name="<%=CurrentPortlet.getPortletKey()%>_useredit" />
<%
			if( StringUtils.strValid(SelectedPortlet.getPortletName()) )
			{
				String sFolderName = SelectedPortlet.getPortletName();
				CurrentUser.setAttribute("CurrentPortlet", SelectedPortlet);

				//sIncludeName declared above
				sIncludeName = new StringBuffer()
										.append("/portlets/")
										.append(sFolderName)
										.append(File.separator)
										.append(sFolderName)
										.append("_useredit.jsp")
								.toString();
				CurrentPortal.LogFull("pane_layout: Loading useredit " + sIncludeName );
				if(new File(application.getRealPath(sIncludeName)).exists() )
				{
					//Tell the include where to go on return
					CurrentUser.setAttribute("CurrentPortlet", SelectedPortlet );
					CurrentUser.setAttribute("useredit_querystring", "?pageNo=" + iPageNo );
					out.flush();
					pageContext.include(sIncludeName);
				}
				else
				{
					//Use generic edit template in absence of portlet specific one
					sIncludeName = "/user/home/portlet_useredit.jsp";
					CurrentPortal.LogFull("pane_layout: Loading useredit " + sIncludeName );
					if(new File(application.getRealPath(sIncludeName)).exists() )
					{
						//Tell the include where to go on return
						CurrentUser.setAttribute("CurrentPortlet", SelectedPortlet );
						CurrentUser.setAttribute("useredit_querystring", "?pageNo=" + iPageNo );
						out.flush();
						pageContext.include(sIncludeName);
					}
					else
					{
%>
						<br />
						<font class="normalbold" >
							<center>
								<%=rb.getString("pane_layout.noSetting")%>
								<br /><br />
								<a class="textButton" title="Ok" href="home.jsp">
									<%=rb.getString("page_layout.ok")%>
								</a>
							</center>
						</font>
<%
					}
				}
			}
		}
		else
		{
			Functions.f_displayError(lsError);
		}
	}
	else
	{
		//Display ok button to go home
%>
		<center>
			<a class="textButton" title="Ok" href="home.jsp?delete=0">
				<%=rb.getString("page_layout.ok")%>
			</a>
		</center>
<%
	}//end of edit portlet check
}//end of fatal error check

//retrieve iff this portlet is on the surface level of inclusion
if(ParentPortlet == null)
{
	CurrentPage.PORTLET_NUMBER = ((Integer) CurrentUser.getAttribute("PortletNumber")).intValue();
}
%>
