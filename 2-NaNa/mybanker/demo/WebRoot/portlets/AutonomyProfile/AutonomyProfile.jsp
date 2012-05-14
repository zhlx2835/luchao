<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.aci.*" %>
<%@ page import = "com.autonomy.aci.businessobjects.Profile" %>
<%@ page import = "com.autonomy.aci.exceptions.AciException" %>
<%@ page import = "com.autonomy.aci.services.IDOLService" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.portlet.*" %>
<%@ page import = "com.autonomy.portlet.PortletUtils" %>
<%@ page import = "com.autonomy.utilities.StringUtils" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

final String PORTLET_NAME	= "Profile";

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
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>">
</head>
<body STYLE="background-color:transparent">
<table width="100%" class="pContainer">
	<tr>
		<td>

<%


			if(service != null)
			{
				// read configuration parameters for this portlet
				String sDBPrivilegeName			= (String)service.getParameter("DatabasePrivilegeName");
				boolean bAllowProfileDeletion 	= StringUtils.atob((String)service.getParameter("AllowProfileDeletion"), false);

				// parameters used to suggest when document is viewed
				// Set threshold (cheat - should end up getting this value from page edit or default edit values
				String svThreshold  = (String)service.getParameter("Threshold");
				String svNumResults = (String)service.getParameter("NumResults");
				int nThreshold  = StringUtils.atoi(svThreshold, 40);
				int nNumResults = StringUtils.atoi(svNumResults, 2);

				IDOLService idol = service.getIDOLService();
				AciConnection acicUser = new AciConnection(idol.getUserConnectionDetails());

				// Get user details
				String sUsername = (service.getUser()).getName();

				// Fully qualified URI towards images folder
				String sImageURL = service.makeLink("AutonomyImages");

				//Declare pane specific variables
				String fDeleteProfileFormName 		= service.makeFormName("DeleteProfile");
				String sProfileToDeleteIDParamName 	= service.makeParameterName("NPToDelete");

				// retrieve any request parameters
				String sIDOfProfileToDelete = service.getRequestParameter(sProfileToDeleteIDParamName);

				// there is a profile to delete so do that now
				if( StringUtils.strValid(sIDOfProfileToDelete) )
				{
					try
					{
						idol.useProfilingFunctionality().deleteProfile(new Profile(sIDOfProfileToDelete));
					}
					catch (AciException acix)
					{
						// continue and show user profile wasn't deleted
					}
				}

				// Currently there's no function in the API to get all of a user's
				// profile results at once, so construct the AciAction ourselves
				AciAction aciaProfile = new AciAction("ProfileGetResults");
				aciaProfile.setParameter(new ActionParameter("Username", sUsername));
				// I am unconvinced that this next parameter exists
				aciaProfile.setParameter(new ActionParameter("ProfileDetails", true));
				aciaProfile.setParameter(new ActionParameter("DRECombine", "Simple"));
				aciaProfile.setParameter(new ActionParameter("DREMaxResults", nNumResults));
				aciaProfile.setParameter(new ActionParameter("DREMinScore", nThreshold));
				aciaProfile.setParameter(new ActionParameter("DRESentences", 3));
				aciaProfile.setParameter(new ActionParameter("DRECharacters", 300));
				aciaProfile.setParameter(new ActionParameter("DREOutputEncoding", "utf8"));
				aciaProfile.setParameter(new ActionParameter("DREAnyLanguage", "true"));

				boolean bSuccess    = false;
				boolean bGotResults = false;

				acicUser.setTimeout(50000);
				AciResponse acirProfileResults = acicUser.aciActionExecute(aciaProfile);

				if(acirProfileResults != null)
				{
					if (acirProfileResults.checkForSuccess())
					{
						bSuccess = true;
						// check to see there is at least one entry
						if (acirProfileResults.findFirstOccurrence("autn:hit") != null)
						{
							bGotResults = true;
						}
					}

					// output named profile deletion form and table header
%>
					<table cellspacing="5"><tr><td>
					<form name="<%= fDeleteProfileFormName %>" action="<%= service.makeFormActionLink(" ") %>" method="POST">
						<%= service.makeAbstractFormFields() %>
						<input type="hidden" name="<%= sProfileToDeleteIDParamName %>" value="" />
					</form>

					<font class="<%= service.getCSSClass(PortalService.HEADER_TEXT_1) %>">
						&nbsp;<%= sUsername %><%=rb.getString("autonomyProfile.someoneProfileResults")%>
					</font>
					</td></tr></table>
					<table class="pResultList" width="90%" cellpadding="0" align="center">
					<tr>
					<td>
					<table width="100%">
						<tr><td colspan="3" height="6"></td></tr>
<%

					// output display
					if(bGotResults)
					{
						// set up parameters for standardResults_include.jsp
						boolean bStandardResults_sayNoResults		= false;
						boolean bStandardResults_withCheckboxes		= false;
						boolean bStandardResults_withImages			= true;
						boolean bStandardResults_withWeight			= false;
						boolean bStandardResults_withSummary 		= true;
						boolean bStandardResults_withDatabase		= false;
						boolean bStandardResults_withContent 		= true;
						boolean bStandardResults_withHighlights		= true;
						boolean bStandardResults_withTitle			= true;
						boolean bStandardResults_withConceptSummary	= true;
						boolean bStandardResults_withMail			= true;
						boolean bStandardResults_withAgent			= true;
						boolean bStandardResults_withSimilar		= true;
						boolean bUsingService						= true;
						String  mResultCheckBxs 					= null;
						// Read the backup logo name
						String sDefaultLogoName = (String)service.getParameter("DefaultLogoName");

						// locate first result set
						AciResponse acirProfile = acirProfileResults.findFirstOccurrence("autn:profile");
						// loop through profiles, displaying profile title and list of hits for each
						while( acirProfile != null )
						{
							String sProfileID = acirProfile.getTagValue("autn:pid", "");
							int nProfileHits  = StringUtils.atoi(acirProfile.getTagValue("autn:numhits", "0"), 0);
%>
							<tr >
								<td colspan="3" height="6">
								</td>
							</tr>

							<tr >
								<td colspan="3" height="3"></td>
							</tr>
<%
							// display results from this named profile
							AciResponse acirResult = acirProfile;
%>
							<%@ include file="standardResults_include.jspf" %>
<%
							// move on to next result set
							AciResponse acirNext = acirProfile.next();
							acirProfile = acirNext != null ? acirNext.findFirstOccurrence("autn:profile") : null;

							if( bAllowProfileDeletion && nProfileHits > 0)
							{
%>
								<tr>
									<td colspan="4" align="right">
										<a class="textButton" title="Delete from profile" href="javascript:document['<%= fDeleteProfileFormName %>']['<%= sProfileToDeleteIDParamName %>']['value']='<%= sProfileID %>';document['<%= fDeleteProfileFormName %>'].submit();" >
											<%=rb.getString("autonomyProfile.deleteProfile")%>
										</a>
									</td>
								</tr>

								<tr>
									<td colspan="4">
										<table width="100%" class="seperator">
											<tr>
												<td>
												</td>
											</tr>
										</table>
									</td>
								</tr>
<%
							}
						}	// while( acirProfile != null )
					}
					else if(bSuccess)
					{
						// if profile successfully read but no hits
%>
						<tr>
							<td></td>
							<td>
								<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
									<%=rb.getString("autonomyProfile.noResults")%>
								</font>
							</td>
						</tr>
<%
					}
					else
					{
%>
						<tr>
							<td></td>
							<td>
								<font class="<%= service.getCSSClass(PortalService.TEXT_1) %>">
									<%=rb.getString("autonomyProfile.unableReadProfile")%>
								</font>
							</td>
						</tr>
<%
					}
%>
					<!-- Finish off table -->
					</table>
					</td>
					</tr>
					</table>
<%
				}
				else	// acirProfileResults == null
				{
%>
					<font class="normal">
						<%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("autonomyCommunity.error.UANotFound")%><br/>
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
		</td>
	</tr>
</table>
</body>
</html>

