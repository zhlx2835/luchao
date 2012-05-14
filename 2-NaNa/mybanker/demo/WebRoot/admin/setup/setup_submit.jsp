<%@ page import="java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/home/admin_checkUser.jspf" %>
<%
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
//
//sanity check
//
Enumeration Names = request.getParameterNames();
String sKeyName = null;
String sValue = null;
String sSection = null;
String sMessage = "Your changes have been saved";
String sRedirectHref = "home.jsp";
String sName = null;

if( Names != null )
{
	CurrentPortal.writeTo( StringUtils.ensureSeparatorAtEnd(BACKEND_LOCATION) + "portal.cfg.bak", false);
	for( ; Names.hasMoreElements(); )
	{
		sName = (String) Names.nextElement();
		if( sName.startsWith("section") )
		{
			sKeyName = sName.substring(7);
			sValue = request.getParameter( sKeyName );
			if( sValue != null )
			{
				//OK to read this key
				sSection = request.getParameter( sName );
                                if(sSection!=null&&sSection.equalsIgnoreCase("Admin")&&sKeyName.equalsIgnoreCase("UserMaxNumberOfPages"))
				{
				      int temp = Integer.parseInt(CurrentPortal.readString(sSection,sKeyName)) - Integer.parseInt(sValue);
				      // if current UserMaxNumberOfPages is greater than the one to be set modify pagemask length as well to avoidArrayIndexOutOfBoundsException
				      // See Bugzilla Bug 109062 for details
				      if(temp>0)
				      {
				       CurrentUser.setExtendedField("PAGEMASK", CurrentUser.getExtendedField("PAGEMASK").substring(0, CurrentUser.getExtendedField("PAGEMASK").length()-temp));
				      }
                                }
				CurrentPortal.setString( sSection, sKeyName, sValue );
			}
		}
	}
	CurrentPortal.write();
	CurrentPortal.flushObjectStore();
}
CurrentUser.setAttribute( "message", sMessage );

response.sendRedirect( sRedirectHref );

%>
