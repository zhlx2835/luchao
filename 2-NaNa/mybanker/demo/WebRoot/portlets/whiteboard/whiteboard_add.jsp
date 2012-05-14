<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/user/home/CheckUser.jspf" %>
<%

String sPortletKey 			= StringUtils.nullToEmpty(request.getParameter("paneKey"));
String sNewInput 			= request.getParameter("newinput");
int nMAXLINES 				= 15;

if (sNewInput != null && sNewInput.length() > 0)
{
	// encode input
	sNewInput = Base64.encodeString(sNewInput);

	String sWhiteboardFolder 	= request.getParameter("whiteboardfolder");
	String sWhiteboard 			= request.getParameter("whiteboard");

	// read in existing whiteboard into Vector (maintainable, but not efficient)
	Vector vLines = new Vector();

	String sContent = null;
	try
	{
		File fWhiteboard = new File(sWhiteboardFolder + File.separator + sWhiteboard + ".txt");
		FileInputStream fisWhiteboard = new FileInputStream(fWhiteboard);
		byte[] abWhiteboard = new byte[(int) fWhiteboard.length()];
		fisWhiteboard.read(abWhiteboard);
		fisWhiteboard.close();
		sContent = new String(abWhiteboard);

	}
	catch (Exception e)
	{
		CurrentPortal.LogThrowable( e );
	}
	if (sContent != null)
	{
		StringTokenizer st = new StringTokenizer(sContent, "\n");
		while (st.hasMoreElements() )
		{
			String sLine = (String) st.nextElement();
			if (StringUtils.strValid(sLine))
			{
				// add to vector
				vLines.addElement(sLine);
			}
		}
	}

	// add new line, format: user, date, text
	String sTheName = CurrentUser.getFullName();

	if( !StringUtils.strValid( sTheName ) )
	{
		sTheName = CurrentUser.getUserName();
	}

	vLines.addElement(sTheName + "," + DateUtils.formatEpochSeconds(System.currentTimeMillis() / 1000, "dd/MM/yyyy HH:mm") + "," + sNewInput);

	// limit vector size to maximum number for whiteboards
	while (vLines.size() > nMAXLINES)
	{
		// remove first line (i.e. first in - first out)
		vLines.removeElementAt(0);
	}

	// write out to file
	try
	{
		FileOutputStream fsOutput = new FileOutputStream(new File(sWhiteboardFolder + File.separator + sWhiteboard + ".txt"));
		// write out a welcome line
		for (int i = 0; i < vLines.size(); i++)
		{
			fsOutput.write( ((String)vLines.elementAt(i) + "\n").getBytes() );
		}
		fsOutput.close();
	}
	catch (Exception e)
	{
		CurrentPortal.LogThrowable( e );
	}
}
response.sendRedirect(request.getContextPath() + "/user/home/home.jsp#" + sPortletKey);
%>

