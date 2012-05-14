<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="com.autonomy.portlet.constants.CATConstants"%>
<%@ page contentType="text/html; charset=utf-8" %>
<%
response.setContentType("text/html; charset=utf-8");

//get Locale information from session
String sLocale =(String)session.getAttribute(CATConstants.SESSION_ATTRIB_LOCALE);
if (sLocale==null)
{
    sLocale = "en";
    session.setAttribute(CATConstants.SESSION_ATTRIB_LOCALE, sLocale);
}
ResourceBundle rb = ResourceBundle.getBundle(CATConstants.SESSION_ATTRIB_PROPERTIES_FILENAME, new Locale(sLocale));
%>

<p>
</p>

<p>
	<%=rb.getString("start.selectCat")%>
	<ul>
		<li><%=rb.getString("start.viewCat")%></li>
		<li><%=rb.getString("start.editCat")%></li>
		<li><%=rb.getString("start.deleteCat")%></li>
		<li><%=rb.getString("start.createCat")%></li>
		<li><%=rb.getString("start.importCat")%></li>
	</ul>
</p>

