package org.cathassist.radio.utils;

import java.io.*;
import java.util.Calendar;
import java.util.Date;

import org.apache.http.util.EncodingUtils;

import android.util.Log;

public class Common
{
	public static boolean isDateSame(Date d1,Date d2)
	{
		Calendar c1 = Calendar.getInstance();
		Calendar c2 = Calendar.getInstance();
		c1.setTime(d1);
		c2.setTime(d2);
		return c1.get(Calendar.DAY_OF_MONTH) == c2.get(Calendar.DAY_OF_MONTH)
				&& c1.get(Calendar.MONTH) == c2.get(Calendar.MONTH)
				&& c1.get(Calendar.YEAR) == c2.get(Calendar.YEAR);

	}
	
	public static String readContentFromFile(String fileName)
	{
		String content = "";
		File fIn = new File(fileName);
		if(fIn.exists())
		{
			try
			{
				FileInputStream fin = new FileInputStream(fIn);
				int length = fin.available();
				byte[] buffer = new byte[length];
				fin.read(buffer);
				content = EncodingUtils.getString(buffer, "UTF-8");
				fin.close();
		        Log.d("utils.Common","Read from file:"+fileName);
			}
			catch (IOException e)
			{
		       e.printStackTrace();
			}
		}
		return content;
	}
	
	public static boolean writeContentToFile(String fileName,String content)
	{
		try
		{
			File fOut = new File(fileName);
			FileOutputStream fout = new FileOutputStream(fOut);
			byte[] bytes = content.getBytes();
	        fout.write(bytes);
	        fout.close();
	        Log.d("utils.Common","Write to file:"+fileName);
        }
		catch(Exception e)
		{
	        e.printStackTrace();
	        return false;
        }
		
		return true;
	}
}
