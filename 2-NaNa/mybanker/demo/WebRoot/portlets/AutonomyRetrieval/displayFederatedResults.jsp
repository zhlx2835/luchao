<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.RetrievalConstants"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>
<%@ page import="com.autonomy.webapps.utils.federated.FederatedResult"%>

<%
response.setContentType("text/html; charset=utf-8");


// Set up services 
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)RetrievalConstants.PORTLET_NAME);

ArrayList federatedResults = (ArrayList)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_FEDERATED_RESULTS);
if(federatedResults != null)
{
	if(federatedResults.size() > 0)
	{
		// display 'sets' of one search result from each engine until one engine runs out of results or
		// the configured number of results have been displayed.

		int nResultsSetIdx = 0;
		int nResultsPrintedCnt = 0;
		boolean bStillHaveResults = true;

%>
	<table class="pResultList" width="90%" cellpadding="0" border="0" align="center">
		<tr>
			<td align="left" colspan="2">
				<font class="normalbold">
					Federated Search Results
				</font>
			</td>		
		</tr>
		<tr>
			<td height="5" />
		</tr>
<%
		int nFedResultsCnt = StringUtils.atoi(service.readConfigParameter("NumberOfFederatedResultsToDisplay", "0"), 0);
		while(bStillHaveResults && (nResultsPrintedCnt < nFedResultsCnt))
		{
			// display one result from each search engine
			Iterator itResultsForAllEngines = federatedResults.iterator();
			while(itResultsForAllEngines.hasNext())
			{
				// for each engine print out the result corresponding to the current 'set'
				ArrayList alSingleEngineResults = (ArrayList)itResultsForAllEngines.next();	
				bStillHaveResults = alSingleEngineResults.size() > nResultsSetIdx;
				if(bStillHaveResults)
				{
					FederatedResult result = (FederatedResult)alSingleEngineResults.get(nResultsSetIdx);
					String engineImageIconPath = service.makeLink("AutonomyImages") + result.image;
%>
					<tr align="left">
						<td valign="middle">
							<img src="<%= engineImageIconPath %>" />&nbsp;
						</td>
						<td>

							<a href="<%= result.reference %>" target="_result">
								<b><%= result.title%></b>
								<%
								String stitle = result.title;
								String strtitle = new String(stitle.getBytes("gbk"),"utf-8"); 
								out.println("----"+strtitle);
								%>
							</a>
						</td>
					</tr>
					<tr align="left">
						<td></td>
						<td>	
							<%= result.summary %>
						</td>
					</tr>
					<tr align="left">
						<td></td>
						<td>	
							<%= result.reference %>
						</td>
					</tr>
					<tr><td height="6" /></tr>
<%
					nResultsPrintedCnt++;
				}	//if (bStillHaveResults)
			}	//while(itResultsForAllEngines.hasNext())	
			nResultsSetIdx++;
		}	//while(bStillHaveResults && (nResultsPrintedCnt < nFedResultsCnt))
%>
	</table>
<%
	}
	else
	{
%>
	<table class="pResultList" width="90%" cellpadding="0" border="0" align="center">
		<tr>
			<td align="left">
				<font class="normalbold">
					Federated Search Results
				</font>
			</td>		
		</tr>
		<tr>
			<td height="5" />
		</tr>
		<tr align="left">
			<td>
				<font class="<%= service.getCSSClass(service.TEXT_2) %>">
					No results were found.
				</font>
			</td>
		</tr>
	</table>
<%
	}
}	//if(federatedResults != null)
%>
