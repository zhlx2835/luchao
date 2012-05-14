<%@ page import="com.autonomy.APSL.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>


<%
String sAdminHeader_title = "Portlet Administration";
String sAdminHeader_image = "modules32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
String sPortletName = Functions.safeRequestGet( request, "portlet", null );

String USERNAME 	= CurrentUser.getUserName();
String CFG_PATH 	= StringUtils.ensureSeparatorAtEnd(CurrentPortal.PORTAL_BACKEND_LOCATION) + "portletSettings.cfg";
String PORTLET_DIR 	= request.getContextPath() + "/portlets/";
try
{
	//Communicate with APSL

	// signal that we want an admin service
	// store PIBServcie retrieved, if any, in backup session variable for being able to  switch back from admin sevice in UI display section
	session.setAttribute("APSLTransferIAmPiB4Backup", session.getAttribute("APSLTransferIAmPiB4"));
	session.removeAttribute( "APSLTransferIAmPiB4" );

	session.setAttribute("APSLTransferPortletBackup", session.getAttribute("APSLTransferPortlet"));
	session.removeAttribute( "APSLTransferPortlet" );

	session.setAttribute("APSLTransferIAmPiB4Admin", "admin");

	// set info needed for PiBAdminService constructor
	session.setAttribute(PortletService.USER_ATTRIB_NAME, 		USERNAME );
	session.setAttribute(PortletService.CONFIGPATH_ATTRIB_NAME, CFG_PATH );
	session.setAttribute(PortletService.PORLTETDIR_ATTRIB_NAME, PORTLET_DIR);

	//See if portlet is to be the same as last time, or different
	if( sPortletName != null )
	{
		session.setAttribute( "APSLTransferPortletName", sPortletName );
	}
	else
	{
		sPortletName = (String) session.getAttribute( "APSLTransferPortletName" );
	}
	String sIncludeName = "/portlets/" + sPortletName + "/" + sPortletName + ".jsp";

%>
	<table cellspacing="0" cellpadding="0" border="1" width="90%" >
		<tr>
			<td>
<%
				pageContext.getOut().flush();
				pageContext.include(sIncludeName);
%>
			</td>
		</tr>
	</table>
<%
}
catch( Exception e)
{
	out.println("Error: " + e.toString() );
	e.printStackTrace( System.out );
}

%>
<%@ include file="/admin/header/admin_footer.jspf" %>
