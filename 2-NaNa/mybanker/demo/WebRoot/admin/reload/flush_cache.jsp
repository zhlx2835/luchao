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
    <%
    if( request.getParameter("doFlush") == null )
    {
        %>
        <font class="normalbold">Flush Cache</font><br /><br />

        <font class="normal">
            This will clear the Portal cache, which stores infrequently changing details like
            DRE database information.  Clearing this cache will force that information to be reloaded.
            <br /><br />
            If you're sure you wish to flush the cache, click OK, otherwise click back:
            <br /><br />
        </font>
        <center>
            <font class="normal">    
                <a class="textButton" title="Flush cache" href="flush_cache.jsp?doFlush=1">
                    Ok
                </a>
            </font>
            &nbsp; &nbsp; &nbsp; &nbsp;<%=f_admin_displayBackButton()%>
        </center>
        <%
    }
    else
    {
        CurrentPortal.flushObjectStore();
        %>
        <font class="normalbold">Flush Cache</font><br /><br />

        <font class="normal">
            The cache was flushed successfully.<br /><br />
            Click on a menu option to continue
        </font>
        <%
    }
    %>
</div>
<%@ include file="/admin/header/adminhome_footer.jspf" %>
