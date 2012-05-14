<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/include/getPortletVars_include.jspf" %>

<%
String sPortletKey = request.getParameter("paneKey");
String sType = request.getParameter("type");
String sTypeName = "folder";
if(sType == null)
{
	sType = "a";
	sTypeName = "bookmark";
}

String sFolderName = request.getParameter("folder");
String sTitle = request.getParameter("title");
String sOldTitle = request.getParameter("oldTitle");
String sHref = request.getParameter("href");
String sMessage = "";
boolean bError = false;

sTitle = StringUtils.stripDangerousChars(sTitle);

if(sPortletKey != null)
{
	boolean bCreate = request.getParameter("create").equals("true");
	sTitle = sTitle.trim();

	if(sOldTitle != null)
	{
		try
		{
			CurrentUser.removeBookmark(sFolderName, sOldTitle);
		}
		catch(Exception e)
		{
			CurrentPortal.Log("bookmark_edit_submit: Could not remove old bookmark - " + e.toString() );
		}
	}
	if(sType.equals("f"))
	{
		sTypeName = "folder";
		try
		{
			CurrentUser.addBookmarkFolder(sFolderName, sTitle);
		}
		catch(Exception e)
		{
			CurrentPortal.Log("bookmark_edit_submit: Could not add bookmark folder - " + e.toString() );
			bError = true;
		}
		if (bError)
		{
			CurrentPortal.Log("bookmark_edit_submit: Tried to add a duplicate folder");
			sMessage = "Can't create folder. You already have a folder of this name";
			bError = false;
		}
		else
		{
			sMessage = "Your " + sTypeName + " has been added.";
		}
	}
	if(sType.equals("a"))
	{
		sTypeName = "bookmark";
		sHref = sHref.trim();
		try
		{
			CurrentUser.addBookmark(sFolderName, sTitle, sHref);
		}
		catch(Exception e)
		{
			CurrentPortal.Log("bookmark_edit_submit: Could not add bookmark link for user " + CurrentUser.getUserName() + " - " + e.toString() );
			bError = true;
		}

		if (bError)
		{
			sMessage = "Could not create bookmark. You already have one with this name";
			bError = false;
		}
		else if(bCreate)
		{
			sMessage = "Your " + sTypeName + " has been added.";
		}
		else
		{
			sMessage = "Your " + sTypeName + " has been modified.";
		}
	}
}
response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?paneKey=" + sPortletKey + "&" + sPortletKey + "=showMessage&message=" + Functions.f_URLEncode(sMessage,request.getCharacterEncoding()) + "&#" + sPortletKey);

%>
