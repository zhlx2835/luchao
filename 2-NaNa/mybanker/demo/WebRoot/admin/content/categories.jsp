<%@ page import="com.autonomy.aci.AciResponse"%>
<%@ page import="com.autonomy.aci.constants.IDOLConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Category permissions";
String sAdminHeader_image = "database32.gif";
ArrayList alCatPermission = new ArrayList();
alCatPermission.add("read");
alCatPermission.add("edit");
alCatPermission.add("createchildren");

//
//Allows close up administration as to which roles can see which category
//
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<%
String[] asAvailableRoles = CurrentRoles.getRoleList();
String sUserName = CurrentUser.getUserName();

String[] asMemberPermission = request.getParameterValues("memberPermission");
String[] asNonMemberPermission = request.getParameterValues("nonMemberPermission");

String sCategory = StringUtils.nullToEmpty(request.getParameter(makeParameterName(ChannelsConstants.REQUEST_PARAM_SELECTED_ID)));
String sMessage = "";

String sSelectedRole = request.getParameter("selectedRole");
if(sSelectedRole==null)
{
    sSelectedRole = "everyone";
}

String sRecurse = request.getParameter("recurse");
if(sRecurse==null)
{
    sRecurse = "true";
}
String sWhatToDo 	= HTMLUtils.safeRequestGet(request, "action", "listPermissions");
IDOLService idol = (IDOLService)session.getAttribute(CATConstants.SESSION_ATTRIB_IDOL);
    
if(sWhatToDo.equals("setPrivilege"))
{
	sMessage = "Your changes have been saved";
	if( request.getParameter("set") != null )
	{
        idol.useChannelsFunctionality().setCatPermission(sCategory, sSelectedRole, asMemberPermission, asNonMemberPermission, sRecurse, sUserName);
	}
}//end of submit check

if(StringUtils.strValid(sMessage))
{
    %>
    <table border="0" align="center" width="100%" cellpadding="0" cellspacing="0">
    <tr>
        <td height="24" colspan="2" align="center">
            <font class="adminwarning" color="#aa4444">
                <%=sMessage%>
            </font>
        </td>
    </tr>
    </table>
    <%
}

//List categories down the side:
%>
<br /><br />
<table width="98%" align="center" border="0" cellspacing="0" cellpadding="0">
<tr><td width="35%" valign="top">
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td>
				<font class="normalbold" >Click on a category to view permission information</font>
			</td>
		</tr>
        <%@ include file="categoryTree_include.jspf" %>
	</table>
</td>
<td width="75%" valign="top">
<%

//Display permission setting if category selected
//
if(StringUtils.strValid(sCategory))
{
    AciResponse aciResponse = idol.useChannelsFunctionality().getCatPermissions(sCategory, sUserName);  
    String sSetRole = getSetRole(aciResponse);
    Category selectedCategory = new Category(sCategory);
%>
    <form action="categories.jsp" method="post">
        <input type="hidden" name="action" value="setPrivilege" />
        <input type="hidden" name="category" value="<%=sCategory%>" />
        <input type="hidden" name="<%= makeParameterName(ChannelsConstants.REQUEST_PARAM_SELECTED_ID) %>" value="<%=sCategory%>" />	
        <table style="margin-left:auto; margin-right:auto;" width="75%" align="center" border="0" cellspacing="0" cellpadding="0" >
            <tr bgcolor="<%=gc()%>">
                <td nowrap="nowrap" align="left" width="100">
                    <font class="normalbold">
                        Owned by Role
                    </font>
                </td>
                <td width="10">
                </td>     		
                <td>
                    <%=Functions.f_createSelect("selectedRole", StringUtils.quickSort(asAvailableRoles), sSetRole, false)%>				      		
                </td>			
            </tr>           
            <tr>
                <td height="20">
                </td>
            </tr>
            <tr bgcolor="<%=gc()%>">
                <td nowrap="nowrap" align="left" width="100">
                    <font class="normalbold">
                        Members
                    </font>				      		
                </td>
                <td width="10">
                </td>
                <td align="left"  height="12"  colspan="1">
                    <input type="hidden" name="action" value="setPrivilege" />
                    <input type="hidden" name="pane" value="<%=sCategory%>" />
                    <input type="hidden" name="<%= makeParameterName(ChannelsConstants.REQUEST_PARAM_SELECTED_ID) %>" value="<%=sCategory%>" />	
                    <font class="normalbold" >
                        Set permission:
                    </font>
                    <font class="normal" >
                        <%= HTMLUtils.createCheckboxs("memberPermission", alCatPermission, getMemberPermissions(aciResponse), 1)%>
                    </font>
                </td>               
            </tr>          
            <tr>
                <td height="20">
                </td>
            </tr>		
            <tr bgcolor="<%=gc()%>">
                <td nowrap="nowrap" align="left" width="100">
                    <font class="normalbold">
                        Non-members
                    </font>				      		
                </td>
                <td width="10">
                </td>
                <td align="left" height="12"  colspan="1">
                    <input type="hidden" name="action" value="setPrivilege" />
                    <input type="hidden" name="pane" value="<%=sCategory%>" />
                    <input type="hidden" name="<%= makeParameterName(ChannelsConstants.REQUEST_PARAM_SELECTED_ID) %>" value="<%=sCategory%>" />	
                    <font class="normalbold" >
                        Set permission:
                    </font>
                    <font class="normal" >
                        <%= HTMLUtils.createCheckboxs("nonMemberPermission", alCatPermission, getNonMemberPermissions(aciResponse), 1)%>
                    </font>
                </td>
            </tr>
            <tr>
                <td height="20">
                </td>
            </tr> 
            <tr bgcolor="<%=gc()%>">
                <td >
                    <font class="normalbold" >
                        Apply settings to sub-categories:
                    </font>
                </td>
                <td width="10">
                </td>
                <td>
                    <input type="radio" <%if(sRecurse.equals("true"))  {%>checked<%}%> name="recurse" value="true" />&nbsp;Yes&nbsp;
                    <br/>
                    <input type="radio" <%if(!sRecurse.equals("true")){%>checked<%}%> name="recurse" value="false" />&nbsp;No&nbsp;							
                </td>			        
            </tr> 
            <tr>
                <td height="20">
                </td>
            </tr>
            <tr>
                <td>
                    <font class="normal">
                        <input style="font-face: verdana; font-size: 8pt" type="submit" name="set" value="  Submit  " />
                        <br />
                    </font>
                </td>
            </tr>                
        </table>
    </form>
    <%
}
%>

</td></tr>
</table>

<%@ include file="/admin/header/admin_footer.jspf" %>

<%!
private static ArrayList getMemberPermissions(AciResponse response) throws AciException, InvalidCategoryException
{
    ArrayList alMemberPermissions = new ArrayList();
    ArrayList checks = new ArrayList();
    if(response != null) {
        // find first category hit
        AciResponse acirCategory = (AciResponse)response.findFirstOccurrence(IDOLConstants.CATEGORY_PERMISSION_MEMBER_TAG_NAME);
        if(acirCategory != null) {
            String sRead = acirCategory.getTagValue(IDOLConstants.CATEGORY_PERMISSION_READ_TAG_NAME, "true");
            alMemberPermissions.add(sRead);
            String sEdit = acirCategory.getTagValue(IDOLConstants.CATEGORY_PERMISSION_EDIT_TAG_NAME, "false");
            alMemberPermissions.add(sEdit);
            String sCreateChildren = acirCategory.getTagValue(IDOLConstants.CATEGORY_PERMISSION_CREATE_CHILDREN_TAG_NAME, "false");
            alMemberPermissions.add(sCreateChildren);
            Iterator options = alMemberPermissions.iterator();
            while(options.hasNext())
            {
                String option = (String)options.next();
                if(option.equalsIgnoreCase("true"))
                {
                    checks.add(Boolean.TRUE);
                }
                else
                {
                    checks.add(Boolean.FALSE);
                }
            }
        }
    }
    return checks;
}

private static ArrayList getNonMemberPermissions(AciResponse response) throws AciException, InvalidCategoryException
{
    ArrayList alNonMemberPermissions = new ArrayList();
    ArrayList checks = new ArrayList();
    if(response != null) {
        // find first category hit
        AciResponse acirCategory = (AciResponse)response.findFirstOccurrence(IDOLConstants.CATEGORY_PERMISSION_NON_MEMBER_TAG_NAME);
        if(acirCategory != null) {
            String sRead = acirCategory.getTagValue(IDOLConstants.CATEGORY_PERMISSION_READ_TAG_NAME, "false");
            alNonMemberPermissions.add(sRead);
            String sEdit = acirCategory.getTagValue(IDOLConstants.CATEGORY_PERMISSION_EDIT_TAG_NAME, "false");
            alNonMemberPermissions.add(sEdit);
            String sCreateChildren = acirCategory.getTagValue(IDOLConstants.CATEGORY_PERMISSION_CREATE_CHILDREN_TAG_NAME, "false");
            alNonMemberPermissions.add(sCreateChildren);
            Iterator options = alNonMemberPermissions.iterator();
            while(options.hasNext())
            {
                String option = (String)options.next();
                if(option.equalsIgnoreCase("true"))
                {
                    checks.add(Boolean.TRUE);
                }
                else
                {
                    checks.add(Boolean.FALSE);
                }
            }
        }
    }
    return checks;
}

private static String getSetRole(AciResponse response) throws AciException, InvalidCategoryException
{
    String sRole = null;
    if(response != null) {
        // find first category hit      
        sRole = response.getTagValue(IDOLConstants.CATEGORY_PERMISSION_ROLE_TAG_NAME, "everyone");         
    }
	return sRole;
}
   
private ArrayList getMemberPermissionChecksList(HttpServletRequest request, ArrayList alAllOptions)
{
	return checkSelectedOptions(request.getParameterValues("memberPermission"), alAllOptions);
}

private ArrayList getNonMemberPermissionChecksList(HttpServletRequest request, ArrayList alAllOptions)
{
	return checkSelectedOptions(request.getParameterValues("nonMemberPermission"), alAllOptions);
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

%>
