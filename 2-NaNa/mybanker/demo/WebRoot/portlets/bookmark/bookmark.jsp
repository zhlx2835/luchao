<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page import="com.autonomy.utilities.StringUtils" %>
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

<%@ include file = "/user/include/getPortletVars_include.jspf" %>
<%
// set response encoding same as request
response.setContentType("text/html; charset="+request.getCharacterEncoding());

String sWhatToDo = request.getParameter(CurrentPortlet.getPortletKey());
String sMessage = "";

if(sWhatToDo == null)
{
	sWhatToDo = "listBookmarks";
}

if(sWhatToDo.equals("showMessage"))
{
	sMessage = request.getParameter("message");
	sWhatToDo = "listBookmarks";
}

if(sWhatToDo.equals("deleteBookmark"))
{
	String sTitle = request.getParameter("title");
	String sFolderName = request.getParameter("folder");

	try
	{
		CurrentUser.removeBookmark(sFolderName, sTitle);
	}
	catch(Exception e)
	{
		CurrentPortal.Log("bookmark: Could not delete bookmark for user " + CurrentUser.getUserName() + " - " + e.toString() );
	}

}
%>
<script type="text/javascript">
<!--
	function jf_isValidTitle(sString)
	{
		if(sString.length == 0)
		{
			return false;
		}

		for(i = 0; i < sString.length; i++)
		{
			var cToValidate = sString.charAt(i);
			if(cToValidate == '<' || cToValidate == '>' || cToValidate == '\"' || cToValidate == '/' || cToValidate == '_')
			{
				return false;
			}
		}

		return true;
	}

	function jf_isValidValue(sString)
	{
		if(sString.length == 0)
		{
			return false;
		}

		for(i = 0; i < sString.length; i++)
		{
			var cToValidate = sString.charAt(i);

			if(cToValidate == '<' || cToValidate == '>' || cToValidate == '\"')
			{
				return false;
			}
		}

		return true;
	}

	function jf_<%=CurrentPortlet.getPortletKey()%>_validate(fForm)
	{
		if(fForm.title.value.length == 0)
		{
			alert("Please give a name");
			return false;
		}
		if(!jf_isValidTitle(fForm.title.value))
		{
			alert("The name contains illegal characters - please remove any >, <, /, \" or _ symbols");
			return false;
		}

		// Check if url contains (a.ab)
		if(fForm.href.value != "no href needed" && fForm.href.value.search(/\w(\.)[a-z]{2}/i) == -1)
		{
			alert("Please give a link (e.g. http://www.autonomy.com) ");
			return false;
		}

		if(!jf_isValidValue(fForm.href.value))
		{
			alert("The link contains illegal characters - please remove any >, < or \" symbols");
			return false;
		}

		return true;
	}

	function deleteBookmark(fForm)
	{
		if(confirm("Are you sure you wish to delete this entry?"))
		{
			fForm.submit();
		}
	}

	function createBookmark(fForm)
	{
		if(jf_<%=CurrentPortlet.getPortletKey()%>_validate(fForm))
		{
			fForm.submit();
		}
	}

-->
</script>
<%
boolean bCreate = (sWhatToDo.equals("newBookmark"));

if(sWhatToDo.equals("editBookmark") || bCreate)
{

	String sBookmark = request.getParameter("title");
	String sFolderName = request.getParameter("folder");
	String sType = request.getParameter("type");

	if(sType == null)
		sType = "a";

	boolean bFolder = (sType.equals("f"));
	String sTypeName = rb.getString("bookmark.bookmark");
	if(bFolder)
	{
		sTypeName = rb.getString("bookmark.folder");
	}
	if(CurrentUser.canHaveMoreBookmarks())
	{
		%>
		<table border="0" cellspacing="5" align="center" width="100%">
		<tr><td>

		<form name="form_<%=CurrentPortlet.getPortletKey()%>_editBookmark" action="<%= request.getContextPath() %>/portlets/bookmark/bookmark_edit_submit.jsp" method="POST" >
		<input type="hidden" name="paneKey" value="<%=CurrentPortlet.getPortletKey()%>" />
		<input type="hidden" name="type" value="<%=sType%>" />
		<input type="hidden" name="folder" value="<%=sFolderName%>" />
		<input type="hidden" name="create" value="<%=bCreate%>" style="margin:0px; padding:0px;"/>
		<table width="320" cellspacing="0">
		<tr>
		<td>

		<%
		//Get current values
		//
		String sTitle = StringUtils.nullToEmpty(request.getParameter("title"));

		String sHref = request.getParameter("href");
		if(sHref == null)
		{
			sHref = "";
		}
		//
		%>

		<tr>
			<td nowrap="yes" height="19">
			<%
			if(!bCreate)
			{
				%>
				<input type="hidden" name="oldTitle" value="<%=sTitle%>" />
				<%
			}
			%>
				<font class="normalbold"><%=sTypeName%><%=rb.getString("bookmark.name")%></font>
			</td>
			<td height="19">
			    <input size="32" type="text" name="title" value="<%=sTitle%>" maxlength="32" />
			</td>
		</tr>
		<%
		if(!bFolder)
		{
		%>
		<tr>
			<td nowrap="yes" height="19">
				<font class="normalbold"><%=rb.getString("bookmark.bookmarkLink")%></font>
			</td>
			<td height="19">
				<input maxlength="256" size="32" type="text" name="href" value="<%=sHref%>" />
			</td>
		</tr>
		<%
		}
		else
		{
		%>
		<tr>
			<td>
				<input type="hidden" name="href" value="no href needed" />
			</td>
		</tr>
		<%
		}
		%>
		<tr><td height="6"></td></tr>

		<tr>
		<td></td>
		<td align="right">
			<a class="textButton" title="Back" href="javascript:history.back()">
				<%=rb.getString("bookmark.back")%>
			</a>
			&nbsp;&nbsp;&nbsp;&nbsp;

			<a class="textButton" title="Submit" href="javascript:createBookmark(form_<%=CurrentPortlet.getPortletKey()%>_editBookmark)">
				<%=rb.getString("bookmark.submit")%>
			</a>
		</td>
		</tr>
		</table>
		</form>
		</td>
		</tr>
		</table>
		<%
	}
	else
	{
		sMessage = "You can not store any more bookmarks here";
	}

}
if(!sMessage.equals(""))
{
	out.println(Functions.f_displayError(sMessage));
}

String sNewFolderName = request.getParameter("newfolder");

if(sNewFolderName != null)
{
	session.setAttribute("folder", sNewFolderName);
	sNewFolderName = request.getParameter("parent");
	if(sNewFolderName == null)
	{
		session.setAttribute("parentfolder", "My Bookmarks");
	}
	else
	{
		session.setAttribute("parentfolder", sNewFolderName);
	}
}

String sFolderName = (String) session.getAttribute("folder");
String sParentFolderName = (String) session.getAttribute("parentfolder");


if(sFolderName == null)
{
	sFolderName = "My Bookmarks";
	sParentFolderName = "My Bookmarks";

	session.setAttribute("folder", sFolderName);
	session.setAttribute("parentfolder", sParentFolderName);

}

Bookmark[] abmk = CurrentUser.getBookmarkList(sFolderName);
%>
<table align="left" border="0" cellpadding="0" cellspacing="5">
<tr>
<td align="left" colspan="2">
<img border="0" height="16" width="16" src="../../images/folder-open.gif" alt=""/>
<font class="normalbold"><%=sFolderName%></font>
</td>
<td>

</td>
</tr>
<tr><td height="6"></td></tr>
<%
if(abmk == null || abmk.length == 0)
{
	%>
	<tr><td colspan="3" align="center" style="text-align:center;"><font class="normalbold" ><%=rb.getString("bookmark.noBookmarks")%></font></td></tr>
	<%
}
else
{
	//list bookmarks
	//
	CurrentPortal.LogFull("bookmark:entering loop");
	for(int i = 0; i < abmk.length; i++)
	{
		CurrentPortal.LogFull("bookmark: at loop " + i);

		if(i == 0 && !sFolderName.equals("My Bookmarks"))
		{
			//Display parent folder link / icon
			//
			%>
			<tr>
				<td width="20"></td>
				<td align="left">
					<a href="home.jsp?<%=StringUtils.XMLEscape(CurrentPortlet.getPortletKey())%>=listBookmarks&amp;newfolder=<%=Functions.f_URLEncode(abmk[i].getTitle(),request.getCharacterEncoding())%>&amp;parent=<%=Functions.f_URLEncode(sFolderName,request.getCharacterEncoding())%>" >
					<img style="vertical-align:middle;" width="16" height="16" border="0" src="../../images/folder-parent.gif" alt=""/>
					<font class="normal"><%=rb.getString("bookmark.goToParentFolder")%></font>
					</a>
				</td>
				<td colspan="1"></td>
			</tr>
			<tr><td height="6"></td></tr>
			<%
		}
		else
		{
			String sTmp = abmk[i].getHref();

			if (sTmp != null)
			{
				if ((!sTmp.startsWith("http://")) && (!sTmp.startsWith("https://")) && (!sTmp.startsWith("ftp://")) && (!sTmp.startsWith("file://")))
				{
					sTmp = "http://" +sTmp;
				}
			}
			%>
                        <tr>
                                <td height="20" width="20"></td>
			<%
			if(abmk[i].getType().equals("a"))
			{
				%>
				<td height="20" align="left">
					<a href="<%=sTmp%>" target="_blank">
						<img style="vertical-align:middle;" width="16" height="16" border="0" src="../../images/bookmark.gif" alt=""/>
						<font class="normal">
						<%=abmk[i].getTitle()%>
                                                </font>
					</a>&nbsp; &nbsp; &nbsp;
				</td>

				<td height="20" width="20" align="right" ><a href="home.jsp?<%=CurrentPortlet.getPortletKey()%>=editBookmark&amp;title=<%=Functions.f_URLEncode(abmk[i].getTitle(),request.getCharacterEncoding())%>&amp;href=<%=Functions.f_URLEncode(abmk[i].getHref(),request.getCharacterEncoding())%>&amp;folder=<%=Functions.f_URLEncode(sFolderName,request.getCharacterEncoding())%>#<%=sPortlet_key%>"><img border="0" src="../../images/buttons/<%=CurrentPage.getButtonStyle()%>/b_editpane.gif" alt=""></a>&nbsp;</td>

				<%
			}
			else
			{

				%>
				<td height="20" align="left">
					<a href="home.jsp?<%=CurrentPortlet.getPortletKey()%>=listBookmarks&amp;newfolder=<%=Functions.f_URLEncode(abmk[i].getTitle(),request.getCharacterEncoding())%>" ><img style="vertical-align:middle;" width="16" height="16" border="0" src="../../images/folder-closed.gif" alt=""/>
					<font class="normal"><%=abmk[i].getTitle()%>&nbsp; &nbsp; &nbsp;</font></a>

				</td>
				<td height="20" colspan="1"></td>
				<%
			}
			%>

                            <td height="20" width="50" valign="middle" align="center">
                                <form name="deleteform<%=i%>" method="<%=CurrentPortal.readString( CurrentPortal.ADMIN_SECTION, "FormMethod", "post")%>" style="padding:0px; margin:0px;" action="home.jsp">
                                    <input type="hidden" name="<%=CurrentPortlet.getPortletKey()%>" value="deleteBookmark" />
                                    <input type="hidden" name="title" value="<%=abmk[i].getTitle()%>" />
                                    <input type="hidden" name="folder" value="<%=sFolderName%>" />
                                </form>
                                    <a class="textButton" title="Delete" href="javascript:deleteBookmark(deleteform<%=i%>)">
                                        <span style="white-space:nowrap;"><%=rb.getString("bookmark.delete")%></span>
                                    </a>
                            </td>

			</tr>
			<tr><td height="6"></td></tr>
			<%
		}//end of parent folder check
	}//end of bookmark loop
	CurrentPortal.LogFull("bookmark: left loop");

}//end of no bookmarks check
%>
<tr><td height="6"></td></tr>
<tr>
	<td>
		<font class="normalbold"><%=rb.getString("bookmark.options")%></font>
	</td>
</tr>
<tr>
	<td></td><td colspan="3" style="white-space:nowrap;">
		<a href="home.jsp?<%=StringUtils.XMLEscape(CurrentPortlet.getPortletKey())%>=editBookmark&amp;folder=<%=Functions.f_URLEncode(sFolderName,request.getCharacterEncoding())%>&amp;type=f"><font class="normal"><%=rb.getString("bookmark.newFolder")%></font></a>
	</td>
</tr>
<tr>
	<td></td><td colspan="3" style="white-space:nowrap;">
		<a href="home.jsp?<%=StringUtils.XMLEscape(CurrentPortlet.getPortletKey())%>=newBookmark&amp;folder=<%=Functions.f_URLEncode(sFolderName,request.getCharacterEncoding())%>&amp;type=a"><font class="normal"><%=rb.getString("bookmark.newBookmark")%></font></a>
	</td>
</tr>

</table>
<br />

