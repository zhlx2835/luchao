<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.client.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ page import = "com.autonomy.aci.AciAction"%>
<%@ page import = "com.autonomy.aci.AciResponse"%>
<%@ page import = "com.autonomy.aci.AciConnection"%>
<%@ page import = "com.autonomy.aci.ActionParameter"%>
<%@ page import = "com.autonomy.aci.AciConnectionDetails"%>
<%@ page import = "com.autonomy.aci.services.IDOLService"%>
<%@ page import = "com.autonomy.aci.exceptions.AciException"%>
<%@ page import = "com.autonomy.aci.exceptions.ServerNotAvailableException"%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

	StandaloneService.markAsStandalone(session);
	PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

	//
	// this jsp makes a ClusterSGDocsServe or ClusterResults request to the classification server based
	// on the parameters sent to it.
	// if the request if successful, the response AciResponse object is placed in the session and two
	// further jsps, clusterText_header.jsp and clusterText_body.jsp, are called to handle the displaying of
	// the cluster results
	//

	String sUsernameEnc        = request.getParameter("username");
	String sClusterName        = request.getParameter("clustername");
	String sClusterNum         = request.getParameter("clusternum");
	String sStartDate          = request.getParameter("startdate");
	String sEndDate            = request.getParameter("enddate");
	String sJobname            = request.getParameter("jobname");
	String sClusterMode        = request.getParameter("mode");
	String sNumPossibleResults = request.getParameter("numresults");

	String sError = null;

	if (StringUtils.strValid(sUsernameEnc) 		&&
		StringUtils.strValid(sClusterNum) 		&&
		StringUtils.strValid(sJobname) 			&&
		StringUtils.strValid(sClusterMode)		&&
		StringUtils.strValid(sNumPossibleResults)
		)
	{
		AciResponse acioClusterDocs = null;
		// construct connection and command objects
		try
		{

		AciConnectionDetails classDetails = service.getIDOLService().getCategoryConnectionDetails();
		AciConnection classServer = new AciConnection(classDetails);
		classServer.setTimeout(10000);

		AciAction clusterCommand = null;

		ArrayList params = new ArrayList();
		params.add(new ActionParameter("SourceJobName",sJobname));
		params.add(new ActionParameter("Cluster",sClusterNum));
		params.add(new ActionParameter("DREOutputEncoding","utf8"));

		if( sClusterMode.equalsIgnoreCase("SG") )
		{
			clusterCommand = new AciAction("ClusterSGDocsServe");
			params.add(new ActionParameter("startdate",sStartDate));
		}
		else
		{
			clusterCommand = new AciAction("ClusterResults");
		}

		params.add(new ActionParameter("NumResults",sNumPossibleResults));

		// make cluster request
		clusterCommand.setParameters(params);
		acioClusterDocs = classServer.aciActionExecute(clusterCommand);
		}
		catch(AciException acie)
		{
		  sError = "Some error occurred when doing cluster command";
		}
		if(sError==null && acioClusterDocs!=null)
		{
			// put response AciResponse in session for clusterText_body.jsp to use
			session.setAttribute("acioClusterResult",(Object)acioClusterDocs);

			String sClusterTitle = acioClusterDocs.getTagValue("autn:title", "Unknown");

			// build '+' separated list of cluster terms and weights. Limit to 30 otherwise parameters will get too long
			StringBuffer sbTermsAndWeights = new StringBuffer("");
			AciResponse acioTerm = acioClusterDocs.findFirstOccurrence("autn:term");
			int i=0;
			while( acioTerm != null && i<30)
			{
				String sTermValue = acioTerm.getValue();
				if( StringUtils.strValid(sTermValue) )
				{
					sbTermsAndWeights.append(sTermValue).append("+");
				}
				i++;
				acioTerm = acioTerm.next();
			}

			// get date into friendly format
			long lnStartDate = 0;
			long lnEndDate = 0;
			try
			{
				lnStartDate = new Long(sStartDate).longValue();
				lnEndDate = new Long(sEndDate).longValue();
			}
			catch(NumberFormatException nfe)
			{
			}

			String[] saMonths = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
			GregorianCalendar gc = (GregorianCalendar)GregorianCalendar.getInstance();

			// from date
			gc.setTime(new Date(lnStartDate * 1000));
			int nDay 	= gc.get(gc.DAY_OF_MONTH);
			int nMonth 	= gc.get(gc.MONTH);
			int nYear 	= gc.get(gc.YEAR);
			String sFrom = nDay + " " + saMonths[nMonth] + " " + nYear;

			// to date
			gc.setTime(new Date(lnEndDate * 1000));
			nDay 	= gc.get(gc.DAY_OF_MONTH);
			nMonth 	= gc.get(gc.MONTH);
			nYear 	= gc.get(gc.YEAR);
			String sTo = nDay + " " + saMonths[nMonth] + " " + nYear;

			StringBuffer sbCommonParameters = new StringBuffer();
			//add session variable names info
			sbCommonParameters.append("?username=");
			sbCommonParameters.append( sUsernameEnc );

			// build up request string for clusterText_header.jsp
			StringBuffer sbHeadURL = new StringBuffer("clusterText_head.jsp");
			sbHeadURL.append(sbCommonParameters.toString());
			sbHeadURL.append("&title=");
			sbHeadURL.append(URLEncoder.encode(sClusterTitle, "UTF8"));
			sbHeadURL.append("&startdate=");
			sbHeadURL.append( sFrom );
			sbHeadURL.append("&enddate=");
			sbHeadURL.append( sTo );
			sbHeadURL.append("&numdocs=");
			sbHeadURL.append( acioClusterDocs.getTagValue("autn:numdocs", "") );
			sbHeadURL.append("&terms=");
			sbHeadURL.append( StringUtils.encryptString( sbTermsAndWeights.toString() ) );
			sbHeadURL.append("&mode=");
			sbHeadURL.append( sClusterMode );

			// build up request string for clusterText_header.jsp
			StringBuffer sbBodyURL = new StringBuffer("clusterText_body.jsp");
			sbBodyURL.append(sbCommonParameters.toString());

			// call displaying jsps
%>
			<html>
				<head><title></title></head>
				<body style="background-color:transparent; margin:0px;">
					<iframe style="height:20%; width:100%;" frameborder="0" name="header" src="<%= StringUtils.XMLEscape(sbHeadURL.toString()) %>" scrolling="no" allowtransparency="true"></iframe>
					<iframe style="height:80%; width:100%;" frameborder="0" name="body" src="<%= StringUtils.XMLEscape(sbBodyURL.toString()) %>" allowtransparency="true"></iframe>
				</body>
			</html>
<%
		}
		else
		{
			// no response.
%>
			<html><body>
			<h4>Request was </h4>
<%
			HTMLUtils.displayRequest(out, request);
			if( acioClusterDocs != null )
			{
%>
				<h3>ClassificationServer produced an error</h3>
				<table>
					<tr>
						<td>Error</td>
						<td><%= acioClusterDocs.getTagValue("errorstring") %></td>
					</tr>
					<tr>
						<td>Description </td>
						<td><%= acioClusterDocs.getTagValue("errordescription") %></td>
					</tr>
				</table>
<%
			}
			else
			{
%>
				<h3>There was no response from ClassificationServer</h3>
<%
			}
%>
			Please contact your web administrator is this problem persists.
			</body><html>
<%
		}
	}
	else
	{
		// some request parameters missing.
%>
			<html>
				<head><title></title></head>
				<body style="background-color:transparent;">
				</body>
			</html>
<%
	}
%>

