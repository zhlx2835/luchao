<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "";
String sAdminHeader_image = "";
%>
<%@ include file="/admin/header/adminhome_header.jspf" %>
<%=f_adminDisplayBigIcon("../../images/admin/plugins.gif")%><br /><br />
<div align="center">	
    <font class="normalbold">Reinitialize</font><br /><br />

    <font class="normal">
        This will reinitialize Portal-in-a-Box, as if this was the first time the portal had been run after your JSP Servlet Engine was started.
        This will give you the option of restarting the portal without having to restart the servlet engine.  If you have changed any settings for the portal manually
        you will have to restart before the new settings will be used.
        <br /><br />
        If you're sure you wish to reset the portal, click OK, otherwise click back:
        <br /><br />
    </font>
    <center>
        <font>
            <a class="textButton" title="Reload settings" href="reload_settings_submit.jsp">
                Ok
            </a>
        </font>
        &nbsp; &nbsp; &nbsp; &nbsp;<%=f_admin_displayBackButton()%>
    </center>
</div>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
