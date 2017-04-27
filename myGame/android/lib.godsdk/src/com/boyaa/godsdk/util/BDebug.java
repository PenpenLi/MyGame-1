package com.boyaa.godsdk.util;

import android.util.Log;

/**
 * 调式工具类
 * @author 
 *
 */
public class BDebug {

	public static final boolean IS_PRINT_LOG = true; //是否打印日志

	public static void v(String tag, String msg){
		if(IS_PRINT_LOG){
			Log.v(tag, msg);
		}
	}
	
	public static void d(String tag, String msg){
		if(IS_PRINT_LOG){
			Log.d(tag, msg);
		}
	}
	
	public static void i(String tag, String msg){
		if(IS_PRINT_LOG){
			Log.i(tag, msg);
		}
	}
	
	public static void w(String tag, String msg){
		if(IS_PRINT_LOG){
			Log.w(tag, msg);
		}
	}
	
	public static void e(String tag, String msg){
		if(IS_PRINT_LOG){
			Log.e(tag, msg);
		}
	}

	public static void print(String msg){
		if(IS_PRINT_LOG){
			Log.d("boyaa-godsdk", msg);
		}
	}
	
}
