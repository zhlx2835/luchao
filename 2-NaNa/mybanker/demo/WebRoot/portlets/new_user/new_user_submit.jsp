<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/home/CheckUser.jspf" %>
<%

CurrentPortal.LogFull("new user submit: In new user submit, Checked User OK");
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
//validate
//
String sPortletKey 	= HTMLUtils.safeRequestGet(request, "paneKey", "");

String sUserName 			= HTMLUtils.safeRequestGet(request, "username", "").trim();
String sPassword1 		= StringUtils.stripDangerousChars(HTMLUtils.safeRequestGet(request, "password1", "").trim());
String sPassword2 		= StringUtils.stripDangerousChars(HTMLUtils.safeRequestGet(request, "password2", "").trim());
String sLanguage			= StringUtils.nullToEmpty(request.getParameter("language"));
String sEmail 				= StringUtils.stripDangerousChars(HTMLUtils.safeRequestGet(request, "email", "").trim());
String sRoleName 			= StringUtils.stripDangerousChars(HTMLUtils.safeRequestGet(request, "role", ""));
String sAuthorisation = StringUtils.stripDangerousChars(HTMLUtils.safeRequestGet(request, "authorisation", "").trim());
String sQueryString 	= Functions.f_requestToQueryString( request, true );

boolean bAuthorised = false;

if(sUserName.equals(""))
{
	CurrentUser.setAttribute( sPortletKey + "message", "Please supply a username");
	response.sendRedirect("../../user/home/home.jsp" + sQueryString + "&#" + sPortletKey);
	return;
}
else
{
	for(int i=0; i<sUserName.length(); i++)
	{
		if(!Character.isLetterOrDigit(sUserName.charAt(i))&&!(sUserName.charAt(i)=='_')&&!(sUserName.charAt(i)=='-')&&!(sUserName.charAt(i)=='@')&&!(sUserName.charAt(i)=='.')&&!(sUserName.charAt(i)==' '))
			{
				CurrentUser.setAttribute( sPortletKey + "message", "Username contains invalid character. Username can only contain letter, digit, underscore, period, hypen, space or @ symbol.");
				response.sendRedirect("../../user/home/home.jsp" + sQueryString + "&#" + sPortletKey);
				return;
			}
	}
}
if(!StringUtils.strValid(sPassword1) || !StringUtils.strValid(sPassword2))
{
	CurrentUser.setAttribute( sPortletKey + "message", "Please supply a password");
	response.sendRedirect("../../user/home/home.jsp" + sQueryString + "&#" + sPortletKey);
	return;
}
if(!sPassword1.equals(sPassword2))
{
	//Show error on pane
	CurrentUser.setAttribute( sPortletKey + "message", "Your two passwords did not match");
	response.sendRedirect("../../user/home/home.jsp" + sQueryString + "&#" + sPortletKey);
	return;
}
if(sEmail.length() <= 5 || sEmail.indexOf("@") == -1 || sEmail.substring(sEmail.indexOf("@")).length()<=4 || sEmail.substring(sEmail.indexOf("@")).indexOf(".")==-1)
{
	//Show error on pane
	CurrentUser.setAttribute( sPortletKey + "message", "Please supply a valid Email address");
	response.sendRedirect("../../user/home/home.jsp" + sQueryString + "&#" + sPortletKey);
	return;
}

String[] saCurrentPassword = CurrentRoles.getValuesForRole(sRoleName, "signup_password", false);
if( saCurrentPassword != null && saCurrentPassword.length > 0)
{
	if(!StringUtils.strValid(sAuthorisation))
	{
		//Show error on pane
		CurrentUser.setAttribute( sPortletKey + "message", "You need to give an authorisation code");
		response.sendRedirect("../../user/home/home.jsp" + sQueryString + "&#" + sPortletKey);
		return;
	}
	else
	{
		//
		//Authorisation, loop through all roles and compare given string to auth password privilege value for that role
		//This should only have one entry - take the first one
		//
		String sRolePassword = saCurrentPassword[0];
		if(sRolePassword.equalsIgnoreCase( sAuthorisation ))
		{
			bAuthorised = true;
		}
	}
}
else
{
	//No authorization password set for role

	CurrentPortal.LogFull("new_user_submit: WARNING - Role " + sRoleName + " has no authorization password");
	bAuthorised = true;
}

if(!bAuthorised)
{
	//Show error on pane

	CurrentUser.setAttribute( sPortletKey + "message", "You failed to enter the correct authorisation password");
	response.sendRedirect("../../user/home/home.jsp" + sQueryString + "&#" + sPortletKey);
	return;

}

//Build up hashtable of fields
Hashtable htFields = new Hashtable();
htFields.put( "EmailAddress", sEmail );
htFields.put( "InitialRoleName", sRoleName );
htFields.put( "DRELanguageType", lookupLanguageType(CurrentPortal, sLanguage));

UserInfo NewUser = null;
try
{
	NewUser = new UserInfo( CurrentPortal, sUserName, sPassword1, htFields, 0 );
	NewUser.add();
	CurrentRoles.addUserToRole( sUserName, sRoleName );
	CurrentRoles.removeUserFromRole( sUserName,
			CurrentSecurity.getKeyByName("GuestRole", "guest")
			);
}
catch( Exception e )
{
	CurrentUser.setAttribute( sPortletKey + "message", "Sorry, could not create user: " + e.getMessage() );
	CurrentPortal.Log("new_user_submit: Could not create the user " + sUserName + ":" );
	CurrentPortal.LogThrowable( e );
	response.sendRedirect("../../user/home/home.jsp" + sQueryString + "&#" + sPortletKey);
	return;
}

//Success - log user in
CurrentPortal.Log("User " + sUserName + " has signed into role " + sRoleName);
CurrentUser.setAttribute( "CurrentUser", NewUser );
Functions.f_initUser(CurrentPortal, NewUser, false, "", session, request);
CurrentPage.makeSystemPortlet("");
response.sendRedirect("../../user/home/home.jsp?headmessage=" + Functions.f_URLEncode("Your sign-up was successful, welcome to Portal-in-a-box, " + sUserName + "!"));
%>

<%!
private String lookupLanguageType(PortalInfo portal, String sLanguageDisplayName)
{
	String sLanguageType = "";
	String[] saLanguageDisplayNames = StringUtils.split(portal.readString(portal.LANGUAGE_SECTION, "LanguageTypesDisplayNames", "English"), ",");
	String[] saLanguageTypes = StringUtils.split(portal.readString(portal.LANGUAGE_SECTION, "LanguageTypes", "englishUTF8"), ",");

	int nNameIdx = StringUtils.isStringInStringArray(saLanguageDisplayNames, sLanguageDisplayName, true);
	if(nNameIdx != -1)
	{
		sLanguageType = saLanguageTypes[nNameIdx];
	}

	return sLanguageType;
}

private static void mylog(String s)
{
	System.out.println(s);
}
%>