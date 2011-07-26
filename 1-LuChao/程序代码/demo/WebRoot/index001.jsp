<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">
    
    <title>My JSP 'index.jsp' starting page</title>
    
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->

  </head>
  
  <body>
    <table width="750px" border="1">
    	 <tr>
    	 	<td align="center" colspan="2"><font color=red size="5"><b>此为 免费送 宝贝<br>↓↓↓↓↓↓↓↓</b></font></td>
    	 	<td align="center" colspan="2"><font color=red size="5"><b>此为 秒杀 宝贝<br>↓↓↓↓↓↓↓↓</b></font></td>
    	 </tr>
    	 <tr>
    	 	<td align="center">
    	 		<a href="http://item.taobao.com/item.htm?id=10868413628" target="_black"><img border=0 src="http://img04.taobaocdn.com/bao/uploaded/i4/T1GXuiXnhtXXXBYAsU_015435.jpg_310x310.jpg" style="width: 300px;height: 250px"/></a>
    	 		<font color=red> 请大家在晚上21：00准时抢购！</font>
    	 	</td>
    	 	<td align="center">
    	 		<a href="" target="_black"> 韩版雪纺衫 淑女装短袖衬衣2011夏季新款 配腰带</a> <br>
    	 		<font color=red><br></font>
    	 	</td>
    	 	<td align="center">
    	 		<a href="" target="_black"><img border=0 src="" style="width: 300px;height: 300px"/></a>
    	 		<font color=red> 请大家在晚上21：00准时抢购！</font>
    	 	</td>
    	 	<td align="center">
    	 		<a href="" target="_black"> 韩版雪纺衫 淑女装短袖衬衣2011夏季新款 配腰带</a> <be><br>
    	 	</td>
    	 </tr>
    	 <tr align="center">
    	 	<td colspan="4"><a href="http://nayijiaren.taobao.com/" target="_black">本店其他活动请点击</a></td>
    	 </tr>
    </table>
  </body>
</html>

