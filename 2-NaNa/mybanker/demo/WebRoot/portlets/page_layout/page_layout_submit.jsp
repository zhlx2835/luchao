<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/home/CheckUser.jspf" %>
<%
//
//Get form values, validate and save
//
UserPageInfo EditPage = (UserPageInfo) CurrentUser.getAttribute("EditPage");
CurrentUser.removeAttribute("EditPage");

String sPortletKey = request.getParameter("paneKey");

if(EditPage != null && sPortletKey != null)
{	
	sPortletKey = HTTPUtils.URLEncode(sPortletKey, request.getCharacterEncoding());
	String sPageName = request.getParameter("pagename");
	sPageName = StringUtils.stripDangerousChars(sPageName);
	sPageName = sPageName.trim();
	
	String sPageStyle = request.getParameter("style");
	String sPageImage = request.getParameter("pageimage");
	String sButtons = request.getParameter("buttons");
	//
	//sBgColor is a string of the form #xxxxxx
	//
	String sBgColor = request.getParameter("bgcolor");
	String sBgImage = request.getParameter("bgimage");

	CurrentUser.batchReset();
	
	for(int i = 1; i <= CurrentPortal.getUserMaxNumberOfPages() ; i++)
	{
		if(request.getParameter("page_active" + i) != null)
		{
			CurrentUser.activatePage(i);
		}
		else
		{
			CurrentUser.deactivatePage(i);
		}
	}

	EditPage.setPageName(sPageName);
	EditPage.setPageImage(sPageImage);
	EditPage.setStyleFileName(sPageStyle + ".jsp");
	EditPage.setButtonStyle(sButtons);
	if(sBgImage != null && !sBgImage.equals("Use plain color"))
		EditPage.setPageBackground("background=\"" + request.getContextPath() +"/images/backgrounds/" + sBgImage + "\"");
	else if(sBgColor != null)
		EditPage.setPageBackground("bgcolor=\"" + sBgColor + "\"");

	try
	{
		CurrentUser.batchSend();
	}
	catch( Exception e )
	{
		CurrentPortal.Log("page_layout_submit: Failed to BatchSend for user " + CurrentUser.getUserName() + ":");
		CurrentPortal.LogThrowable( e );
	}
}
String sPageNo = request.getParameter("pageNo");
if(request.getParameter("actionType").equals("Apply"))
	response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?paneKey=" + sPortletKey + "&pageNo=" + sPageNo + "&#" + sPortletKey);
else
	response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?paneKey=" + sPortletKey + "&delete=0&#" + sPortletKey);
%>
