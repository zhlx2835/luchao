<%@ page import = "java.util.*"%>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.utilities.*"%>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants" %>
<%@ page import = "com.autonomy.aci.AciConnection" %>
<%@ page import = "com.autonomy.aci.ActionParameter" %>
<%@ page import = "com.autonomy.aci.AciAction" %>
<%@ page import = "com.autonomy.aci.services.IDOLService" %>
<%@ page import = "com.autonomy.aci.AciConnectionDetails" %>
<%@ page import = "com.autonomy.aci.AciResponse" %>
<%@ page import = "com.autonomy.aci.exceptions.ServerNotAvailableException" %>
<%@ page import = "com.autonomy.aci.exceptions.AciException" %>

<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

final String PORTLET_NAME = "2DMap";

// Set up services object
PortalService service = ServiceFactory.getService(request, response, PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

String  stylesheetURL = service.makeLink("AutonomyImages");
%>

<html>
<head>
	<link rel="stylesheet" type="text/css" href="<%= stylesheetURL %>/autonomyportlets.css">
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
</head>

<body STYLE="background-color:transparent">
<%
if(service != null)
{
	/************************    SETTINGS    ***********************/

	// Get user details
	String sUsername = (service.getUser()).getName();

	// Form names
	String fJobChoice	= service.makeFormName("JobChoice");

	// Parameter names
	String mJobIndex	= service.makeParameterName("mJobIndex");

	// Grab configuration parameter details
	String[] asJobNames 	= StringUtils.split((String)service.getParameter("ClusterJobNames"), ",");
	String[] asJobTitles	= StringUtils.split((String)service.getParameter("ClusterJobTitles"), ",");
	int nClassTimeout	= StringUtils.atoi( (String)service.getParameter("ClassTimeout"), 10000 );

	AciConnectionDetails classDetails = service.getIDOLService().getCategoryConnectionDetails();
	AciConnectionDetails userDetails = service.getIDOLService().getUserConnectionDetails();
	AciConnectionDetails dreDetails = service.getIDOLService().getQueryConnectionDetails();

	String sCSHost = classDetails.getHost();
	String sCSPort = String.valueOf(classDetails.getPort());
	String sUAHost = userDetails.getHost();
	String sUAPort 	= String.valueOf(userDetails.getPort());
	String sDREHost	= dreDetails.getHost();
	String sDREPort	= String.valueOf(dreDetails.getPort());

	// Grab request parameters
	int iJobIndex   = StringUtils.atoi( service.getRequestParameter(mJobIndex), 0 );

	// derive the job name from job index and job names array
	String sJobName = iJobIndex < asJobNames.length ? asJobNames[iJobIndex] : asJobNames[0];

	// ClassificationServer settings

	/*
	 *  This is a hardcoded value. Should just retrieve actual number of documents in each cluster but a old
	 *  bug in Category will prevent this from working. So keep it this way for now.
	 */

	int nMaxDocsPerCluster = 5000;

	// map position and size
	int nMapHeight = StringUtils.atoi((String)service.getParameter("MapHeight"), 400);
	int nMapWidth  = StringUtils.atoi((String)service.getParameter("MapWidth"), 400);
	int nMapTop    = 0;
	int nMapLeft   = 0;
	// time details
	int nMaxOffset = 14;
	int nMinOffset = 0;

	// This overides the above to make the map smaller as required by the new PIB GUI design
	nMapHeight=320;
	nMapWidth=320;

	// iframe name for cluster documents to appear in
	String sMapDocsTargetFrame	= service.makeParameterName("iframe_2dmap");
	// Remove full stops (for application servers which generate unique names with full stops)
	sMapDocsTargetFrame = sMapDocsTargetFrame.replace('.','_');

	String sMapDocsTargetPage = service.makeLink("clustertext.jsp");
	int nMapDocsFrameHeight   = nMapHeight;
	int nMapDocsFrameWidth    = (int)(nMapWidth * 1.58);

	// node sizes
	int nNodeHeight      = 8;
	int nNodeWidth       = 8;
	int nNodeBorderWidth = 1;
	//<--code replacement tag id=weblogic_whitespace_init-->

	// distance mouse must be from a cluster to activate its tooltip
	int nMaxDistFromCluster     = 15;

	// tooltip
	int nToolTipBorderWidth     = 1;
	int nMapToolTipMouseXOffset = 15;
	int nMapToolTipMouseYOffset = -50;


	// colours
	String sToolTipBGColor         = "#FFFF00";
	String sToolTipTextColor       = "#000000";
	String sToolTipBorderColor     = "#000000";
	String sNodeBGBaseColor        = "#FF0000";
	String sNodeBGHoverColor       = "#0000FF";
	String sNodeBGSelectColor      = "#00FF00";
	String sNodeBorderColor        = "#000000";
	String sHighlightColor         = "#DDDDDD";
	String sSelectedHighlightColor = "#FFFFFF";

	// default pic size returned from server is 512
	int nDefaultMapSize			= 512;

	String sError = null;

	/***************************************************************/


	String sTitleTableStyle = new StringBuffer()
	                                   .append("background-color:").append(sToolTipBGColor)
	                                   .append(";color:").append(sToolTipTextColor)
	                                   .append(";border:solid ").append(sToolTipBorderColor)
	                                   .append(" ").append(nToolTipBorderWidth).append("px")
	                                   .append(";font-size:9pt")
	                                   .append(";font-family:sans-serif")
	                                   .toString();

	String sImageStyle = "position:relative;z-Index:1";

	String sTitleStyle = "position:absolute;z-Index:4;visibility:hidden";

	String sMapIFrameStyle = new StringBuffer()
                                      .append("position:relative")
                                      .append(";height:").append(nMapDocsFrameHeight)
                                      .append(";width:").append(nMapDocsFrameWidth)
                                      .toString();

	String sClusterNodeStyle = new StringBuffer()
	                                    .append("position:absolute")
	                                    .append(";z-Index:2")
	                                    .append(";background-color:").append(sNodeBGBaseColor)
	                                    .append(";border:solid ").append(sNodeBorderColor)
	                                    .append(" ").append( nNodeBorderWidth).append("px")
	                                    .append(";font-size:1px") 		// otherwise the min height of the div is one char high, whatever that size is
	                                    .append(";width:").append( nNodeWidth )
	                                    .append(";height:").append( nNodeHeight )
	                                    .append(";visibility:hidden")
	                                    .toString();

	String sClusterTitleStyle = "position:absolute;z-Index:3;visibility:hidden";

	String sClusterTextRequestParameters = new StringBuffer()
	                                                .append("&jobname=").append(sJobName)
	                                                .append("&csserver=").append(StringUtils.encryptString(sCSHost))
	                                                .append("&csport=").append(StringUtils.encryptString(sCSPort))
	                                                .append("&seshost=").append(StringUtils.encryptString(sUAHost))
	                                                .append("&sesport=").append(StringUtils.encryptString(sUAPort))
	                                                .append("&drehost=").append(StringUtils.encryptString(sDREHost))
	                                                .append("&dreport=").append(StringUtils.encryptString(sDREPort))
	                                                .append("&username=").append(StringUtils.encryptString(sUsername))
	                                                .append("&numresults=").append(nMaxDocsPerCluster)
	                                                .append("&displaymax=").append("20")
	                                                .append("&mode=").append("2dmap")
	                                                .toString();


	Vector vTitles = new Vector();
	Vector vXCoords = new Vector();
	Vector vYCoords = new Vector();
	Vector vNumDocs = new Vector();


	try {

	// Declare connection, request and result objects
	AciConnection classServer = new AciConnection(classDetails);
	// Create the connection and command objects
	AciAction clusterResults = new AciAction("ClusterResults");

	ArrayList params = new ArrayList();
	params.add(new ActionParameter("sourcejobname", sJobName));
	params.add(new ActionParameter("numresults", nMaxDocsPerCluster));

	clusterResults.setParameters(params);
	clusterResults.usePostHTTPMethod();

	AciResponse acioResults = classServer.aciActionExecute(clusterResults);

	if(acioResults!=null)
	{
		int nClusters = 0;

		AciResponse acioThisCluster = acioResults.findFirstOccurrence("autn:cluster");

		while (acioThisCluster != null)
		{
			String sClusterTitle = acioThisCluster.getTagValue("autn:title", "");
			int nXCoord = StringUtils.atoi(acioThisCluster.getTagValue("autn:x_coord"), -1);
			int nYCoord = StringUtils.atoi(acioThisCluster.getTagValue("autn:y_coord"), -1);
			int nNumDocs = StringUtils.atoi(acioThisCluster.getTagValue("autn:numdocs"), -1);

			sClusterTitle = sClusterTitle.replace('\"','\'');

			// convert the coordinates to fit our map size
			nXCoord = (int) ((float)nXCoord * (float)nMapWidth / (float)nDefaultMapSize);
			nYCoord = (int) ((float)nYCoord * (float)nMapWidth / (float)nDefaultMapSize);

			vTitles.addElement(sClusterTitle);
			vXCoords.addElement(new Integer(nXCoord));
			vYCoords.addElement(new Integer(nYCoord));
			vNumDocs.addElement(new Integer(nNumDocs));

			nClusters++;
			acioThisCluster = acioThisCluster.next();
		}

		if(nClusters == 0)
		{
			sError = (rb.getString("autonomy2DMap.error.CSRunning")) + sCSHost + ":" + sCSPort + (rb.getString("autonomy2DMap.error.CSRunning.noClusters")) + sJobName;
		}
	}

	} // end of try
	catch(AciException acie)
	{

		if(acie instanceof ServerNotAvailableException)
		{
			sError = (rb.getString("autonomy2DMap.error.CSNotRunning")) + sCSHost + ":" + sCSPort;
		}
		else
		{
			sError = (rb.getString("autonomy2DMap.error.CSRunning")) + sCSHost + ":" + sCSPort + (rb.getString("autonomy2DMap.error.CSRunning.requestFailed"));
		}
	}

	if (sError != null)
	{
%>
		<font class="normal">
			<%=rb.getString("autonomy2DMap.error.internalError")%> <%= sError %>.<br/>
			<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
		</font>
<%
	}
	else
	{
%>
	<script type="text/javascript">

		document.expando=false;

		var bLoaded = Boolean(false);
<%
		PortletUtils.printJSArray("aTitles", vTitles, out, true);
		PortletUtils.printJSArray("aXCoords", vXCoords, out, false);
		PortletUtils.printJSArray("aYCoords", vYCoords, out, false);
		PortletUtils.printJSArray("aNumDocs", vNumDocs, out, false);
%>

		var nCurrentHoverCluster = -1;
		var nCurrentSelectedCluster = -1;

		function stringReplace(str, from, to)
		{
			var arr = str.split(from);
			var ret = arr[0];

			for (i=1;i<arr.length;i++)
			{
				ret = ret + to + arr[i];
			}

			return ret;
		}

		function getCurrentHover(nX, nY)
		{
			var nFound = -1;
			var nClosestDistSquared = <%=nMaxDistFromCluster * nMaxDistFromCluster%> + 1;

			for (i=0;i < <%=vTitles.size()%>;i++)
			{
				var nXDelta = nX - aXCoords[i];
				var nYDelta = nY - aYCoords[i];

				<%-- abs --%>
				nXDelta = (nXDelta > 0) ? nXDelta : -nXDelta;
				nYDelta = (nYDelta > 0) ? nYDelta : -nYDelta;

				<%-- first approximation check - no point measuring exact distance on every node --%>
				if (nXDelta < <%=nMaxDistFromCluster%> && nYDelta < <%=nMaxDistFromCluster%>)
				{
					var nDistSquared = (nXDelta*nXDelta) + (nYDelta*nYDelta);

					if (nDistSquared < nClosestDistSquared )
					{
						nFound = i;
						nClosestDistSquared = nDistSquared;
					}
				}
			}

			return nFound;
		}

		function checkMousePos(x)
		{
			var nFound = -1;

			if (x.length > 4 && x.substring(0,4) == "node")
			{
				// over a node itself
				nFound = x.substring(4);
			}
			else
			{
				nFound = getCurrentHover(window.pageXOffset, window.pageYOffset);
			}

			if (nCurrentHoverCluster != -1)
			{
				var nClusterNode = "clusternode" + nCurrentHoverCluster;

				var vClusterNode = document.getElementById(nClusterNode);

				var nClusterTitle = "clustertitle" + nCurrentHoverCluster;

				var vClusterTitle = document.getElementById(nClusterTitle);

				var vClusterBgSelectColor = "vClusterNode.style.backgroundColor='<%=sNodeBGSelectColor%>'";
				var vClusterBgBaseColor = "vClusterNode.style.backgroundColor='<%=sNodeBGBaseColor%>'";
				var vClusterVisibility = "vClusterTitle.style.visibility='hidden'";

				// reset old node to base colour
				if (nCurrentHoverCluster == nCurrentSelectedCluster)
				{
					eval(vClusterBgSelectColor);
				}
				else
				{
					eval(vClusterBgBaseColor);
				}

				// reset old title to hidden
				if (nCurrentHoverCluster != nFound)
				{
					eval(vClusterVisibility);
				}
			}

			if (nFound != -1 && bLoaded)
			{
				var nClusterNode = "clusternode" + nFound;

				var vClusterNode = document.getElementById(nClusterNode);

				var nClusterTitle = "clustertitle" + nFound;

				var vClusterTitle = document.getElementById(nClusterTitle);

				var vClusterBgHoverColor = "vClusterNode.style.backgroundColor='<%=sNodeBGHoverColor%>'";
				var vClusterVisibility = "vClusterTitle.style.visibility='visible'";

				eval(vClusterBgHoverColor);
				eval(vClusterVisibility);
			}

			nCurrentHoverCluster = nFound;
		}

		function selectCluster(x)
		{
			var nFound = -1;

			if (x.length > 4 && x.substring(0,4) == "node")
			{
				// over a node itself
				nFound = x.substring(4);
			}
			else
			{
				nFound = getCurrentHover(window.pageXOffset, window.pageYOffset);
			}

			if (nFound != -1 && bLoaded)
			{
				var nClusterNodeSelect = "clusternode" + nCurrentSelectedCluster;

				// reset old selected node to base colour
				if (nCurrentSelectedCluster != -1)
				{
					var vClusterNode = document.getElementById(nClusterNodeSelect);

					var vClusterBgBaseColor = "vClusterNode.style.backgroundColor='<%=sNodeBGBaseColor%>'";

					eval(vClusterBgBaseColor);
				}
				var nClusterNodeFound = "clusternode" + nFound;
				var vClusterNode = document.getElementById(nClusterNodeFound);
				var vClusterBgSelectColor = "vClusterNode.style.backgroundColor='<%=sNodeBGSelectColor%>'";

				// set new selected node to selected colour
				eval(vClusterBgSelectColor);

				nCurrentSelectedCluster = nFound;

				<%=sMapDocsTargetFrame%>.location.href = "<%=sMapDocsTargetPage%>?clusternum=" + nFound + "<%= sClusterTextRequestParameters %>";
			}
		}

		// gets called as soon as the 2dmap image has loaded - make all nodes visible
		function loaded()
		{
			var clusterimagevar=document.clusterimage;

			bLoaded = Boolean(true);

			for (i=0; i < <%=vTitles.size()%>; i++)
			{
				var nThisNodeTop = aYCoords[i] + clusterimagevar.offsetTop - <%=nNodeHeight/2%>;
				var nThisNodeLeft = aXCoords[i] + clusterimagevar.offsetLeft - <%=nNodeWidth/2%>;

				var nThisTitleTop = aYCoords[i] + clusterimagevar.offsetTop + <%=nMapToolTipMouseYOffset%>
				var nThisTitleLeft = aXCoords[i] + clusterimagevar.offsetLeft + <%=nMapToolTipMouseXOffset%>

				var nClusterTitle = "clustertitle" + i;

				var vClusterTitle = document.getElementById(nClusterTitle);

				var vClusterTitleTop = "vClusterTitle.style.top="+nThisTitleTop;
				var vClusterTitleLeft = "vClusterTitle.style.left="+nThisTitleLeft;

				var nClusterNode = "clusternode" + i;

				var vClusterNode = document.getElementById(nClusterNode);

				var vClusterNodeTop = "vClusterNode.style.top="+nThisNodeTop;
				var vClusterNodeLeft = "vClusterNode.style.left="+nThisNodeLeft;
				var vClusterNodeVisibility = "vClusterNode.style.visibility='visible'";

				// make sure they don't fall off the outside of the image
				var nTitleHeight = eval(vClusterTitle.offsetHeight);
				var nTitleWidth = eval(vClusterTitle.offsetWidth);

				if (i == 0)
				{
					//alert("titlewidth " + nTitleWidth + " titleheight " + nTitleHeight);
					//alert("before " + nThisTitleTop + " " + nThisTitleLeft);
				}

				// top
				if (aYCoords[i] + <%=nMapToolTipMouseYOffset%> <= 0)
				{
					nThisTitleTop = clusterimagevar.offsetTop + nTitleHeight + 10;
				}

				// bottom
				if (aYCoords[i] + <%=nMapToolTipMouseYOffset%> + nTitleHeight > <%=nMapHeight%>)
				{
					nThisTitleTop = clusterimagevar.offsetTop + aYCoords[i] - nTitleHeight - 10;
				}

				// right
				if (nThisTitleLeft + nTitleWidth > clusterimagevar.offsetLeft + <%=nMapWidth%> - 10)
				{
					nThisTitleLeft = clusterimagevar.offsetLeft + <%=nMapWidth%> - nTitleWidth - 10;
				}

				// left
				if (nThisTitleLeft < clusterimagevar.offsetLeft + 10)
				{
					nThisTitleLeft = clusterimagevar.offsetLeft + 10;
				}

				if (i == 0)
				{
					//alert("after " + nThisTitleTop + " " + nThisTitleLeft);
				}

				eval(vClusterTitleTop);
				eval(vClusterTitleLeft);

				eval(vClusterNodeTop);
				eval(vClusterNodeLeft);
				eval(vClusterNodeVisibility);
			}
		}

		function clearAll()
		{
			for (i=0; i < <%=vTitles.size()%>; i++)
			{
				eval("clustertitle" + i + ".style.visibility='hidden'");
				eval("clusternode" + i + ".style.backgroundColor='<%=sNodeBGBaseColor%>'");
			}
		}

	</script>

	<table border="0" cellspacing="5">
		<tr>
			<td>
				<table border="0" align="left">
					<tr>
						<td>
							<img name="clusterimage"
							     alt=""
							     height="<%=nMapHeight%>"
							     width="<%=nMapWidth%>"
							     style="<%=sImageStyle%>"
							     onMouseMove="javascript:checkMousePos('base');"
							     onMouseDown="javascript:selectCluster('base');"
							     src="<%=service.makeLink("proxy.jsp")%>?action=ClusterServe2DMap&amp;sourcejobname=<%=sJobName%>"
							>
						</td>

					</tr>
				</table>
			</td>

			<td>
				<iframe frameborder="0" width="<%=nMapDocsFrameWidth%>" height="<%=nMapDocsFrameHeight%>" name="<%= sMapDocsTargetFrame %>" allowtransparency="true" src="<%= sMapDocsTargetPage %>"></iframe>
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
		for (int nClusterIdx=0; nClusterIdx < vTitles.size() ;nClusterIdx++)
		{
			String sThisTitle = (String)vTitles.elementAt(nClusterIdx);
			int nNumDocs = ((Integer)vNumDocs.elementAt(nClusterIdx)).intValue();

			// window.event.cancelBubble=true stops the mouseover event from propagating up the div hierarchy,
			// so we can handle it as a node mouseover (offsetX and Y are relative to the div here)
%>
		<div id="clusternode<%= nClusterIdx %>"
			 style="<%= sClusterNodeStyle %>"
			 onMouseMove="javascript:checkMousePos('node<%= nClusterIdx %>');"
			 onMouseDown="javascript:selectCluster('node<%= nClusterIdx %>');"
			 >
			 <img src="<%=stylesheetURL%>/redsquare.gif" alt="red square" height="8" width="8"/>
			 <%--code replacement tag id=weblogic_whitespace--%>
		</div>

		<div id="clustertitle<%=nClusterIdx%>"
			  style="<%=sClusterTitleStyle%>"
			  onMouseMove="javascript:checkMousePos('title')"
			  >
			  	<table cellpadding="3">
			  		<tr>
			  			<td nowrap="nowrap" style="<%=sTitleTableStyle%>">
			  				<b><%= sThisTitle %></b>
			  				<br>
			  				<%= nNumDocs %> <%=rb.getString("autonomy2DMap.docs")%>
			  			</td>
			  		</tr>
			  	</table>
		</div>

<%
		}
	// This onload must be kept here for 2D Map to work with Websphere 5.0
	// for some reason it doesn't like the onload in the body tag
%>

	<script type="text/javascript">
		window.onload=loaded;
	</script>
<%
	}
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

</body>

</html>
