<%@ include file="/user/include/getPortletVars_include.jspf" %>
<%
//
//Start writing your portlet as an independent jsp page here
//Including al variable definitions.
//The contents of the string StatusBarMessage, which is declared in the
//header, will be placed on the status bar of the portlet, if the group has opted to
//use it
//
String sWhatToDo = request.getParameter(CurrentPortlet.getPortletKey());
if( sWhatToDo == null )
	sWhatToDo = "AskName";
	
if(sWhatToDo.equals("AskAge"))
{
	String sName = request.getParameter("name");
	if(sName.length() == 0)
		sName = "Anon.";
	%>
	<br />
	<br />
	<p>Hello, <%=sName%>!  Welcome to Portal-in-a-box.  How old are you?</p>
	<form action="../home/home.jsp#<%=CurrentPortlet.getPortletKey()%>" method="post">
		<center>Enter your age here: <input type="text" name="age" size="3" maxlength="3"> <input type="submit" name="send" value="send" /></center>
		<input type="hidden" name="<%=CurrentPortlet.getPortletKey()%>" value="ShowGreeting" />
		<input type="hidden" name="name" value="<%=sName%>" />
	</form>
	<%
}
else if(sWhatToDo.equals("ShowGreeting"))
{
	String sName = request.getParameter("name");
	String sAge = request.getParameter("age");
	int intAge;
	try
	{
		intAge = Integer.valueOf(sAge).intValue();
		sAge = "is " + sAge;
	}
	catch(NumberFormatException e)
	{
		sAge = "you wouldn't tell me";
	}
	%>
	<br />
	<br />
	<table cellpadding="10"><tr><td>Well <%=sName%>, you look very young for your age, which <%=sAge%>!<br /></td></tr>
	<tr><td height="11"></td></tr>
	
	<%--IE will not re-submit if the href is the same as the current one, so the querystring is used just to make IE re-submit --%>
	<tr><td align="center">Click <a href="../home/home.jsp?<%=CurrentPortlet.getPortletKey()%>=#<%=CurrentPortlet.getPortletKey()%>">here</a> to start the tutorial again</td></tr></table>
	<br />
	<br />
	<%
}
else
{
	//Default case
	//
	sWhatToDo = "AskName";
	%>
	<br />
	<br />
	<p>This is an example portlet, to illustrate how to create a portlet and allow it to communicate with all the functionality of Portal-in-a-Box 4.
	The code for this portlet demonstrates how to write portlet code specific to Portal-in-a-Box 4.  The important points are: </p>
	<ul>
	<li>To allow the user to interact with the portlet, you will need a key unique to this instance of this portlet.  This can be got using the Java call:
	<center><code>CurrentPortlet.getPortletKey()</code></center><br /><br />
	<li>Follow any links to the portlet with <code>#&lt;%=CurrentPortlet.getPortletKey()%&gt;</code>.  This will ensure your portlet takes pride of place on the screen while the user is using it.
	</ul>
	So you can write some jsp like:<br />
	<br /><center><code>&lt;input type="hidden" name="&lt;%=CurrentPortlet.getPortletKey()%&gt;" value="AskAge" &gt;</code></center><br /><br />
	<p>This is how this portlet knows which action to perform at any point.  Try it:</p>
	<form action="../home/home.jsp#CurrentPortlet.getPortletKey()" method="post">
		<center>What is your name?<input type="text" name="name" maxlength="30"> <input type="submit" name="send" value="send" /></center>
		<input type="hidden" name="<%=CurrentPortlet.getPortletKey()%>" value="AskAge" />

	</form>
	<%
}
%>
