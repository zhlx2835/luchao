<%@ page import = "com.autonomy.utilities.*" %>
<%@ page import = "java.util.*" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>


<%
String c = request.getParameter("xcol");
String c2 = request.getParameter("xdcol");
if( c != null )
{
	session.setAttribute("xcol", c );
	if( c2 != null )
	{
		session.setAttribute("xdcol", c2 );
	}
}
%>
<html>
	<HEAD>
		<TITLE> Portal-in-a-Box Administration</TITLE>
		<script type="text/javascript" >
			<!--
			window.name="frameset";
			window.focus();
			//-->
		</script>
	</HEAD>
	<frameset rows="36,*" >

		<frame name="mainmenuFrame" frameborder="0" noresize="noresize" scrolling="no" src="menuFrame.jsp" />

		<frameset cols="160,*">

		  <frame name="menuFrame" noresize="noresize" scrolling="no" src="index.jsp" />
		  <frame name="mainFrame" scrolling="auto" src="home.jsp" />

		</frameset>
	</frameset>

	<noframes>
		Your browser does not support frames.  Please upgrade to one that does.
	</noframes>

</html>

