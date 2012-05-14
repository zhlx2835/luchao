<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import = "com.autonomy.aci.AciAction"%>
<%@ page import = "com.autonomy.aci.AciResponse"%>
<%@ page import = "com.autonomy.aci.AciConnection"%>
<%@ page import = "com.autonomy.aci.ActionParameter"%>
<%@ page import = "com.autonomy.aci.AciConnectionDetails"%>
<%@ page import = "com.autonomy.aci.services.IDOLService"%>
<%@ page import = "com.autonomy.aci.exceptions.AciException"%>
<%@ page import = "com.autonomy.aci.businessobjects.User"%>
<%@ page import = "com.autonomy.aci.exceptions.ServerNotAvailableException"%>
<%@ page import = "com.autonomy.aci.exceptions.UserNotFoundException"%>

<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

final String PORTLET_NAME= "Expertise";

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
%>

<html>
<head>
	<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>">
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
</head>
<body STYLE="background-color:transparent">
<table width="100%" class="pContainer"><tr><td>

<%


if(service != null)
{
	// read configuration parameters for this portlet
	String sFindProfiles	= (String)service.getParameter("FindProfiles");
	String sFindAgents		= (String)service.getParameter("FindAgents");
	boolean bIsAlive = true;

	try{

	        AciConnectionDetails uaDetails = service.getIDOLService().getUserConnectionDetails();
		AciConnection uaServer = new AciConnection(uaDetails);
		AciAction testALive = new AciAction("GetVersion");
		AciResponse acioResults = uaServer.aciActionExecute(testALive);
	}
	catch (AciException acie)
	{
		if(acie instanceof ServerNotAvailableException)
		{
			bIsAlive = false;
		}
	}

	AciConnectionDetails uaDetails = service.getIDOLService().getUserConnectionDetails();
	AciConnection uaServer = new AciConnection(uaDetails);

	if(bIsAlive)
	{
		//
		//Declare pane specific variables
		//
		String sMethodParamName 		= service.makeParameterName("method");
		String sQueryParamName 			= service.makeParameterName("query");
		String sNumResultsParamName 	= service.makeParameterName("numresults");
		String sThresholdParamName 		= service.makeParameterName("threshold");
		String sFindAgentsParamName		= service.makeParameterName("findagents");
		String sFindProfilesParamName	= service.makeParameterName("findprofiles");
		String sQueryFormName			= service.makeFormName("fQueryform");


		// Get user details
		String sUsername = ((AutonomyPortalUser)service.getUser()).getName();
		User user = null;
		boolean isUserError = false;

		//
		IDOLService idol = service.getIDOLService();
		try
		{
		 user = idol.useUserFunctionality().getUser(sUsername);
		}
		catch(UserNotFoundException unfe)
		{

		  isUserError = true;
		  System.out.println("Autonomy Expertise - User " + sUsername + " does not exist. Read user failed");
		}
		catch(AciException acie)
		{
		  isUserError = true;
		  System.out.println("Autonomy Expertise - Errors occurred when trying to retrieve " + sUsername);
		}
		if(user!=null && !isUserError)
		{
		String sSecString = user.getSecurityInfo();

		// fully qualified URI for image folder
		String  sImageURL	= service.makeLink("AutonomyImages");

		//
		// start retrieving request parameters
		//
		String sWhatToDo = service.getRequestParameter(sMethodParamName);

		if(sWhatToDo == null)
			sWhatToDo = "newQuery";

		boolean bSearch =  sWhatToDo.equals("search");
		String[] saAgentNames = null;

		String sQuery 				= "";
		Integer NNumberOfResults	= new Integer(6);
		Integer NThreshold 		= new Integer(20);
		boolean bFindProfiles 		= false;
		boolean bFindAgents			= true;
		// placeholder for single community result entry
		AciResponse acioCommunityResult = null;
		AciResponse acioHit  = null;
		if(bSearch)
		{
			//
			//come from form, read all values, store in session for future use since there is a few of them
			//
			sQuery 				= service.getRequestParameter(sQueryParamName);
			NNumberOfResults 	= new Integer(StringUtils.atoi(service.getRequestParameter(sNumResultsParamName), 6));
			NThreshold 			= new Integer(StringUtils.atoi(service.getRequestParameter(sThresholdParamName), 20));
			bFindProfiles 		= StringUtils.isTrue(service.getSafeRequestParameter(sFindProfilesParamName, "false"));
			bFindAgents			= StringUtils.isTrue(service.getSafeRequestParameter(sFindAgentsParamName, "false"));

			// read user's agent list so unique agent names can be created for cloned agents
			try{
			 ArrayList alAgentNames = idol.useAgentFunctionality().getAgentNames(user);
			 saAgentNames = new String[alAgentNames.size()];
			 for(int i=0;i<alAgentNames.size();i++)
			 {
			  saAgentNames[i] = (String)alAgentNames.get(i);
			 }
			}
			catch(AciException acie)
			{
			 System.out.println("Autonomy Expertise - Errors occurred when trying to read agents for user " + user.getUsername());
			}
			boolean bError = false;
			//
			//Now do community search
			//
			try{
			AciAction community = new AciAction("Community");

			ArrayList params = new ArrayList();
			params.add(new ActionParameter("username", sUsername));
			params.add(new ActionParameter("Text", sQuery));
			params.add(new ActionParameter("DREMinScore", NThreshold.intValue()));
			params.add(new ActionParameter("DREMaxResults", NNumberOfResults.intValue()));
			params.add(new ActionParameter("Profile", bFindProfiles));
			params.add(new ActionParameter("Agents", bFindAgents));
			params.add(new ActionParameter("DREPrint", "all"));

			community.setParameters(params);
			acioCommunityResult = uaServer.aciActionExecute(community);
			}
			catch(AciException acie)
			{
				bError=true;
			}
			if(!bError)
			{
				acioHit = acioCommunityResult.findFirstOccurrence("autn:hit");
			}
		}// if(bSearch)

		// always display query form
%>
		<script type="text/javascript">
			function expertiseCheckForEnter()
			{
				nLength = document['<%= sQueryFormName %>']['<%= sQueryParamName %>']['value']['length'];
				if( nLength > 2 )
				{
					if (document['<%= sQueryFormName %>']['<%= sQueryParamName %>']['value'].charAt(nLength-1) == "\n")
					{
						document['<%= sQueryFormName %>']['<%= sQueryParamName %>']['value'] = document['<%= sQueryFormName %>']['<%= sQueryParamName %>']['value'].substring(0,nLength-2);
						document['<%= sQueryFormName %>'].submit();
					}
				}
			}
		// finished Script hiding-->
		</script>
		<table width="100%" cellspacing="5">
			<tr>
				<td>
					<form name="<%= sQueryFormName %>" action="<%= service.makeFormActionLink(" ") %>" method="post" onSubmit="if(this['<%=sQueryParamName%>']['value']['length']==0){alert('Please enter a query'); this['<%=sQueryParamName%>'].focus(); return false;}" >
					<%= service.makeAbstractFormFields() %>
					<input type="hidden" name="<%= sMethodParamName %>" value="search" />
						<table width="318">
							<tr>
								<td colspan="2">
									<font class="normalbold" >
										<%=rb.getString("autonomyExpertise.queryText")%>
									</font>
								</td>
							</tr>
							<tr>
								<td colspan="2" align="right">
									<textarea
											  rows="5"
											  cols="49"
											  wrap="soft"
											  onkeyup="javascript:expertiseCheckForEnter();"
											  name="<%=sQueryParamName%>"
											  value="<%= StringUtils.XMLEscape(sQuery) %>"
											  ><%= StringUtils.XMLEscape(sQuery) %></textarea>
								</td>
							</tr>
							<tr>
								<td nowrap="true">
									<font class="normalbold" >
										<%=rb.getString("autonomyExpertise.numOfResults")%>
									</font>
									&nbsp;

									<%=HTMLUtils.createSelect(sNumResultsParamName, new int[] {1,2,3,4,5,6,7,8,9,10,15,20,50,100}, NNumberOfResults.intValue())%>
									&nbsp;
								</td>
								<td align="right" nowrap="yes">
									<font class="normalbold" >
										<%=rb.getString("autonomyExpertise.quality")%>
									</font>
									&nbsp;

									<%=HTMLUtils.createSelect(sThresholdParamName, new int[] {10,20,30,40,50,60,70,80,90}, NThreshold.intValue())%>

								</td>
							</tr>

							<tr>
								<td colspan="2">
									<table width="100%" class="seperator">
										<tr>
											<td>
											</td>
										</tr>
									</table>
								</td>
							</tr>

			<%
							if(StringUtils.isTrue((String)service.getParameter("AllowMatchChoice")))
							{
								String sAgentsChecked 	= bFindAgents 	? "checked=\"checked\"" : "";
								String sProfilesChecked = bFindProfiles ? "checked=\"checked\"" : "";

			%>
								<tr>
									<td colspan="2">
										<font class="normalbold" >
											<%=rb.getString("autonomyExpertise.accordingAgentOrProfile")%>
										</font>
									</td>
								</tr>
								<tr>
									<td></td>
									<td nowrap="yes">
										<font class="<%=service.getCSSClass(service.TEXT_1)%>" >
											<input type="checkbox" name="<%= sFindAgentsParamName %>" value="true" <%= sAgentsChecked %> />
											<%=rb.getString("autonomyExpertise.agent")%>
										</font>
									</td>
								</tr>
								<tr>
									<td></td>
									<td nowrap="yes">
										<font class="<%=service.getCSSClass(service.TEXT_1)%>" >
											<input type="checkbox" name="<%= sFindProfilesParamName %>" value="true" <%= sProfilesChecked %> />
											<%=rb.getString("autonomyExpertise.profiles")%>
										</font>
									</td>
								</tr>
			<%
							}
			%>
							<tr><td></td></tr>
							<tr>
								<td colspan="2" width="100%" align="right" height="3">
									<a class="textButton" title="Submit" href="javascript:<%= sQueryFormName %>.submit();">
										<%=rb.getString("autonomyExpertise.submit")%>
									</a>
								</td>
							</tr>
						</table>
					</form>
				</td>
			</tr>
<%
			//
			// now display results if there are any
			//
			if(acioHit != null)
			{
%>
				<tr><td colspan="2" height="6"><hr></td></tr>
				<tr>
					<td align="center" colspan="2">
						<table width="95%" class="pResultList" border="0">
							<tr>
								<td align="left" nowrap="nowrap" >
									<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
										<b><%=rb.getString("autonomyExpertise.agentOrProfile")%></b>
									</font>
								</td>
								<td align="left" nowrap="nowrap" >
									<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
										<b><%=rb.getString("autonomyExpertise.ownByUser")%></b>
									</font>
								</td>
								<td align="left">
									<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
										<b><%=rb.getString("autonomyExpertise.options")%></b>
									</font>
								</td>
							</tr>

							<%@ include file = "expertiseResults_include.jspf"%>

						</table>
					</td>
				</tr>
<%
			}
			else if(bSearch)
			{
%>
				<tr><td colspan="2" width="100%">
					<font class="<%=service.getCSSClass(service.TEXT_1)%>" >
						<%=rb.getString("autonomyExpertise.noMatch")%>
					</font>
				</td><tr>
<%
			}
%>

		</table>
<%
	  } // end of  if(user!=null && !isUserError )
	  else
	  {
%>
		<font class="<%=service.getCSSClass(service.TEXT_1)%>">
			<%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("autonomyCommunity.error.UserError")%><br/>
			<%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
		</font>
<%
	  }
	}
	else	//if(acioUAServer.isAlive())
	{
%>
		<font class="<%=service.getCSSClass(service.TEXT_1)%>">
			<%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("autonomyCommunity.error.UAIsNotAlive")%><br/>
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
	</font>
<%
}
%>
</td></tr></table>
</body>
</html>
