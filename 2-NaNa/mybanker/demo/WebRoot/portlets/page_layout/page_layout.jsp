<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page import="com.autonomy.utilities.HTTPUtils" %>
<%@ page import="com.autonomy.utilities.StringUtils" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/include/getPortletVars_include.jspf"%>
<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

try
{
	if(ParentPortlet == null)
	{
		//This pane is 'on the surface' so store the pane number since
		//This actions of this pane will shred up all the variables given to it
		//
		Integer IPortletNum = new Integer(CurrentPage.PORTLET_NUMBER);
		CurrentUser.setAttribute("PortletNumber", IPortletNum);
	}
	//
	String sWhatToDo = request.getParameter(CurrentPortlet.getPortletKey());

	String sCacheKeyStyle = new String("PAGELAYOUT_STYLE");
	String sCacheKeyPageImages = new String("PAGELAYOUT_PAGEIMAGE");
	String sCacheKeyButton = new String("PAGELAYOUT_BUTTON");
	String sCacheKeyBackground = new String("PAGELAYOUT_BACKGROUND");

	String lsError = "";
	String[] sPortletList = null;
	int iPortletNum = 0;
	PortletInfo EditPortlet = null;
	if(sWhatToDo == null)
	{
		sWhatToDo = "editPage";

	}
	//
	//Get page to edit, if editing
	//

	int iPageNo = 1;
	UserPageInfo EditPage = null;
	String sPageNo = request.getParameter("pageNo");
	try
	{
		iPageNo = Integer.valueOf(sPageNo).intValue();
	}
	catch(NumberFormatException e)
	{
		iPageNo = CurrentPage.PAGE_NUMBER;
	}

	EditPage = CurrentUser.getPageByNumber(iPageNo);

	boolean bWasError = false;
	String[] asPageNames = null;
	String[] asActivePageNames = null;
	try
	{
		asPageNames = CurrentUser.getAllPageNames();
		asActivePageNames = CurrentUser.getActivePageNames();
	}
	catch(Exception e)
	{
		CurrentPortal.Log("Page Layout: Could not read user " + CurrentUser.getUserName() + " page names - " + e.toString());
		//can't recover
		bWasError = true;
	}

	if(bWasError)
	{
		out.write(Functions.f_displayError("Could not read page information, please try reloading the page, then contact the system administrator"));
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
		catch(Exception e)
		{}
%>
		<form name="pagelayoutform" action="<%= request.getContextPath()%>/portlets/<%=CurrentPortlet.getPortletName()%>/page_layout_submit.jsp" method="POST" onSubmit="return jf_<%=CurrentPortlet.getPortletKey()%>_validate(this);">
			<input type="hidden" name="paneKey" value="<%=CurrentPortlet.getPortletKey()%>" />
			<input type="hidden" name="pageNo" value="<%=sPageNo%>" />
			<input type="hidden" name="actionType" value="Ok" />

			<table style="width:100%; height:16px;" cellspacing="0" cellpadding="0">
				<tr>
					<td nowrap>
						<font class="normalbold"><%=rb.getString("page_layout.activePages")%></font>
					</td>
<%
					for(int i = 1; i < asPageNames.length; i++)
					{
						String sCellColour = "#ffffff";
						boolean bIsSelectedPage = false;
						if(i == iPageNo)
						{
							bIsSelectedPage = true;
							sCellColour = "#FFFFCC";
						}
%>
						<td align="left" bgcolor="<%=sCellColour%>" nowrap>
							<input type="checkbox" name="page_active<%=i%>" value="<%=i%>" <%= CurrentUser.isPageActive(i) ? "checked" : "" %>/>
<%
						//
						//Only display href if user is not editing this page
						//Do this test by number to differentiate between two pages of the same name
						//
						if(bIsSelectedPage)
						{
%>
							<font class="normal" >
								<%=asPageNames[i]%>
							</font>
<%
						}
						else
						{
%>
							<a class="normal" href="home.jsp?<%=CurrentPortlet.getPortletKey()%>=editPage&amp;pageNo=<%=i%>#<%=CurrentPortlet.getPortletKey()%>">
								<font class="normal" >
									<%=asPageNames[i]%>
								</font>
							</a>
<%
						}
%>
					</td>
<%
				}
%>
				</tr>
				<tr><td height="6"></td></tr>
			</table>
<%
			//
			//Get page will clear the system pane.  There is a case where the user will be on page x and want to edit the layout
			//for page x, then the system pane (which is layout) will be cleared.  Don't want this to happen.
			//
			//String sTmpSysPortletName = CurrentPage.getSystemPortletName();

			//CurrentPage.makeSystemPortlet(sTmpSysPortletName);
			if(EditPage != null)
			{
				String sPageName = EditPage.getPageName();
				String sPageImage = EditPage.getPageImage();
				String sPageStyle = EditPage.getStyleFileName();
				String sButtons = EditPage.getButtonStyle();
				//
				//Get lists
				//
				String[] saButtons = null;
				String[] saBackgroundImages = null;
				String[] saStyleFiles = null;
				String[] saPageImages = null;

				// try to get from cache
				saButtons = (String[])CurrentPortal.getAttribute(sCacheKeyButton, null);
				saStyleFiles = (String[])CurrentPortal.getAttribute(sCacheKeyStyle, null);
				saBackgroundImages = (String[])CurrentPortal.getAttribute(sCacheKeyBackground, null);
				saPageImages = (String[])CurrentPortal.getAttribute(sCacheKeyPageImages, null);

				if (saPageImages == null)
				{
					// not cached, get list
					String sFolder = "/images/page";

					saPageImages = new File(application.getRealPath(sFolder)).list( new WildFilter("*_col.*", true ) );
					StringUtils.quickSort( saPageImages );
					// cache
					CurrentPortal.setAttribute(sCacheKeyPageImages, saPageImages );
				}

				if (saButtons == null)
				{
					// not cached, get list
					saButtons = Functions.f_getFilesInFolder(application, request, request.getContextPath()  + "images/buttons");
					// cache
					CurrentPortal.setAttribute(sCacheKeyButton, saButtons);
				}
				if (saStyleFiles == null)
				{
					// not cached, get list
					saStyleFiles = Functions.f_getFilesInFolder(application, request, request.getContextPath() + "user/style" );
					for (int i = 0; i < saStyleFiles.length; i++)
					{
						saStyleFiles[i] = StringUtils.split(saStyleFiles[i], ".")[0];
					}
					// cache
					CurrentPortal.setAttribute(sCacheKeyStyle, saStyleFiles);
				}
				if (saBackgroundImages == null)
				{
					// not cached, get list
					saBackgroundImages = Functions.f_getFilesInFolder(application, request, request.getContextPath() + "images/backgrounds" );
					// cache
					CurrentPortal.setAttribute(sCacheKeyBackground, saBackgroundImages);
				}
				//
				//Want users sBgColor to be in the form #xxxxxx
				//
				String sBackground = EditPage.getPageBackground().trim();
				String sBgColor = StringUtils.getHTMLColorFromString(sBackground);
				if( !StringUtils.strValid(sBgColor) )
				{
					sBgColor = "";
					//
					//get background image
					//
					try
					{
						sBgColor = StringUtils.getImageNameFromString(sBackground);
					}
					catch(StringIndexOutOfBoundsException sioobe)
					{}
				}
				CurrentUser.setAttribute("EditPage", EditPage);

				//Check existence of style file
				File fStyle = new File(application.getRealPath("/user/style/" + sPageStyle ));

 				if(!fStyle.exists())
				{
					sPageStyle = CurrentPortal.readString( CurrentPortal.DEFAULTSTYLE_SECTION, "DefaultPageStyle", "2 Columns");
					EditPage.setStyleFileName(sPageStyle);

				}
				String sCurrentPageStyle = StringUtils.split(sPageStyle, ".")[0];
%>
				<script type="text/javascript">
					<!--
					function setActionOk()
					{
						pagelayoutform.actionType.value="Ok";
						pagelayoutform.submit();
					}
					function setActionApply()
					{
						pagelayoutform.actionType.value="Apply";
						pagelayoutform.submit();
					}
					function jf_isValidString(sString)
					{
						for(i = 0; i < sString.length; i++)
						{
							cToValidate = sString.charAt(i);
							if(cToValidate == "<%="<"%>" || cToValidate == "<%=">"%>" || cToValidate == "\"")
							{
								return false;
							}
						}
						return true;
					}
					function jf_<%=CurrentPortlet.getPortletKey()%>_validate(fForm)
					{
						if(fForm.pagename.value.length == 0)
						{
							alert("Please give the page a name");
							return false;
						}
						if(!jf_isValidString(fForm.pagename.value))
						{
							alert("The page name contains illegal characters - please remove any >, < or \" symbols");
							return false;
						}
						return true;
					}
					function jf_<%=CurrentPortlet.getPortletKey()%>_swapImage(oImage, sNewImage)
					{
							oImage.src = "<%= request.getContextPath() %>/images/pane_styles/" + escape(sNewImage) + ".jpg";
					}
					function jf_<%=CurrentPortlet.getPortletKey()%>_swapButton(oImage, sNewButton)
					{
						oImage.src = "<%= request.getContextPath() %>/images/buttons/" + sNewButton + "/b_test.gif";
					}
					function jf_<%=CurrentPortlet.getPortletKey()%>_swapTiles( sNewTile )
					{
						if(sNewTile != "Use plain color")
						{
							document.<%=CurrentPortlet.getPortletKey()%>_pageImageGr.src = "<%= request.getContextPath() %>/images/page/" + sNewTile;
							var n = sNewTile.lastIndexOf(".");
							if (n > -1)
								sNewTile = sNewTile.substring(0,n) + "_col" + sNewTile.substring(n);
							document.<%=CurrentPortlet.getPortletKey()%>_pageImageGrCol.src = "<%= request.getContextPath() %>/images/page/" + sNewTile;
						}
						else
						{
							document.<%=CurrentPortlet.getPortletKey()%>_pageImageGr.src = "<%= request.getContextPath() %>/images/blank.gif";
							document.<%=CurrentPortlet.getPortletKey()%>_pageImageGrCol.src = "<%= request.getContextPath() %>/images/blank.gif";
						}
					}
					//-->
				</script>
				<table align="left" border="0" cellpadding="1" cellspacing="1">
					<tr>
						<td width="30%">
							<font class="normalbold" >
								<%=rb.getString("page_layout.pageName")%>
							</font>
						</td>
						<td width="70%" colspan="2">
							<input type="text" name="pagename" size="17" maxlength="20" value="<%=sPageName%>" />
						</td>
					</tr>
					<tr>
						<td colspan="3" height="6" ></td>
					</tr>
					<tr>
						<td valign="top">
							<font class="normalbold" >
								<%=rb.getString("page_layout.style")%>
							</font>
						</td>
						<td valign="top">
							<%=Functions.f_createSelectNoLCase("style\" onChange=\"jf_" + CurrentPortlet.getPortletKey() + "_swapImage(document." + CurrentPortlet.getPortletKey() + "_styleImage, this.options[selectedIndex].value) ", saStyleFiles, sCurrentPageStyle, false )%>
						</td>

						<td width="70%">
							<img vspace="2" name="<%=CurrentPortlet.getPortletKey()%>_styleImage" height="120" width="100" border="1" align="middle" src="<%= request.getContextPath() %>/images/pane_styles/<%= HTTPUtils.URLEncode(sCurrentPageStyle, "UTF8") %>.jpg" alt="">
						</td>
					</tr>

<%
					if( saPageImages != null )
					{
%>
						<tr>
							<td>
								<font class="normalbold" >
								    <%=rb.getString("page_layout.pageImage")%>
								</font>
							</td>
							<td colspan="1">
								<%=Functions.f_createSelect("pageimage\" onChange=\"jf_" + CurrentPortlet.getPortletKey() + "_swapTiles(this.options[selectedIndex].value)", saPageImages, sPageImage)%>
							</td>
							<td height="32"><%
							if(StringUtils.strValid( EditPage.getPageImage() ))
							{
								String sColImage = EditPage.getPageImage();
								int n = sColImage.lastIndexOf(".");
								if (n > -1)
									sColImage = sColImage.substring(0,n) + "_col" + sColImage.substring(n);
%>
								<img name="<%=CurrentPortlet.getPortletKey()%>_pageImageGr" alt="" width="32" height="32" border="0" src="<%= request.getContextPath() %>/images/page/<%=EditPage.getPageImage()%>" />
								<img name="<%=CurrentPortlet.getPortletKey()%>_pageImageGrCol" alt="" width="32" height="32" border="0" src="<%= request.getContextPath() %>/images/page/<%=sColImage%>" />
<%
							}
							else
							{
%>
								<img name="<%=CurrentPortlet.getPortletKey()%>_pageImageGr" alt="" width="32" height="32" border="0" src="<%= request.getContextPath() %>/images/blank.gif" />
								<img name="<%=CurrentPortlet.getPortletKey()%>_pageImageGrCol" alt="" width="32" height="32" border="0" src="<%= request.getContextPath() %>/images/blank.gif" />
<%
							}
%>
							</td>
						</tr>
						<tr><td height="4"></td></tr>
<%
					}
%>
					<tr>
						<td colspan="3" height="6" ></td>
					</tr>
					<tr>
						<td colspan="3" align="center">
							<a class="textButton" title="Ok" href="javascript:setActionOk();">
								<%=rb.getString("page_layout.ok")%>
							</a>
							&nbsp;&nbsp;&nbsp;&nbsp;
<%
							if(CurrentPortlet.isSystemPortlet())
							{
%>
								<a class="textButton" title="Apply" href="javascript:setActionApply();">
									<%=rb.getString("page_layout.apply")%>
								</a>

								&nbsp;&nbsp;&nbsp;&nbsp;

								<a class="textButton" title="Back" href="<%= request.getContextPath() %>/user/home/home.jsp?page=<%=CurrentPage.PAGE_NUMBER%>">
									<%=rb.getString("page_layout.back")%>
								</a>
<%
							}
%>
						</td>
					</tr>
				</table>
			</form>
<%
		}
		else
		{
			out.println( Functions.f_displayError("Could not locate page") );
		}
	}//end of fatal error check
	//retrieve iff this pane is on the surface level of inclusion
	//
	if(ParentPortlet == null)
	{
		CurrentPage.PORTLET_NUMBER = ((Integer) CurrentUser.getAttribute("PortletNumber")).intValue();
	}
}
catch( Exception e )
{
	CurrentPortal.LogThrowable( e );
}
%>
