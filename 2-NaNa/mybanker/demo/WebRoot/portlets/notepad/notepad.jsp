<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.client.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portal4.*" %>
<%@ page import="com.autonomy.portlet.constants.CommonConstants" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file = "/user/include/getPortletVars_include.jspf" %>

<html>
<head>
	<link rel="stylesheet" type="text/css" href="../../portalinabox.css">
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
</head>
<body>
<table width="100%" class="pContainer"><tr><td>

<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

final String PORTLET_NAME	= "Notepad";

// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, PORTLET_NAME);

// fully qualified URL for image folder
String  sImageURL	= service.makeLink("./AutonomyImages");

// Get user details
String sUsername = ((AutonomyPortalUser)service.getUser()).getName();

// notes file location and name
String sNotePadDir = BACKEND_LOCATION + File.separator + "notes" + File.separator;
String sNotePadName = sNotePadDir + sUsername+ "_notes.txt";

String sMessage = "";
int nMaxBytes = 1024;


// are there notes to save to file?
String sSubmittedNotes = request.getParameter("notes");
if(sSubmittedNotes != null)
{
	if(sSubmittedNotes.length() > nMaxBytes)
	{
		sMessage = rb.getString("notepad.error.tooLarge");
	}
	else
	{
		File fNotes = new File(sNotePadName);
		if(!fNotes.exists())
		{
			new File(sNotePadDir).mkdirs();
		}
		FileOutputStream notesFileOutputStream = new FileOutputStream(fNotes);
		try
		{
			notesFileOutputStream.write(sSubmittedNotes.getBytes(request.getCharacterEncoding()));
			notesFileOutputStream.close();
		}
		catch(Exception e)
		{
			CurrentPortal.LogThrowable(e);
		}
	}
}

// if some notes were submitted for saving then there is no need to read from file - we
// just use the submitted string
String sNotesToDisplay = "";
if(StringUtils.strValid(sSubmittedNotes))
{
	sNotesToDisplay = sSubmittedNotes;
}
else
{
	File fNotes = new File(sNotePadName);
	if(fNotes.exists())
	{
		FileInputStream noteFileInputStream = new FileInputStream(fNotes);

		try
		{
			byte[] abNotes = new byte[(int) fNotes.length()];
			noteFileInputStream.read(abNotes);
			noteFileInputStream.close();
			sNotesToDisplay = new String(abNotes, request.getCharacterEncoding());
		}
		catch(Exception e)
		{
			CurrentPortal.LogThrowable(e);
		}
	}
}

// display error message if there is one
if(StringUtils.strValid(sMessage))
{
%>
	<center>
		<font class="warning" >
			<%=sMessage%>
		</font>
	</center>
	<br /><br />
<%
}
%>
<table width="33%" cellspacing="5">
	<tr>
		<td align="right">
			<form name="notepadform" method="post">
				<div align="right">
					<textarea name="notes"
										rows="10"
										cols="50"
										wrap="soft"
										><%=StringUtils.XMLEscape(sNotesToDisplay)%></textarea>
				</div>

				<br />

				<a class="textButton" title="Save notes" href="javascript:notepadform.submit();">
					<%=rb.getString("notepad.save")%>
				</a>
			</form>
		</td>
	</tr>
</table>

</td></tr></table>
</body>
</html>