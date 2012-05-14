<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
if( request.getParameter("okPressed")!=null&&request.getParameter("okPressed").equals("true"))
{
	%>
	<%@ include file="/admin/home/admin_checkUser.jspf" %>
	<%
	RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
	String sMessage = "All users initialized";
	//
	//Get form values, validate and save
	//
	try
	{
		String[] asUsers = CurrentRoles.getUserList(-1, -1, null);
		String sBaseRole = CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone");
		for(int i = 0; i < asUsers.length; i++)
		{
			String[] asRoles = CurrentRoles.getRoleList();
			for(int j=0; j<asRoles.length; j++)
			{
				CurrentRoles.deleteUserFromRole(asUsers[i], asRoles[j]);
			}
			CurrentRoles.addUserToRole(asUsers[i], sBaseRole);
		}
	}
	catch(Exception e)
	{
		CurrentPortal.Log( "roles_edit_initialize:  Could not complete operation:" );
		CurrentPortal.LogThrowable( e );
		sMessage = "Could not complete operation, please check the log file for details";
	}

	CurrentUser.setAttribute("message", sMessage );

	response.sendRedirect("editdisplay.jsp" + Functions.f_requestToQueryString( request, true ) );
}
else
{
	String sAdminHeader_title = "Initialize All Users";
	String sAdminHeader_image = "users32.gif";
	%>
	<%@ include file="/admin/header/admin_header.jspf" %>
        <p>
            <font class="normal">
                Click OK if you have imported users from another
                application and to ensure that all the users are in the base role of the
                portal, so that they can be properly administered from the administrative
                Portal pages.
            </font>
        </p>
	<p>
	<a class="textButton" title="Initialize" href="initialize.jsp?okPressed=true" >
		OK
	</a>
	<%@ include file="/admin/header/admin_footer.jspf" %>
	<%
}
%>
