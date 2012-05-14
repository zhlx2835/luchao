<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.aci.businessobjects.Agent"%>
<%@ page import="com.autonomy.aci.businessobjects.ResultDocument"%>
<%@ page import="com.autonomy.aci.businessobjects.User"%>
<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.AgentConstants"%>
<%@ page import="com.autonomy.utilities.CSVTokenizer" %>
<%@ page import="com.autonomy.utilities.HTMLUtils" %>
<%@ page import="com.autonomy.utilities.StringUtils" %>

<%
response.setContentType("text/html; charset=utf-8");

// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)AgentConstants.PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(AgentConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(AgentConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(AgentConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// clear 'show edit form' flag if present
service.setSessionAttribute(AgentConstants.SESSION_ATTRIB_SHOW_EDIT_FORM, null);

// get the agent to edit. if there is no agent set on the session, then we are creating a new one
Agent selectedAgent = (Agent)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_SELECTED_AGENT);
if(selectedAgent == null)
{
	selectedAgent = new Agent();
}

// these names are used many times so it's worth recording them here
String agentFormName = service.makeFormName(AgentConstants.AGENT_FORM_NAME);
String agentTrainingParamName = service.makeParameterName(AgentConstants.REQUEST_PARAM_TRAINING_TEXT);

// this value is used many time so it's worth recording it here
boolean isUsingDate = StringUtils.isTrue(service.getSafeRequestParameter(service.makeParameterName(AgentConstants.REQUEST_PARAM_USE_DATE), "false"));

%>

<script type="text/javascript">
//<!-- script hiding
function selectAll(objCheckboxes, bChecked)
{
	if(objCheckboxes.type == "checkbox")
	{
		//One checkbox as opposed to an array of them
		//
		objCheckboxes.checked = bChecked;
	}
	else
	{
		for(i = 0; i < objCheckboxes.length; i++)
		{
			objCheckboxes[i].checked = bChecked;
		}
	}
}
function AUTN_WEBcheckForm()
{
	y=AUTN_WEBcheckLetters();

	if (y==true)
	{
		return(true);
	}
	else if(checkTrainingDocs())
	{
		return(true);
	}
	else
	{
		msg = "<%=rb.getString("displayAgentForm.alert.enterText")%>\n";
		alert(msg);
		return(false);
	}
}
function AUTN_WEBcheckLetters()
{
	var query = document['<%= agentFormName %>']['<%= agentTrainingParamName %>']['value'];

	if (query.length<1)
	{
		// Likely to be no words at all.NB single letter words in e.g. Japanese must count.
		return(false);
	}
	else
	{
		return(true);
	}
}

function isNull(a) {
    return typeof a == 'object' && !a;
}

function isObject(a) {
    return (a && typeof a == 'object');
}

function isArray(a) {
    return(typeof(a.length)=="undefined")?false:true;
}

function checkTrainingDocs()
{
	var trainingDocSelected = false;

	var trainingDocs = document['<%= agentFormName %>']['<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_TRAINING_FILES) %>'];
	if(isNull(trainingDocs))
	{
		return trainingDocSelected;
	}
	else if(isObject(trainingDocs)&&!isArray(trainingDocs))
	{
		trainingDocSelected = trainingDocs.checked;
		return trainingDocSelected;
	}
	else if(isArray(trainingDocs))
	{
		for(trainingDocIdx = 0; trainingDocIdx < trainingDocs.length && !trainingDocSelected; trainingDocIdx++)
        {
            trainingDocSelected = trainingDocs[trainingDocIdx].checked;
        }
        return trainingDocSelected;
	}
}

function checkAgentFormInfoSources()
{
	<%= getUsersDatabases(service).size() > 1 ? "" : "return true;" %>

	var sourceSelected = false;

	var infoSources = document['<%= agentFormName %>']['<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_INFO_SOURCES) %>'];
	for(sourceIdx = 0; sourceIdx < infoSources.length && !sourceSelected; sourceIdx++)
	{
		sourceSelected = infoSources[sourceIdx].checked;
	}

	if(!sourceSelected)
	{
		msg="<%=rb.getString("displayQueryForm.alert.selectInfoSource")%>";
		alert(msg);
	}

	return sourceSelected;
}

function submitAgentForm()
{
	formOK = AUTN_WEBcheckForm() && checkAgentFormInfoSources();

	if ( formOK )
	{
		var querytext = document['<%= agentFormName %>']['<%= agentTrainingParamName %>']['value'];
		var newquerytext = "";
		var foundAt=0;

		for (j=0; j<querytext.length; j++)
		{
			if (querytext.charCodeAt(j) == 13)
			{
				newquerytext = newquerytext + querytext.substring(foundAt, j);
				foundAt = j+1;
			}
			else if (querytext.charCodeAt(j) == 10)
			{
				newquerytext = newquerytext + querytext.substring(foundAt, j) + " ";
				foundAt = j+1;
			}
		}

		newquerytext = newquerytext + querytext.substring(foundAt);
		document['<%= agentFormName %>']['<%= agentTrainingParamName %>']['value'] = newquerytext;

		document['<%= agentFormName %>'].submit();
	}
}

function retrievalCheckForEnter()
{
	nLength = document['<%= agentFormName %>']['<%= agentTrainingParamName %>']['value']['length'];
	if( nLength > 2 )
	{
		if (document['<%= agentFormName %>']['<%= agentTrainingParamName %>']['value'].charAt(nLength-1) == "\n")
		{
			document['<%= agentFormName %>']['<%= agentTrainingParamName %>']['value'] = document['<%= agentFormName %>']['<%= agentTrainingParamName %>']['value'].substring(0,nLength-1);
			submitAgentForm();
		}
	}
}

function submitCancelForm()
{
	document['<%= service.makeFormName(AgentConstants.CANCEL_EDIT_FORM_NAME) %>'].submit();
}
// finished Script hiding-->
</script>

<!-- Output HTML content -->
<form name="<%= service.makeFormName(AgentConstants.CANCEL_EDIT_FORM_NAME) %>" action="<%= service.makeFormActionLink(" ")%>" method="POST">
	<%= service.makeAbstractFormFields() %>
	<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE) %>" value="<%= AgentConstants.JSP_PAGE_SHOW_AGENT%>"/>
</form>
<form name="<%= agentFormName %>" action="<%= service.makeFormActionLink(" ")%>" method="POST">
	<%= service.makeAbstractFormFields() %>
	<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_PAGE) %>" value="<%= AgentConstants.JSP_PAGE_UPDATE_AGENT%>"/>

	<table>
		<!-- AGENT NAME -->
		<tr>
			<td colspan="2">
				<font class="normalbold"><%=rb.getString("displayAgentForm.agent")%></font> &nbsp; <input type="text" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_AGENT_NAME) %>" value="<%= selectedAgent.getAgentname() %>" size="20" />
			</td>
		</tr>
		<!-- VSPACE -->
		<tr>
			<td colspan="2" height="5">
			</td>
		</tr>
		<!-- TRAINING TEXT -->
		<tr>
			<td colspan="2">
				<font class="normalbold">
					<%=rb.getString("displayAgentForm.training")%>
				</font>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="left">
				<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
					<textarea rows="5"
					          cols="49"
					          wrap="virtual"
					          tabindex="1"
					          onkeyup="javascript:retrievalCheckForEnter();"
					          name="<%= agentTrainingParamName %>"
					          ><%= StringUtils.XMLEscape(selectedAgent.getTraining()) %></textarea>
				</font>
			</td>
		</tr>
		<!-- VSPACE -->
		<tr>
			<td colspan="2" height="5">
			</td>
		</tr>
		<!-- TRAINING FILES -->
<%
		Iterator agentTrainingDocs = selectedAgent.getTrainingDocs().iterator();
		if(agentTrainingDocs.hasNext()){
%>
		<tr>
			<td colspan="2" height="5">
				<table>
<%
                                    while(agentTrainingDocs.hasNext())
					{
						ResultDocument trainingDoc = (ResultDocument)agentTrainingDocs.next();
%>
						<tr>
							<td>
								<input type="checkbox"
								       name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_TRAINING_FILES) %>"
								       value="<%= trainingDoc.getDocReference() %>"
								       checked="checked"
								       />
								<%= trainingDoc.getTitle() %>
							</td>
						</tr>
<%
					}
%>
				</table>
			</td>
		</tr>
<%
		}
%>
		<!-- RESULTS PER PAGE AND QUALITY -->
		<tr>
			<td nowrap="true">
				<font class="normalbold">
					<%=rb.getString("displayAgentForm.numOfResults")%>
				</font>
				&nbsp;
				<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
					<%= HTMLUtils.createSelect(service.makeParameterName(AgentConstants.REQUEST_PARAM_NUM_RESULTS),
					                                                     AgentConstants.NUM_RESULTS_OPTIONS,
					                                                     selectedAgent.getNumResults()
					                                                     )%>
				</font>
			</td>
			<td nowrap="true">
				&nbsp;
				<font class="normalbold">
					<%=rb.getString("displayAgentForm.quality")%>
				</font>
				&nbsp;
				<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
					<%= HTMLUtils.createSelect(service.makeParameterName(AgentConstants.REQUEST_PARAM_THRESHOLD),
					                                                     AgentConstants.THRESHOLD_OPTIONS,
					                                                     selectedAgent.getThreshold()
					                                                     )%>
				</font>
			</td>
		</tr>

		<!-- This produces a simple seperator -->

		<tr>
			<td colspan="2">
				<table width="315" class="seperator">
					<tr>
						<td>
						</td>
					</tr>
				</table>
			</td>
		</tr>

		<!-- AGE OF RESULS -->
		<tr>
			<td>
				<font class="normalbold">
					<%=rb.getString("displayAgentForm.ageOfResults")%>
				</font>
			</td>
			<td>
				<%= HTMLUtils.createSelect(service.makeParameterName(AgentConstants.REQUEST_PARAM_MAX_AGE),
				                                                     AgentConstants.maxAgeOptions(),
				                                                     AgentConstants.maxAgeValues(),
				                                                     selectedAgent.getMaxAgeOfResults()+"",
				                                                     null,
				                                                     false
				                                                     ) %>
			</td>
		</tr>

		<!-- This produces a simple seperator -->

		<tr>
			<td colspan="2">
				<table width="315" class="seperator">
					<tr>
						<td>
						</td>
					</tr>
				</table>
			</td>
		</tr>

		<!-- SOURCES -->
		<%
		if(getUsersDatabases(service).size() > 1)
		{
			%>
			<tr>
				<td>
					<font class="normalbold">
						<%=rb.getString("displayAgentForm.infoSources")%>
					</font>
				</td>
				<td>
						<%= HTMLUtils.createCheckboxs(service.makeParameterName(AgentConstants.REQUEST_PARAM_INFO_SOURCES),
					                                                            getUsersDatabases(service),
					                                                            getInfoSourceChecksList(service, selectedAgent),
					                                                            2
					                                                            )%>
				</td>
			</tr>
			<tr>
				<td>
					<font class="normalbold">
						<%=rb.getString("displayAgentForm.selectAll")%>
					</font>
					<input type="checkbox" name="selectAllbox" onClick="selectAll(this['form']['<%=service.makeParameterName(AgentConstants.REQUEST_PARAM_INFO_SOURCES)%>'], checked)" />
				</td>
			</tr>

			<!-- This produces a simple seperator -->

			<tr>
				<td colspan="2">
					<table width="315" class="seperator">
						<tr>
							<td>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<%
		}
		else if(getUsersDatabases(service).size() == 1)
		{
			%>
			<input type="hidden" name="<%= service.makeParameterName(AgentConstants.REQUEST_PARAM_INFO_SOURCES) %>" value="<%= (String)getUsersDatabases(service).get(0) %>"/>
			<%
		}
		%>

		<!-- VSPACE -->
		<tr>
			<td colspan="2" height="5">
			</td>
		</tr>

		<!-- QUERY LANGUAGE -->
		<tr>
			<td colspan="2">
				<font class="normalbold">
					<%=rb.getString("displayAgentForm.queryIn")%>
				</font>
				<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
					<%= HTMLUtils.createSelect(service.makeParameterName(AgentConstants.REQUEST_PARAM_QUERY_LANGUAGE),
					                                                     readLanguageNames(service),
					                                                     readLanguageTypes(service),
					                                                     selectedAgent.getAgentFieldValue("DRELanguageType", getUsersDefaultQueryLanguage(service)),
					                                                     null,
					                                                     false
					                                                     )%>
				</font>
			</td>
		</tr>

		<!-- This produces a simple seperator -->

		<tr>
			<td colspan="2">
				<table width="315" class="seperator">
					<tr>
						<td>
						</td>
					</tr>
				</table>
			</td>
		</tr>

		<!-- VSPACE -->
		<tr>
			<td colspan="2" height="5">
			</td>
		</tr>

		<!-- SORTING -->
		<tr>
			<td colspan="2">
				<font class="normalbold">
					<%=rb.getString("displayAgentForm.sortBy")%>
				</font>

				<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
					<%= HTMLUtils.createSelect(service.makeParameterName(AgentConstants.REQUEST_PARAM_SORT_BY),
					                                                     AgentConstants.SORT_TYPES,
					                                                     selectedAgent.getAgentFieldValue("DRESort", "Relevence"),
					                                                     false
					                                                     )%>
				</font>
			</td>
		</tr>


		<tr>
			<td colspan="2">
			<table width="315" class="seperator">
				<tr>
					<td>
					</td>
				</tr>
			</table>
			</td>
		</tr>

		<!-- VSPACE -->
		<tr>
			<td colspan="2" height="5">
			</td>
		</tr>
		<!--SHOWN IN COMMUNITY-->

		<tr>
			<td colspan="2">
				<font class="normalbold">
					<%=rb.getString("displayAgentForm.shownInCommunity")%>
				</font>
				<input type="checkbox" name="<%= service.makeParameterName("ShownInCommunity") %>" <%= selectedAgent.isShownInCommunity() ? "checked" : "" %> />

			</td>
		</tr>


		<tr>
			<td colspan="2">
				<table width="315" class="seperator">
				<tr>
					<td>
					</td>
				</tr>
				</table>
			</td>
		</tr>

		<!-- VSPACE -->
		<tr>
			<td colspan="2" height="5">
			</td>
		</tr>

		<tr>
			<td colspan="2" align="left">
				<a class="textButton" href="javascript:submitAgentForm();" title="Update agent">
					<%=rb.getString("displayAgentForm.submit")%>
				</a>
				&nbsp;
				<a class="textButton" href="javascript:submitCancelForm();" title="Cancel edit">
					<%=rb.getString("displayAgentForm.cancel")%>
				</a>
			</td>
		</tr>
	</table>
</form>

<%!
private ArrayList getInfoSourceChecksList(PortalService service, Agent agent)
{
	return checkSelectedOptions(agent.getDatabases(), getUsersDatabases(service));
}
private ArrayList getUsersDatabases(PortalService service)
{
	return ((User)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_USER)).getPrivilegeValues((String)service.getParameter(PortalService.CONFIG_DATABASE_PRIVILEGE));
//	return service.getUser().getPrivilegeValues(service.getConfigParameter(PortalService.CONFIG_DATABASE_PRIVILEGE, ""))
}
private String getUsersDefaultQueryLanguage(PortalService service)
{
	return ((User)service.getSessionAttribute(AgentConstants.SESSION_ATTRIB_USER)).getUserFieldValue("drelanguagetype", "");
}

private ArrayList readLanguageNames(PortalService service)
{
	return new CSVTokenizer(service.readConfigParameter("LanguageTypesDisplayNames", "English")).asList();
}
private ArrayList readLanguageTypes(PortalService service)
{
	return new CSVTokenizer(service.readConfigParameter("LanguageTypes", "englishUTF8")).asList();
}

private static ArrayList checkSelectedOptions(List selectedOptions, List availableOptions)
{
	ArrayList checks = new ArrayList();

	if(availableOptions != null && !availableOptions.isEmpty())
	{
		if(selectedOptions != null && !selectedOptions.isEmpty())
		{
			Iterator options = availableOptions.iterator();
			while(options.hasNext())
			{
				String option = (String)options.next();
				if(selectedOptions.contains(option))
				{
					checks.add(Boolean.TRUE);
				}
				else
				{
					checks.add(Boolean.FALSE);
				}
			}
		}
		else
		{
			// if there are no selected options, this is either the first time the portlet is
			// invoked or there has been a user error.
			// in either case, all options should be displayed as selected:
			for(int nOptionIdx = 0; nOptionIdx < availableOptions.size(); nOptionIdx++)
			{
				checks.add(Boolean.TRUE);
			}
		}
	}
	return checks;
}
private static void mylog(String s)
{
	System.out.println("displayAgentForm.jsp " + s);
}
%>