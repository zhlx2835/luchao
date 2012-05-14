<%@ page import="java.net.*,java.io.*" %>
<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.aci.*"%>
<%@ page import="javax.net.ssl.*"%>
<%@ page import="org.apache.commons.httpclient.HttpClient"%>
<%@ page import="org.apache.commons.httpclient.HttpMethod"%>
<%@ page import="org.apache.commons.httpclient.methods.GetMethod"%>
<%@ page import="org.apache.commons.httpclient.HttpStatus"%>

<%

	StandaloneService.markAsStandalone(session);
	PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

	String sAddress = service.getIDOLService().getCategoryConnectionDetails().getHost();
	String sPort = String.valueOf(service.getIDOLService().getCategoryConnectionDetails().getPort());
	String sProtocol = String.valueOf(service.getIDOLService().getCategoryConnectionDetails().getProtocol());

	String sAction = request.getParameter("action");
	String sJobName = request.getParameter("sourcejobname");
	String sStartDate = request.getParameter("startdate");
	String sEndDate = request.getParameter("enddate");

	String sURL = null;

	if(sAction != null)
	{
		if(sAction.equalsIgnoreCase("clustersgpicserve"))
		{
			sURL = sProtocol + "://" + sAddress + ":" + sPort + "/action=clustersgpicserve";
		}

		if(sAction.equalsIgnoreCase("clusterserve2dmap"))
		{
			sURL = sProtocol + "://" + sAddress + ":" + sPort + "/action=clusterserve2dmap";
		}

		if(sURL != null)
		{

			if(sJobName != null)
			{
				sURL += "&sourcejobname=" + sJobName;
			}

			if(sStartDate != null)
			{
				sURL += "&startdate=" + sStartDate;
			}

			if(sEndDate != null)
			{
				sURL += "&enddate=" + sEndDate;
			}

			HttpClient client = new HttpClient();
			GetMethod httpget = new GetMethod(sURL);
			InputStream inputStream = null;
			ServletOutputStream sos = null;

			try
			{
				int statusCode = client.executeMethod(httpget);
				if (statusCode == HttpStatus.SC_OK)
				{
					inputStream = httpget.getResponseBodyAsStream() ;
					if (inputStream != null)
					{

						String sContentType = httpget.getResponseHeader("Content-Type").toString();

				 		sos = response.getOutputStream();

						if (sos != null)
						{
							byte[] thisPart = new byte[4096];
							int nBytesRead = inputStream.read(thisPart);
							while (nBytesRead > -1)
							{
								sos.write(thisPart, 0, nBytesRead);
								nBytesRead = inputStream.read(thisPart);
							}
						}

						response.setContentType(sContentType);
					}
				}
			}
			catch (Exception e)
			{
				e.printStackTrace();
				out.print("error: " + e);
			}
			finally
			{
				if(sos != null)
				{
					sos.close();
				}
				if(inputStream != null)
				{
					inputStream.close();
				}
				if(httpget != null)
				{
					httpget.releaseConnection();
				}
			}
		}
	}
%>