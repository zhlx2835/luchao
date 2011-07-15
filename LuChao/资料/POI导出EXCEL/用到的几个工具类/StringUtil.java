package com.dpsms.util;

import java.io.BufferedReader;
import java.io.FileReader;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.apache.poi.ss.usermodel.Cell;

public class StringUtil {
	public static final String pattern = "##########.##";

	public static String getCellValue(Cell cell) {
		if (cell == null)
			return null;
		String result = "";
		int cellType = cell.getCellType();
		switch (cellType) {
		case Cell.CELL_TYPE_BLANK:
			break;
		case Cell.CELL_TYPE_BOOLEAN:
			result = "" + cell.getBooleanCellValue();
			break;
		case Cell.CELL_TYPE_FORMULA:
			result = "" + cell.getRichStringCellValue();
			break;
		case Cell.CELL_TYPE_NUMERIC:
			double num = cell.getNumericCellValue();
			BigDecimal bd = new BigDecimal(Double.toString(num));
			result = "" + bd.toString();
			break;
		case Cell.CELL_TYPE_STRING:
			result = "" + cell.getRichStringCellValue();
			break;
		default:
			break;
		}
		return result;
	}

	public static String createCode(int length) {
		String code = "";
		for (int i = 0; i < length; ++i) {
			java.util.Random seedRan = new java.util.Random();
			int seed = seedRan.nextInt();
			java.util.Random ran = new java.util.Random(seed);
			int num = Math.abs((ran.nextInt()) % 91);
			if (65 <= num && num <= 90) {
				char c = (char) num;
				code += c;
			} else {
				num = num % 10;
				code += num;
			}
		}
		return code;
	}

	public static String formatFloatNum(float f) {
		DecimalFormat df = new DecimalFormat(pattern);
		return df.format(f);
	}

	public static String formatlongNum(long l) {
		DecimalFormat df = new DecimalFormat(pattern);
		return df.format(l);
	}

	public static String formatObjNum(Object o) {
		DecimalFormat df = new DecimalFormat(pattern);
		return df.format(o);
	}

	public static String formatFloatNum(float f, String p) {
		DecimalFormat df = new DecimalFormat(p);
		return df.format(f);
	}

	public static String substring(String str, int toCount, String more) {
		int reInt = 0;
		String reStr = "";
		if (str == null)
			return "";
		char[] tempChar = str.toCharArray();
		for (int kk = 0; (kk < tempChar.length && toCount > reInt); kk++) {
			String s1 = str.valueOf(tempChar[kk]);
			byte[] b = s1.getBytes();
			reInt += b.length;
			reStr += tempChar[kk];
		}
		if (toCount == reInt || (toCount == reInt - 1))
			reStr += more;
		return reStr;
	}

	public static long[] stringToLong(String[] str) {
		long[] lon = new long[str.length];
		if (str != null && str.length > 0) {
			for (int i = 0; i < str.length; i++) {
				String s = str[i];
				long thelong = Long.valueOf(s);
				lon[i] = thelong;
			}
		}
		return lon;
	}

	public static Date parseDate(String dateStr, String style) {
		if (dateStr == null || dateStr.equals(""))
			return null;
		SimpleDateFormat sf = new SimpleDateFormat(style);
		Date date = null;
		try {
			date = sf.parse(dateStr);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return date;
	}

	public static String formatDate(Date date, String style) {
		if (date == null)
			return null;
		SimpleDateFormat sf = new SimpleDateFormat(style);
		String str = sf.format(date);
		return str;
	}

	public static String getChineseNumber(int num) {
		String result = "";
		switch (num) {
		case 1:
			result = "一";
		case 2:
			result = "二";
		case 3:
			result = "三";
		case 4:
			result = "四";
		case 5:
			result = "五";
		case 6:
			result = "六";
		case 7:
			result = "七";
		case 8:
			result = "八";
		case 9:
			result = "九";
		default:
			result = "";
		}
		return result;
	}
	/**
	 * 获取年度：<br>
	 * @eg:<br>
	 * 2009-2010<br>
	 * 2008-2009<br>
	 * 2007-2008<br>
	 * 2006-2007<br>
	 * @param count 获取几年
	 * @return
	 */
	public static List<String> getLastYeatToCurrentYear(int count){
		Calendar calendar = Calendar.getInstance();
		int currentY = calendar.get(calendar.YEAR)+1;
		List<String> list = new ArrayList<String>();
		for(int i=currentY;i>(currentY-count);i--){
			list.add((i-1)+"-"+i);
		}
		return list;
	}
	public static ArrayList readTxt(String fileName)
	{
		try
		{
			ArrayList file = new ArrayList();
			BufferedReader bReader = new BufferedReader(new FileReader(fileName));
			String s = null;
			while((s = bReader.readLine()) != null)
			{
				String line = s;
				file.add(line);
			}
			bReader.close();
			return file;
		}	
		catch(Exception e)
		{
			return null;
		}
	}
	/**
	 * 去掉指定字符串中的按回车键产生的转义字符
	 * @param str
	 * @return
	 */
	public static String replacKeyEnter(String str) {
		str = str.replaceAll("\r", "").replaceAll("\n", "");
		return str;
	}
	
	public static int FindStrAppearCount(String str, String con){
		
		str = " "+str;
        if(str.endsWith(con)){
            return str.split(con).length;
        }else{
            return str.split(con).length - 1;
        }		
		/*int srtlength = str.length() + 1;
		char strchar[] = new char[srtlength];
		for (int i=0; i<=srtlength-2; i++) {
			strchar[i] = str.charAt(i);
			strchar[srtlength - 1] = '齄';
		}
		Arrays.sort(strchar);
		for(int j=0;j<srtlength;j++){
			for(int k=j;k<srtlength;k++){
				if(strchar[j]!=strchar[k]){
					System.out.println(strchar[j]+":"+(k-j));
			        j=k;
				}
			}
		}*/
	}
	/**
	 * 判断一个字符串，是否在指定的字符串数组中
	 * @param substring
	 * @param source
	 * @return 存在返回：true;不存在返回：false
	 */
	public static boolean isIn(String substring, String[] source){
		if(source==null || source.length==0){
			return false;
		}
		for(int i=0; i<source.length; i++){
			String aSource = source[i];
			if(aSource.equals(substring)){
				return true;
			}
		}
		return false;
	}
}
