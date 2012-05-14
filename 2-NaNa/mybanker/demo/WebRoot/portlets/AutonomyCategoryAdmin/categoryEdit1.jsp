<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.portlet.constants.CATConstants"%>
<%@ page import="com.autonomy.aci.businessobjects.Category"%>
<%@ page import="com.autonomy.aci.constants.IDOLLanguages"%>
<%@ page import="com.autonomy.utilities.HTMLUtils"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
response.setContentType("text/html; charset=utf-8");
%>

<%
//get Locale information from session
String sLocale =(String)session.getAttribute(CATConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CATConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CATConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));

// Set up services object
PortalService service = ServiceFactory.getService((Object)request, (Object)response, (Object)CATConstants.PORTLET_NAME);
if(service == null)
{
	setError(session, rb.getString("categorySelected.error.notLoaded"));
}

// get category to edit from session
Category category = (Category)session.getAttribute(CATConstants.SESSION_ATTRIB_SELECTED_CAT);
if(category == null)
{
	setError(session, rb.getString("categoryView.error.noCatSelected"));
}
%>

<%@ include file="showError_include.jspf" %>

<%
if(service != null && category != null)
{
%>
	<h4><%=rb.getString("categoryEdit1.editingCat")%> <%= category.getName()%></h4>
	<h5><%=rb.getString("categoryEdit1.catDetails")%></h5>
	<form name="catdetails" action="<%= service.makeFormActionLink("") %>" method="POST">
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_EDIT_2 %>" />
		<table>
			<!-- name -->
			<tr>
				<td>
					<font class="normalbold">
						<%=rb.getString("categoryEdit1.catName")%>
					</font>
				</td>
				<td align="right">
					<input type="text" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_NAME) %>" value="<%= category.getName() %>" size="13" />
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

			<!-- This bit lowers the sorting stuff so everything looks in place -->
			<tr>
				<td colspan="2" height="5">
				</td>
			</tr>

			<!-- language -->
			<tr>
				<td>
					<font class="normalbold">
						<%=rb.getString("categoryEdit1.lang")%>
					</font>
				</td>
				<td align="right">

					<%= HTMLUtils.createSelect(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_LANGUAGE),
																		 IDOLLanguages.getLanguageList(),
																		 category.getLanguage(),
																		 IDOLLanguages.ENGLISH,
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

			<!-- This bit lowers the sorting stuff so everything looks in place -->
			<tr>
				<td colspan="2" height="5">
				</td>
			</tr>

			<!-- RESULTS PER PAGE AND QUALITY -->
			<tr>
				<td nowrap=true>
					<font class="normalbold">
						<%=rb.getString("categoryEdit1.noOfResults")%>
					</font>
						&nbsp;
					<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
						<%= HTMLUtils.createSelect(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_NUM_RESULTS),
																		 CATConstants.NUM_RESULTS_OPTIONS,
																		 category.getNumResults()
																		) %>
					</font>
				</td>
				<td align="right">
					<table cellpadding="0">
						<tr>
							<td>
								<font class="normalbold">
									<%=rb.getString("categoryEdit1.quality")%>
								</font>
									&nbsp;
							</td>
							<td>
								<font class="<%= service.getCSSClass(PortalService.FIELD_TEXT) %>">
									<%= HTMLUtils.createSelect(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_THRESHOLD),
																		 CATConstants.THRESHOLD_OPTIONS,
																		 category.getThreshold()
																		) %>
								</font>
							</td>
						</tr>
					</table>
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

			<!-- This bit lowers the sorting stuff so everything looks in place -->
			<tr>
				<td colspan="2" height="5">
				</td>
			</tr>

			<!-- databases -->
			<tr>
				<td valign="top">
					<font class="normalbold">
						<%=rb.getString("categoryEdit1.database")%>
					</font>
				</td>
				<td align="right">
					<%= HTMLUtils.createMultipleSelect(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_DATABASES),
																		 				 (ArrayList)session.getAttribute(CATConstants.SESSION_ATTRIB_DATABASE_LIST),
																		 				 category.getDatabases(),
																		 				 StringUtils.atoi((String)service.getParameter(PortalService.CONFIG_DATABASE_LIST_SIZE), 5),
																		 				 false
																					) %>
				</td>
			</tr>

			<!-- continue/cancel links -->
			<tr><td height="6"></td></tr>

			<tr>
				<td colspan="2" align="right">
					<a class="textButton" href="javascript:cancel();" title="Cancel">
						<%=rb.getString("categoryEdit1.cancel")%>
					</a>
					&nbsp;
					<a class="textButton" href="javascript:document.catdetails.submit();" title="Continue">
						<%=rb.getString("categoryEdit1.continue")%>
					</a>
			<script name="JavaScript" type="text/javascript">
			<!--
			function cancel()
			{
				document.catdetails['<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>']['value'] = '<%= CATConstants.JSP_PAGE_CAT_SELECTED %>';
				document.catdetails.submit();
			}
			-->
			</script>
				</td>
			</tr>
		</table>
	</form>
<%
}
%>

<%!
private void setError(HttpSession session, String sErrorMess)
{
	if(session != null && StringUtils.strValid(sErrorMess))
	{
		// append any existing error message
		String sCurrentError = (String)session.getAttribute(CATConstants.SESSION_ATTRIB_ERROR_MESSAGE);
		if(StringUtils.strValid(sCurrentError))
		{
			sErrorMess = sCurrentError + "<br />" + sErrorMess;
		}
		session.setAttribute(CATConstants.SESSION_ATTRIB_ERROR_MESSAGE, sErrorMess);
	}
}
%>