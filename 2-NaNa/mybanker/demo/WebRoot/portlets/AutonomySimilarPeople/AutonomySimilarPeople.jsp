<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "com.autonomy.APSL.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "com.autonomy.portlet.constants.CommonConstants"%>
<%@ page import = "com.autonomy.aci.AciAction" %>
<%@ page import = "com.autonomy.aci.AciConnection" %>
<%@ page import = "com.autonomy.aci.AciConnectionDetails" %>
<%@ page import = "com.autonomy.aci.AciResponse" %>
<%@ page import = "com.autonomy.aci.AciResponseChecker" %>
<%@ page import = "com.autonomy.aci.ActionParameter" %>
<%@ page import = "com.autonomy.aci.exceptions.AciException" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

final String PORTLET_NAME	= "SimilarPeople";

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

String  sImageURL = service.makeLink("AutonomyImages");
%>

<html>
<head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <link rel="stylesheet" type="text/css" href="<%= service.makeLink("AutonomyImages/autonomyportlets.css") %>">
</head>
<body STYLE="background-color:transparent">
<table width="100%" class="pContainer"><tr><td>

<%

if(service != null)
{
    // Get user details
    String sUsername = (service.getUser()).getName();

    //
    // Read user's community and analyse contents
    //

    // should similar people be found by comparing agents or profiles? Default is profiles.
    boolean bUseAgents 	    	= StringUtils.isTrue((String)service.getParameter("UseAgents"));
    boolean bProfilesFindAgents = StringUtils.isTrue((String)service.getParameter("ProfilesFindAgents"));
    int 	nMaxNumberOfStars 	= StringUtils.atoi  ((String)service.getSafeRequestParameter("MaxNumberOfStars", ""), 5);
    double	dSlopeFactor 		= StringUtils.atod  ((String)service.getSafeRequestParameter("SlopeFactor", ""), 9.0);

    // Read the user's community with either agents=true&agentServiceFactoryindprofiles=true
    //	or	 profile=true&profileServiceFactoryindagents=true
    // depending on bUseAgents

    try {
        // create and set up action
        AciAction similarPeopleAction = new AciAction("Community");
        similarPeopleAction.setParameter(new ActionParameter("DREPrint", "all"));
        similarPeopleAction.setParameter(new ActionParameter("Username", sUsername));
        // always return profiles
        similarPeopleAction.setParameter(new ActionParameter("Profiles", true));
        // should profiles find and return agents
        similarPeopleAction.setParameter(new ActionParameter("ProfilesFindAgents", bProfilesFindAgents));
        // should agents be returned
        similarPeopleAction.setParameter(new ActionParameter("Agents", bUseAgents));
        // should agents find and return profiles
        similarPeopleAction.setParameter(new ActionParameter("AgentsFindProfiles", bUseAgents));

        AciConnection aciConnection = new AciConnection(service.getIDOLService().getUserConnectionDetails());

        AciResponse aciResponse = aciConnection.aciActionExecute(similarPeopleAction);

        if(aciResponse != null && aciResponse.checkForSuccess())
        {
            // for each hit	(either profile or agent), find the corresponding owner's name and email and
            // increase that person's hitcount.

            // kind of hashtable used to manage hitcounts
            League lgSimilarPeople = new League();

            // loop through agent results first
            AciResponse acirAgent = aciResponse != null ? aciResponse.findFirstOccurrence("autn:agent") : null;

            while( acirAgent != null)
            {
                // loop through hits within agent entry
                AciResponse acirHit = acirAgent.findFirstOccurrence("autn:hit");

                while( acirHit != null )
                {
                    String sOthersUsername = acirHit.getTagValue("USERNAME");
                    String sOthersEmail    = acirHit.getTagValue("EMAILADDRESS");

                    if( sOthersUsername != null && !sOthersUsername.equals(sUsername) )
                    {
                        // store this user details and increase hitcount
                        if( !lgSimilarPeople.add(sOthersUsername, 1) ) //return value of false means that there was no existing entry
                        {
                            lgSimilarPeople.addSpareData("Full Name", sOthersUsername, sOthersUsername);
                            if( sOthersEmail != null )
                            {
                                lgSimilarPeople.addSpareData("Email Address", sOthersUsername, sOthersEmail);
                            }
                        }
                    }

                    acirHit = acirHit.next();
                }	//while( acirHit != null )

                acirAgent = acirAgent.next();
            }	//while( acirAgent != null)

            // now loop through profile results
            AciResponse acirProfileHit = aciResponse != null ? aciResponse.findFirstOccurrence("autn:profile") : null;
            while( acirProfileHit != null)
            {
                // loop through hits within agent entry
                AciResponse acirHit = acirProfileHit.findFirstOccurrence("autn:hit");

                while(acirHit != null)
                {
                    String sOthersUsername = acirHit.getTagValue("USERNAME");
                    String sOthersEmail    = acirHit.getTagValue("EMAILADDRESS");

                    if( sOthersUsername != null && !sOthersUsername.equals(sUsername) )
                    {
                        // store this user details and increase hitcount
                        if( !lgSimilarPeople.add(sOthersUsername, 1) ) //return value of false means that there was no existing entry
                        {
                            lgSimilarPeople.addSpareData("Full Name", sOthersUsername, sOthersUsername);
                            if( sOthersEmail != null )
                            {
                                lgSimilarPeople.addSpareData("Email Address", sOthersUsername, sOthersEmail);
                            }
                        }
                    } //while( acirHit != null )
                    acirHit = acirHit.next();
                }
                acirProfileHit = acirProfileHit.next();
            }	//while( acirProfileHit != null)

            //
            // finished adding entries to league table, can now display results
            //
            Vector vLeagueEntries =  lgSimilarPeople.makeLeagueTable();

            if( !vLeagueEntries.isEmpty() )
            {
            // result table title and (blank) first row
        %>

                <table cellspacing="5" width=320>
                    <tr>
                        <td colspan="2">
                            <font class="normalbold" >
                                <%=rb.getString("autonomySimilarPeople.similarPeople")%>
                            </font>
                        </td>
                    </tr>

                    <tr>
                        <td height="10" colspan="2"></td>
                    </tr>
        <%
                    // result table entry
                    for(int nLoop = 0; nLoop < vLeagueEntries.size(); nLoop++ )
                    {
                        LeagueEntry leSimilarPerson = (LeagueEntry)vLeagueEntries.elementAt(nLoop);
                        String sEntryName  = leSimilarPerson.getName();
                        String sEntryEmail = (String)lgSimilarPeople.getSpareData("Email Address", sEntryName);

                        // work out number of stars to display based on number of matchs found previously
                        // 'SlopeFactor' of 9 gives 5 stars after 15 matchs
                        double 	dTanh 		= MathUtils.tanh(((double)leSimilarPerson.getScore()) / dSlopeFactor);
                        int    	nEntryScore = (int)Math.round(nMaxNumberOfStars * dTanh);

%>
                        <tr>
                            <td width="50%">
                                <font class="<%= service.getCSSClass(PortalService.TEXT_1) %>" >
<%
                                    if( sEntryEmail != null && sEntryEmail.length() > 0 )
                                    {
%>
                                        <a href="mailto:<%= sEntryEmail %>">
                                            <%= sEntryName %>
                                        </a>
<%
                                    }
                                    else
                                    {
%>
                                        <%= sEntryName %>
<%
                                    }
%>
                                </font>
                            </td>
                            <td width="50%">
<%
                                for(int nScoreLoop = 0; nScoreLoop < nEntryScore; nScoreLoop++ )
                                {
%>
                                    <img src="<%= sImageURL %>/star.gif" border="0" alt="<%= nEntryScore %> star document">
<%
                                }
%>
                            </td>
                        </tr>
<%
                    }	// end of league table entry loop
%>
                </table>
<%
            }
            else	//if( !vLeagueEntries.isEmpty() )
            {
%>
                <table>
                    <tr><td>
                        <font class="<%= service.getCSSClass(PortalService.TEXT_1) %>" >
                            <%=rb.getString("autonomySimilarPeople.noSimilarPeople")%>
                        </font>
                    </td></tr>
                </table>
<%
            }
        }
        else	//if(aciResponse != null && aciResponse.checkForSuccess())
        {
%>
            <font class="normal">
                <%=rb.getString("autonomy2DMap.error.internalError")%> <%=rb.getString("autonomyCommunity.error.UANotFound")%><br/>
                <%=rb.getString("autonomy2DMap.error.internalError.contactWebAdmin")%>
            </font>
<%
        }
    } //try
    catch (AciException acie)
    {
%>
        <font class="normal">
            <%=rb.getString("autonomy2DMap.error.internalError") + " " + acie.getMessage() %> <br/>
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
