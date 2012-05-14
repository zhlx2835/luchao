<%@ page import = "java.util.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "com.autonomy.APSL.*"%>
<%@ page import = "com.autonomy.utilities.*"%>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>

<%
final String PARAM_TO_SAVE_TOKEN 	= "prmsv";
final String PORTLET_NAME			= "PortletAdmin";

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
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>">
</head>
<body STYLE="background-color:transparent;">
<table width="100%" class="pContainer"><tr><td>

<%
if(service != null)
{
	// form names
	String fMain 		= service.makeFormName("Main");
	String fResetForm	= service.makeFormName("Reset");

	// Request parameter names for use in forms
	String siMethod 			= service.makeParameterName("Method");
	String siSelectedPortlet	= service.makeParameterName("SlctdPtlt");
	String siNewParamName 		= service.makeParameterName("NwPrmName");
	String siNewParamValue 		= service.makeParameterName("NwPrmValue");
	String siParamToChange		= service.makeParameterName("PrmToRmv");

	// read request parameters if any
	String sMethod				= service.getSafeRequestParameter(siMethod, "");
	String sSelectedPortlet 	= URLDecoder.decode(service.getSafeRequestParameter(siSelectedPortlet, "") );
	String sNewParamName 		= URLDecoder.decode(service.getSafeRequestParameter(siNewParamName, "") );
	String sNewParamValue 		= URLDecoder.decode(service.getSafeRequestParameter(siNewParamValue, "") );
	String sParamToRemoveName 	= service.getSafeRequestParameter(siParamToChange, "");


	// Get user details
	AutonomyPortalUser apuUser = service.getUser();

	// Fully qualified URI towards images folder
	String  sImageURL	= service.makeLink("AutonomyImages");

	// retrieve the portlet configuration object which is to be displayed/modified.
	PortletConfigFile pcfConfig = service.getConfig();

	if( pcfConfig != null && apuUser != null )	// && apuUser.isAdmin() )
	{
		//
		// pre-display processing
		//

		// Placeholder for any errors generated during processing
		String sError = null;

		if( sMethod.equals("AddParam") )
		{
			// add parameter info to config object. N.B. this only changes the singleton instantiation of
			// the PortletConfigFile object, not the configuration file itself.
			if( StringUtils.strValid(sNewParamName) &&	StringUtils.strValid(sNewParamValue) )
			{
				pcfConfig.setPortletParam(sSelectedPortlet, sNewParamName, sNewParamValue);
				commitChangesAndReloadConfig(pcfConfig, service);
			}
			else
			{
				sError = "The parameter information given (name - " + sNewParamName + ", value = " + sNewParamValue + ") is invalid.<br/>";
			}
			// carry on viewing same portlet
			sMethod = "View";
		}
		else if( sMethod.equals("RemoveParam") )
		{
			// remove parameter from config object. N.B. this only changes the singleton instantiation of
			// the PortletConfigFile object, not the configuration file itself.
			if( StringUtils.strValid(sParamToRemoveName) )
			{
				pcfConfig.removePortletParam(sSelectedPortlet, sParamToRemoveName);
				commitChangesAndReloadConfig(pcfConfig, service);
			}
			else
			{
				sError = "The parameter information given (name - " + sParamToRemoveName + ") is invalid.<br/>";
			}
			// carry on viewing same portlet
			sMethod = "View";
		}
		else if( sMethod.equals("Save") )
		{
			// read current parameter values from request
			Vector vPortletParamNames = new Vector();
			Vector vPortletParamValues = new Vector();

			Enumeration enumAllRequestParams = service.getRequestParameterNames();
			if( enumAllRequestParams != null )
			{
				while( enumAllRequestParams.hasMoreElements() )
				{
					String sParamName = (String)enumAllRequestParams.nextElement();

					int nIdx = sParamName.indexOf(PARAM_TO_SAVE_TOKEN);
					if( nIdx != -1 )
					{
						String sName = sParamName.substring(nIdx + PARAM_TO_SAVE_TOKEN.length() );
						// NB must use qualified parameter name here for Oracle.
						String sValue = null;
/*
		OracleR2Service class is no longer public so can't do this - leave this code in here until
		the portlet can be tested on Oracle to see if it's really necessary
						if(service instanceof OracleR2Service)
						{
							sValue = service.getRequestParameter( service.makeParameterName( sParamName ) );
						}
						else
						{
*/
							sValue = service.getRequestParameter(sParamName);
/*
						}
*/
						if( sValue != null )
						{
							vPortletParamNames.add( sName );
							vPortletParamValues.add( sValue );
						}
					}
				}
			}

			// make changes to config object
			int nNumParams = vPortletParamNames.size();
			if( nNumParams > 0 && pcfConfig != null )
			{
				for(int nParamIdx = 0; nParamIdx < nNumParams; nParamIdx++)
				{
					pcfConfig.setPortletParam( sSelectedPortlet,
								  (String)vPortletParamNames.elementAt(nParamIdx),
								  (String)vPortletParamValues.elementAt(nParamIdx));
				}

				// commit changes made to configuration object
				if(service instanceof PiB4ServiceInterface)
				{
					// remove server defaults as these are read from the overall portal config, portal.cfg.
					pcfConfig.removeDefaultParam("QueryHost");
					pcfConfig.removeDefaultParam("QueryPort");
					pcfConfig.removeDefaultParam("QueryProtocol");
					pcfConfig.removeDefaultParam("QueryTimeout");
					pcfConfig.removeDefaultParam("QueryEncoding");
					pcfConfig.removeDefaultParam("UserHost");
					pcfConfig.removeDefaultParam("UserPort");
					pcfConfig.removeDefaultParam("UserProtocol");
					pcfConfig.removeDefaultParam("UserTimeout");
					pcfConfig.removeDefaultParam("UserEncoding");
					pcfConfig.removeDefaultParam("CategoryHost");
					pcfConfig.removeDefaultParam("CategoryPort");
					pcfConfig.removeDefaultParam("CategoryProtocol");
					pcfConfig.removeDefaultParam("CategoryTimeout");
					pcfConfig.removeDefaultParam("CategoryEncoding");
				}

				commitChangesAndReloadConfig(pcfConfig, service);
			}
		}
		else if( sMethod.equals("Reset") )
		{
			// reload configuration object from file
			pcfConfig.reset();
			pcfConfig = service.getConfig();
		}


		//
		// start of main display
		//

		// display table containing list of available portlets, with parameter details for selected portlet
%>
		<table class="<%= service.getCSSClass(service.TEXT_1)%>" cellspacing="5">
			<tr>
				<td>
					<font class="<%= service.getCSSClass(service.TEXT_1)%>">
						<b><%=rb.getString("autonomyPortletAdmin.availPortlets")%></b>
					</font>
				</td>
			</tr>
			<tr>
				<td height="3" />
			</tr>
			<tr>
				<td nowrap="nowrap">
					<table class="<%= service.getCSSClass(service.TEXT_1)%>">
						<tr>
							<td align="left" valign="top">
								<table border="0">
<%
									Enumeration ePortletNames = pcfConfig.getPortletNames();
									boolean bAllowParamRemoval = true;
									while( ePortletNames.hasMoreElements() )
									{
										String sPortletName = (String)ePortletNames.nextElement();
										String sViewPortletForm = service.makeFormName(sPortletName);

										if( sPortletName.equals(sSelectedPortlet) )
										{
%>
											<tr><td>
												<font class="<%= service.getCSSClass(service.TEXT_1)%>">
													<b><%= sPortletName%></b>
												</font>
											</td></tr>
<%
										}
										else
										{
%>
											<tr><td>
												<form name="<%= sViewPortletForm%>" action="<%= service.makeFormActionLink(" ")%>" method="POST" style="margin:0px; padding:0px;">
													<%= service.makeAbstractFormFields()%>
													<input type="hidden" name="<%= siMethod%>" value="View" />
													<input type="hidden" name="<%= siSelectedPortlet%>" value="<%= URLEncoder.encode(sPortletName)%>" />
												</form>
												<font class="<%= service.getCSSClass(service.TEXT_1)%>">
													<a href="javascript:document['<%= sViewPortletForm%>'].submit()" >
														<%= sPortletName%>
													</a>
												</font>
											</td></tr>
<%
										}
									}
%>
								</table>
							</td>
							<td valign="top">
<%
								// don't want the default section to be displayed twice
								if(!sSelectedPortlet.equals("default"))
								{
%>
									<%@ include file="adminPortletDisplay_include.jspf"%>
<%
								}
%>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td height="6">
				</td>
			</tr>

			<tr>
				<td>
					<font class="<%= service.getCSSClass(service.TEXT_1)%>">
						<b><%=rb.getString("autonomyPortletAdmin.defaultParam")%></b>:
					</font>
				</td>
			</tr>
			<tr>
				<td>
					<%@ include file="adminDefaultDisplay_include.jspf"%>
				</td>
			</tr>

		</table>
<%
	}
	else	//if( pcfConfig != null && apuUser != null )
	{
%>
		<font class="normal">
			<%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("autonomyPortletAdmin.error.portletConfig")%><br/>
			<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
		</font>
<%
	}
}
else	//if(service != null)
{
%>
	<font class="normal">
		<%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("autonomy2DMap.error.internalError.erroMsg")%><br/>
		<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
		<br/>
	</font>
<%
}
%>

<%!
private void commitChangesAndReloadConfig(PortletConfigFile pcfConfig, PortalService service)
{
	// commit changes made to configuration object
	pcfConfig.write();
	//reload configuration object from file
	pcfConfig.reset();
	pcfConfig = service.getConfig();
}
%>
</td></tr></table>
</body>
</html>
