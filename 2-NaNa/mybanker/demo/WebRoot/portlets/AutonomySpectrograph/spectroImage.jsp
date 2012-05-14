<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import = "com.autonomy.aci.AciAction"%>
<%@ page import = "com.autonomy.aci.AciResponse"%>
<%@ page import = "com.autonomy.aci.AciConnection"%>
<%@ page import = "com.autonomy.aci.ActionParameter"%>
<%@ page import = "com.autonomy.aci.AciConnectionDetails"%>
<%@ page import = "com.autonomy.aci.services.IDOLService"%>
<%@ page import = "com.autonomy.aci.exceptions.AciException"%>
<%@ page import = "com.autonomy.aci.exceptions.ServerNotAvailableException"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
response.setContentType("text/html; charset=utf-8");

StandaloneService.markAsStandalone(session);

PortalService service = ServiceFactory.getService((Object)request, (Object)response, "Spectrograph");

//get Locale information from session
String sLocale =(String)session.getAttribute(CommonConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CommonConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CommonConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

String sUsernameEnc			= request.getParameter("username");
String sClusterJobName 	= request.getParameter("jobname");
String sGraphHeight			= request.getParameter("graphheight");
String sGraphWidth			= request.getParameter("graphwidth");
String sOffset					= request.getParameter("offset");
String sSGInterval			= request.getParameter("sginterval");
String sSGDocsFrame			= request.getParameter("clusterframe");


if(StringUtils.strValid(sUsernameEnc) 		&&
	 StringUtils.strValid(sClusterJobName) 	&&
	 StringUtils.strValid(sGraphHeight)     &&
	 StringUtils.strValid(sGraphWidth)      &&
	 StringUtils.strValid(sSGInterval)      &&
	 StringUtils.strValid(sOffset)
	)
{
	int nOffset 			= StringUtils.atoi(sOffset, 0);
	int nSGInterval 	= StringUtils.atoi(sSGInterval, 7);
	int nGraphHeight 	= StringUtils.atoi(sGraphHeight, 400);
	int nGraphWidth 	= StringUtils.atoi(sGraphWidth, 400);

    Vector vIDs 		= new Vector();
	Vector vTitles 		= new Vector();
	Vector vStartDates 	= new Vector();
	Vector vEndDates 	= new Vector();
	Vector vX1 			= new Vector();
	Vector vX2 			= new Vector();
	Vector vX1All 		= new Vector();
	Vector vX2All 		= new Vector();
	Vector vY1 			= new Vector();
	Vector vY2 			= new Vector();
	Vector vNumDocs 	= new Vector();
	Vector vNewSlicePositions = new Vector();

	String sClassHost 		= null;
	String sClassPort 		= null;
	String sClassHostEnc 	= null;
	String sClassPortEnc 	= null;
	String sUAHostEnc 		= null;
	String sUAPortEnc 		= null;
	String sDREHostEnc 		= null;
	String sDREPortEnc 		= null;
    String sClusterTextRequestParameters = null;
    String sError = null;

	// set styles etc
	%><%@ include file="spectroSettings_include.jspf" %><%

    final int catVerWStructuredXML = 508; //from version 508, Component Category has structuredXML function
    int categoryVersion = getCategoryVersion(service);

    if(categoryVersion<catVerWStructuredXML ){ //if Category has StructuredXML function, add this parameter

        // retrieve and store spectrograph data
        try{

        AciConnectionDetails classDetails = service.getIDOLService().getCategoryConnectionDetails();
        AciConnectionDetails uaDetails = service.getIDOLService().getUserConnectionDetails();
        AciConnectionDetails dreDetails = service.getIDOLService().getQueryConnectionDetails();

		AciConnection classServer = new AciConnection(classDetails);
		classServer.setRetries(1);

		ArrayList params = new ArrayList();
		params.add(new ActionParameter("sourcejobname", sClusterJobName));
		params.add(new ActionParameter("startdate", nStart));
		params.add(new ActionParameter("enddate", nEnd));
		params.add(new ActionParameter("StructuredXML","true"));
		AciAction clusterSGDataServe = new AciAction("ClusterSGDataServe");

		clusterSGDataServe.usePostHTTPMethod();
		clusterSGDataServe.setParameters(params);

		AciResponse acioResults =null;
		acioResults = classServer.aciActionExecute(clusterSGDataServe);

     	sClassHost = classDetails.getHost();
        sClassPort = String.valueOf(classDetails.getPort());
        sClassHostEnc = StringUtils.encryptString( sClassHost);
        sClassPortEnc = StringUtils.encryptString( String.valueOf(sClassPort));
        sUAHostEnc = StringUtils.encryptString( uaDetails.getHost());
        sUAPortEnc = StringUtils.encryptString( String.valueOf(uaDetails.getPort()));
        sDREHostEnc = StringUtils.encryptString( dreDetails.getHost());
        sDREPortEnc = StringUtils.encryptString( String.valueOf(dreDetails.getPort()));

        sClusterTextRequestParameters = new StringBuffer()
                                                    .append( "&jobname=" 	)	.append( sClusterJobName )
                                                    .append( "&csserver=" 	)	.append( sClassHostEnc )
                                                    .append( "&csport=" 	)	.append( sClassPortEnc )
                                                    .append( "&seshost=" 	)	.append( sUAHostEnc )
                                                    .append( "&sesport=" 	)	.append( sUAPortEnc )
                                                    .append( "&drehost=" 	)	.append( sDREHostEnc )
                                                    .append( "&dreport=" 	)	.append( sDREPortEnc )
                                                    .append( "&username=" 	)	.append( sUsernameEnc )
                                                    .append( "&mode=" 		)	.append( "SG" )
                                               .toString();

        /*
            Each line in the autn:sgdata block represents a cluster
            Typical line looks like:

            4	MDN_1DAY	Serena Williams, Capriati, Krajicek, Mauresmo	1025828190	1025915278	0	92	57	92	8	53

            divided up and explained:

            0.	4												This cluster ID
            1.	MDN_1DAY										Jobname (should be the same for every cluster in the response)
            2.	Serena Williams, Capriati, Krajicek, Mauresmo	Cluster title
            3.	1025828190										Start date
            4.	1025915278										End date
            5.	0												x-coordinate 1
            6.	92												y-coordinate
            7.	57												x-coordinate 2
            8.	92												y-coordinate - (same as 6, unused)
            9.	8												vertical width of cluster
            10.	53												Number of documents in cluster
        */

              if(acioResults!=null)
              {
                // returns the data from the current sgdata node
                String sContent = acioResults.getTagValue("autn:sgdata");
                boolean bAtLeastOne = false;

                if (sContent != null)
                {
                    // Sorts the returning data string into tokens ending with carriage return
                    StringTokenizer st = new StringTokenizer( sContent, "\n" );
                    int nLine = 0;
                    String sLastStartDate = "";

                    while( st.hasMoreElements() )
                    {
                        // split up entries
                        String[] saThisCluster = StringUtils.split((String) st.nextElement(), "\t");


                        if (saThisCluster.length != 11)
                        {
                            sError = "invalid format at line " + nLine;
                            break;
                        }
                        else
                        {
                            bAtLeastOne = true;
                            // store per-cluster information
                            vIDs.addElement(saThisCluster[0]);
                            vTitles.addElement(saThisCluster[2].replace('\"','\''));
                            vNumDocs.addElement(new Integer(StringUtils.atoi(saThisCluster[10],0)));

                            // resize the coordinates

                            int nY = (int) ( StringUtils.atof(saThisCluster[6],0) * (float)nGraphHeight / (float)nDefaultPicSize );
                            int nX1 = (int) ( StringUtils.atof(saThisCluster[5],0) * (float)nGraphWidth / (float)nDefaultPicSize );
                            int nX2 = (int) ( StringUtils.atof(saThisCluster[7],0) * (float)nGraphWidth / (float)nDefaultPicSize );

                            if (bUseExactClusterWidths)
                            {
                                int nWidth = (int) ( StringUtils.atof(saThisCluster[9],0) * (float)nGraphHeight / (float)nDefaultPicSize );
                                vY1.addElement(new Integer(nY - (nWidth/2) - 2 ));
                                vY2.addElement(new Integer(nY + (nWidth/2) + 1 ));
                            }
                            else
                            {
                                vY1.addElement(new Integer(nY - (nHighlightHeight/2) - 2 ));
                                vY2.addElement(new Integer(nY + (nHighlightHeight/2) + 1 ));
                            }

                            vX1All.addElement(new Integer(nX1));
                            vX2All.addElement(new Integer(nX2));

                            // now store arrays of the information that is fixed for each slice
                            // and store the positions in our large array where we start a new slice
                            if (!saThisCluster[3].equals(sLastStartDate))
                            {
                                vX1.addElement(new Integer(nX1));
                                vX2.addElement(new Integer(nX2));
                                vStartDates.addElement(saThisCluster[3]);
                                vEndDates.addElement(saThisCluster[4]);

                                vNewSlicePositions.addElement(new Integer(nLine));

                                sLastStartDate = saThisCluster[3];
                            }
                        }

                        nLine++;
                    }
                }

                if (!bAtLeastOne)
                {
                   sError = rb.getString("autonomy2DMap.error.CSRunning") + " " + sClassHost + ":" + sClassPort + ", " + rb.getString("spectroImage.error.noCluster") + " " + sClusterJobName + " " + rb.getString("spectroImage.error.between")+ " " + nStart + " " + rb.getString("spectroImage.error.and") + " " + nEnd;
                }
              } // end of acioResults!=null
			}
            catch(AciException acie)
            {
            	if(acie instanceof ServerNotAvailableException)
				{
					sError = rb.getString("autonomy2DMap.error.CSNotRunning") + " " + sClassHost + ":" + sClassPort;
				}
				else
				{
					sError = rb.getString("autonomy2DMap.error.CSRunning") + " " + sClassHost + ":" + sClassPort + ", " + rb.getString("autonomy2DMap.error.CSRunning.requestFailed") + "(" + rb.getString("spectroImage.jobname")+ " " + sClusterJobName + ")";
            	}
            }
    }
    else{
        // retrieve and store spectrograph data
        try{
        AciConnectionDetails classDetails = service.getIDOLService().getCategoryConnectionDetails();
        AciConnectionDetails uaDetails = service.getIDOLService().getUserConnectionDetails();
        AciConnectionDetails dreDetails = service.getIDOLService().getQueryConnectionDetails();
        AciConnection classServer = new AciConnection(classDetails);
        classServer.setRetries(1);

        ArrayList params = new ArrayList();
		params.add(new ActionParameter("sourcejobname", sClusterJobName));
		params.add(new ActionParameter("startdate", nStart));
		params.add(new ActionParameter("enddate", nEnd));
		params.add(new ActionParameter("StructuredXML","true"));

		AciAction clusterSGDataServe = new AciAction("ClusterSGDataServe");
		clusterSGDataServe.usePostHTTPMethod();
		clusterSGDataServe.setParameters(params);

		AciResponse acioResults =null;
		acioResults = classServer.aciActionExecute(clusterSGDataServe);

		sClassHost = classDetails.getHost();
        sClassPort = String.valueOf(classDetails.getPort());
        sClassHostEnc = StringUtils.encryptString( sClassHost);
        sClassPortEnc = StringUtils.encryptString( String.valueOf(sClassPort));
        sUAHostEnc = StringUtils.encryptString( uaDetails.getHost());
        sUAPortEnc = StringUtils.encryptString( String.valueOf(uaDetails.getPort()));
        sDREHostEnc = StringUtils.encryptString( dreDetails.getHost());
        sDREPortEnc = StringUtils.encryptString( String.valueOf(dreDetails.getPort()));

        sClusterTextRequestParameters = new StringBuffer()
                                                    .append( "&jobname=" 	)	.append( sClusterJobName )
                                                    .append( "&csserver=" 	)	.append( sClassHostEnc )
                                                    .append( "&csport=" 	)	.append( sClassPortEnc )
                                                    .append( "&seshost=" 	)	.append( sUAHostEnc )
                                                    .append( "&sesport=" 	)	.append( sUAPortEnc )
                                                    .append( "&drehost=" 	)	.append( sDREHostEnc )
                                                    .append( "&dreport=" 	)	.append( sDREPortEnc )
                                                    .append( "&username=" 	)	.append( sUsernameEnc )
                                                    .append( "&mode=" 		)	.append( "SG" )
                                               .toString();

        /*
            Each line in the autn:sgdata block represents a cluster
            Typical line looks like:

            4	MDN_1DAY	Serena Williams, Capriati, Krajicek, Mauresmo	1025828190	1025915278	0	92	57	92	8	53

            divided up and explained:

            0.	4												This cluster ID
            1.	MDN_1DAY										Jobname (should be the same for every cluster in the response)
            2.	Serena Williams, Capriati, Krajicek, Mauresmo	Cluster title
            3.	1025828190										Start date
            4.	1025915278										End date
            5.	0												x-coordinate 1
            6.	92												y-coordinate
            7.	57												x-coordinate 2
            8.	92												y-coordinate - (same as 6, unused)
            9.	8												vertical width of cluster
            10.	53												Number of documents in cluster
        */

            int nY 		= 0;
	        int nX1 	= 0;
	        int nX2 	= 0;
            int nLine = 0;
            String sLastStartDate = "";

            if(acioResults != null)
            {
                boolean bAtLeastOne = false;

                // returns the data from the current CLUSTERSGDATASERVE
                AciResponse acioClustersResults = acioResults.findFirstOccurrence("autn:clusters");
                if(acioClustersResults != null)
                {

                    AciResponse acioClustersResult = acioClustersResults.findFirstOccurrence("autn:cluster");

                    while(acioClustersResult != null)
                    {
                        bAtLeastOne = true;
                        vIDs.addElement(acioClustersResult.getTagValue("autn:id", ""));
                        vTitles.addElement(acioClustersResult.getTagValue("autn:title", ""));
                        vNumDocs.addElement(new Integer(StringUtils.atoi(acioClustersResult.getTagValue("autn:numdocs", ""), 0)));

                        nY 		= (int)(StringUtils.atof(acioClustersResult.getTagValue("autn:y1", ""), 0) * (float)nGraphHeight / (float)nDefaultPicSize );
                        nX1 	= (int)(StringUtils.atof(acioClustersResult.getTagValue("autn:x1", ""), 0) * (float)nGraphWidth / (float)nDefaultPicSize );
                        float temp = StringUtils.atof(acioClustersResult.getTagValue("autn:x2", ""), 0) - StringUtils.atof(acioClustersResult.getTagValue("autn:x1", ""), 0);
                        temp = temp/2;
                        temp = temp + StringUtils.atof(acioClustersResult.getTagValue("autn:x1", ""), 0);
                        nX2 	= (int)((int)temp * (float)nGraphWidth / (float)nDefaultPicSize );

                        if (bUseExactClusterWidths)
                        {
                            int nWidth = (int) ( (StringUtils.atof(acioClustersResult.getTagValue("autn:radius_from", ""), 0) + StringUtils.atof(acioClustersResult.getTagValue("autn:radius_to", ""), 0) + 1.0 )/2 * (float)nGraphHeight / (float)nDefaultPicSize );
                            vY1.addElement(new Integer(nY - (nWidth/2) - 2 ));
                            vY2.addElement(new Integer(nY + (nWidth/2) + 1 ));
                        }
                        else
                        {
                            vY1.addElement(new Integer(nY - (nHighlightHeight/2) - 2 ));
                            vY2.addElement(new Integer(nY + (nHighlightHeight/2) + 1 ));
                        }

                        vX1All.addElement(new Integer(nX1));
                        vX2All.addElement(new Integer(nX2));

                        // now store arrays of the information that is fixed for each slice
                        // and store the positions in our large array where we start a new slice
                        if (!acioClustersResult.getTagValue("autn:fromdate", "").equals(sLastStartDate))
                        {
                            vX1.addElement(new Integer(nX1));
                            vX2.addElement(new Integer(nX2));
                            vStartDates.addElement(acioClustersResult.getTagValue("autn:fromdate", ""));
                            vEndDates.addElement(acioClustersResult.getTagValue("autn:todate", ""));

                            vNewSlicePositions.addElement(new Integer(nLine));

                            sLastStartDate = acioClustersResult.getTagValue("autn:fromdate", "");
                        }

                        nLine++;

                        // move to next ResultCluster - always siblings so just get next object
                        acioClustersResult = acioClustersResult.next();
                    }
                }

                if (!bAtLeastOne)
                {
                    sError = rb.getString("spectroImage.error.CSRunning") + " " + sClassHost + ":" + sClassPort + " " + rb.getString("spectroImage.error.CSRunning.noClusters") +  " " + sClusterJobName + " " + rb.getString("spectroImage.error.between") + " " + nStart + " " + rb.getString("spectroImage.error.and") + " " + nEnd;
                }
			  }  // acioResults != null
            }
            catch(AciException acie)
            {
            	if(acie instanceof ServerNotAvailableException)
            	{
            	 sError = rb.getString("spectroImage.error.CSNotRunning") + " " + sClassHost + ":" + sClassPort;
            	}
            	else
            	{
            	 sError = rb.getString("spectroImage.error.CSRunning") + " " + sClassHost + ":" + sClassPort + ", " + rb.getString("spectroImage.error.CSRunning.requestFailed") + "(" + rb.getString("spectroImage.jobname")+ " " + sClusterJobName + ")";
            	}
            }
    }

	if( sError == null )
	{
		// print out javascript arrays containing data
		// if (vIDs.size() > 0)
        if (vNumDocs.size() > 0)
		{
%>
			<html>
				<head>
		<script type="text/javascript">

			document.expando=false;
		<%
				PortletUtils.printJSArray("aIDs", 		vIDs, 				out, false);
				PortletUtils.printJSArray("aNumDocs", 	vNumDocs, 			out, false);
				PortletUtils.printJSArray("aTitles", 	vTitles, 			out, true);
				PortletUtils.printJSArray("aStartDates",vStartDates, 		out, false);
				PortletUtils.printJSArray("aEndDates", 	vEndDates, 			out, false);
				PortletUtils.printJSArray("aX1", 		vX1, 				out, false);
				PortletUtils.printJSArray("aX2", 		vX2, 				out, false);
				PortletUtils.printJSArray("aX1All", 	vX1All, 			out, false);
				PortletUtils.printJSArray("aX2All", 	vX2All, 			out, false);
				PortletUtils.printJSArray("aSlicePos", 	vNewSlicePositions, out, false);
				PortletUtils.printJSArray("aY1", 		vY1, 				out, false);
				PortletUtils.printJSArray("aY2", 		vY2, 				out, false);
		%>

			<%-- use globals so we can return two both values --%>
			var nFound = -1;
			var nSlice = -1;

			var nCurrentHoverCluster = -1;

			function getCurrentHover(nX, nY)
			{
				<%-- move through x1 and x2 arrays --%>

				nFound = -1;
				nSlice = -1;

				for (i=0; i < <%=vX1.size()%>; i++)
				{
					if (nX >= aX1[i] && nX <= aX2[i])
					{
						nSlice = i;
						break;
					}
				}

				<%-- if we're in a vertical slice, find out which cluster we're in --%>
				if (nSlice != -1 && nSlice < aSlicePos.length)
				{
					var nStartSearch = aSlicePos[nSlice];
					var nEndSearch = (nSlice == aSlicePos.length - 1) ? (<%=vY1.size()%>) : (aSlicePos[nSlice+1]);

					for (i=nStartSearch; i<nEndSearch; i++)
					{
						if (nY >= aY1[i] && nY <= aY2[i])
						{
							nFound = i;
							break;
						}
					}
				}
			}

			function checkMousePos(x,e)
			{
				var nX = 0;
				var nY = 0;
				var ev = (!e) ? window.event : e; //Moz:IE
				if(ev.pageX) //Mozilla or compatible
				{
					nX = ev.pageX;
					nY = ev.pageY;
					nX = nX - 5;
					nY = nY - 5;
				}
				else if(ev.clientX) //IE or compatible
				{
					nX = ev.clientX;
					nY = ev.clientY;
					nX = nX - 15;
					nY = nY - 15;
				}
				else //older browsers
				{
					return false
				}

				getCurrentHover(nX, nY);

				// reset old title to hidden
				if (nCurrentHoverCluster != -1 && nCurrentHoverCluster != nFound)
				{
					var vClusterTitle = document.getElementById('clustertitle' + nCurrentHoverCluster);
                    vClusterTitle.style.visibility='hidden';
				}

				var vClusterHighLight = document.getElementById("clusterhighlight");

				// new title selected

				if (x == 'base' && nFound != -1)
				{
                    var vSgImage = document.getElementById("sgimage");
					var nHeight = aY2[nFound] - aY1[nFound];

                    vClusterHighLight.style.top = vSgImage.offsetTop + aY1[nFound] + 1 + nHeight/2 - <%=nHighlightHeight%>/2;
					vClusterHighLight.style.left = vSgImage.offsetLeft + aX1[nSlice] - <%=nHighlightThickness * 2%>;
					vClusterHighLight.style.width = aX2[nSlice] + <%=nHighlightThickness * 4%> - aX1[nSlice];

					vClusterHighLight.style.visibility = "visible";

					var vClusterTitle = document.getElementById('clustertitle' + nFound);
                    updateLocation(nFound);
                    vClusterTitle.style.visibility = 'visible';
                }
				else
				{
					vClusterHighLight.style.visibility = "hidden";
				}

				nCurrentHoverCluster = nFound;
			}

			function selectCluster(x,e)
			{
				if (x == 'base')
				{
					var nX = 0;
					var nY = 0;
					var ev = (!e) ? window.event : e; //Moz:IE
					if(ev.pageX) //Mozilla or compatible
					{
						nX = ev.pageX - 5;
						nY = ev.pageY - 5;
					}
					else if(ev.clientX) //IE or compatible
					{
						nX = ev.clientX - 15;
						nY = ev.clientY - 15;
					}
					else //older browsers
					{
						return false
					}

					getCurrentHover(nX, nY);
				}

				if ((x == 'base' || x == 'select') && nFound != -1)
				{
					var vSgImage = document.getElementById("sgimage");
					var vSelectedClusterHighlight = document.getElementById("selectedclusterhighlight");
					var nHeight = aY2[nFound] - aY1[nFound];

					vSelectedClusterHighlight.style.top = vSgImage.offsetTop + aY1[nFound] + 1 + nHeight/2 - <%=nHighlightHeight%>/2;
					vSelectedClusterHighlight.style.left = vSgImage.offsetLeft + aX1[nSlice] - <%=nHighlightThickness * 2%>;
					vSelectedClusterHighlight.style.width = aX2[nSlice] + <%=nHighlightThickness * 4%> - aX1[nSlice];

					vSelectedClusterHighlight.style.visibility = "visible";

					parent['<%=sSGDocsFrame%>']['location']['href'] = '<%= service.makeLink("clustertext.jsp?clusternum=") %>' + aIDs[nFound] + "&startdate=" + aStartDates[nSlice] + "&enddate=" + aEndDates[nSlice] + "&numresults=" + aNumDocs[nFound] + "<%= sClusterTextRequestParameters %>";
                }
			}

            function updateLocation(index) {
                var nSGToolTipMouseYOffset = <%=nSGToolTipMouseYOffset%>;
                var nSGToolTipMouseXOffset = <%=nSGToolTipMouseXOffset%>;
                var vSgImage = document.getElementById("sgimage");
                // set the title positions
                var nThisTitleTop = aY1[i] + vSgImage.offsetTop + nSGToolTipMouseYOffset;
                var nThisTitleLeft = aX1All[i] + vSgImage.offsetLeft + nSGToolTipMouseXOffset;

                var vClusterTitle = document.getElementById('clustertitle' + i);

                // make sure they don't fall off the outside of the image
                var nTitleHeight = vClusterTitle.offsetHeight;
                var nTitleWidth = vClusterTitle.offsetWidth;

                // top
                if (aY1[i] + nSGToolTipMouseYOffset <= 0)
                {
                    nThisTitleTop = vSgImage.offsetTop + 10;
                }

                // bottom
                if (aY1[i] + nSGToolTipMouseYOffset + nTitleHeight > <%=nGraphHeight%>)
                {
                    nThisTitleTop = vSgImage.offsetTop + aY1[i] - nTitleHeight;
                }

                // right
                if (aX1All[i] + nSGToolTipMouseXOffset + nTitleWidth > <%=nGraphWidth%>)
                {
                    nThisTitleLeft = vSgImage.offsetLeft + <%=nGraphWidth%> - nTitleWidth - 10;
                }

                // left
                if (aX1All[i] + nSGToolTipMouseXOffset <= 0)
                {
                    nThisTitleLeft = vSgImage.offsetLeft + 10;
                }

                vClusterTitle.style.top = nThisTitleTop;
                vClusterTitle.style.left = nThisTitleLeft;
            }

			function clearAll()
			{
				document.getElementById('clusterhighlight').style.visibility='hidden';
				for (var i=0; i < <%=vNumDocs.size()%>; i++)
				{
                    document.getElementById('clustertitle' + i).style.visibility='hidden';
				}
			}


        </script>
				</head>
		<body style="background-color:transparent;">

		<%
			for (int nClusterIdx=0;nClusterIdx<vNumDocs.size();nClusterIdx++)
			{
                String sTitle = null;
				sTitle       = (String)vTitles.elementAt(nClusterIdx);
				Integer NNumDocs    = (Integer)vNumDocs.elementAt(nClusterIdx);
		%>
				<span id="clustertitle<%=nClusterIdx%>"
					  style="<%=sTitleStyle%>"
					  onMouseMove="checkMousePos('title',event)"
					  >
						<table cellpadding="3">
							<tr>
								<td nowrap="nowrap" style="<%=sTitleTableStyle%>">
									<b><%= sTitle %></b>
									<br>
									<%= NNumDocs %> <%=rb.getString("autonomy2DMap.docs")%>
								</td>
							</tr>
						</table>
				</span>
		<%
			}
		%>
			<div id="clusterhighlight"
				 style="<%=sHighlightStyle%>"
				 onMouseDown="selectCluster('select',event)"
				 >
			</div>
			<div id="selectedclusterhighlight"
				 style="<%=sSelectedHighlightStyle%>"
				 onMouseDown="selectCluster('select',event)"
				 >
			</div>

			<table width="100%">
				<tr>
					<td colspan="3">
						<img id="sgimage"
							 style="<%=sImageStyle%>"
							 height="<%=nGraphHeight%>"
							 width="<%=nGraphWidth%>"
							 onMouseMove="checkMousePos('base',event)"
							 onMouseDown="selectCluster('base',event)"
							 src="<%=service.makeLink("proxy.jsp")%>?action=ClusterSGPicServe&sourcejobname=<%=sClusterJobName%>&startdate=<%=nStart%>&enddate=<%=nEnd%>">
					</td>
				</tr>
				<tr>
					<td valign="top" width="1%">
						&nbsp;&nbsp;<font style="font-size:10;font-weight:bold" face="arial" ><%=sStart%></font>
					</td>
					<td align="center" valign="top" nowrap="nowrap" width="1%">
						<font style="font-size:12;font-weight:bold" face="arial">
							- <%=rb.getString("spectroImage.date")%> -
						</font>
					</td>
					<td align="right" valign="top" width="1%">
						<font style="font-size:10;font-weight:bold" face="arial">
							<%=sEnd%>
						</font>
						&nbsp;&nbsp;
					</td>
				</tr>
				<tr>
					<td width="1%">

						<%-- form for navigating offset --%>
						<form name="offsetform" action="spectroImage.jsp" method="POST">
							<input type="hidden" name="offset" 		value="">
							<input type="hidden" name="username" 	value="<%= sUsernameEnc		%>" >
							<input type="hidden" name="csserver" 	value="<%= sClassHostEnc 	%>" >
							<input type="hidden" name="csport" 		value="<%= sClassPortEnc 	%>" >
							<input type="hidden" name="cstimeout" 	value="60000" >
							<input type="hidden" name="seshost" 	value="<%= sUAHostEnc		%>" >
							<input type="hidden" name="sesport" 	value="<%= sUAPortEnc		%>" >
							<input type="hidden" name="drehost" 	value="<%= sDREHostEnc		%>" >
							<input type="hidden" name="dreport" 	value="<%= sDREPortEnc		%>" >
							<input type="hidden" name="jobname" 	value="<%= sClusterJobName 	%>" >
							<input type="hidden" name="graphheight"	value="<%= sGraphHeight		%>" >
							<input type="hidden" name="graphwidth"	value="<%= sGraphWidth		%>" >
							<input type="hidden" name="sginterval"	value="<%= sSGInterval		%>" >
							<input type="hidden" name="clusterframe"value="<%= sSGDocsFrame	%>" >
						</form>
		<%
				if (bAtMaxOffset)
				{
		%>
						<img align="absmiddle" src="<%= sImageURL %>/leftendarrow_grey.gif">
						<img align="absmiddle" src="<%= sImageURL %>/leftarrow_grey.gif">
		<%
				}
				else
				{
		%>
						<a href="javascript:document.offsetform.offset.value='<%=nMaxOffset%>';document.offsetform.submit();"
							><img align="absmiddle" src="<%= sImageURL %>/leftendarrow.gif" border="0"
						></a>
						<a href="javascript:document.offsetform.offset.value='<%=nOffset + 1%>';document.offsetform.submit();"
							><img align="absmiddle" src="<%= sImageURL %>/leftarrow.gif" border="0"
						></a>
		<%
				}
		%>
					</td>
					<td width="1%">
					</td>
					<td align="right" width="1%">
		<%
				if (bAtMinOffset)
				{
		%>
						<img align="absmiddle" src="<%= sImageURL %>/rightarrow_grey.gif">
						<img align="absmiddle" src="<%= sImageURL %>/rightendarrow_grey.gif">
		<%
				}
				else
				{
		%>
						<a href="javascript:document.offsetform.offset.value='<%=nOffset - 1%>';document.offsetform.submit();"
							><img align="absmiddle" src="<%= sImageURL %>/rightarrow.gif" border="0"
						></a>
						<a href="javascript:document.offsetform.offset.value='<%=nMinOffset%>';document.offsetform.submit();"
							><img align="absmiddle" src="<%= sImageURL %>/rightendarrow.gif" border="0"
						></a>
		<%
				}
		%>
						&nbsp;&nbsp;
					</td>
				</tr>
			</table>
        </body>
	</html>
<%
		}
	}
	else
	{
	%>
		<font class="normal">
			<%=rb.getString("autonomy2DMap.error.internalError")%> <%= sError %><br/>
			<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
		</font>
	<%
	}
}
else
{
%>
	<font class="normal">
		<%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("spectroImage.error.missParam")%>Missing parameters<br/>
		<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
	</font>
<%
	HTMLUtils.displayRequest(out, request);
}
%>

<%!
    // 	Get Component Category version number
    private int getCategoryVersion(PortalService service)
    {
         String sVersion = null;
         int nVersion = -1;
 	 AciConnection dreServer = new AciConnection(service.getIDOLService().getQueryConnectionDetails());
	 dreServer.setRetries(1);
	 AciAction getstatus = new AciAction("getstatus");
	 try
	 {
	 	AciConnectionDetails classDetails = service.getIDOLService().getCategoryConnectionDetails();
	 		 
	 	AciConnection classServer = new AciConnection(classDetails);
	 	classServer.setRetries(1);
	 	
	 	AciAction getVersion = new AciAction("getversion");
	 	AciResponse acioVersionResults = classServer.aciActionExecute(getVersion);
	 	sVersion = acioVersionResults.getTagValue("autn:version");
	 	sVersion = StringUtils.stringReplace(sVersion, ".", "");
	 	nVersion = StringUtils.atoi(sVersion, -1);
	 }
	 catch(AciException acie)
	 {

	 }
	 return nVersion;
    }
%>

