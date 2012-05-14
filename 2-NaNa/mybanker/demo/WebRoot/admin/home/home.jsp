<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "";
String sAdminHeader_image = "";
String sth="24";
%>
<%@ include file="/admin/header/adminhome_header.jspf" %>
<%
//when we get here, clear any old "Log in as Other User" logins
//
String sAdminUserName = (String) CurrentUser.getAttribute("IAmAdmin" );

if( sAdminUserName != null )
{
	CurrentUser.removeAttribute("IAmAdmin");
	CurrentUser = CurrentPortal.getUserInfo( sAdminUserName );
	if( CurrentUser != null )
	{
		CurrentUser.removeAttribute("IAmAdmin");
	}
	out.clearBuffer();
	
	//Check everything again
	response.sendRedirect("home.jsp");
}
%>
		
<table border="0" cellpadding="0" cellspacing="0" width="95%">
<tr>
	<td height="<%=sth%>" colspan="3" align="center" ><font class="normalbold">Administration Home Page</font></td>
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="User Interface Settings" target="menuFrame" class="head" href="../ui/index.jsp" ><img height="32" width="32" border="0" src="../../images/admin/interface32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="User Interface Settings" target="menuFrame" class="head" href="../ui/index.jsp" >UI</a></font></td> 
    <td><br /><font class="normal">Allows you to log in to the User Interface as yourself or another user.  You can also edit the layout of the default and template users.</font><br /><br /></td> 
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="User Settings" target="menuFrame" class="head" href="../users/index.jsp"  ><img height="32" width="32" border="0" src="../../images/admin/users32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="User Settings" target="menuFrame" class="head" href="../users/index.jsp"  >Users</a></font></td> 
    <td><br /><font class="normal">Allows you to add, delete, edit or clone users.  You can also initialize all users.</font><br /><br /></td> 
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="Role Settings" target="menuFrame" class="head" href="../roles/index.jsp"  ><img height="32" width="32" border="0" src="../../images/admin/authentication32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="Role Settings" target="menuFrame" class="head" href="../roles/index.jsp"  >Roles</a></font></td> 
    <td><br /><font class="normal">Allows you to add, delete or move roles.  You can also include or exclude users in/from roles, and set database or portlet permissions for roles.</font><br /><br /></td> 
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="Portlet Settings" target="menuFrame" class="head" href="../portlets/index.jsp" ><img height="32" width="32" border="0" src="../../images/admin/modules32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="Portlet Settings" target="menuFrame" class="head" href="../portlets/index.jsp" >Portlets</a></font></td> 
    <td><br /><font class="normal">Allows you to create a custom portlet, to remove portlets from the user interface or the Portal and to edit portlets.  You can also set portlet permissions for roles.</font><br /><br /></td> 
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="Content Source / Database Settings" target="menuFrame" class="head" href="../content/index.jsp" ><img height="32" width="32" border="0" src="../../images/admin/database32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="Content Source / Database Settings" target="menuFrame" class="head" href="../content/index.jsp" >Content</a></font></td> 
    <td><br /><font class="normal">Allows you to allocate database access to roles.</font><br /><br /></td> 
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="Reload All Settings" target="menuFrame" class="head" href="../reload/index.jsp" ><img height="32" width="32" border="0" src="../../images/admin/plugins32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="Reload All Settings" target="menuFrame" class="head" href="../reload/index.jsp" >Reload</a></font></td> 
    <td><br /><font class="normal">Allows you to reinitialize the Portal or flush the Portal's cache.</font><br /><br /></td> 
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="Setup &amp; Configuration Settings" target="menuFrame" class="head" href="../setup/index.jsp" ><img height="32" width="32" border="0" src="../../images/admin/administrator32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="Setup &amp; Configuration Settings" target="menuFrame" class="head" href="../setup/index.jsp" >Setup</a></font></td> 
    <td><br /><font class="normal">Allows you to modify the Portal's configuration settings.</font><br /><br /></td> 
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="Help &amp; Support" target="menuFrame" class="head" href="../support/index.jsp"  ><img height="32" width="32" border="0" src="../../images/admin/server32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="Help &amp; Support" target="menuFrame" class="head" href="../support/index.jsp"  >Help</a></font></td> 
    <td><br /><font class="normal">Allows you to display Autonomy documentation, online help or server request logs.  You can also e-mail Autonomy Support or log on to the Autonomy Helpdesk.</font><br /><br /></td> 
</tr>	
<tr>
    <td width="60" height="<%=sth%>" colspan="1"><a title="Logout" target="mainFrame" class="head" href="../home/logout.jsp"  ><img height="32" width="32" border="0" src="../../images/admin/logout32.gif" alt=""></a></td>
    <td width="70"><font class="normalbold"><a title="Logout" target="mainFrame" class="head" href="../home/logout.jsp"  >Logout</a></font></td> 
    <td><br /><font class="normal">Logs you out of the Portal.</font><br /><br /></td> 
</tr>	
</table>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
