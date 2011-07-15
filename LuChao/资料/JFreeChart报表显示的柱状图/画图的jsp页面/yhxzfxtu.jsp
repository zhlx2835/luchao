
<%@ page contentType="text/html;charset=GBK"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib uri="http://struts.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib uri="/WEB-INF/speed-pagination.tld" prefix="page"%>
<%@ page import="java.util.*,
                 java.awt.Color,
                 java.awt.Font,
                 com.dpsms.entity.vo.*,
                 org.jfree.chart.ChartFactory,
                 org.jfree.chart.JFreeChart,
                 org.jfree.chart.title.LegendTitle,
                 org.jfree.chart.plot.PlotOrientation,
                 org.jfree.chart.servlet.ServletUtilities,
                 org.jfree.data.category.CategoryDataset,
                 org.jfree.data.general.DatasetUtilities,
                 org.jfree.chart.plot.*,
                 org.jfree.chart.axis.*,
                 org.jfree.chart.renderer.category.BarRenderer3D,
                 org.jfree.chart.labels.*,
                 org.jfree.ui.RectangleEdge,
                 org.jfree.ui.RectangleInsets,
                 org.jfree.chart.block.BlockBorder,
                 org.jfree.data.category.DefaultCategoryDataset,
                 org.jfree.chart.axis.AxisLocation"%>
                 
<jsp:include flush="true" page="/checkUser.jsp"></jsp:include>
 
<%

  DefaultCategoryDataset dataset = new DefaultCategoryDataset();

//CategoryDataset dataset = DatasetUtilities.createCategoryDataset(rowKeys, columnKeys, data); 
  java.util.List list = (ArrayList)request.getAttribute("yhxzfxlist");
  //*******这儿动态循环
  if (list != null && list.size() > 0) {
    for (int i = 0; i < list.size(); i++){
        WluruVO vo = (WluruVO)list.get(i);
    	String wentitype=vo.getWentitype();	//问题类型
    	String swnumber=vo.getSwnumber(); //三违总次数
    	String ssw=vo.getSsw();		//是三违
    	String fsw=vo.getFsw();		//否三违	
    	dataset.addValue(Integer.parseInt(swnumber),"总次数",wentitype);
    	dataset.addValue(Integer.parseInt(ssw),"三违次数",wentitype);
    	dataset.addValue(Integer.parseInt(fsw),"非三违次数",wentitype);
             	
 	}
  }
//  double[][] data = new double[][] {{672, 766, 223, 540, 126}, {325, 521, 210, 340, 106}, {332, 256, 523, 240, 526}};
//  String[] rowKeys = {"苹果","梨子","葡萄"};
//  String[] columnKeys = {"北京","上海","广州","成都","深圳"};
 
//  dataset.addValue(100, "北京", "苹果"); 
//	dataset.addValue(500, "北京", "荔枝"); 
//  dataset.addValue(400, "北京", "香蕉"); 
//	dataset.addValue(200, "北京", "梨子"); 
//	dataset.addValue(300, "北京", "葡萄"); 
//	dataset.addValue(500, "上海", "葡萄"); 
//	dataset.addValue(600, "上海", "梨子"); 
//	dataset.addValue(400, "上海", "香蕉"); 
//	dataset.addValue(700, "上海", "苹果"); 
//	dataset.addValue(300, "上海", "荔枝"); 
//	dataset.addValue(300, "广州", "苹果"); 
//	dataset.addValue(200, "广州", "梨子"); 
//	dataset.addValue(500, "广州", "香蕉"); 
//	dataset.addValue(400, "广州", "葡萄"); 
//	dataset.addValue(700, "广州", "荔枝");

 //这儿是坐标上的字体,自己试试....
JFreeChart chart = ChartFactory.createBarChart3D("隐患_违规性质分析", // chart title
    "问题类别", // domain axis label
    "次数", // range axis label
    dataset, // data
    PlotOrientation.VERTICAL, // PlotOrientation.VERTICAL 让平行柱垂直显示，而 PlotOrientation.HORIZONTAL 则让平行柱水平显示
    true, // include legend
    true, // tooltips
    false // urls
    );

 chart.setBackgroundPaint(Color.WHITE);
  CategoryPlot plot = chart.getCategoryPlot();
  CategoryAxis domainAxis = plot.getDomainAxis();
  domainAxis.setCategoryMargin(0.15);
  domainAxis.setMaximumCategoryLabelLines(3);
  domainAxis.setMaximumCategoryLabelWidthRatio(3);
  plot.setDomainAxis(domainAxis);
// 图示在图表中的显示位置

  LegendTitle legend = (LegendTitle) chart.getLegend();
  legend.setPosition(RectangleEdge.TOP);    //示意图位置
 // legend.setPosition(RectangleEdge.RIGHT);
  legend.setLegendItemGraphicEdge(RectangleEdge.LEFT);

  ValueAxis rangeAxis = plot.getRangeAxis();
  
  //设置最高的一个 Item 与图片顶端的距离
  rangeAxis.setUpperMargin(0.15);
  
  //设置最低的一个 Item 与图片底端的距离
  rangeAxis.setLowerMargin(0.15);
  plot.setRangeAxis(rangeAxis);

  BarRenderer3D renderer = new BarRenderer3D();
  renderer.setBaseOutlinePaint(Color.blue);
  
  //设置 Wall 的颜色
  renderer.setWallPaint(Color.darkGray);
  
  renderer.setSeriesPaint(0, Color.red);
  renderer.setSeriesPaint(1, Color.GREEN);
  renderer.setSeriesPaint(2, Color.orange);
  
  //设置每个地区所包含的平行柱的之间距离
  renderer.setItemMargin(0.03);
  
  //显示每个柱的数值(名称)，并修改该数值的字体属性
  renderer.setItemLabelGenerator(new StandardCategoryItemLabelGenerator());

  renderer.setItemLabelFont(new Font("黑体",Font.PLAIN,12));
  renderer.setItemLabelsVisible(true);
  ItemLabelPosition itemLabelPosition = new ItemLabelPosition();
  renderer.setPositiveItemLabelPosition(itemLabelPosition);
  plot.setRenderer(renderer);

  //设置柱的透明度
  plot.setForegroundAlpha(1f);
  
  //设置专业、数量的显示位置
//  plot.setDrawSharedDomainAxis(true);
  plot.setDomainAxisLocation(AxisLocation.BOTTOM_OR_LEFT);
  plot.setRangeAxisLocation(AxisLocation.BOTTOM_OR_LEFT);

  //台式机屏幕大小
  //String  filename = ServletUtilities.saveChartAsPNG(chart, 1450, 750, null, session);
  
  //笔记本屏幕大小
  String filename = ServletUtilities.saveChartAsPNG(chart, 1220, 490, null, session);
  String graphURL = request.getContextPath() + "/servlet/DisplayChart?filename=" + filename;
%>
<html>
<head>
	
	<link href="Css/TestDate.css" rel="stylesheet">
	<%--背景--%>
	
	<link href="Css/calendar-blue.css" rel="stylesheet">
	
<title></title>
<script language="javascript">
  function printtu(printpage){
    var headstr = "<html><head><title></title></head><body>";
    var footstr = "</body>";
    var newstr = document.all.item(printpage).innerHTML;
    var oldstr = document.body.innerHTML;
    document.body.innerHTML = headstr+newstr+footstr;
    window.print();
    document.body.innerHTML = oldstr;
    return false;
  }
 
    
          
</script>
</head>
<body topmargin="0" leftmargin="0">
  <html:form action="massquery?method=select" >
 <table width="100%" height="100%" border="0" align="center" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" valign="top">
          
               <div id="gzycyqk">
	           <table width="100%" height="80%" border="0" cellpadding="0" cellspacing="0" >
                    <tr>
                      <td align="center">
                        <img src="<%= graphURL %>" border=0 usemap="#<%= filename %>">
                      </td>
                    </tr>
                    
                </table>
                </div>
                
     </td>
   </tr>
 </table>
</html:form>
</body>
</html>

