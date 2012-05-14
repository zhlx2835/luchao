<%@ page import = "com.autonomy.aci.AciConnection" %>
<%@ page import = "com.autonomy.aci.AciResponse" %>
<%@ page import = "com.autonomy.utilities.AutnHttpURLConnection" %>
<%@ page import = "com.autonomy.utilities.ByteArrayBuffer" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>
<%@ page import = "com.autonomy.APSL.StandaloneService" %>
<%@ page import = "com.autonomy.APSL.PortalService" %>
<%@ page import = "com.autonomy.APSL.ServiceFactory" %>
<%@ page import = "java.net.URL" %>
<%@ page import = "java.net.HttpURLConnection" %>
<%@ page import = "java.io.InputStream" %>
<%@ page import = "javax.servlet.ServletOutputStream" %>


<%
// construct service
StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "docmanserver");

// read doc ref and filename and username from request
String sUrl = service.getSafeRequestParameter("url", "");
String sFilename = service.getSafeRequestParameter("filename", "");
String sUsername = StringUtils.decryptString(service.getSafeRequestParameter("username", ""));	

// form download URI
StringBuffer sbDownloadURI = new StringBuffer("/action=DocumentRetrieve&Document=");
sbDownloadURI.append(sUrl);
sbDownloadURI.append("&user=");
sbDownloadURI.append(sUsername);
sbDownloadURI.append("&group=people");

// read DocMan Server host and port from config
String sDocManHost = service.readConfigParameter("DocmanHost", "");
int nDocManPort = StringUtils.atoi(service.readConfigParameter("DocmanPort", ""), 0);

// try to download document
URL url = new URL("http", sDocManHost, nDocManPort, sbDownloadURI.toString());
HttpURLConnection conn = (HttpURLConnection)url.openConnection();
if (conn != null)
{
	String sContentType = conn.getContentType();
	if(!sContentType.startsWith("text/") || sContentType.equals("text/html"))
	{
		// document - set content header and dump out response from DocMan to the browser
		response.setContentType(sContentType);	
		response.setHeader("Content-disposition", "attachment; filename=" + sFilename);			

		InputStream connectionInput = conn.getInputStream();		
		ServletOutputStream responseOutput = response.getOutputStream();						
		if(responseOutput != null)
		{
			byte[] thisPart = new byte[4096];
			int nBytesRead = connectionInput.read(thisPart);
			while(nBytesRead > -1)
			{
				responseOutput.write(thisPart, 0, nBytesRead);
				nBytesRead = connectionInput.read(thisPart);
			}
		}
		responseOutput.flush();
		responseOutput.close();
	}
	else
	{
		// aci error response - try to read cause and display error message
		ByteArrayBuffer babErrorResponse = new ByteArrayBuffer(conn.getInputStream(), 4096);
		AciResponse aciErrorResponse = AciConnection.parseResponseString(babErrorResponse.toString());
		
		String sErrorString = "ERROR";
		String sErrorDescription = "unable to determine error";
		if(aciErrorResponse != null)
		{
			sErrorString = aciErrorResponse.getTagValue("errorstring", "");
			sErrorDescription = aciErrorResponse.getTagValue("errordescription", "");
		}
%>
		<html>
			<head>
				<meta http-equiv="content-type" content="text/html;charset=utf-8" />
				<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() + "/portalinabox.css" %>" />
				<title>Error in downloading original DocMan Server document</title>
			</head>
			<body>
				<table class="pContainer" width="100%" border="0">
					<tr>
						<td>
							<center>
								<font class="normalbold">
									DocMan document download error
								</font>
							</center>
						</td>
					</tr>
					<tr>
						<td>
							<font class="normal">
								Sorry, the document: "<%= StringUtils.XMLEscape(sFilename) %>" could not be downloaded.
							</font>
						</td>
					</tr>
					<tr>
						<td>
							<font class="normal">
								Reason - 
							</font>
							<font class="warning">
								<%= StringUtils.XMLEscape(sErrorString) %>: <%= StringUtils.XMLEscape(sErrorDescription) %>
							</font>
						</td>
					</tr>
				</table>
			</body>
		</html>
<%
	}	
}
%>
