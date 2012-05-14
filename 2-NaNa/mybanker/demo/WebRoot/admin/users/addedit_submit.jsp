<%@ page import="java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.UAClient.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/home/admin_checkUser.jspf" %>

<%
RolesInfo CurrentRoles = CurrentPortal.getRolesObject();
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();
// read user info from form
String sUserName 	= request.getParameter("username");
String sPassword1 = HTMLUtils.safeRequestGet(request, "password1", "").trim();
String sPassword2 = HTMLUtils.safeRequestGet(request, "password2", "").trim();
String sFullName 	= HTMLUtils.safeRequestGet(request, "fullname", "").trim();
String sEmail 		= HTMLUtils.safeRequestGet(request, "email", "").trim();
String sAddress1 	= HTMLUtils.safeRequestGet(request, "address1", "").trim();
String sAddress2 	= HTMLUtils.safeRequestGet(request, "address2", "").trim();
String sAddress3 	= HTMLUtils.safeRequestGet(request, "address3", "").trim();
String sAddress4 	= HTMLUtils.safeRequestGet(request, "address4", "").trim();
String sHomeNo 		= HTMLUtils.safeRequestGet(request, "homeno", "").trim();
String sWorkNo 		= HTMLUtils.safeRequestGet(request, "workno", "").trim();
String sFax 			= HTMLUtils.safeRequestGet(request, "fax", "").trim();
String sSMS 			= HTMLUtils.safeRequestGet(request, "sms", "").trim();
String sRoleName 	= HTMLUtils.safeRequestGet(request, "rolename", CurrentSecurity.getKeyByName("BaseRole", "everyone"));
String sDob 			= HTMLUtils.safeRequestGet(request, "dob", "");
boolean bEditUser 	= HTMLUtils.safeRequestGet(request, "action", "add").equals("edit"); // set to true if new user
String sOldUserName = bEditUser ? HTMLUtils.safeRequestGet(request, "oldusername", "") : sUserName;
String sQueryString = Functions.f_requestToQueryString(request, true);

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

String sAddURL = request.getContextPath() + "/admin/users/addedit.jsp";
String sMenuURL = request.getContextPath() + "/admin/users/editdisplay.jsp";

//
// validate form parameters
//
if( !StringUtils.strValid(sUserName, CurrentPortal.readInt( CurrentPortal.ADMIN_SECTION, "MaxUserNameLength", 256 )) )
{
	CurrentUser.setAttribute("message", "You need to supply a username and a password" );
	response.sendRedirect(sAddURL + sQueryString );
	out.flush();
	return;
}
if(!sPassword1.equals(sPassword2))
{
	//Show error on pane
	CurrentUser.setAttribute("message", "Your two passwords did not match" );
	response.sendRedirect(sAddURL + sQueryString );
	out.flush();
	return;
}
if(sEmail.length() <= 5 || sEmail.indexOf("@") == -1)
{
	//Show error on pane
	CurrentUser.setAttribute("message", "Please enter a valid email address" );
	response.sendRedirect(sAddURL + sQueryString );
	out.flush();
	return;
}

//
//Attempt to read user
//
UserInfo user = null;
try
{
	user = CurrentPortal.getUserInfo( sOldUserName );
}
catch(Exception e)
{
	String err = e.getMessage();
	//
	//if editing, user must exist
	//
	boolean bFound = err.toLowerCase().indexOf("not be found") == -1;
	if( (bEditUser && !bFound) || (!bEditUser && bFound) )
	{
		CurrentUser.setAttribute( "message", err );
		response.sendRedirect(sAddURL + sQueryString );
		return;
	}
}

if(bEditUser)
{
	//Edit and save a user
	try
	{
		// remove any alterations to the user that may have been stored
		user.batchReset();
		// set new user details
		user.setExtendedField("FullName", sFullName);
		user.setExtendedField("DOB", sDob);
		user.setExtendedField("ADDRESS1", sAddress1);
		user.setExtendedField("ADDRESS2", sAddress2);
		user.setExtendedField("ADDRESS3", sAddress3);
		user.setExtendedField("ADDRESS4", sAddress4);
		user.setExtendedField("HOMENO", sHomeNo);
		user.setExtendedField("WORKNO", sWorkNo);
		user.setExtendedField("FAXNUMBER", sFax);
		user.setExtendedField("SMSNUMBER", sSMS);
		user.setExplicitField("EmailAddress", sEmail);
		if(asSecTypeNames != null)
		{
			user.setSecurityTypeInfo(asSecTypeNames, avSecTypeFields);
		}

		// send new details to IDOL
		user.batchSend();

		//Ensure user is in the base role
		CurrentRoles.addUserToRole( sOldUserName,
			CurrentSecurity.getKeyByName("BaseRole", "everyone") );

		// if the username is  being changed, need to copy the old user using the new username and
		// then remove the old user entry
		if( !sOldUserName.equals( sUserName ) )
		{
			try
			{
				CurrentPortal.copyUser(sOldUserName, sUserName, false);
				CurrentPortal.removeUsers(new String[]{sOldUserName});
			}
			catch(Exception e1)
			{
				//Show error on pane
				CurrentUser.setAttribute( "message", "could not rename user: &nbsp;" + e1.getMessage() );
				response.sendRedirect( sAddURL + sQueryString );
				return;
			}
		}
	}
	catch(Exception e)
	{
		//Show error on pane
		CurrentUser.setAttribute( "message", "could not modify user: &nbsp;" + e.getMessage() );
		response.sendRedirect( sAddURL + sQueryString );
		return;
	}

	CurrentUser.setAttribute( "message", "Your changes have been saved");
	response.sendRedirect( sMenuURL + sQueryString + "&oldaction=");
	return;
}
else
{
	//Create user
	//
	Hashtable htFields = new Hashtable();
	htFields.put("FullName", sFullName);
	htFields.put("DOB", sDob);
	htFields.put("ADDRESS1", sAddress1);
	htFields.put("ADDRESS2", sAddress2);
	htFields.put("ADDRESS3", sAddress3);
	htFields.put("ADDRESS4", sAddress4);
	htFields.put("HOMENO", sHomeNo);
	htFields.put("WORKNO", sWorkNo);
	htFields.put("FAXNUMBER", sFax);
	htFields.put("SMSNUMBER", sSMS);
	htFields.put("InitialRoleName", sRoleName);
	user = new UserInfo(CurrentPortal, sUserName, sPassword1, htFields, 0);

	if(asSecTypeNames != null && avSecTypeFields != null)
	{
		user.setSecurityTypeInfo(asSecTypeNames, avSecTypeFields);
	}

	try
	{
		user.add();
		user.setExplicitField("EmailAddress", sEmail);
		//
		//Ensure user is in the base role and not in guest role
		//
		CurrentRoles.addUserToRole( sUserName, sRoleName );
		CurrentRoles.removeUserFromRole( sUserName,CurrentSecurity.getKeyByName("GuestRole", "guest"));
	}
	catch(Exception e)
	{
		//Show error on pane
		CurrentUser.setAttribute( "message", "could not create user: &nbsp; " + e.getMessage());
		response.sendRedirect( sAddURL + sQueryString );
		return;
	}

	CurrentUser.setAttribute( "message", "The user " + sUserName + " has been added");
	CurrentPortal.Log("Created new user: " + sUserName);
	response.sendRedirect( sMenuURL + sQueryString );
}//end of edit / create test
%>
