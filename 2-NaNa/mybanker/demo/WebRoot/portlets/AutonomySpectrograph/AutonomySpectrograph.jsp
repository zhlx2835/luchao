<%@ page import = "java.awt.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import = "com.autonomy.aci.AciAction"%>
<%@ page import = "com.autonomy.aci.AciResponse"%>
<%@ page import = "com.autonomy.aci.AciConnection"%>
<%@ page import = "com.autonomy.aci.ActionParameter"%>
<%@ page import = "com.autonomy.aci.AciConnectionDetails"%>
<%@ page import = "com.autonomy.aci.services.IDOLService"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//
// This jsp has one mode - it displays the Classification spectrograph applet
// duplicated width and height attributes are placed in iframe to fix iframe size bug in weblogic portal, and some other portals perhaps
//
final String PORTLET_NAME	= "Spectrograph";

// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

if(service != null)
{
	// Get user details
	String sUsername = (service.getUser()).getName();

	// Form names
	String fJobChoice	= service.makeFormName("JobChoice");

	// Parameter names
	String mJobIndex	= service.makeParameterName("mJobIndex");

	// Grab configuration parameter details
	String[] asJobNames 	= StringUtils.split((String)service.getParameter("ClusterJobNames"), ",");
	String[] asJobTitles	= StringUtils.split((String)service.getParameter("ClusterJobTitles"), ",");
	int nClassTimeout			= StringUtils.atoi((String)service.getParameter("ClassTimeout"), 10000);
	int nDisplayMax   	 	= StringUtils.atoi((String)service.getParameter("MaxNumberOfClusters"), 20);
	int nGraphHeight 			= StringUtils.atoi((String)service.getParameter("GraphHeight"), 400);
	int nGraphWidth  			= StringUtils.atoi((String)service.getParameter("GraphWidth"), 400);
	String sSGInterval    	= (String)service.getParameter("DaysToDisplay");

	AciConnectionDetails classDetails = service.getIDOLService().getCategoryConnectionDetails();
	AciConnectionDetails uaDetails = service.getIDOLService().getUserConnectionDetails();
	AciConnectionDetails dreDetails = service.getIDOLService().getQueryConnectionDetails();

	String sClassHost = classDetails.getHost();
	String sClassPort = String.valueOf(classDetails.getPort());
	String sUAHost 	= uaDetails.getHost();
	String sUAPort 	= String.valueOf(uaDetails.getPort());
	String sDREHost = dreDetails.getHost();
	String sDREPort = String.valueOf(dreDetails.getPort());

	// Grab request parameters
	int iJobIndex		= StringUtils.atoi( service.getRequestParameter(mJobIndex), 0 );

	// derive the job name from job index and job names array
	String sClusterJobName	= iJobIndex < asJobNames.length ? asJobNames[iJobIndex] : asJobNames[0];

	int nClassPort = StringUtils.atoi( sClassPort, -1);

	String sImageURL 		= service.makeLink("AutonomyImages");
	String sSGDocsTargetFrame 	= service.makeParameterName( "iframesgdocs" );
	String sSGPicTargetFrame	= service.makeParameterName( "iframesggraph" );

	// These are the dimensions for the spectograph for the new PIB design
	nGraphWidth = 320;
	nGraphHeight = 320;

	int aSGPicWidth = (int)(nGraphWidth *1.08);
	int aSGPicHeight = (int)(nGraphHeight*1.35);

	int sSGDocsWidth = (int)(nGraphWidth *1.45);
	int sSGDocsHeight = (int)(nGraphHeight*1.35);

	String sSGPicIFrameStyle	= new StringBuffer("position:relative")
							.append( ";height:" )	.append( aSGPicHeight )
							.append( ";width:" ) 	.append( aSGPicWidth)
						.toString();

	String sSGDocsIFrameStyle	= new StringBuffer("position:relative")
										.append( ";height:" )	.append( sSGDocsHeight )
										.append( ";width:" ) 	.append( sSGDocsWidth )
								  .toString();

	String sImageFrameSrc =	new StringBuffer( service.makeLink("./spectroImage.jsp") )
									.append( "?jobname=" )		.append( sClusterJobName )
									.append( "&csserver=" )		.append( StringUtils.encryptString( sClassHost ) )
									.append( "&csport=" )			.append( StringUtils.encryptString( sClassPort ) )
									.append( "&cstimeout=" )	.append( nClassTimeout )
									.append( "&seshost=" )		.append( StringUtils.encryptString(	sUAHost) )
									.append( "&sesport=" )		.append( StringUtils.encryptString(	sUAPort) )
									.append( "&drehost=" )		.append( StringUtils.encryptString(	sDREHost) )
									.append( "&dreport=" )		.append( StringUtils.encryptString(	sDREPort) )
									.append( "&username=" )		.append( StringUtils.encryptString(	sUsername ) )
									.append( "&graphwidth=" )	.append( nGraphWidth )
									.append( "&graphheight=" ).append( nGraphHeight )
									.append( "&sginterval=" )	.append( sSGInterval )
									.append( "&clusterframe=").append( sSGDocsTargetFrame )
									.append( "&offset=0" )
							.toString();
	%>
		<table width="100%" cellspacing="5" border="0">
			<tr>
				<td valign="center" rowspan="2">
					<font style="font-size:14;font-weight:bold" face="arial">
						C<br/>L<br/>U<br/>S<br/>T<br/>E<br/>R<br/>S<br/><br/><br/><br/>
					</font>
				</td>
				<td width="<%=aSGPicWidth%>">
					<iframe style="<%=sSGPicIFrameStyle%>"
							name="<%=sSGPicTargetFrame%>"
							width="<%=aSGPicWidth%>"
							height="<%=aSGPicHeight%>"
							src="<%=sImageFrameSrc%>"
							frameborder="0"
							scrolling="no"
							background-color="transparent"
							allowtransparency="true"
							>
					</iframe>

				</td>
				<td>
					<iframe style="<%=sSGDocsIFrameStyle%>"
							name="<%=sSGDocsTargetFrame%>"
							width="<%=sSGDocsWidth%>"
							height="<%=sSGDocsHeight%>"
							src="<%= service.makeLink("clustertext.jsp") %>"
							frameborder="0"
							background-color="transparent"
							allowtransparency="true"
							>
					</iframe>
				</td>
			</tr>
<%
			if (asJobNames.length > 1)
			{
%>
				<tr>
					<td>
						<form name="<%= fJobChoice %>" action="<%= service.makeFormActionLink(" ") %>" method="post">
							<%=rb.getString("autonomy2DMap.job")%> <select name="<%= mJobIndex %>" onChange="submit();">
<%
								for (int iIndex = 0; iIndex < asJobTitles.length; iIndex++)
								{
%>
									<option value="<%= iIndex %>"<%= iJobIndex == iIndex ? " selected" : ""%>><%= asJobTitles[iIndex] %></option>
<%
								}
%>
							</select>
						</form>
					</td>
				</tr>
<%
			}
%>
		</table>
	<%
}
else	//if(service != null)
{
%>
	<font class="normal">
		<%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("autonomy2DMap.error.internalError.erroMsg")%><br/>
		<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
	</font>
<%
}
%>
