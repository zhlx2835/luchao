<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.autonomy.aci.*" %>
<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.APSL.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

StandaloneService.markAsStandalone(session);
PortalService service = ServiceFactory.getService((Object)request, (Object)response, "default");

String  sImageURL = service.makeLink("AutonomyImages");
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/portalinabox.css">
	<link rel="stylesheet" type="text/css" href="<%= sImageURL %>/autonomyportlets.css">
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
		<script type="text/javascript" >
			<!--
			window.focus();
			//-->
		</script>
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />


<%
	String sAgentName   	= request.getParameter("agentname");
	String sTermStringEnc 	= request.getParameter("tnw");
	String sUsernameEnc   	= request.getParameter("username");
	String sThreshold		= request.getParameter("threshold");
	String sNumResult		= request.getParameter("numresults");
	String sCommunity		= request.getParameter("addtocommunity");

	if (StringUtils.strValid(sAgentName) && StringUtils.strValid(sUsernameEnc) && 
			StringUtils.strValid(sTermStringEnc) && StringUtils.strValid(sCommunity))
	{
		// set defaults if necessary
		if (!StringUtils.strValid(sThreshold))
		{
			sThreshold = "40";
		}
		if (!StringUtils.strValid(sNumResult))
		{
			sNumResult = "6";
		}
		
		// decrypt/unencode parameters for agent add
		String sUsername 	= StringUtils.decryptString(sUsernameEnc);
		String sTermString 	= StringUtils.decryptString(sTermStringEnc);

		//
		// add the agent for this user  
		//
		
		// Set server details
		AciConnectionDetails acicdUser = service.getIDOLService().getUserConnectionDetails();
		AciConnection acicUser = new AciConnection(acicdUser);

		// Set action
		AciAction aciaAgentAdd = new AciAction("AgentAdd");
		aciaAgentAdd.setParameter(new ActionParameter("Username", sUsername));
		aciaAgentAdd.setParameter(new ActionParameter("AgentName", sAgentName));
		aciaAgentAdd.setParameter(new ActionParameter("Training", sTermString));
		aciaAgentAdd.setParameter(new ActionParameter("Threshold", sThreshold));
		aciaAgentAdd.setParameter(new ActionParameter("NumResults", sNumResult));

		AciResponse acir = acicUser.aciActionExecute(aciaAgentAdd);

		if (acir != null)
		{
			if (acir.checkForSuccess())
			{
%>
				<title>Agent created successfully</title>
				</head>
				<body>
					<table class="pResultList"><tr><td>
					<font class="normal">
						Agent <%= sAgentName %> successfully created.<br />
						<br />
						<a href="javascript:this.window.close();">
							Click here
						</a> 
						to close this window.
					</font>
					</td></tr></table>
				</body>
<%
			}
			else
			{
				String sError = acir.getTagValue("errordescription");
%>
				<title>Error</title>
				</head>
				<body>
					<table class="pResultList"><tr><td>				
					<font class="normal">
						Error creating agent: <%=sError%>.<br />
						Please contact your system administrator if this is persistent. <br />
						<br />
						<a href="javascript:this.window.close();">
							Click here
						</a> 
						to close this window.
					</font>
					</td></tr></table>					
				</body>
<%
			}
		}
		else	// response was null
		{
%>
			<title>Error</title>
			</head>
			<body>
				<font class="normal">
					Error creating agent: Community server did not return a response.<br />
					Please contact your system administrator if this is persistent. <br />
					<br />
					<a href="javascript:this.window.close();">
						Click here
					</a> 
					to close this window.
				</font>
			</body>
<%						
		}
	}
	else
	{
		out.print("parameter missing <br/>");
	}
%>
</html>