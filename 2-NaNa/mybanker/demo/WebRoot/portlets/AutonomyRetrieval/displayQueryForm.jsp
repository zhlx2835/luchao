<%@ page import="java.util.ArrayList,
                 java.util.Calendar,
                 java.util.GregorianCalendar,
                 java.util.Iterator,
                 java.util.List,
                 java.util.Locale,
                 java.util.ResourceBundle,
                 com.autonomy.aci.businessobjects.User,
                 com.autonomy.APSL.PortalService,
                 com.autonomy.APSL.ServiceFactory,
                 com.autonomy.portlet.constants.RetrievalConstants,
                 com.autonomy.utilities.CSVTokenizer,
                 com.autonomy.utilities.HTMLUtils,
                 com.autonomy.utilities.StringUtils,
                 com.autonomy.webapps.utils.parametric.ParametricFieldInfo"%><%

response.setContentType("text/html; charset=utf-8");

// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)RetrievalConstants.PORTLET_NAME);

//get Locale information from session
String sLocale =(String)session.getAttribute(RetrievalConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(RetrievalConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(RetrievalConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// these names are used many times so it's worth recording them here
String queryFormName = service.makeFormName(RetrievalConstants.QUERY_FORM_NAME);
String queryTextParamName = service.makeParameterName(RetrievalConstants.REQUEST_PARAM_QUERY_TEXT);

// this value is used many time so it's worth recording it here
boolean isUsingDate = StringUtils.isTrue(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_DATE), "false"));

// it's easier to deal with calendar than date strings
GregorianCalendar calenderFromDate = readMinDate(service);
GregorianCalendar calenderToDate = readMaxDate(service);

// query text is overidden by query expansion path if present (modify in displayNavigationBar_include.jsp as well)
String queryText = service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_EXPANSION_PATH));

if(!StringUtils.strValid(queryText) || getBrowsingType(service).equalsIgnoreCase("DynamicClustering") || getBrowsingType(service).equalsIgnoreCase("DynamicThesaurus") || getBrowsingType(service).equalsIgnoreCase("AQG") || getBrowsingType(service).equalsIgnoreCase("IdeasCloud"))
{
	queryText = service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_QUERY_TEXT), "").trim();
}
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
function AUTN_WEBcheckText()
{
	y=AUTN_WEBcountLetters();

	if (y==true)
	{
		return(true);
	}
	else
	{
		msg = "<%=rb.getString("displayQueryForm.alert.enterText")%>";
		alert(msg);
		return(false);
	}
}
function AUTN_WEBcountLetters()
{
	var query = document['<%= queryFormName %>']['<%= queryTextParamName %>']['value'];

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

function isAnObject(a) {
    return (a && typeof a == 'object');
}

function isAnArray(a) {
    return(typeof(a.length)=="undefined")?false:true;
}

function checkInfoSources()
{
	var sourceSelected = false;

	var infoSources = document['<%= queryFormName %>']['<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES) %>'];

    if(isAnObject(infoSources)&&(!isAnArray(infoSources)))
	{
		sourceSelected = infoSources.checked;
	}
	else if(isAnArray(infoSources))
	{
		for(sourceIdx = 0; sourceIdx < infoSources.length && !sourceSelected; sourceIdx++)
		{
			sourceSelected = infoSources[sourceIdx].checked;
		}
	}
    if(!sourceSelected)
	{
		msg="<%=rb.getString("displayQueryForm.alert.selectInfoSource")%>";
		alert(msg);
	}

	return sourceSelected;
}

function retrievalSubmitForm()
{
	if(AUTN_WEBcheckText() && checkInfoSources())
	{
		var querytext = document['<%= queryFormName %>']['<%= queryTextParamName %>']['value'];
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
		document['<%= queryFormName %>']['<%= queryTextParamName %>']['value'] = newquerytext;

		document['<%= queryFormName %>'].submit();
	}
}

function retrievalCheckForEnter()
{
	nLength = document['<%= queryFormName %>']['<%= queryTextParamName %>']['value']['length'];
	if( nLength > 2 )
	{
		if (document['<%= queryFormName %>']['<%= queryTextParamName %>']['value'].charAt(nLength-1) == "\n")
		{
			document['<%= queryFormName %>']['<%= queryTextParamName %>']['value'] = document['<%= queryFormName %>']['<%= queryTextParamName %>']['value'].substring(0,nLength-1);
			retrievalSubmitForm();
		}
	}
}

// finished Script hiding-->
</script>

<!-- Output HTML content -->
<form name="<%= queryFormName %>" action="<%= service.makeFormActionLink(" ")%>queryResultsTop" method="POST">
	<%= service.makeAbstractFormFields() %>
	<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PAGE) %>" value="<%= RetrievalConstants.JSP_PAGE_DO_QUERY %>"/>
	<!-- used by query suggestion mechanism to set specify which query expansion node is invoked -->
	<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_EXPANSION_PATH) %>" value=""/>
	<!-- used by parametric browsing mechanism to specify which parametric value is invoked -->
	<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PARAM_VALUE) %>" value=""/>

	<table width="100%" cellspacing="5">
		<tr>
			<td>
				<table>
					<!-- QUERY TEXT -->
					<tr>
						<td colspan="2">
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.queryText")%>
							</font>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="right">
							<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
								<textarea rows="5"
								          cols="49"
								          wrap="virtual"
								          tabindex="1"
								          onkeyup="javascript:retrievalCheckForEnter();"
								          name="<%= queryTextParamName %>"
 								          ><%= StringUtils.XMLEscape(queryText) %></textarea>
							</font>
						</td>
					</tr>

					<!-- RESULTS PER PAGE AND QUALITY -->
					<tr>
						<td nowrap=true>
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.numOfResults")%>
							</font>
								&nbsp;
							<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
								<%= HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_NUM_RESULTS),
								                                                     RetrievalConstants.NUM_RESULTS_OPTIONS,
								                                                     Integer.parseInt(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_NUM_RESULTS), "6"))
								                                                     )%>
							</font>
						</td>
						<td align="right">
							<table cellpadding="0">
								<tr>
									<td>
										<font class="normalbold">
											<%=rb.getString("displayQueryForm.quality")%>
										</font>
										&nbsp;
									</td>
									<td>
										<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
											<%= HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_THRESHOLD),
											                                                     RetrievalConstants.THRESHOLD_OPTIONS,
											                                                     Integer.parseInt(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_THRESHOLD), "20"))
											                                                     )%>
										</font>
									</td>
								</tr>
							</table>
						</td>
					</tr>

					<!-- This produces a simple separator -->

					<tr>
						<td colspan="2">
							<table width="315" class="separator">
								<tr>
									<td>
									</td>
								</tr>
							</table>
						</td>
					</tr>

					<tr>
						<td colspan="2">
						<font class="normalbold">
								<%=rb.getString("displayQueryForm.useDates")%>
							</font>
							<input type="checkbox"
							       name="<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_DATE)%>"
							       onClick="this['form']['<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY)%>']['disabled'] = !this.checked;
							                this['form']['<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH)%>']['disabled'] = !this.checked;
							                this['form']['<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR)%>']['disabled'] = !this.checked;
							                this['form']['<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY)%>']['disabled'] = !this.checked;
							                this['form']['<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH)%>']['disabled'] = !this.checked;
							                this['form']['<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR)%>']['disabled'] = !this.checked;"
							                <%= isUsingDate ? "checked=\"checked\"" : "" %>
							                />
						</td>
					</tr>

					<!-- DATES -->
					<tr>

						<td colspan="2" align="right">
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.useDates.from")%>
							</font>
							<%=HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY),
							                                                    RetrievalConstants.DAYS_OF_MONTH,
							                                                    StringUtils.padWithZeros(calenderFromDate.get(Calendar.DATE) + "",2),
							                                                    !isUsingDate
							                                                    )%>
							&nbsp;
							<%=HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH),
							                                                    RetrievalConstants.MONTHS_OF_YEAR,
							                                                    StringUtils.padWithZeros((calenderFromDate.get(Calendar.MONTH)+1) + "",2), // Have to add 1 because months are saved 0-11
							                                                    !isUsingDate
							                                                    )%>
							&nbsp;
							<%=HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR),
							                                                    getYears(),
							                                                    calenderFromDate.get(Calendar.YEAR) + "",
							                                                    !isUsingDate
							                                                    )%>
						</td>
					</tr>
					<tr>
						<td colspan="2" align="right">
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.useDates.to")%>
							</font>
							<%=HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY),
							                                                    RetrievalConstants.DAYS_OF_MONTH,
							                                                    StringUtils.padWithZeros(calenderToDate.get(Calendar.DATE) + "",2),
							                                                    !isUsingDate
							                                                    )%>
							&nbsp;
							<%=HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH),
							                                                    RetrievalConstants.MONTHS_OF_YEAR,
							                                                    StringUtils.padWithZeros((calenderToDate.get(Calendar.MONTH)+1) + "",2), // Have to add 1 because months are saved 0-11
							                                                    !isUsingDate
							                                                    )%>
							&nbsp;
							<%=HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR),
							                                                    getYears(),
							                                                    calenderToDate.get(Calendar.YEAR) + "",
							                                                    !isUsingDate
							                                                    )%>
						</td>
					</tr>

					<!-- This produces a simple separator -->

					<tr>
						<td colspan="2">
							<table width="315" class="separator">
								<tr>
									<td>
									</td>
								</tr>
							</table>
						</td>
					</tr>

					<!-- SOURCES -->
					<tr>
						<td>
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.infoSources")%>
							</font>
						</td>
						<td>
							<%= HTMLUtils.createCheckboxs(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES),
							                                                        getUsersDatabases(service),
							                                                        getInfoSourceChecksList(service),
							                                                        2
							                                                        )%>
						</td>
					</tr>
					<tr>
						<td>
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.selectAll")%>
							</font>
							<input type="checkbox" name="selectAllbox" onClick="selectAll(this['form']['<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES)%>'], checked)" />
						</td>
					</tr>

					<!-- This produces a simple separator -->

					<tr>
						<td colspan="2">
							<table width="315" class="separator">
								<tr>
									<td>
									</td>
								</tr>
							</table>
						</td>
					</tr>

					<!-- This bit lowers the sorting stuff so everything looks in place -->
					<tr>
						<td colspan="2" height="5">
						</td>
					</tr>

					<!-- QUERY LANGUAGE -->
					<tr>
						<td colspan="2">
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.queryIn")%>
							</font>
							<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
								<%= HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_QUERY_LANGUAGE),
								                                                     readLanguageNames(service),
								                                                     readLanguageTypes(service),
								                                                     service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_QUERY_LANGUAGE), getUsersDefaultQueryLanguage(service)),
								                                                     null,
								                                                     false
								                                                     )%>
							</font>
						</td>
					</tr>

					<!-- This produces a simple separator -->

					<tr>
						<td colspan="2">
							<table width="315" class="separator">
								<tr>
									<td>
									</td>
								</tr>
							</table>
						</td>
					</tr>

					<!-- This bit lowers the sorting stuff so everything looks in place -->
					<tr>
						<td colspan="2" height="5">
						</td>
					</tr>

					<!-- SORTING -->
					<tr>
						<td colspan="2">
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.sortBy")%>
							</font>

							<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
								<%= HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SORT_BY),
								                                                     RetrievalConstants.SORT_TYPES,
								                                                     service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SORT_BY), "Relevance"),
								                                                     false
								                                                     )%>
							</font>
						</td>
					</tr>

<%
				if(service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO) != null)
				{
%>
					<!-- This produces a simple separator --> <tr> <td colspan="2"> <table width="315" class="separator"> <tr> <td> </td> </tr> </table> </td> </tr>

					<!-- This bit lowers the sorting stuff so everything looks in place --> <tr> <td colspan="2" height="5"> </td> </tr>

					<!-- PARAMETRIC FIELDS -->
					<tr><td colspan="2"><table>
<%
					Iterator parametricFields = ((List)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO)).iterator();
					while(parametricFields.hasNext())
					{
						ParametricFieldInfo fieldInfo = (ParametricFieldInfo)parametricFields.next();
						String onChangeCall = "javascript:reloadParametricFields('"+ fieldInfo.getDisplayName() + "');";
%>
						<tr>
							<td>
								<font class="normalbold">
									<%= fieldInfo.getDisplayName() %>:
								</font>
							</td>
							<td>
								<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
									<%= HTMLUtils.createSelect(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PARAM_FIELD_PREFIX + fieldInfo.getDisplayName()),
									                                                     fieldInfo.getValueDisplayNames(),
									                                                     fieldInfo.getIDOLValues(),
									                                                     fieldInfo.getSelectedValue(),
									                                                     null,
									                                                     false,
									                                                     onChangeCall
									                                                     )%>
								</font>
							</td>
						</tr>
<%
					}
%>
					</table></td></tr>
<%
				}
%>



					<!-- FEDERATED SEARCH -->
				<%
					if(StringUtils.isTrue((String)service.getParameter("DisplayFederatedSearch")))
					{
				%>
					<!-- This produces a simple separator -->

					<tr>
						<td colspan="2">
							<table width="315" class="separator">
								<tr>
									<td>
									</td>
								</tr>
							</table>
						</td>
					</tr>

					<tr>
						<td>
							<font class="normalbold">
								<%=rb.getString("displayQueryForm.federatedSearch")%>
								<input type="checkbox"
								       name="<%=service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FEDERATED)%>"
								       <%= StringUtils.isTrue(service.getSafeRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FEDERATED), "false")) ? "checked=\"checked\"" : "" %>
								       />
							</font>
						</td>
						<td>
							<%= HTMLUtils.createCheckboxs(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_FED_ENGINES),
							                                                        getFederatedEngineNameList(service),
							                                                        getFederatedEngineChecksList(service),
							                                                        3
							                                                        )%>
						</td>
					</tr>
				<%
					}
				%>

					<!-- This bit lowers the sorting stuff so everything looks in place -->
					<tr>
						<td colspan="2" height="5">
						</td>
					</tr>
					<tr>
						<td colspan="2" align="right">
							<a class="textButton" href="javascript:retrievalSubmitForm();" title="Search">
								<%=rb.getString("displayQueryForm.search")%>
							</a>

						</td>
					</tr>

				</table>
			</td>
		</tr>
	</table>
</form>
<%
// form and javascript for parametric field operations
if(service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO) != null)
{
%>
	<script type="text/javascript">
	//<!-- script hiding
	function reloadParametricFields(modifiedFieldName)
	{
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_MODIFIED_FIELD) %>.value = modifiedFieldName;
		document.parametricform.<%= queryTextParamName %>.value = document.<%= queryFormName %>.<%= queryTextParamName %>.value;
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_NUM_RESULTS) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_NUM_RESULTS) %>.value;
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_THRESHOLD) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_THRESHOLD) %>.value;
		if(document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_DATE) %>.checked==true)
		{
			document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_DATE) %>.value = 'true';
		}
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY) %>.value;
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH) %>.value;
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR) %>.value;
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY) %>.value;
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH) %>.value;
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR) %>.value;
		document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SORT_BY) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SORT_BY) %>.value;
		var infoSources = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES) %>;
		for(var i=0; i<infoSources.length; i++)
		{
			if(document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES) %>[i].checked==true)
		  		{document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES) %>[i].value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES) %>[i].value;}
		}
<%
		Iterator parametricFields = ((List)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO)).iterator();
		while(parametricFields.hasNext())
		{
			ParametricFieldInfo fieldInfo = (ParametricFieldInfo)parametricFields.next();
%>
			document.parametricform.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PARAM_FIELD_PREFIX + fieldInfo.getDisplayName()) %>.value = document.<%= queryFormName %>.<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PARAM_FIELD_PREFIX + fieldInfo.getDisplayName()) %>.value;
<%
		}
%>
		document.parametricform.submit();
	}

	// finished Script hiding-->
	</script>
	<form name="parametricform" action="<%= service.makeFormActionLink(" ")%>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PAGE) %>" value="<%= RetrievalConstants.JSP_PAGE_UPDATE_PARAMETRIC %>"/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_MODIFIED_FIELD) %>" value=""/>
		<input type="hidden" name="<%= queryTextParamName %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_NUM_RESULTS) %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_THRESHOLD) %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_DATE) %>"  value="false"/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY) %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH) %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR) %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY) %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH) %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR) %>" value=""/>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_SORT_BY) %>" value=""/>

		<%
				for(int i=0; i<getUsersDatabases(service).size(); i++)
				{
		%>
					<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES) %>" value=""/>
		<%
		}
		parametricFields = ((List)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO)).iterator();
		while(parametricFields.hasNext())
		{
			ParametricFieldInfo fieldInfo = (ParametricFieldInfo)parametricFields.next();
%>
		<input type="hidden" name="<%= service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PARAM_FIELD_PREFIX + fieldInfo.getDisplayName()) %>" value=""/>
<%
		}
%>
	</form>
<%
}
%>

<%!
private ArrayList getInfoSourceChecksList(PortalService service)
{
	return checkSelectedOptions(service.getRequestParameterValues(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_INFO_SOURCES)),
															getUsersDatabases(service)
															);
}
private ArrayList getFederatedEngineChecksList(PortalService service)
{
	return checkSelectedOptions(service.getRequestParameterValues(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_FED_ENGINES)),
															getFederatedEngineNameList(service)
															);
}
private ArrayList getFederatedEngineNameList(PortalService service)
{
	ArrayList fedEngineNames = new ArrayList();

	int nAvailableFedEngineCnt = StringUtils.atoi(service.readConfigParameter("NumberOfFederatedEngines", "0"), 0);
	for (int nEngineIdx = 0; nEngineIdx < nAvailableFedEngineCnt; nEngineIdx++)
	{
		fedEngineNames.add(service.readConfigParameter("FederatedEngine." + nEngineIdx + ".name", ""));
	}

	return fedEngineNames;
}
private ArrayList getUsersDatabases(PortalService service)
{
	return ((User)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER)).getPrivilegeValues((String)service.getParameter(PortalService.CONFIG_DATABASE_PRIVILEGE));
//	return service.getUser().getPrivilegeValues(service.getConfigParameter(PortalService.CONFIG_DATABASE_PRIVILEGE, ""))
}
private String getUsersDefaultQueryLanguage(PortalService service)
{
	return ((User)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_USER)).getUserFieldValue("drelanguagetype", "englishUTF8");
}
private ArrayList readLanguageNames(PortalService service)
{
	return new CSVTokenizer(service.readConfigParameter("LanguageTypesDisplayNames", "English")).asList();
}
private ArrayList readLanguageTypes(PortalService service)
{
	return new CSVTokenizer(service.readConfigParameter("LanguageTypes", "englishUTF8")).asList();
}
/**
 *	Set calendar using date read from request or 2 months ago if there is no date info on the request.
 */
private GregorianCalendar readMinDate(PortalService service)
{
	GregorianCalendar calenderMinDate;

	String svFromDateDay		= service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_DAY));
	String svFromDateMonth	= service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_MONTH));
	String svFromDateYear		= service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_FROM_YEAR));
	if(StringUtils.strValid(svFromDateDay))
	{
		// set calendar using date read from request
		calenderMinDate = new GregorianCalendar();
		calenderMinDate.set(StringUtils.atoi(svFromDateYear, 1999),
		                    StringUtils.atoi(svFromDateMonth, 1) - 1, // Months are stored 0-11
		                    StringUtils.atoi(svFromDateDay, 1));
	}
	else
	{
		// not coming from a query so use 2 months ago as min date and today as max date.
		calenderMinDate = (GregorianCalendar)Calendar.getInstance();
		calenderMinDate.add(Calendar.MONTH, -2);
	}
	return calenderMinDate;
}

/**
 *	Set calendar using date read from request or today if there is no date info on the request.
 */
private GregorianCalendar readMaxDate(PortalService service)
{
	GregorianCalendar calenderMaxDate;

	String svToDateDay			= service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_DAY));
	String svToDateMonth		= service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_MONTH));
	String svToDateYear			= service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_USE_TO_YEAR));
	if(StringUtils.strValid(svToDateDay))
	{
		Calendar today = (GregorianCalendar)Calendar.getInstance();
		calenderMaxDate = new GregorianCalendar();
		calenderMaxDate.set(StringUtils.atoi(svToDateYear, today.get(Calendar.YEAR)),
		                    StringUtils.atoi(svToDateMonth, today.get(Calendar.MONTH) + 1) - 1, // Months are stored 0-11
		                    StringUtils.atoi(svToDateDay, today.get(Calendar.DATE)));
	}
	else
	{
		calenderMaxDate = (GregorianCalendar)Calendar.getInstance();
	}
	return calenderMaxDate;
}

private static ArrayList checkSelectedOptions(String[] saSelectedOptions, List availableOptions)
{
	ArrayList checks = new ArrayList();

	if(availableOptions != null && availableOptions.size() > 0)
	{
		if(saSelectedOptions != null && saSelectedOptions.length > 0)
		{
			Iterator options = availableOptions.iterator();
			while(options.hasNext())
			{
				String option = (String)options.next();
				if(StringUtils.isStringInStringArray(saSelectedOptions, option, true) != -1)
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
	System.out.println("QF.jsp " + s);
}
private static String[] getYears()
{
	/* This function tries to ensure that the list of years is up to date.

	   If the current array of years in PiB includes the current year then that list
	   is returned unchanged. Otherwise, an array is generated up to the current year.
	   The start year for the array depends on both the earliest year in the original
	   PiB array and the value nCutOffYear, which acts as a safety net in case there
	   is a problem with the PiB array and a silly start year, such as 0, arises.

	   This functionality will be written into PiB at some stage, at which point
	   this function can be removed.
	*/
	int nCutOffYear = 1995;
	String asDefaultYears[] = RetrievalConstants.YEARS;
	int nCurYear = Calendar.getInstance().get(Calendar.YEAR);

	for(int nLoop = 0; nLoop < asDefaultYears.length; nLoop++)
	{
		if(StringUtils.atoi(asDefaultYears[nLoop], 0) == nCurYear)
		{
			return asDefaultYears;
		}
	}

	// Current year is not in the list - generate a list of years up to the current year

	int nMinYear = nCurYear;
	for(int nLoop = 0; nLoop < asDefaultYears.length; nLoop++)
	{
		if(StringUtils.atoi(asDefaultYears[nLoop], 0) < nMinYear)
		{
			nMinYear = StringUtils.atoi(asDefaultYears[nLoop], 0);
		}
	}

	if(nMinYear < nCutOffYear) nMinYear = nCutOffYear; // Assume that a minimum before the 'cutoff year' is a mistake, probably 0
	if(nCurYear < nMinYear)    nCurYear = nMinYear;    // Should never happen but just in case.

	String asYears[] = new String[nCurYear - nMinYear + 1];

	for(int nLoop = 0; nLoop < asYears.length; nLoop++)
	{
		asYears[nLoop] = (nMinYear + nLoop) + "";
	}
	return asYears;
}

private static String getBrowsingType(PortalService service)
{
	String browsingType = service.readConfigParameter("QuerySummaryType", null);

	if(browsingType == null)
	{
		// Old config parameter name
		browsingType = service.readConfigParameter("ResultBrowsingType", "");
	}

	return browsingType;
}

%>