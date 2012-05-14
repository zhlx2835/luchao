<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Creating a new portlet - Step 3 - Creating the template";
String sAdminHeader_image = "modules32.gif";
String sPortletName = request.getParameter("pane");
if(!StringUtils.strValid(sPortletName))
{
	response.sendRedirect(request.getContextPath() + "/admin/home/home.jsp");
	return;
}
%>
<%@ include file="/admin/header/admin_header.jspf" %>

<table width="600" border="0" <%=Functions.f_getTableCenter(session)%>>
	<tr>
		<td>
			<%
			String sAction = request.getParameter("action");
			if(sAction == null)
				sAction = "";

			//Now we know we have a clear space to place the portlet template folder
			//Duplicate the templates folder, rename it and copy into place
			String sTemplateFilePath = application.getRealPath("/portlets/template/portlet.jsp");
			File templateFile = new File(sTemplateFilePath);
			if(!templateFile.exists())
			{
			%>
                            <p><font class="normalbold" >The portlet template cannot be found.</font></p>
                            <p><font class="normal" >You cannot continue this process without it.  Please contact Autonomy if you wish to continue.</font></p>
			<%
				return;
			}

			String sPortletFolderName = StringUtils.ensureSeparatorAtEnd(application.getRealPath("/portlets/")) + sPortletName;
			String sPortletFileName = sPortletFolderName + File.separator + sPortletName + ".jsp";
			try
			{
				// create new directory
				 new File(sPortletFolderName).mkdir();

				// copy template file into new portlet folder using portlet name
				FileUtils.copyFile(templateFile, new File(sPortletFileName));
			}
			catch(Exception e)
			{
			%>
                            <p><font class="normalbold" >Could not copy the template files into place</font></p>
                            <p><font class="normal" >This is probably because the permissions are not setup to allow the web-server to do this.  Please ensure the directory</font><br />
                            <font class="normalbold" ><%= sPortletFileName %></font><br/><br />
                            <font class="normal" >
                            is write enabled.  Then reload this page to try again.  The error is displayed in the log file</font></p></td></tr></table>
			<%
				CurrentPortal.Log("new: Could not copy files - " + e.toString() );
				return;
			}
			boolean bUpdatedRoles = true;
			try
			{
				SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
				//
				//Give user privilege to see this pane
				//
				CurrentRoles.addPrivilegeToRole("panes_viewable", sPortletName, CurrentSecurity.getKeyByName("AdminRole"));
				CurrentRoles.addPrivilegeToRole("panes_editable", sPortletName, CurrentSecurity.getKeyByName("AdminRole"));
				CurrentRoles.addPrivilegeToRole("panes_selectable", sPortletName, CurrentSecurity.getKeyByName("AdminRole"));
			}
			catch(Exception e)
			{
				CurrentPortal.Log("new4:  Could not give administrator new privilege for portlet - " + e.toString() );
				bUpdatedRoles = false;
			}
			%>

                        <p><font class="normalbold" >The necessary files have been copied into place</font></p>
			<%
			if(bUpdatedRoles)
			{
                            %>
                            <p><font class="normal" >You have also been given permission to view and edit this portlet.</font></p>
                            <%
			}
			else
			{
                            %>
                            <p><font class="normal" >But I could not give you permission to view and edit this portlet, please do this from the portlet administration page.</font></p>
                            <%
			}
			%>

                        <p>
                            <font class="normal" >The </font><font class="normalbold" ><%=sPortletFolderName%> </font><font class="normal" > folder has been created and contains one file:</font></p>

                            <ul>
                                <li><font class="normalbold" ><%=sPortletName%>.jsp</font><br />
                            </ul>
                            <font class="normal" >This file that contains the main script for the portlet.  This will contain the portlet content.</font>
                            <br>
                            <p>
                            <font class="normal" >
                                You can now go and look at this portlet (by going to the main portal site and selecting it from the
                                portlet layout section) and these source files.  The portlet contains some template source code advising you on the ways to
                                code JSP for portal portlets.  The source code for the user and admin edit pages show you how easy it is to add custom
                                variables to your portlet.  You have at your disposal an extensive library of Java methods (which you will have the Javadocs for)
                                to make the task as easy as possible.
                            </font>
                        </p>
                        <p>
                            <font class="normal" >
                                Or, to set up the portlet permissions - click here to visit the portlet permissions screen:<br />
                            </font>
                        </p>
			<a class="textButton" title="Ok" href="permissions.jsp?pane=<%=sPortletName%>">
                            Ok
			</a>
		</td>
	</tr>
</table>
<%@ include file="/admin/header/admin_footer.jspf" %>
