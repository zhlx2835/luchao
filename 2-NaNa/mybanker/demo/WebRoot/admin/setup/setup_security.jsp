<%@ page contentType="text/html; charset=utf-8" %>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<%
String sAdminHeader_title = "User Authentication";
String sAdminHeader_image = "administrator32.gif";
%>
<%@ include file="/admin/header/adminhome_header.jspf" %>
<%
SecurityInfo CurrentSecurity = CurrentPortal.getSecurityObject();

String sAuthMethod 	= CurrentSecurity.getKeyByName("AuthenticationMethod", "autonomy"); 
String sAuthType 	= CurrentSecurity.getKeyByName("LoginMethod", "normal");
String sNtMethod 	= CurrentSecurity.getKeyByName("NTMethod", "none");
String sBaseRole  = CurrentSecurity.getKeyByName("BaseRole", "everyone");

%>
<form name="setup_security_form" action="sec_submit.jsp" method="POST">


<table class="normal" width="100%" align="center">
	<tr>
		<td width="30%">
			<font class="normal" >
				Select which type to use:
			</font>
		</td>
		<td>
			<input type="radio" name="loginmethod" value="normal" <%if(sAuthType.equals("normal")){out.write("checked");}%> ><font class="normal" >Normal</font>
			<font class="note">
				(manually enter username and password to log in)
			</font>
		</td>
	</tr>

	<tr><td colspan="2" height="8"></td></tr>

	<tr>
		<td>
		</td>
		<td>
			<input type="radio" name="loginmethod" value="ntlm" <%if(sAuthType.equals("ntlm")){out.write("checked");}%> ><font class="normal" >NTLM</font><br>
			<font class=note>
				(use NTLM authentication to automatically login.
			</font>
			<font class="adminwarning">
				NTLM authentication must be turned on for the web directory - use IIS Manager for this.
			</font>
			<font class=note>
				)
			</font>
			<br>
			<font class=normal>
				Please select which Portal group selection method will be used:
			</font>
		</td>
	</tr>

	<tr>
		<td>
		</td>
		<td>
			<table align=right>
				<tr>
					<td>
						<img src="<%= request.getContextPath() %>/images/blank.gif" width=30 height=1 alt="">
					</td>
					<td><input name="NTMethod" type="radio" value="none" <%if(sNtMethod.equals("none")){out.write("checked");}%> ><font class="normal" >
						Standard - Users will be placed in the standard (<%= sBaseRole %>) Portal Group
						regardless of their NT group.</font>
					</td>
				</tr>
				<tr>
					<td>
					</td>
					<td><input name="NTMethod" type="radio" value="first"  <%if(sNtMethod.equals("first")){out.write("checked");}%> ><font class="normal" >
						First Time - Users when they first use the Portal site will be placed in Portal group(s) corresponding to the NT group obtained from
						the system.</font>
					</td>
				</tr>
				<tr>
					<td>
					</td>
					<td><input name="NTMethod" type="radio" value="auto" <%if(sNtMethod.equals("auto")){out.write("checked");}%> ><font class="normal" >
						Automatic - Everytime a user visits a site the Portal will check which NT group(s) they are in and move them
						to the same Portal role(s) (creating the Portal role if necessary).</font>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>Select authentication library:</td>
		<td>
			<input type="text" name="authmethod" value="<%=sAuthMethod%>" />
		</td>
	</tr>

	<tr>
		<td></td>
		<td colspan="1" >
			<font class="note" >This must be a valid security section as configured in IDOL Server</font>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="6">
			<a class="textButton" title="Submit" href="javascript:setup_security_form.submit();">
				Submit
			</a>
			&nbsp;
		</td>
	</tr>

</table>

</form>

<%@ include file="/admin/header/adminhome_footer.jspf" %>
