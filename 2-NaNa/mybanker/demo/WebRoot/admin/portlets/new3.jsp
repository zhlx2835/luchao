<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Creating a new portlet - This portlet already exists";
String sAdminHeader_image = "modules32.gif";
String sPortletName = request.getParameter("pane");
if(!StringUtils.strValid(sPortletName))
{
	response.sendRedirect(request.getContextPath() + "/admin/home/home.jsp");
	return;
}
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
String sAction = request.getParameter("action");
if(sAction == null)
	sAction = "";

File filePortletFolder = new File(application.getRealPath("/portlets/" + sPortletName));
boolean bPortletExists = filePortletFolder.exists();

if(sAction.equals("deletePortlet"))
{
	//Attempt to delete file
	//
	if(bPortletExists)
		FileUtils.removeWithRecurse(filePortletFolder);
	//
	//Check again if file exists if security intervened
	//
	if(filePortletFolder.exists())
	{
		%>
                <p><font class="normalbold" >It was not possible to delete all the necessary files.</font></p>
                <p><font class="normal" >Please manually delete the folder <%=application.getRealPath("/portlets/" + sPortletName)%> and run this wizard again</font></p>
		</body></html>
		<%
		return;
	}
	response.sendRedirect("new4.jsp?pane=" + sPortletName);
	out.clearBuffer();
	return;
}

//
//See if portlet already exists in portlet structure
//
//
if(bPortletExists)
{
	%>
	<table border="0" width="60%" <%=Functions.f_getTableCenter(session)%> ><tr><td>
        <p><font class="normalbold" >The portlet folder exists already exists.</font></p>
        <p><font class="normal" >You can either:</font></p>
	<p>&nbsp;&nbsp;&nbsp;&nbsp;a) <a class="normal" href="new3.jsp?action=deletePortlet&pane=<%=sPortletName%>">Remove this folder and any files within</a></p>
	<p>&nbsp;&nbsp;&nbsp;&nbsp;b) <a class="normal" href="new5.jsp?pane=<%=sPortletName%>">Leave the folder and files within alone and use these to construct your portlet</a></p>
	</td></tr></table>
	<%
}
else
{
	out.clearBuffer();
	response.sendRedirect("new4.jsp?pane=" + sPortletName);
}
%>
</table>
<%@ include file="/admin/header/admin_footer.jspf" %>
