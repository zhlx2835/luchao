<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Creating a new portlet - Step 2 - Portlet Details";
String sAdminHeader_image = "modules32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<script type="text/javascript">
	<!--
	function jf_action_paneTest(objForm)
	{
		var sBdColor = "#000000";
		var sHdColor = "#000000";
		var BODY_BGCOLOR = "#000000";
		for(i = 0; i < objForm.bdcolor.length; i++)
		{
			if(objForm.bdcolor[i].checked)
				sBdColor = objForm.bdcolor[i].value;
			if(objForm.hdcolor[i].checked)
				sHdColor = objForm.hdcolor[i].value;
			if(objForm.bgcolor[i].checked)
				BODY_BGCOLOR = objForm.bgcolor[i].value;
		}

		var winHandle = window.open("", "paneWin", "height=216,width=216,scrollbars=no,titlebar=no,toolbar=no,resizable=no,menubar=no,dependent=yes,fullscreen=no");
		winHandle.document.write('<html><head><title>Settings for your new pane</title></head>');
		winHandle.document.write('<body topmargin="8" leftmargin="8" ><link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/portalinabox.css" >');
		winHandle.document.write('<table class="pane1" width="200" height="200" cellspacing="0" border="2" bordercolor=' + sBdColor + '><tr><td valign=\"top\" bgcolor=' + BODY_BGCOLOR + '>');
		winHandle.document.write('<table class="pane2" width="100%" height="100%" cellspacing="0" border="0">');
		winHandle.document.write('<tr><td height="22" bgcolor="' + sHdColor + '" align="center"><font class="head" color="' + sBdColor + '" />My New Portlet</td></tr>');
		winHandle.document.write('<tr><td height="160" bgcolor="' + BODY_BGCOLOR + '" align="center"><font class="normal" >porlet content</td></tr>');
		winHandle.document.write('</table></td></tr></table></body></html>');
		winHandle.document.close();
		winHandle.focus();

	}

	function validate(objForm)
	{
		//Check name given
		//
		if(objForm.identifier.value.length == 0)
		{
			alert("You must supply an identifier for this portlet!");
			objForm.identifier.focus();
			return false;
		}
		//
		for(i = 0; i < sa_jsPortletList.length; i++)
		{
			if(sa_jsPortletList[i] == objForm.identifier.value.toLowerCase())
			{
				alert("A portlet already exists with this identity, please supply a different one");
				objForm.identifier.focus();
				return false;
			}
		}
	}

	var sa_jsPortletList = new Array(<%

	//This bit's JSP
	//
	String[] sa_paneList = allPortlets.getSectionNames();
	for(int i = 0; i < sa_paneList.length; i++)
	{
		if(i == sa_paneList.length - 1)
		{
			// dont print the comma

			out.write("\"" + sa_paneList[i].toLowerCase() + "\"");
		}
		else
		{
			out.write("\"" + sa_paneList[i].toLowerCase() + "\", ");
		}
	}
	//and back to javascript
	//
	%>);

	//-->
</script>

<form action="new2_submit.jsp" method="POST" name="form_new2" onSubmit="return validate(this);">
<table width="600" <%=Functions.f_getTableCenter(session)%> border="0">

<%
//pick up on any errors
//
String sIdentifier = "";
String sName = "";
String sDescription = "";
String sBgColor = "";
String sHdColor = "";
String sBdColor = "";
String sMessage = request.getParameter("message");

if(StringUtils.strValid(sMessage))
{
	sIdentifier = request.getParameter("identifier");
	if(sIdentifier == null) sIdentifier = "";

	sName = request.getParameter("fullname");
	if(sName == null) sName = "";

	sDescription = request.getParameter("description");
	if(sDescription == null) sDescription = "";

	sBgColor = request.getParameter("bgcolor");
	if(sBgColor == null) sBgColor = "";

	sBdColor = request.getParameter("bdcolor");
	if(sBdColor == null) sBdColor = "";

	sHdColor = request.getParameter("hdcolor");
	if(sHdColor == null) sHdColor = "";

	%>
	<tr>
            <td align="center" colspan="2"><font class="normalbold" ><%=sMessage%></font></td>
	</tr>
	<%
}
%>
<tr><td height="12" width="20%"></td><td width="80%"></tr>
<tr>
    <td width="25%"><font class="normal" >Unique Identifier:</font></td>
    <td width="75%"><input type="text" name="identifier" size="30" value="<%=sIdentifier%>" maxlength="24"/></td>
</tr>
<tr><td colspan="2" ><font class="note" >This is a short text identifier for your portlet, which must be unique to this portlet.<br /><br /></font></td></tr>
<tr>
	<td width="25%"><font class="normal" >full name:</font></td>
	<td width="75%"><input type="text" name="fullname" size="30" value="<%=sName%>" /></td>
</tr>
<tr><td colspan="2" ><font class="note" >This is the full name of this portlet - the text that appears on the header of all instances of this portlet<br /><br /></font></td></tr>
<tr>
	<td width="25%"><font class="normal" >description:</font></td>
	<td width="75%"><textarea name="description" rows="3" cols="30" wrap="soft" ><%=sDescription%></textarea></td>
</tr>
<tr><td colspan="2" ><font class="note" >This is a brief desciption of this portlet which can be used to aid users and administrators alike<br /><br /></font></td></tr>

<tr><td height="12" width="20%"></td><td width="80%"></tr>
<tr>
	<td></td><td colspan="1" valign="bottom"><a class="textButton" title="Ok" href="javascript:document.form_new2.submit();">Ok</a>&nbsp;&nbsp;&nbsp;&nbsp;<a class="textButton" title="Cancel" href="home.jsp">Cancel</a></td>
</tr>
</table>
</form>
<%@ include file="/admin/header/admin_footer.jspf" %>

