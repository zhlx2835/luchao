<%@ page import="com.autonomy.utilities.*" %>
<%@ page import="com.autonomy.aci.*" %>
<%@ page import="com.autonomy.aci.constants.*" %>
<%@ page import="com.autonomy.client.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%!
private aciObject nextHit(aciObject acioEntry)
	{
		aciObject acioNextHit = null;
		if(acioEntry != null)
		{
		   // should simply be next sibling entry in linked list...
		   acioNextHit = acioEntry.aciObjectNextEntry();
		   //... but check name to be sure
		   if(acioNextHit != null)
		   {
			String sEntryName = acioNextHit.paramGetString(aciObject.ACI_DATA_NODE_NAME);
			if(sEntryName != null && !sEntryName.equals("autn:hit"))
			{
			   // not a hit entry:
			   // move to immediate sibling and try to find next hit from there
			   aciObject acioNextEntry = acioNextHit.aciObjectNextEntry();
			   if(acioNextEntry != null)
			   {
				// findFirstOccurrence will return acioNextEntry itself if it is a hit
				acioNextHit = acioNextEntry.findFirstOccurrence("autn:hit");
			   }
			   else
			   {
				// end of hits and siblings list so just return null
				acioNextHit = null;
			   }
			}
		    }
		 }
		 return acioNextHit;
	}
%>

<%
//DRE Settings
String strHost = "192.168.1.40";
int nPort = 11000;
long TimeBegin=0;
long TimeEnd=0;
//DRE action required parameters
String strQuery = com.autonomy.utilities.StringUtils.nullToEmpty(request.getParameter("qtext"));
String strDisplayQuery = new String(strQuery.getBytes("ISO-8859-1"),"utf-8");
String strSearchText = java.net.URLEncoder.encode(strDisplayQuery, "utf-8");
int curpage = com.autonomy.utilities.StringUtils.atoi(request.getParameter("cp"),1);
String strSecurity=request.getParameter("securityinfo")==null?"":request.getParameter("securityinfo");

//page display parameters
boolean qFlag = true;
int pagesize = 10;
if(strQuery==null || strQuery.equals("")) {qFlag = false;}
int list_start = (curpage-1)*pagesize+1;
int list_end = curpage*pagesize;
String strLinkText = "simplequery.jsp?qtext="+strSearchText+"&cp=";

ArrayList queryResultList = new ArrayList();
String strTotalResults = "0";

if(qFlag)
{
	client aci = new client();
	aciObject acioConnection = null;
	aciObject aciResponse = null;
	aciObject res = null;
	aciObject acioCommand = null;

	// Create the connection object
	acioConnection = aci.aciObjectCreate(aciObject.ACI_CONNECTION);
	// Set host details
	acioConnection.paramSetString(aciObject.ACI_HOSTNAME, strHost);
	acioConnection.paramSetInt(aciObject.ACI_PORTNUMBER, nPort);
	acioConnection.setTimeout(5000);
	acioConnection.paramSetString("ACIO SENDENCODING", "UTF-8");
	acioConnection.paramSetString("ACIO ENCODING", "UTF-8");
	
	// Create the command object
	acioCommand = aci.aciObjectCreate(aciObject.ACI_COMMAND);
	// set http method
	acioCommand.paramSetBool(aciObject.ACI_COM_USE_POST,true);
	// set command
	acioCommand.paramSetString(aciObject.ACI_COM_COMMAND,"ACTION=query");
	
	// Set query parameters
	acioCommand.paramSetString("text",strDisplayQuery);
	acioCommand.paramSetString("minscore","40");
	acioCommand.paramSetString("sort","relevance+date");
	acioCommand.paramSetString("start",String.valueOf(list_start));
	acioCommand.paramSetString("maxResults",String.valueOf(list_end));
	acioCommand.paramSetString("summary","context");
	acioCommand.paramSetString("characters","300");
	acioCommand.paramSetString("sentences","4");
	acioCommand.paramSetString("highlight","terms+summaryterms");
	acioCommand.paramSetString("totalresults","true");
	acioCommand.paramSetString("predict","false");
	acioCommand.paramSetString("combine","Simple");
	acioCommand.paramSetString("printfields","DRETITLE");
	if(!strSecurity.equals("")){
	  acioCommand.paramSetString("securityinfo",strSecurity);
	}
 	//acioCommand.paramSetString("outputencoding", "UTF8");
 	//acioCommand.paramSetString("languagetype", "chineseUTF8");
	// check that a connection to the server can be made
	if(acioConnection.isAlive()){
		TimeBegin=System.currentTimeMillis();
		aciResponse = acioConnection.aciObjectExecute(acioCommand);
		TimeEnd=System.currentTimeMillis();
		//System.out.println("command="+acioCommand.toString());
		
		if(aciResponse != null)
		{
			if(aciResponse.checkForSuccess())
			{
				aciObject totalResults = aciResponse.findFirstOccurrence("autn:totalhits");
  				strTotalResults = totalResults.getTagValue("autn:totalhits","0");
  				
  				res = aciResponse.findFirstOccurrence("autn:hit");
  				while(res != null) 
				{
					String strReference = res.getTagValue("autn:reference", "");
					String strTitle = res.getTagValue("DRETITLE", "");
					String strSummary = res.getTagValue("autn:summary", "");
					
					Hashtable h = new Hashtable();
					h.put("DREREFERENCE",strReference);
					h.put("DRETITLE",strTitle);
					h.put("SUMMARY",strSummary);
					queryResultList.add(h);

					res = nextHit(res);
				}
  			}
  			else{
				System.out.println("Request failed.");
			}
		}
		else{
			//throw new Exception("none");
			System.out.println("No result object returned. Sending parameters are:");
			//System.out.println(acioCommand);
		}
	}
	else{
		System.out.println("Could not connect to server");
	}
}
else
{
	out.println("当前没有搜索结果!");
}

%>

<html>
<head>
<title>Autonomy搜索结果</title>
<META http-equiv=Content-Type content="text/html; charset=utf-8">
<link href="simplequery.css" rel="stylesheet" type="text/css">
</head>
<body>
<table class="text" >
<tr>
	<form action="simplequery.jsp">
	<td valign="middle" align="right">
 		<input type="submit" value="确定" name="submit">
		<input type="text" name="qtext" id="qtext" size="50" maxlength="100" value="<%=strDisplayQuery%>">
		<input type="hidden" value="<%=strSecurity%>" name="securityinfo">
	</td>
	</form>
</tr>
</table>
<hr>
<table class="text"  width="100%">
<tr>
	<td valign="top">
		<!--content-->
		共有 <%=strTotalResults%> 条记录  用时 <%=TimeEnd-TimeBegin%> 毫秒
		<table class="text">
<%
	for(int i=0;i<queryResultList.size();i++)
	{
		Hashtable newH = (Hashtable) queryResultList.get(i);
		out.println("<tr><td><div><a target='_blank' href="+(String)newH.get("DREREFERENCE")+">");
		out.println((String)newH.get("DRETITLE"));
		out.println("</a><div>");
		out.println("<div>"+(String)newH.get("SUMMARY")+"</div>");
	}
%>
		</table>
		<div>
<% 
	int thispage = curpage;
	int totalpage = (Integer.parseInt(strTotalResults)-1)/pagesize+1;
	if(!strTotalResults.equals("0")) {
		out.println("<a href='"+strLinkText+(1)+"'>首页</a>");
		if((thispage-1)>=1&&(thispage-1)<=totalpage){
			out.println("<a href='"+strLinkText+(thispage-1)+"'>上一页</a>");
		}
		if(thispage<=3){
			for(int i=1;i<=5;i++) {
				if(i<=totalpage) {
					if(thispage==i) {
						out.println("<a href='"+strLinkText+i+"'>"+i+"</a>");
					}else{
						out.println("<a href='"+strLinkText+i+"'>["+i+"]</a>");
					}
				}
			}
		}else{
			for(int i=thispage-2;i<=thispage+2;i++){
				if(i<=totalpage){
					if(thispage==i){
						out.println("<a href='"+strLinkText+i+"'>"+i+"</a>");
					}else{
						out.println("<a href='"+strLinkText+i+"'>["+i+"]</a>");
					}
				}
			}
		}
		if((thispage+1)<=totalpage){
			out.println("<a href='"+strLinkText+(thispage+1)+"'>下一页</a>");
		}
		out.println("<a href='"+strLinkText+(totalpage)+"'>最后一页</a>");
	}

%>	
	</div>
	</td>
</tr>
</table>
</body>
</html>