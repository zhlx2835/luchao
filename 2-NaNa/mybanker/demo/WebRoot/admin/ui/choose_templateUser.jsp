<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sAdminHeader_title = "Select a Template User for this role";
String sAdminHeader_image = "interface32.gif";
%>

<%@ include file="/admin/header/admin_header.jspf" %>


<table width="100%" bgcolor="#84C6EF" cellspacing="0" cellpadding="0" border="0">
<%
String sRoleName = Functions.safeRequestGet( request, "rolename", CurrentPortal.getSecurityObject().getKeyByName("BaseRole", "everyone"));

boolean bDisplayUsers_withCheckboxes = false;
String sDisplayUsers_listUsersCommand = "";
String sDisplayUsers_clickUserCommand = "&amp;username=*";
String[] asDisplayUsers_checkedUsers = null;
String sDisplayUsers_listUserHref = "choose_templateUser.jsp";
String sDisplayUsers_noUsersErrorMessage = "There are no users to display";
String sDisplayUsers_currentRole = sRoleName;
String sDisplayUsers_clickUserHref = "makeTemplateUser.jsp?tuyn=1";
String sDisplayUsers_templateUserName = "";
String sDisplayUsers_formName = "";
%>
</table>

<%@ include file="/admin/include/displayUsers_include.jspf" %>
<%@ include file="/admin/header/admin_footer.jspf" %>
