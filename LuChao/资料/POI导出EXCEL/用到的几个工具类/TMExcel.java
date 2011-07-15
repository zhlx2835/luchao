package com.dpsms.util;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

/**
 * 
 * ���ߣ�Ҷ��<br>
 * ��������: Excel�����࣬���Ը���Excelģ��������Excel����<br>
 * ����ʱ�䣺2011-05-19 20:27:57<br>
 * �汾��Ϣ��1.0 <br>
 * Copyright: Copyright (c) 2011<br>
 */
public class TMExcel {
	private static Log logger = LogFactory.getLog(TMExcel.class);
	private static final String DATAS = "datas";
	
	private HSSFWorkbook workbook;
	private HSSFSheet sheet;
	private HSSFRow currentRow;
	private Map styles = new HashMap(); //�����е�Ĭ����ʽ����
	private Map confStyles = new HashMap(); //ͨ������"#STYLE_XXX"����ʶ����ʽ����
	private int initrow; //���������ʼ��
	private int initcol; //���������ʼ��
	private int num; //index number
	private int currentcol; //��ǰ��
	private int currentRowIndex; //��ǰ��index
	private int rowheight = 22; //�и�
	private int lastLowNum = 0;
	private String cellStyle = null;
	
	private TMExcel() {
	}
	
	/**
	 * ʹ��Ĭ��ģ�崴��TMExcel����
	 * @return ����ģ���ѳ�ʼ����ɵ�TMExcel����
	 */
	public static TMExcel newInstance(){
		return newInstance("templates/default.xls");
	}

	/**
	 * ָ��ģ�崴��TMExcel����
	 * @param templates ģ������
	 * @return ����ģ���ѳ�ʼ����ɵ�TMExcel����
	 */
	public static TMExcel newInstance(String templates){
		try {
			TMExcel excel = new TMExcel();
			POIFSFileSystem fs = new POIFSFileSystem(Thread.currentThread().getContextClassLoader().getResourceAsStream(templates));
			excel.workbook = new HSSFWorkbook(fs);
			excel.sheet = excel.workbook.getSheetAt(0);
			
			//��������
			excel.initConfig();
			
			//����������ʽ����
			excel.readCellStyles();
			
			//ɾ��������
			excel.sheet.removeRow( excel.sheet.getRow(excel.initrow) );
			
			return excel;
		} catch (Exception e) {
			e.printStackTrace();
			logger.trace("����Excel��������쳣",e);
			throw new RuntimeException("����Excel��������쳣");
		}
	}
	
	
	/**
	 * �����ض��ĵ�Ԫ����ʽ������ʽ����ͨ����ģ���ļ��ж���"#STYLE_XX"���õ����磺
	 * #STYLE_1������Ĳ�������"STYLE_1"
	 * @param style 
	 */
	public void setCellStyle(String style){
		cellStyle = style;
	}
	
	/**
	 * ȡ���ض��ĵ�Ԫ���ʽ���ָ�Ĭ�ϵ�����ֵ����DATAS�����е�ֵ
	 */
	public void setCellDefaultStyle(){
		cellStyle = null;
	}
	
	/**
	 * ��������
	 * @param index ��0��ʼ����
	 */
	public void createRow(int index){
		//����ڵ�ǰ�������ݵ������к����У����������������ƶ�
		if(lastLowNum > initrow && index > 0){
			sheet.shiftRows(index + initrow ,lastLowNum + index,1,true,true);
		}
		currentRow = sheet.createRow(index + initrow);
		currentRow.setHeight((short)rowheight);
		currentRowIndex = index;
		currentcol = initcol;
	}
	
	/**
	 * ���ݴ�����ַ���ֵ���ڵ�ǰ���ϴ�������
	 * @param value �е�ֵ���ַ�����
	 */
	public void createCell(String value){
		HSSFCell cell = createCell();
		cell.setCellType(HSSFCell.CELL_TYPE_STRING);
		cell.setCellValue(value);
	}
	
	/**
	 * ���ݴ��������ֵ���ڵ�ǰ���ϴ�������
	 * ����������£��������ڣ����������ģ���ж����Ӧ��
	 * �����ڸ�ʽ�������������ͨ��ģ����������������ڸ�ʽ
	 * @param value ����
	 */
	public void createCell(Date value){
		HSSFCell cell = createCell();
		cell.setCellValue(value);
	}
	
	/**
	 * ������ǰ�е����к��У�ͨ����һ�еĿ�ͷ��ᴴ��
	 * ע��Ҫʹ�����������������ڴ�����֮ǰ����initPageNumber����
	 */
	public void createSerialNumCell(){
		HSSFCell cell = createCell();
		cell.setCellValue(currentRowIndex + num);
	}
	
	private HSSFCell createCell(){
		HSSFCell cell = currentRow.createCell(currentcol++);
//		cell.setEncoding(HSSFCell.ENCODING_UTF_16);
		HSSFCellStyle style = (HSSFCellStyle)styles.get(new Integer(cell.getColumnIndex()));
		if(style != null){
			cell.setCellStyle(style);
		}
		
		//�������ض���ʽ
		if(cellStyle != null){
			HSSFCellStyle ts = (HSSFCellStyle)confStyles.get(cellStyle);
			if(ts != null){
				cell.setCellStyle(ts);
			}
		}
		return cell;
	}
	
	/**
	 * ��ȡ��ǰHSSFWorkbook��ʵ��
	 * @return
	 */
	public HSSFWorkbook getWorkbook(){
		return workbook;
	}
	
	/**
	 * ��ȡģ���ж���ĵ�Ԫ����ʽ�����û�ж��壬�򷵻ؿ�
	 * @param style ģ�嶨�����ʽ����
	 * @return ģ�嶨��ĵ�Ԫ�����ʽ�����û�ж����򷵻ؿ�
	 */
	public HSSFCellStyle getTemplateStyle(String style){
		return (HSSFCellStyle)confStyles.get(style);
	}
	
	/**
	 * �滻ģ���е��ı�����
	 * �����ԡ�#����ʼ
	 * @param props
	 */
	public void replaceParameters(Properties props){
		if(props == null || props.size() == 0){
			return;
		}
		Set propsets = props.entrySet();
		Iterator rowit = sheet.rowIterator();
		while(rowit.hasNext()){
			HSSFRow row = (HSSFRow)rowit.next();
			if(row == null)	continue;
			int cellLength = row.getLastCellNum();
			for(int i=0; i<cellLength; i++){
				HSSFCell cell = (HSSFCell)row.getCell(i);
				if(cell == null) continue;
				String value = cell.getStringCellValue();
				if(value != null && value.indexOf("#") != -1){
					for (Iterator iter = propsets.iterator(); iter.hasNext();) {
						Map.Entry entry = (Map.Entry) iter.next();
						value = value.replaceAll("#"+entry.getKey(),(String)entry.getValue());
					}
				}
//				cell.setEncoding(HSSFCell.ENCODING_UTF_16);
				cell.setCellValue(value);
			}
		}
	}
	
	/**
	 * ��ʼ��Excel����
	 */
	private void initConfig(){
		lastLowNum = sheet.getLastRowNum();
		Iterator rowit = sheet.rowIterator();
		boolean configFinish = false;
		while(rowit.hasNext()){
			if(configFinish){
				break;
			}
			HSSFRow row = (HSSFRow)rowit.next();
			if(row == null)	continue;
			int cellLength = row.getLastCellNum();
			int rownum = row.getRowNum();
			for(int i=0; i<cellLength; i++){
				HSSFCell cell = (HSSFCell)row.getCell(i);
				if(cell == null) continue;
				String config = cell.getStringCellValue();
				if(DATAS.equalsIgnoreCase(config)){
					//���������ݿ�ʼ�к���ʽ�����У���Ҫ��ȡ��Ӧ��������Ϣ
					initrow = row.getRowNum();
					rowheight = row.getHeight();
					initcol = cell.getColumnIndex();
					configFinish = true;
				}
				if(configFinish){
					readCellStyle(cell);
				}				
			}
		}
	}
	
	/**
	 * ��ȡcell����ʽ
	 * @param cell
	 */
	private void readCellStyle(HSSFCell cell){
		HSSFCellStyle style = cell.getCellStyle();
		if(style == null) return;
		styles.put(new Integer(cell.getColumnIndex()),style);
	}
	
	/**
	 * ��ȡģ����������Ԫ�����ʽ����
	 */
	private void readCellStyles(){
		Iterator rowit = sheet.rowIterator();
		while(rowit.hasNext()){
			HSSFRow row = (HSSFRow)rowit.next();
			if(row == null)	continue;
			int cellLength = row.getLastCellNum();
			for(int i=0; i<cellLength; i++){
				HSSFCell cell = (HSSFCell)row.getCell(i);
				if(cell == null) continue;
				String value = cell.getStringCellValue();
				if(value != null && value.indexOf("#STYLE_") != -1){
					HSSFCellStyle style = cell.getCellStyle();
					if(style == null) continue;
					confStyles.put(value.substring(1),style);
					
					//remove it
					row.removeCell(cell);
				}
			}
		}
	}
	
	//Test TMExcel
	public static void main(String[] args){
		try {
			TMExcel excel = new TMExcel();
			POIFSFileSystem fs = new POIFSFileSystem(Thread.currentThread().getContextClassLoader().getResourceAsStream("com/dpsms/temp.xls"));
			excel.workbook = new HSSFWorkbook(fs);
			excel.sheet = excel.workbook.getSheetAt(0);

//			excel.mergeTable(3,3);
			
			FileOutputStream fileOut = new FileOutputStream("E:/temp.xls");
			excel.getWorkbook().write(fileOut);
			fileOut.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
