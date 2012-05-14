<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
String sAdminHeader_title = "";
String sAdminHeader_image = "plugins32.gif";
%>
<%@ include file="/admin/header/adminhome_header.jspf" %>

<%
//
try
{
	String sCfgFilePath = CurrentPortal.readString(CurrentPortal.PORTAL_SECTION, "PortletConfigFilePath", StringUtils.ensureSeparatorAtEnd(CurrentPortal.PORTAL_BACKEND_LOCATION) + "portletSettings.cfg" );
	PortletConfigFile.getInstance( sCfgFilePath).reset();
	%>
	<font class="normalbold">
	The portlets have successfully been reset - click on a menu option to continue
	<br /><br />
	</font>
	<%
}
catch(Exception e)
{
	CurrentPortal.Log("Failed - error cause:" );
	CurrentPortal.LogThrowable( e );
	%>
	<font class="normal" >Please click on a menu option to continue<br /><br /></font>
	<%
	out.flush();
	
	return;
}
%>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
