<%@ page import="java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.aci.exceptions.AciException" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/home/CheckUser.jspf" %>
<%
String sUserName = null;
try
{
	CurrentUser = (UserInfo) session.getAttribute(CurrentPortal.PORTAL_BACKEND_LOCATION+"CurrentUser");
	if( CurrentUser == null)
		throw new NullPointerException("No user logged in");

	SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
	//
	//validate
	//
	sUserName = request.getParameter("username");
	String sOldPassword = Functions.safeRequestGet( request, "oldpassword", "");
	String sPassword1 	= Functions.safeRequestGet( request, "password1", "");
	String sPassword2 	= Functions.safeRequestGet( request, "password2", "");
	String sPaneKey 	= Functions.safeRequestGet( request, "paneKey", "");
	String sRedirectHref= request.getContextPath() + "/user/home/home.jsp";

	if(sUserName == null)
	{
		response.sendRedirect( sRedirectHref );
		out.flush();
		return;
	}

	if(!sPassword1.equals(sPassword2))
	{
		//Show error on pane
		CurrentUser.setAttribute( sPaneKey + "message", "Your two passwords did not match" );
		response.sendRedirect(sRedirectHref + "?" + sPaneKey + "=chPassword" );
		out.flush();
		return;
	}

        try
        {
            CurrentPortal.setPasswordFor( sUserName, sOldPassword, sPassword1, null );
            CurrentUser.setAttribute( sPaneKey + "message", "Password changed successfully" );
            response.sendRedirect(sRedirectHref);
            out.flush();
            return;
        }
        catch (AciException err)
        {
            CurrentUser.setAttribute( sPaneKey + "message", err.getMessage() );
            response.sendRedirect(sRedirectHref + "?" + sPaneKey + "=chPassword" );
            out.flush();
            return;
        }
        catch (Exception err)
        {
            CurrentUser.setAttribute( sPaneKey + "message", "Could not contact UAServer" );
            response.sendRedirect( sRedirectHref + "?" + sPaneKey + "=chPassword" );
            out.flush();
            return;
        }
}
catch( Exception e )
{
	response.sendRedirect(request.getContextPath() + "/user/home/home.jsp");
}
%>
