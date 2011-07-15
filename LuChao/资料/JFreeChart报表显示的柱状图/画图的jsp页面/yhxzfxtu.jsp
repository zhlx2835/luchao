
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
  //*******�����̬ѭ��
  if (list != null && list.size() > 0) {
    for (int i = 0; i < list.size(); i++){
        WluruVO vo = (WluruVO)list.get(i);
    	String wentitype=vo.getWentitype();	//��������
    	String swnumber=vo.getSwnumber(); //��Υ�ܴ���
    	String ssw=vo.getSsw();		//����Υ
    	String fsw=vo.getFsw();		//����Υ	
    	dataset.addValue(Integer.parseInt(swnumber),"�ܴ���",wentitype);
    	dataset.addValue(Integer.parseInt(ssw),"��Υ����",wentitype);
    	dataset.addValue(Integer.parseInt(fsw),"����Υ����",wentitype);
             	
 	}
  }
//  double[][] data = new double[][] {{672, 766, 223, 540, 126}, {325, 521, 210, 340, 106}, {332, 256, 523, 240, 526}};
//  String[] rowKeys = {"ƻ��","����","����"};
//  String[] columnKeys = {"����","�Ϻ�","����","�ɶ�","����"};
 
//  dataset.addValue(100, "����", "ƻ��"); 
//	dataset.addValue(500, "����", "��֦"); 
//  dataset.addValue(400, "����", "�㽶"); 
//	dataset.addValue(200, "����", "����"); 
//	dataset.addValue(300, "����", "����"); 
//	dataset.addValue(500, "�Ϻ�", "����"); 
//	dataset.addValue(600, "�Ϻ�", "����"); 
//	dataset.addValue(400, "�Ϻ�", "�㽶"); 
//	dataset.addValue(700, "�Ϻ�", "ƻ��"); 
//	dataset.addValue(300, "�Ϻ�", "��֦"); 
//	dataset.addValue(300, "����", "ƻ��"); 
//	dataset.addValue(200, "����", "����"); 
//	dataset.addValue(500, "����", "�㽶"); 
//	dataset.addValue(400, "����", "����"); 
//	dataset.addValue(700, "����", "��֦");

 //����������ϵ�����,�Լ�����....
JFreeChart chart = ChartFactory.createBarChart3D("����_Υ�����ʷ���", // chart title
    "�������", // domain axis label
    "����", // range axis label
    dataset, // data
    PlotOrientation.VERTICAL, // PlotOrientation.VERTICAL ��ƽ������ֱ��ʾ���� PlotOrientation.HORIZONTAL ����ƽ����ˮƽ��ʾ
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
// ͼʾ��ͼ���е���ʾλ��

  LegendTitle legend = (LegendTitle) chart.getLegend();
  legend.setPosition(RectangleEdge.TOP);    //ʾ��ͼλ��
 // legend.setPosition(RectangleEdge.RIGHT);
  legend.setLegendItemGraphicEdge(RectangleEdge.LEFT);

  ValueAxis rangeAxis = plot.getRangeAxis();
  
  //������ߵ�һ�� Item ��ͼƬ���˵ľ���
  rangeAxis.setUpperMargin(0.15);
  
  //������͵�һ�� Item ��ͼƬ�׶˵ľ���
  rangeAxis.setLowerMargin(0.15);
  plot.setRangeAxis(rangeAxis);

  BarRenderer3D renderer = new BarRenderer3D();
  renderer.setBaseOutlinePaint(Color.blue);
  
  //���� Wall ����ɫ
  renderer.setWallPaint(Color.darkGray);
  
  renderer.setSeriesPaint(0, Color.red);
  renderer.setSeriesPaint(1, Color.GREEN);
  renderer.setSeriesPaint(2, Color.orange);
  
  //����ÿ��������������ƽ������֮�����
  renderer.setItemMargin(0.03);
  
  //��ʾÿ��������ֵ(����)�����޸ĸ���ֵ����������
  renderer.setItemLabelGenerator(new StandardCategoryItemLabelGenerator());

  renderer.setItemLabelFont(new Font("����",Font.PLAIN,12));
  renderer.setItemLabelsVisible(true);
  ItemLabelPosition itemLabelPosition = new ItemLabelPosition();
  renderer.setPositiveItemLabelPosition(itemLabelPosition);
  plot.setRenderer(renderer);

  //��������͸����
  plot.setForegroundAlpha(1f);
  
  //����רҵ����������ʾλ��
//  plot.setDrawSharedDomainAxis(true);
  plot.setDomainAxisLocation(AxisLocation.BOTTOM_OR_LEFT);
  plot.setRangeAxisLocation(AxisLocation.BOTTOM_OR_LEFT);

  //̨ʽ����Ļ��С
  //String  filename = ServletUtilities.saveChartAsPNG(chart, 1450, 750, null, session);
  
  //�ʼǱ���Ļ��С
  String filename = ServletUtilities.saveChartAsPNG(chart, 1220, 490, null, session);
  String graphURL = request.getContextPath() + "/servlet/DisplayChart?filename=" + filename;
%>
<html>
<head>
	
	<link href="Css/TestDate.css" rel="stylesheet">
	<%--����--%>
	
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

