<%@ page import="com.autonomy.APSL.*"%>
<%@ page import="com.autonomy.portlet.constants.CATConstants"%>
<%@ page import="com.autonomy.aci.businessobjects.Category"%>
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
	// read category details given in first edit page and set on category
	category.setName			(request.getParameter(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_NAME)));
	category.setLanguage	(request.getParameter(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_LANGUAGE)));
	category.setThreshold	(StringUtils.atoi(request.getParameter(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_THRESHOLD)), Category.DEFAULT_THRESHOLD));
	category.setNumResults(StringUtils.atoi(request.getParameter(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_NUM_RESULTS)), Category.DEFAULT_NUM_RESULTS));
	// databases
	String[] asDatabases = request.getParameterValues(service.makeParameterName(CATConstants.REQUEST_PARAM_CAT_DATABASES));

	String sUploadParameter = service.readConfigParameter("DisplayTrainingFileUpload", "false");

	// don't allow removal of all databases
	if(asDatabases != null && asDatabases.length > 0)
	{
		category.clearDatabases();
		for(int nDBIdx = 0;nDBIdx < asDatabases.length; nDBIdx++)
		{
			category.addDatabase(asDatabases[nDBIdx]);
		}
	}

	String sImageURL = service.makeLink("AutonomyImages");
%>
	<h4><%=rb.getString("categoryEdit1.editingCat")%> <%= category.getName()%></h4>
	<h5><%=rb.getString("categoryEdit2.initialTraining")%></h5>

	<form name="cattraining" action="<%= service.makeFormActionLink("") %>" method="POST"
<%
	if(sUploadParameter.equals("true"))
	{
%>
		enctype="multipart/form-data"
<%
	}
%>
	>
		<%= service.makeAbstractFormFields() %>
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_EDIT_3 %>" />
		<table width="460">
			<tr>
				<td>
					<strong><%=rb.getString("categoryEdit2.freeText")%></strong>
				</td>
			</tr>
			<tr>
				<!-- free text -->
				<td valign="top">
					<textarea name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_TRAINING_TEXT) %>"
										rows="5"
										cols="49"><%=StringUtils.XMLEscape(category.getTrainingText().trim())%></textarea>
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
			<tr>
				<td>
					<strong><%=rb.getString("categoryEdit2.trainingFile")%></strong>
				</td>
			</tr>
			<tr>
				<td valign="top">
					<%@ include file="trainingDocs_include.jspf" %>
				</td>
			</tr>
			<!-- Upload training files - not Websphere portal-->
<%
			if(sUploadParameter.equals("true"))
			{
%>
				<tr>
					<td>
						<%=rb.getString("categoryEdit2.uploadTrainingFile")%>
						<a title="Files must be less that <%= service.readConfigParameter("MaxUploadFileSizeKBs", "1024") %>kB"
							 href="javascript:void(0);"
							 onClick='javascript:alert("File to upload must be less that <%= service.readConfigParameter("MaxUploadFileSizeKBs", "1024") %> kiloBytes.");'>*</a>
					</td>
				</tr>
				<tr>
					<td>
						<input type="file" name="file" accept="*/*" /> &nbsp;
						<a class="textButton" href="javascript:document.cattraining.submit();" title="Add new file to training">
							<%=rb.getString("categoryEdit2.add")%>
						</a>
					</td>
				</tr>
<%
			}
%>

			<!-- This produces a simple seperator -->

			<tr>
				<td>
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
				<td height="5">
				</td>
			</tr>
			<tr>
				<td>
					<strong><%=rb.getString("categoryEdit2.booleanExpr")%></strong>
				</td>
			</tr>
			<!-- boolean expression -->
			<tr>
				<td>
					<%@ include file="booleanExpression_include.jspf" %>
				</td>
			</tr>

			<!-- back, continue, cancel -->
			<tr><td height="6"></td></tr>

			<script name="JavaScript" type="text/javascript">
			<!--
			function cancel()
			{
				document.cattrainingcancel.submit();
			}
			function back()
			{
				document.cattrainingback.submit();
			}

			function replace(string,text,by)
			{
			    var strLength = string.length, txtLength = text.length;
			    if ((strLength == 0) || (txtLength == 0)) return string;

			    var i = string.indexOf(text);
			    if ((!i) && (text != string.substring(0,txtLength))) return string;
			    if (i == -1) return string;

			    var newstr = string.substring(0,i) + by;

			    if (i+txtLength < strLength)
			        newstr += replace(string.substring(i+txtLength,strLength),text,by);

			    return newstr;
			}

			function removeNewLinesInTextArea()
			{
				document.cattraining.<%=service.makeParameterName(CATConstants.REQUEST_PARAM_TRAINING_TEXT)%>.value = replace(replace(document.cattraining.<%=service.makeParameterName(CATConstants.REQUEST_PARAM_TRAINING_TEXT)%>.value,'\n',' '),'\r',' ');
			}

			-->
			</script>
			<tr>
				<td>
					<a class="textButton" href="javascript:back();" title="Back to previous step">
						<%=rb.getString("categoryEdit2.back")%>
					</a>
					&nbsp;
					<a class="textButton" href="javascript:cancel();" title="Cancel">
						<%=rb.getString("categoryEdit1.cancel")%>
					</a>
					&nbsp;
					<a class="textButton" href="javascript:removeNewLinesInTextArea();document.cattraining.submit();" title="View sample results">
						<%=rb.getString("categoryEdit1.continue")%>
					</a>
				</td>
			</tr>

		</table>
	</form>

	<!-- Forms for going back a step and cancelling - hack as AutonomyCategoryAdmin.jsp looks for "multipart/form-data" in the header of the submitted form -->

	<form name="cattrainingback" action="<%= service.makeFormActionLink("") %>" method="POST">
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_EDIT_1 %>" />

	</form>

	<form name="cattrainingcancel" action="<%= service.makeFormActionLink("") %>" method="POST">
		<input type="hidden" name="<%= service.makeParameterName(CATConstants.REQUEST_PARAM_PAGE) %>" value="<%= CATConstants.JSP_PAGE_CAT_SELECTED %>" />

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