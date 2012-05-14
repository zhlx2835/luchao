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
    <font class="normalbold">Reset Portlets</font><br /><br />

    <font class="normal">
        This will force the portlets to reload their settings, as if they were run for the first time.  
        If you have changed the Portlet Settings configuration file you will need to do this before the changes will
        be picked up.
        <br /><br />
        If you're sure you wish to reset the portlets, click OK, otherwise click back:
        <br /><br />
    </font>
    <center>
        <font>
            <a class="textButton" title="Ok" href="reset_portlets_submit.jsp">
                Ok
            </a>
        </font>
        &nbsp; &nbsp; &nbsp; &nbsp;<%=f_admin_displayBackButton()%>
    </center>
</div>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
