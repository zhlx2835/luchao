<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");

String sAdminHeader_title = "Add a page to existing users";
String sAdminHeader_image = "users32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>

<%
// get the list of page style options
ArrayList pageStyleOptions = new ArrayList();
String[] styleFiles = Functions.f_getFilesInFolder(application, request, request.getContextPath() + "user/style" );
for(int nPageIdx = 0; nPageIdx < styleFiles.length; nPageIdx++)
{
	pageStyleOptions.add(new PageInfo(styleFiles[nPageIdx]));
}

// list of available portlets
ArrayList portletOptions = new ArrayList();
String[] portletList = CurrentRoles.getUserPrivilege(CurrentUser.getUserName(), "panes_selectable", true);
StringUtils.quickSort(portletList);
for(int nPageIdx = 0; nPageIdx < portletList.length; nPageIdx++)
{
	portletOptions.add(portletList[nPageIdx]);
}

// list of roles
ArrayList roles = new ArrayList();
String[] asAvailableRoles = CurrentRoles.getRoleList();
for(int nPageIdx = 0; nPageIdx < asAvailableRoles.length; nPageIdx++)
{
	roles.add(asAvailableRoles[nPageIdx]);
}


%>

<form action="addPortlet_submit.jsp">
<table width="66%">
	<tr>
		<td colspan="2">
			Please give details of the new page that you want all users to see. Note that this new page
			will appear as the last page in the user's interface and that users who already have the
			maximum number of pages visible will not be updated.
		</td>
	</tr>
	<tr><td height="6"/></tr>
		<tr>
			<td>
				New page name:
			</td>
			<td>
				<input type="text" name="pagename" value=""/>
			</td>
		</tr>
		<tr>
			<td>
				Page style:
			</td>
			<td>
				<select name="pagestyle">
<%
					Iterator pageStyles = pageStyleOptions.iterator();
					while(pageStyles.hasNext())
					{
						PageInfo pageInfo = (PageInfo)pageStyles.next();
%>
						<option value="<%= pageInfo.getJspName() %>"><%= pageInfo.getStyleName() %></option>
<%
					}
%>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				New portlet name:
			</td>
			<td>
				<select name="portletName">
<%
					Iterator portlets = portletOptions.iterator();
					while(portlets.hasNext())
					{
						String portletName = (String)portlets.next();
%>
						<option value="<%= portletName %>"><%= portletName %></option>
<%
					}
%>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				For users in role:
			</td>
			<td>
				<select name="role">
<%
					Iterator roleOptions = roles.iterator();
					while(roleOptions.hasNext())
					{
						String roleName = (String)roleOptions.next();
%>
						<option value="<%= roleName %>"><%= roleName %></option>
<%
					}
%>
				</select>
			</td>
		</tr>
		<tr>
			<td/>
			<td>
				<a class="textButton" title="Confirm" href="javascript:void(document.forms[0].submit());" >Confirm</a>
			</td>
		</tr>
</table>
</form>

<%@ include file="/admin/header/admin_footer.jspf" %>


<%!
class PageInfo
{
	private String jspName;
	private String styleName;

	public PageInfo(String jspName)
	{
		this.jspName = jspName;
		if(jspName.endsWith(".jsp"))
		{
			styleName = jspName.substring(0, jspName.length() - 4);
		}
		else
		{
			styleName = jspName;
		}
	}

	public String getJspName()
	{
		return jspName;
	}
	public String getStyleName()
	{
		return styleName;
	}
}


%>