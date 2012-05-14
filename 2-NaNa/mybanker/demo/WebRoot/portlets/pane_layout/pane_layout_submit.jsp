<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.client.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>


<%@ include file = "/user/home/CheckUser.jspf" %>
<%
try
{
	AllPortlets allPortlets = CurrentPortal.getAllPortletsObject();
	
	//
	//Get form values, validate and save
	//
	String sMessage = "";
	PortletInfo SelectedPortlet = (PortletInfo) CurrentUser.getAttribute("SelectedPortlet");

	if(SelectedPortlet != null)
	{
		String sPortletName = request.getParameter("newPortletName");
		String sPortletKey 	= request.getParameter("panekey");
		String sPageNum 	= request.getParameter("pageNo");
		String sPortletNum 	= request.getParameter("paneNo");
		if(sPortletName.equals("no_pane") || sPortletName.startsWith("---"))
		{
			SelectedPortlet.setPortletName("");
		}
		else
		{
			//
			//Check pane exists
			//
			String sIncludeName = "/portlets/" + sPortletName;
			if(!new File(application.getRealPath(sIncludeName)).exists())
			{
				CurrentPortal.Log("pane_layout_submit: Tried to load pane " + sPortletName + " from " + sIncludeName + " that no longer exists");
				String[] saRoleList = CurrentRoles.getRoleList(CurrentUser.getUserName(), true);
				for(int i = 0; i < saRoleList.length; i++)
				{
					try
					{
						CurrentRoles.removePrivilegeFromRole("panes_selectable", sPortletName, saRoleList[i]);
						CurrentRoles.removePrivilegeFromRole("panes_viewable", sPortletName, saRoleList[i]);
						CurrentRoles.removePrivilegeFromRole("panes_editable", sPortletName, saRoleList[i]);
					}
					catch(Exception e)
					{
						CurrentPortal.Log("pane_layout_submit: Could not remove pane privileges for pane " + sPortletName + " from role " + saRoleList[i] + " - " + e.toString() );
					}
				}

				SelectedPortlet.setPortletName("");
				sMessage = "You cannot view this portlet because it no longer exists";
				CurrentPortal.setAttribute("message", sMessage );

				response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?paneKey=" + sPortletKey + "&pageNo=" + sPageNum + "&paneNo=" + sPortletNum + "&" + sPortletKey + "=showMessage&oldaction=editPortlet&#" + sPortletKey );
				out.flush();
				return;
			}
			else
			{
				SelectedPortlet.delete();
				SelectedPortlet.setPortletName(sPortletName.toLowerCase());
				//
				//Check user has permission to view it...
				//
				if( !CurrentRoles.hasUserGotPrivilege(CurrentUser.getUserName(), "panes_viewable", sPortletName, true) )
				{
					CurrentPortal.Log("pane_layout_submit: User " + CurrentUser.getUserName() + " has selected pane " + sPortletName + " but does not have permission to view it");

					SelectedPortlet.setPortletName("");

					sMessage = "You cannot view this portlet, please contact the system administrator";
					CurrentPortal.setAttribute( "message", sMessage );

					response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?paneKey=" + sPortletKey + "&pageNo=" + sPageNum + "&paneNo=" + sPortletNum + "&" + sPortletKey + "=showMessage&oldaction=editPortlet&#" + sPortletKey );
					out.flush();
					return;
				}
			}
		}
		response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?paneKey=" + sPortletKey + "&pageNo=" + sPageNum + "&paneNo=" + sPortletNum + "&" + sPortletKey + "=showMessage&oldaction=editPortlet&#" + sPortletKey + "_useredit");
	}
}
catch( Exception e )
{
	CurrentPortal.LogThrowable( e );
}
%>
