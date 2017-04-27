package com.boyaa.gaple.utils.head;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ContentUris;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.util.Log;
import android.widget.Toast;

import com.boyaa.xiaojian.R;
import com.boyaa.gaple.nativeEvent.LuaEventCall;
import com.boyaa.gaple.utils.head.SDTools;
//import com.boyaa.app.core.HandlerManager;
import com.boyaa.gaple.Game;
import com.boyaa.engine.made.AppActivity;
//import com.boyaa.util.JsonUtil;

public class FeedbackPicture {

	private Game activity;
	private String strDicName;

	public FeedbackPicture() {

	}

	public FeedbackPicture(Game activity) {
		this.activity = activity;
	}

	private static final String TAG = FeedbackPicture.class.getSimpleName();
	/**
	 * 用来标识请求picture的activity
	 */
	public static final int FEEDBACK_PICKED_PICTURE_DATA = 1001;
	private String imagePath = "";


    public void getPicture(String path){
		imagePath = path;
		if (!SDTools.isExternalStorageWriteable()) {
			Toast.makeText(this.activity, "noSDCard",
					Toast.LENGTH_SHORT).show();
			return;
		}

		Intent intent = new Intent(Intent.ACTION_PICK, null);
		intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
		AppActivity.getInstance().startActivityForResult(intent,
				FEEDBACK_PICKED_PICTURE_DATA);
	}

	public void saveBitmap(Intent data){
		Uri selectedImage = data.getData();
		String[] filePathColumn = {MediaStore.Images.Media.DATA};
		Context mContext = this.activity.getBaseContext();
		Cursor cursor = mContext.getContentResolver().query(selectedImage,filePathColumn, null, null, null);
		cursor.moveToFirst();
		int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
		final String picturePath = cursor.getString(columnIndex);
		Log.d(TAG, "selectedImage:" + selectedImage + ",picturePath:" + picturePath);
		BitmapFactory.Options newOpts = new BitmapFactory.Options();
		//开始读入图片，此时把options.inJustDecodeBounds 设回true了
		newOpts.inJustDecodeBounds = true;
		Bitmap bitmap = BitmapFactory.decodeFile(picturePath,newOpts);//此时返回bm为空

		newOpts.inJustDecodeBounds = false;
		int w = newOpts.outWidth;
		int h = newOpts.outHeight;
		float hh = 800f;
		float ww = 800f;
		//缩放比。由于是固定比例缩放，只用高或者宽其中一个数据进行计算即可
		int be = 1;//be=1表示不缩放
		if (w > h && w > ww) {//如果宽度大的话根据宽度固定大小缩放
			be = (int) (newOpts.outWidth / ww);
		} else if (w < h && h > hh) {//如果高度高的话根据宽度固定大小缩放
			be = (int) (newOpts.outHeight / hh);
		}
		if (be <= 0)
			be = 1;
		newOpts.inSampleSize = be;//设置缩放比例
		//重新读入图片，注意此时已经把options.inJustDecodeBounds 设回false了
		bitmap = BitmapFactory.decodeFile(picturePath, newOpts);

		File file = new File(imagePath, "temp_upload_image.jpg");
		if(file.exists()) {
			file.delete();
		}
		FileOutputStream fos = null;
		String newPicturePath = picturePath;
		try {
			fos = new FileOutputStream(file);
			bitmap.compress(Bitmap.CompressFormat.JPEG, 40, fos);
			fos.flush();
			newPicturePath = file.getAbsolutePath();
			file.deleteOnExit();
		} catch (FileNotFoundException e) {
			Log.e(TAG, e.getMessage(), e);
		} catch (IOException e) {
			Log.e(TAG, e.getMessage(), e);
		} finally {
			if(fos != null) {
				try {
					fos.close();
				} catch(Exception e) {}
			}
		}
		final String finalPicturePath = "temp_upload_image.jpg";

		Game.getInstance().getLuaEventCall().luaCallEvent("gamePickPictureCallBack", LuaEventCall.kResultSucess, 3, finalPicturePath);
	}
}