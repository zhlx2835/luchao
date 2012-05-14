<%@ page import = "com.autonomy.portal4.*" %>
<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.aci.services.IDOLService"%>
<%@ page import="com.autonomy.portlet.constants.CATConstants"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>

<%@ include file="/admin/home/admin_checkUser.jspf" %>

<%
   //backup idol info in session
IDOLService idol = (IDOLService)session.getAttribute(CATConstants.SESSION_ATTRIB_IDOL);
Functions.f_invalidateSession(session);
session.setAttribute(CATConstants.SESSION_ATTRIB_IDOL, idol);
response.sendRedirect("home.jsp");
%>
