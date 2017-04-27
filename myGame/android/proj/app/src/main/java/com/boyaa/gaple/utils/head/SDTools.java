package com.boyaa.gaple.utils.head;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.os.Environment;
import android.util.Log;

import com.boyaa.engine.made.AppActivity;
import com.boyaa.engine.made.Sys;

public class SDTools {

	public static final String PNG_SUFFIX = "";
	private static byte[] sync = new byte[0];

	//保存png 图片
	public static boolean saveBitmap(Context context, String filePath , String fileName , Bitmap bmp ) {
		synchronized (sync) {
			
			if (null == filePath || 0 == filePath.length())
				return false;
			if (null == fileName || 0 == fileName.length())
				return false;
			if (null == bmp)
				return false;
			if (bmp.isRecycled())
				return false;

			// 生成新的
			String fullPath = filePath + fileName + PNG_SUFFIX;
			deleteFile(fileName);
			File file = new File(fullPath);
			try {
				file.createNewFile();
			} catch (IOException e) {
				Log.e("SDTools", e.toString());
				return false;
			}
			FileOutputStream fOut = null;
			try {
				fOut = new FileOutputStream(file);
			} catch (FileNotFoundException e) {
				Log.e("SDTools", e.toString());
				return false;
			}
			bmp.compress(Bitmap.CompressFormat.PNG, 100, fOut);
			try {
				fOut.flush();
				fOut.close();
				fOut = null;
			} catch (IOException e) {
				Log.e("SDTools", e.toString());
				return false;
			} finally {
				try {
					if (null != fOut)
						fOut.close();
				} catch (Exception e) {
					return false;
				}
			}
			return true;
		}
		
	}
	
	//删除文件
	private static boolean deleteFile(String name) {
		File file = new File(name);
		if (file.exists()) {
			return file.delete();
		}
		return false;
	}

   /**
    * sd卡是否可写
    * @return
    */
	public static boolean isExternalStorageWriteable() {

		return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
	}

	/** 获取外部存储根目录（mnt/sdcard） */
	public static String getExternalStorageRootDirectory() {
		return Environment.getExternalStorageDirectory().getAbsolutePath();
	}

	private static String getStorageUserRoot() {
		return Sys.getString("storage_outer_root");
	}

	public static boolean isFirstRun() {
		try {
			String e = AppActivity.getInstance().getPackageName();
			PackageInfo info = AppActivity.getInstance().getPackageManager().getPackageInfo(e, 0);
			int currentVersion = info.versionCode;
			int lastVersion = getLastVersionCode();
			if(currentVersion != lastVersion) {
				setCurrentVersionCode(currentVersion);
				return true;
			} else {
				return false;
			}
		} catch (PackageManager.NameNotFoundException var4) {
			var4.printStackTrace();
			return false;
		}
	}

	private static int getLastVersionCode() {
		File file = new File(getStorageUserRoot() + ".version_code");
		FileReader fr = null;
		BufferedReader br = null;
		if(file.exists() && file.isFile()) {
			int var5;
			try {
				fr = new FileReader(file);
				br = new BufferedReader(fr);
				String e = br.readLine();
				var5 = Integer.valueOf(e).intValue();
			} catch (Exception var17) {
				var17.printStackTrace();
				return 0;
			} finally {
				if(fr != null) {
					try {
						fr.close();
					} catch (IOException var16) {
						Log.e("ExternalStorage", var16.toString());
					}
				}

				if(br != null) {
					try {
						br.close();
					} catch (IOException var15) {
						Log.e("ExternalStorage", var15.toString());
					}
				}

			}

			return var5;
		} else {
			return 0;
		}
	}

	private static void setCurrentVersionCode(int code) {
		File file = new File(getStorageUserRoot() + ".version_code");
		FileWriter fw = null;
		BufferedWriter bw = null;

		try {
			if(!file.exists()) {
				file.createNewFile();
			}

			fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			bw.write(String.valueOf(code));
			bw.flush();
		} catch (Exception var17) {
			var17.printStackTrace();
		} finally {
			if(fw != null) {
				try {
					fw.close();
				} catch (IOException var16) {
					Log.e("ExternalStorage", var16.toString());
				}
			}

			if(bw != null) {
				try {
					bw.close();
				} catch (IOException var15) {
					Log.e("ExternalStorage", var15.toString());
				}
			}

		}

	}

	
}
