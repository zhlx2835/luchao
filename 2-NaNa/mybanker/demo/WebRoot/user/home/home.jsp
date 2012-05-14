<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.math.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portlet.*" %>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>


<%
String CONTEXTPATH = request.getContextPath();
//
//See if user logged in over this session
//
%>
	<%@ include file = "CheckUser.jspf" %>
<%
try
{
	//This sometimes is not removed from the session when I've asked it to.
	CurrentUser.removeAttribute("ParentPortlet");

	String sPageNo = request.getParameter("page");
	if(StringUtils.strValid(sPageNo))
	{
		//Clear pop up info on current page before moving on to next one
		CurrentPage.makeSystemPortlet("");
		int nNewPageNum = StringUtils.atoi(sPageNo, 1);
		if( CurrentUser.isPageActive(nNewPageNum) )
		{
			CurrentPage = CurrentUser.getPageByNumber( nNewPageNum );
			CurrentUser.setClientField("PAGE", sPageNo);
			CurrentUser.setAttribute("CurrentPage", CurrentPage);
		}
	}

	//
	//Delete any unwanted panes
	//
	String sDeletedPortletName = request.getParameter("delete");
	if( sDeletedPortletName != null && !CurrentUser.isDefaultUser())
	{
		//There is a portlet to delete
		deletePortlet(CurrentPage, StringUtils.atoi(sDeletedPortletName, -1), CurrentPortal);
	}

	//
	//If any pane has been maximised, include it straight away
	//
	String sMaximisedPortlet = request.getParameter("maximise");
	if(sMaximisedPortlet != null)
	{
		if(sMaximisedPortlet.equals("") && !CurrentUser.isDefaultUser())
		{
			//restore previously maximised pane
			CurrentPage.maximisePortlet(null);
		}
		else
		{
			//Maximise new pane
			CurrentPage.maximisePortlet(CurrentPage.getPortletByNumber(StringUtils.atoi(sMaximisedPortlet, -1)));
		}
	}

	// Agents portlet may need preprocessing (adding/deleting an agent) before any of the other portlets are rendered
	String sPreprocessPortlet = "Agents";
	if(StringUtils.strValid(sPreprocessPortlet))
	{
		// build up include path to preprocess jsp
		PortletInfo piPortletToPreprocess = CurrentPage.getFirstPortletByName("Autonomy" + sPreprocessPortlet);
		if(piPortletToPreprocess != null)
		{
			CurrentPortal.LogFull("home.jsp: Preprocessing " + sPreprocessPortlet + " portlet.");
			// add portal to portlet object (needed for PiBService)
			piPortletToPreprocess.CurrentPortal = CurrentPortal;
			session.setAttribute( "APSLTransferPortlet", piPortletToPreprocess);

			String sResolvedPath = new StringBuffer("/portlets/Autonomy")
			                                .append(sPreprocessPortlet)
			                                .append("/preprocess_Autonomy")
			                                .append(sPreprocessPortlet)
			                                .append(".jsp")
			                                .toString();
			try
			{
				pageContext.include(sResolvedPath);
			}
			catch(Exception e)
			{
				CurrentPortal.Log("home.jsp: exception was thrown while preprocessing " + sPreprocessPortlet + " portlet.");
				CurrentPortal.LogThrowable(e);
			}
		}
	}
	//
	//Display page
	//

	// This sets the name of the CSS file to be used (as read from the portal.cfg file)
	String cssFilePath = CONTEXTPATH + "/" + CurrentPortal.readString(CurrentPortal.DEFAULTSTYLE_SECTION , "DefaultStyleSheet", "portalinabox.css");
	String organName = CurrentPortal.readString(CurrentPortal.PORTAL_SECTION, "OrganizationName", "Portal-in-a-Box");
	organName = organName + " " + CurrentPortal.readString(CurrentPortal.PORTAL_SECTION, "Version", "");

    //String sPropertiesFilename = "ApplicationResources";
    ResourceBundle rb = null;

    //get locale information from user's choice'
    String sLangCode = "zh";
    if (sLangCode!=null)
    {
        session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLangCode);
    }
    sLangCode = (String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
    if(sLangCode ==null)
    {
    	rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME,new Locale("en"));
    }
    else
    {
    	rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME,new Locale(sLangCode));
    }
%>
	<html>
		<head>
			<meta http-equiv="pragma" content="no-cache">
			<meta http-equiv="expires" content="-1">
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			<link rel="stylesheet" type="text/css" href="<%= cssFilePath %>" />
 			<script type="text/javascript" src="<%= CONTEXTPATH %>/user/home/home_files/home.js"></script>
			<title>
				<%= organName %>
			</title>
		</head>
		<body style="margin:0px;" <%= CurrentPage.getPageBackground() %> >
			<!-- BANNER -->
			<table style="width:100%; height:55px;" align="center" cellpadding="0" cellspacing="0">
				<%@ include file="banner.jspf" %>
			</table>
			<!-- GREETING & DATE -->
			<table style="width:100%;">
				<tr>
					<td>
						<font class="normalbold">
							<%= getHeadGreeting(organName, CurrentUser, request, rb) %>
						</font>
					</td>
					<td align="right">
						<font class="normalbold">
							<script type="text/javascript">document.write(getDate());</script>&nbsp;
						</font>
					</td>
				</tr>
			</table>

			<!-- This creates the coloured strip below the welcome message -->
			<table width="100%" class="strip"><tr><td></td></tr></table>
<%
		//
		//Now see if user chose to edit pane:
		//
		String sPortletToEdit = request.getParameter("paneToEdit");
		if(sPortletToEdit != null && !CurrentUser.isDefaultUser())
		{
			//Get details of pane to edit, store in session and pageContext include that panes edit page
			//
			PortletInfo CurrentPortlet = CurrentPage.getPortletByNumber(Integer.parseInt(sPortletToEdit));
			CurrentUser.setAttribute("CurrentPortlet", CurrentPortlet);
			String sCurrentPortletName = CurrentPortlet.getPortletName();
%>
			<table class="pContainer" style="border-spacing:0px; margin-left:auto; margin-right:auto;" border="2" width="100%" cellspacing="0" cellpadding="2" >
				<tr><td>
					<!-- Portlet Edit Header -->
					<table border="0" class="pContent" width="100%" cellspacing="0" cellpadding="0" style="margin-left:auto; margin-right:auto;" >
						<tr>
							<td height="16" width="100%" style="margin-left:auto; margin-right:auto;">
								<font class="head" color='<%=CurrentPortlet.getPortletBorderColor()%>'>
									<%=CurrentPortal.getAllPortletsObject().readString(sCurrentPortletName, "NAME", "").replace('_', ' ')%> - Options&nbsp;
								</font>
							</td>
						</tr>
					</table>

<%
					//Check edit page exists and include if it does
					String sOrigPortletName = CurrentPortal.getAllPortletsObject().getOriginalName( sCurrentPortletName );
					String sVirtualPath = new StringBuffer()
					                               .append("/portlets/")
					                               .append(sOrigPortletName)
					                               .append("/" )
					                               .append(sOrigPortletName)
					                               .append("_useredit.jsp")
					                               .toString();

					if(new File(application.getRealPath(sVirtualPath)).exists() )
					{
						//Tell edit pages that the specific template is being used
						CurrentUser.setAttribute("useredit_state", "specific");
					}
					else
					{
						//Tell edit pages that the generic template is being used
						CurrentUser.setAttribute("useredit_state", "generic");
						sVirtualPath = "/user/home/portlet_useredit.jsp";
					}
					out.flush();
					pageContext.include(sVirtualPath);
%>
				</td></tr>
			</table>
<%
		}	// is there a portlet to edit?
		else
		{
			// what are the names of the user's pages?
			String[] sa_PageNames = null;
			try
			{
				sa_PageNames = CurrentUser.getAllPageNames();
			}
			catch(Exception e)
			{
				CurrentPortal.Log("home: Could not get user " + CurrentUser.getUserName() + " page names - " + e.toString());
				sa_PageNames = new String[] {"", "Page 1", "Page 2"};
			}

			// which page are we displaying?
			int iCurrentPage = CurrentPage.getPageNumber();
			//if there is a System portlet on this page, don't highlight any of the tabs
			PortletInfo maximalPortlet = CurrentPage.getMaximalPortlet();
			boolean bDrawTabs_highlight = true;
			if(maximalPortlet != null && maximalPortlet.PORTLET_NUMBER == 0)
			{
				bDrawTabs_highlight = false;
			}
%>
			<!-- Display page tabs -->
			<table border="0" width="100%" cellpadding="0" cellspacing="0" >
				<tr>
<%
					for(int nPageIdx = 1; nPageIdx < sa_PageNames.length; nPageIdx++)
					{
						if(CurrentUser.isPageActive(nPageIdx) || nPageIdx == sa_PageNames.length )
						{
							String sSeparatorGif = getTabSeparatorGifName(nPageIdx, sa_PageNames.length, iCurrentPage, bDrawTabs_highlight);
%>
							<td rowspan="4" width="12">
								<img src="<%= CONTEXTPATH %>/images/tabs/<%= sSeparatorGif %>" width="12" height="19" alt="" border="0">
							</td>
<%
							// This is used to format the page links and icons
							if(nPageIdx < sa_PageNames.length)
							{
%>
								<td>
								</td>
<%
							}
						}
					}
%>
					<td rowspan="4" width="100%">
					&nbsp;
					</td>
				</tr>
				<tr>
<%
				for(int nPageIdx = 1; nPageIdx < sa_PageNames.length; nPageIdx++)
				{
					if(CurrentUser.isPageActive(nPageIdx))
					{
%>
						<td>
						</td>
<%
					}
				}
%>
				</tr>

				<tr valign="middle">
<%
				for(int nPageIdx = 1; nPageIdx < sa_PageNames.length; nPageIdx++)
				{
					if(CurrentUser.isPageActive(nPageIdx))
					{
						if(nPageIdx == iCurrentPage && bDrawTabs_highlight)
						{
							String sPageImage = CurrentUser.getPageByNumber(nPageIdx).getPageImage();
							try
							{
								int nIndex = sPageImage.lastIndexOf(".");
								sPageImage = sPageImage.substring(0, nIndex) + "_col" + sPageImage.substring( nIndex );
							}
							catch( Exception e) {}
%>
							<td width="50" nowrap align="center" >
								<img name="pageimg<%=nPageIdx%>" align="middle" alt="" border="0" hspace="1" src="<%= CONTEXTPATH %>/images/page/<%=sPageImage%>" />
								<br><%=sa_PageNames[nPageIdx]%>
							</td>
<%
						}
						else
						{
%>
							<td width="50" nowrap align="center" >
								<a class="tab" onMouseOver="imgswap( document.pageimg<%=nPageIdx%>, true );" onMouseOut="imgswap( document.pageimg<%=nPageIdx%>, false );" href="<%= CONTEXTPATH %>/user/home/home.jsp?page=<%=nPageIdx%>"><img alt="" name="pageimg<%=nPageIdx%>" align="middle" border="0" hspace="1" src="<%= CONTEXTPATH %>/images/page/<%=CurrentUser.getPageByNumber(nPageIdx).getPageImage()%>" /><br><%=sa_PageNames[nPageIdx]%></a>
							</td>
<%
						}
					}
				}
%>
				</tr>
			</table>
			<!-- This provides the gap between the page links and the top of the portlets -->

			<!-- Display portlets -->
			<table style="margin-left:auto; margin-right:auto; width:100%; height:400px;" cellspacing="0" cellpadding="0">
				<tr>
					<td align="center" valign="top">
<%
						if(maximalPortlet != null)
						{
							//
							//There is a maximal pane
							//
							String sMaximalPaneInclude = "/user/header/portlet_container.jsp";
							CurrentUser.setAttribute("CurrentPortlet", maximalPortlet);
%>
							<table style="margin-left:auto; margin-right:auto; width:96%;" cellpadding="0" cellspacing="0">
								<tr><td>
<%
									out.flush();
									pageContext.include(sMaximalPaneInclude);
%>
								</td></tr>
							</table>
<%
						}
						else
						{
							//Get page style name and include file
							String sStyleInclude = "/user/style/" + CurrentPage.getStyleFileName();
							if(!new File(application.getRealPath(sStyleInclude)).exists())
							{
								//Opt for a default and recalculate the include path to this one
								CurrentPage.setStyleFileName( CurrentPortal.readString(CurrentPortal.DEFAULTSTYLE_SECTION, "DefaultPageStyle", "") );
								sStyleInclude = new StringBuffer()
								                         .append("/user/style/")
								                         .append(CurrentPage.getStyleFileName())
								                         .toString();
							}

							out.flush();
							pageContext.include(sStyleInclude);
						}
%>
					</td>
				</tr>
			</table>
<%
		}//end of edit pane test

		// dummy form used by some portlets to refresh main portal page after creating an agent using a pop-up
%>
		<form name="dummy" action="home.jsp">
<%
			// loop through all request parameters and create a hidden input for each of their values.
			Enumeration params = request.getParameterNames();
			while(params.hasMoreElements())
			{
				String sThisParam = (String)params.nextElement();
				String[] asThisValue = request.getParameterValues(sThisParam);

				if(asThisValue != null)
				{
					int nValueCnt = asThisValue.length;

					for(int nValueIdx = 0; nValueIdx < nValueCnt; nValueIdx++)
					{
						if(!asThisValue[nValueIdx].equals("editAgentSubmit") && !asThisValue[nValueIdx].equals("createAgentSubmit"))
						{
%>
							<input type="hidden" name="<%= sThisParam %>" value="<%= StringUtils.XMLEscape(asThisValue[nValueIdx]) %>">
<%
						}
					}
				}	//if(asThisValue != null)
			}	//while(params.hasMoreElements())
%>
		</form>
		<!-- This creates the coloured strip above the footer -->
		<table width="100%" class="strip"><tr><td></td></tr></table>

		<img src="<%= CONTEXTPATH %>/images/footer.gif" alt="" /><font class="genericbold">&nbsp;Copyright Autonomy 2006</font>
	</body>
</html>
<%
}
catch(Exception e)
{
	// log stack trace and throw out to error handler page
	CurrentPortal.LogThrowable(e);
	e.printStackTrace(System.out);
	throw e;
}
%>

<%!
private String getUserGreeting(String organName, UserInfo CurrentUser, HttpServletRequest request, ResourceBundle rb)
{
	String sHeadMessage = (String)CurrentUser.getAttribute("headmessage");
	if( sHeadMessage != null )
	{
		CurrentUser.removeAttribute("headmessage");
	}
	else
	{
		sHeadMessage = request.getParameter("headmessage");
	}
	if( sHeadMessage == null )
	{
        try
        {
            String sName = CurrentUser.getFullName();
            if(sName.length() == 0)
            {
                sName = CurrentUser.getUserName();
            }

            String sWelcomeMsg = rb.getString("home.welcome");
            String sToMsg = rb.getString("home.welcome.to");
            sHeadMessage = new StringBuffer("&nbsp;").append(sWelcomeMsg).append(" ").append(sName).append(" ").append(sToMsg).append(" ").append(organName).toString();
        }
        catch(Exception e)
        {
        }
	}
	return sHeadMessage;
}

private String getDefaultGreeting(String organName, HttpServletRequest request, ResourceBundle rb)
{
	String sHeadMessage = request.getParameter("defaultmessage");
    try
    {
        String sWelcomeMsg = rb.getString("home.welcomeTo");

        if(sHeadMessage == null)
        {
            sHeadMessage = new StringBuffer("&nbsp;").append(sWelcomeMsg).append(" ").append(organName).toString();
        }

    }
    catch(Exception e)
    {
        // log stack trace and throw out to error handler page
        e.printStackTrace(System.out);
    }
    return sHeadMessage;

}

private String getHeadGreeting(String organName, UserInfo CurrentUser, HttpServletRequest request, ResourceBundle rb)
{
	if(!CurrentUser.isDefaultUser())
	{
		return getUserGreeting(organName, CurrentUser, request, rb);
	}
	else
	{
		return getDefaultGreeting(organName, request, rb);
	}
}

private String getTabSeparatorGifName(int nPageIdx, int nPageCnt, int iCurrentPage, boolean bHighlight)
{
	char[] ca_gifName = new String("nn.gif").toCharArray();
	if(nPageIdx == 1)
		ca_gifName[0] = 'x';

	if(nPageIdx == nPageCnt)
		ca_gifName[1] = 'x';

	if(bHighlight && nPageIdx == iCurrentPage)
	{
		ca_gifName[1] = 'f';
	}
	return new String(ca_gifName);
}

private void deletePortlet(UserPageInfo CurrentPage, int nPortletToDelete, PortalInfo CurrentPortal)
{
	if(CurrentPage != null && nPortletToDelete > -1)
	{
		try {
		PortletInfo DeletedPortlet = CurrentPage.getPortletByNumber(nPortletToDelete);
		if(DeletedPortlet != null)
                    {
                            DeletedPortlet.delete();
                    }
                }
                catch (AciException ae) {
                    CurrentPortal.Log("Failed to delete portlet: " + ae.toString());
		}
	}
}
%>