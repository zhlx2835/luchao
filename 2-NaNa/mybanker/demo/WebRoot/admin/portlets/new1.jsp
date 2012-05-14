<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%
//set var picked up by pre-compile include
//
String sAdminHeader_title = "Creating a new portlet - Step 1 - Overview";
String sAdminHeader_image = "modules32.gif";
%>
<%@ include file="/admin/header/admin_header.jspf" %>
<table width="600" <%=Functions.f_getTableCenter(session)%> >
    <tr>
        <td>                        
            <p>
                <font class="normal" >
                    This series of simple steps will take you through setting up a template portlet into which you can either add an existing JSP application or create a new one. Below is an overview of the series of steps needed to create a new portlet. 
                </font>
            </p>                        
            <br />
            <ol>
                <li><font class="normalbold" >Give the portlet an entry in the portlet list.&nbsp; </font><font class="normal" >The portlet will then be visible to any site administrator visiting the portlet administration screen.  You will need to give your portlet a unique identifier, a name, a description and some initial colors.</font><br /><br /></li>
                <li><font class="normalbold" >Create a folder for the portlet and the template files.&nbsp; </font><font class="normal" >This step creates everything that is needed to allow the portlet to be viewed by users</font><br /><br /></li>
                <li><font class="normalbold" >Write the portlet JSPs.&nbsp; </font><font class="normal" >The content of your portlet should be written as an independent piece of JSP code. It is a simple matter to convert existing JSP programs into portal portlets.</font><br /><br /></li>
                <li><font class="normalbold" >Decide on some privileges for the portlet.&nbsp; </font><font class="normal" >This will allow certain users with given roles to view your new portlet</font><br /><br /></li>
            </ol>
            <br />
            <p>And then the process is complete.  If you are ready to create or insert a portlet into Portal-in-a-box, click 'OK' below, otherwise click cancel to return to the previous screen.</p>
            <br /><br />
            <center>
                <a class="textButton" title="Ok" href="new2.jsp">
                    Ok
                </a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="textButton" title="Cancel" href="javascript:history.back();">
                    Cancel
                </a>
            </center>
        </td>
    </tr>
</table>
<%@ include file="/admin/header/admin_footer.jspf" %>
