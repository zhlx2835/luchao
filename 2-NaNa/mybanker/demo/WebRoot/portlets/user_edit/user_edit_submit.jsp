<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/home/CheckUser.jspf" %>

<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

//validate
//
String sPortletKey	= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("paneKey"))).trim())).trim();
String sUserName 	= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("username"))).trim();

String sFullName 	= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("fullname"))).trim();

String sLanguage	= StringUtils.nullToEmpty(request.getParameter("language"));
System.out.println("language type is " + sLanguage);
String sEmail 		= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("email"))).trim();

String sAddress1 	= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("address1"))).trim();
String sAddress2 	= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("address2"))).trim();
String sAddress3 	= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("address3"))).trim();
String sAddress4 	= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("address4"))).trim();

String sPhone 		= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("phone"))).trim();
String sWPhone 		= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("workphone"))).trim();
String sFax 		= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("fax"))).trim();
String sSMS 		= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("sms"))).trim();

String sDob 		= StringUtils.stripDangerousChars(StringUtils.nullToEmpty(request.getParameter("dob"))).trim();

String sQueryString = Functions.f_requestToQueryString(request, false);

// security type info
Vector[] avSecTypeFields = null;
String[] asSecTypeNames = request.getParameterValues("securitytype");
if(asSecTypeNames != null)
{
	avSecTypeFields = new Vector[asSecTypeNames.length];
	for(int nSecTypeIdx = 0; nSecTypeIdx < asSecTypeNames.length; nSecTypeIdx++)
	{
		avSecTypeFields[nSecTypeIdx] = new Vector();
		String[] asSecTypeFieldNames  = request.getParameterValues("securitytypefieldnames" + nSecTypeIdx);
		String[] asSecTypeFieldValues = request.getParameterValues("securitytypefieldvalues" + nSecTypeIdx);
		if(asSecTypeFieldNames != null)
		{
			for(int nSecTypeFieldIdx = 0; nSecTypeFieldIdx < asSecTypeFieldNames.length ;nSecTypeFieldIdx++)
			{
				avSecTypeFields[nSecTypeIdx].add(new SecurityField(asSecTypeFieldNames[nSecTypeFieldIdx], asSecTypeFieldValues[nSecTypeFieldIdx]));
			}
		}
	}
}


//
//Check existence of required fields
//
if(!StringUtils.strValid(sUserName, 1024) )
{
	CurrentUser.setAttribute(sPortletKey + "message", "Invalid username");
	response.sendRedirect(new StringBuffer(request.getContextPath())
								   .append("/user/home/home.jsp?paneKey=")
								   .append(sPortletKey)
								   .append(sQueryString)
								   .append("&")
								   .append(sPortletKey)
								   .append("=showMessage&#")
								   .append(sPortletKey)
								   .toString()
						 );
	out.flush();
	return;
}

if(sEmail.length() <= 5 || sEmail.indexOf("@") == -1)
{
	//Show error on pane
	CurrentUser.setAttribute(sPortletKey + "message", rb.getString("user_edit_submit.invalidEmail"));
	response.sendRedirect(new StringBuffer(request.getContextPath())
								   .append("/user/home/home.jsp?paneKey=")
								   .append(sPortletKey)
								   .append(sQueryString)
								   .append("&")
								   .append(sPortletKey)
								   .append("=showMessage&#")
								   .append(sPortletKey)
								   .toString()
						 );
	out.flush();
	return;
}

//edit and save a user, Copy default user extended field into new user and read
//
try
{
	CurrentUser.batchReset();
	CurrentUser.setExtendedField("fullname", sFullName);
	CurrentUser.setExtendedField("emailaddress", sEmail);

	CurrentUser.setExtendedField("DRELanguageType", lookupLanguageType(CurrentPortal, sLanguage));

	CurrentUser.setExtendedField("DOB", sDob);
	CurrentUser.setExtendedField("ADDRESS1", sAddress1);
	CurrentUser.setExtendedField("ADDRESS2", sAddress2);
	CurrentUser.setExtendedField("ADDRESS3", sAddress3);
	CurrentUser.setExtendedField("ADDRESS4", sAddress4);

	CurrentUser.setExtendedField("HOMENO", sPhone);
	CurrentUser.setExtendedField("WORKNO", sWPhone);
	CurrentUser.setExtendedField("FAXNUMBER", sFax);
	CurrentUser.setExtendedField("SMSNUMBER", sSMS);

	if(asSecTypeNames != null)
	{
		CurrentUser.setSecurityTypeInfo(asSecTypeNames, avSecTypeFields);
	}

	CurrentUser.batchSend();
}
catch(Exception e)
{
	//Show error on pane
	response.sendRedirect(new StringBuffer(request.getContextPath())
								   .append("/user/home/home.jsp?paneKey=")
								   .append(sPortletKey)
								   .append(sQueryString)
								   .append("&")
								   .append(sPortletKey)
								   .append("=showMessage&message=")
								   .append(HTTPUtils.URLEncode("could not create user " + e.getMessage(), request.getCharacterEncoding()))
								   .append("&#")
								   .append(sPortletKey)
								   .toString()
						 );
	out.flush();
	return;
}

CurrentUser.setAttribute("headmessage", rb.getString("user_edit_submit.changeSaved") );
response.sendRedirect(new StringBuffer(request.getContextPath())
							   .append("/user/home/home.jsp?paneKey=")
							   .append(sPortletKey)
							   .append("&delete=0")
							   .toString()
					 );
%>

<%!
private String lookupLanguageType(PortalInfo portal, String sLanguageDisplayName)
{
	String sLanguageType = "";

	String[] saLanguageDisplayNames = StringUtils.split(portal.readString(portal.LANGUAGE_SECTION, "LanguageTypesDisplayNames", "english"), ",");
	String[] saLanguageTypes = StringUtils.split(portal.readString(portal.LANGUAGE_SECTION, "LanguageTypes", "english"), ",");

	int nNameIdx = StringUtils.isStringInStringArray(saLanguageDisplayNames, sLanguageDisplayName, false);
	if(nNameIdx != -1)
	{
		sLanguageType = saLanguageTypes[nNameIdx];
	}
	return sLanguageType;
}
%>