<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*" %>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/include/getBackendLocation_include.jspf" %>
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
	PortalInfo CurrentPortal = PortalDistributor.getInstance(BACKEND_LOCATION);
	UserInfo CurrentUser = (UserInfo) session.getAttribute( CurrentPortal.PORTAL_BACKEND_LOCATION + "CurrentUser" );
	PortletInfo ParentPortlet = (PortletInfo) CurrentUser.getAttribute("ParentPortlet");
	UserPageInfo ParentPage = (UserPageInfo) CurrentUser.getAttribute("ParentPage");
	UserPageInfo CurrentPage = (UserPageInfo) CurrentUser.getAttribute("CurrentPage");

	if(ParentPortlet != null)
	{
		String sBgColor = "#FFFFFF";
		String sHdColor = "#FFFFFF";
		String sHighlightBgColor = "#FFFFFF";
		try
		{
			sBgColor = Functions.f_colorDarkener(StringUtils.getHTMLColorFromString(ParentPortlet.getPortletBackground()), 0.90);
			sHdColor = Functions.f_colorDarkener(StringUtils.getHTMLColorFromString(ParentPortlet.getPortletBackground()), 0.80);
			sHighlightBgColor = Functions.f_colorDarkener(StringUtils.getHTMLColorFromString(ParentPortlet.getPortletBackground()), 1);
		}
		catch(Exception e)
		{
			CurrentPortal.Log("no pane:  color darkener failed - " + e.toString());
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
			CurrentPortal.LogFull("pane header: Could not establish whether to highlight " + ParentPortlet + " on " + CurrentPage);
		}
		if(bHighlightPortlet)
		{
%>
			<table class="pane1" style="border-color: #FFF; width:100%; height:48px;"  border="2" bgcolor="<%=sHighlightBgColor%>" cellspacing="0" cellpadding="0">
				<tr>
					<td align="center" valign="middle">
						<font class="normal" >
							<%=rb.getString("no_pane.empty")%>
						</font>
					</td>
				</tr>
			</table>
<%
		}
		else
		{
%>
			<table class="pane1" style="width:100%; height:48px;" bgcolor="<%=sBgColor%>" cellspacing="0" cellpadding="0">
				<tr align="center">
					<td>
						<table>
							<tr>
								<td>
									<font class="normal" >
										<%=rb.getString("no_pane.empty")%>
									</font>

								</td>
							</tr>
							<tr align="center">
								<td>
									<a href="<%= request.getContextPath() %>/user/home/home.jsp?<%=ParentPortlet.getPortletKey()%>=editPortlet&amp;pageNo=<%=CurrentPage.PAGE_NUMBER%>&amp;paneNo=<%=CurrentPage.PORTLET_NUMBER%>#<%=ParentPortlet.getPortletKey()%>_2">
										<img alt="Change this portlet" src="../../images/buttons/blue_slant/b_editpane.gif">
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
catch( Throwable t )
{
	t.printStackTrace( System.out );
}
%>
