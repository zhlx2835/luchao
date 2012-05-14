<%@ page import = "java.net.URLEncoder"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

//get locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));
%>

<%@ include file = "/user/home/CheckPortal.jspf" %>

<%
try
{
	//Fill in session vars allowing users to log in
	//
	String sPortletKey 	= request.getParameter("paneKey");
	String sRedirectHref= request.getParameter("redirecthref");
	String sUserName 	= request.getParameter("username");
	String sPassword = request.getParameter("password");

	if(!StringUtils.strValid(sUserName, CurrentPortal.readInt( CurrentPortal.ADMIN_SECTION, "MaxUserNameLength", 256 ) ) )
	{
		response.sendRedirect(sRedirectHref + "?message=You must provide a valid username");
	}//username is null check
	if(!StringUtils.strValid(sPassword))
	{
		response.sendRedirect(sRedirectHref + "?message=You must provide a valid password");
	}

	sUserName = sUserName.trim();
	sPassword = sPassword.trim();

	// try to authenticate user using UAServer
	String sRepository = CurrentPortal.getSecurityObject().getKeyByName("AuthenticationMethod", "");
	boolean bAuthenticated = CurrentPortal.authenticate( sUserName, sPassword, null, sRepository, false);

	// if authenticated, make sure we have a UAServer entry for that user and log them in.
	// otherwise, go back to login form with error message.
	if(bAuthenticated)
	{
		boolean bOKToLogin = true;
		// if user was authenticated and we're using a 3rd party plugin to do this, there might not be an entry
		// in the UAServer for this user (e.g. the first time such a user logs in). In this case, an entry must
		// be created.
		if(sRepository.equalsIgnoreCase("ldap"))
		{
			bOKToLogin = checkUserEntry(sRepository, sUserName, sPassword, CurrentPortal);
		}	//if(sRepository.equalsIgnoreCase("ldap"))

		// now log user in
		if(bOKToLogin)
		{
			try
			{
				UserInfo CurrentUser = new UserInfo( CurrentPortal, sUserName, 0, sPassword );
				//Success - log user in
				Functions.f_initUser(CurrentPortal, CurrentUser, true, "", session, request);
				UserPageInfo CurrentPage = (UserPageInfo) CurrentUser.getAttribute( "CurrentPage" );
				if ( CurrentPage != null )
				{
					CurrentPage.makeSystemPortlet("");
				}
				CurrentUser.removeAttribute( "CurrentPage" );
				response.sendRedirect(request.getContextPath() + "/user/home/home.jsp?headmessage=Log+in+successful");
				return;
			}
			catch( Exception e )
			{
				response.sendRedirect(sRedirectHref + "?paneKey=" + sPortletKey + "&" + sPortletKey + "=showMessage&message=" + Functions.f_URLEncode( e.getMessage() ) + "&#" + sPortletKey);
				return;
			}
		}
		else	//if(bOKToLogin)
		{
			response.sendRedirect(sRedirectHref + "?paneKey=" + sPortletKey + "&" + sPortletKey + "=showMessage&message=" + Functions.f_URLEncode(rb.getString("login_submit.notReadUserFromUA")) + "&#" + sPortletKey);
			return;
		}
	}
	else	//if(bAuthenticated)
	{
		// login failed
		response.sendRedirect(sRedirectHref + "?paneKey=" + sPortletKey + "&" + sPortletKey + "=showMessage&message=" + Functions.f_URLEncode( rb.getString("login_submit.notRecognised")) + "&#" + sPortletKey);
		return;
	}
}
catch( Exception e)
{
	out.println("An internal error occurred while loading this page - please contact the administrator");
	CurrentPortal.LogThrowable( e );
}
%>

<%!
private static boolean checkUserEntry(String sRepository,
								   	  String sUserName,
								   	  String sPassword,
								   	  PortalInfo CurrentPortal
								  	 )
{
	boolean bUserEntryExists = false;

	// see if there is an entry for this user
	UserInfo user = null;
	try
	{
		user = CurrentPortal.getUserInfo(sUserName);
	}
	catch(Exception e)
	{}

	if(user == null)
	{
		// currently no entry so create a new user entry
		CurrentPortal.LogFull(sRepository + " authentication: no current UAServer user called " + sUserName);
		CurrentPortal.LogFull(sRepository + " authentication: creating new user.");
		try
		{
			Vector vSecurityFields = new Vector();
			vSecurityFields.add(new SecurityField("username", sUserName));
			vSecurityFields.add(new SecurityField("password", sPassword));

			UserSecurityFields usf = new UserSecurityFields();
			usf.setSecurityTypeNames(new String[]{sRepository});
			usf.setSecurityTypeFields(new Vector[]{vSecurityFields});

			CurrentPortal.updateOrCreateUser(sUserName, sUserName, usf);
			bUserEntryExists = true;
		}
		catch( Exception e3)
		{
			CurrentPortal.Log(sRepository + " authentication: Failed to updateOrCreateUser- " + e3.toString() );
		}
	}
	else
	{
		bUserEntryExists = true;
	}
	return bUserEntryExists;
}
%>
