package com.boyaa.gaple.utils.head;

import java.io.File;
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
import android.print.PrinterInfo;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;
import android.util.Log;
import android.widget.Toast;

import com.boyaa.xiaojian.R;
import com.boyaa.gaple.nativeEvent.LuaEventCall;
import com.boyaa.gaple.utils.head.SDTools;
import com.boyaa.gaple.Game;
import com.boyaa.engine.made.AppActivity;

public class SaveHeadImage {
	private static SaveHeadImage instance;
	private SaveHeadImage() {
		Log.d("SaveHeadImage","SaveHeadImage.ctor()");
	}
	public static SaveHeadImage getInstance(){
		if (instance == null){
			instance = new SaveHeadImage();
		}
		return instance;
	}
	private Game activity;
	private String imagePath = "";
	/**
	 * 请求gallery的activity标识
	 */
	public static final int GALLERY_PICKED_DATA = 10001;
	/**
	 * 请求camera的activity标识
	 */
	public static final int CAMERA_PICKED_DATA = 10002;

	private File mCurrentPhotoFile;
	private int mode = 1;
	private  String IMAGE_FILE_LOCATION = "";
	private Uri imageUri ;
	private boolean mIsPhoto = false;

	public void setActivity(Game activity){
		this.activity = activity;
	}

	public void doPickPhotoAction(JSONObject jsonstr) {
		if (!SDTools.isExternalStorageWriteable()) {
			Toast.makeText(this.activity, "noSDCard",
					Toast.LENGTH_SHORT).show();
			return;
		}

		try {
			JSONObject jsonResult = jsonstr;

			imagePath = jsonResult.getString("imagePath");
			mode = jsonResult.getInt("mode");

			IMAGE_FILE_LOCATION = "file://" + "/" + imagePath + "temp.png";
			imageUri = Uri.parse(IMAGE_FILE_LOCATION);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		if (mode == 1)
			doPickPhotoFromGallery();
		else
			doTakePhoto();
	}

	/**
	 * 选择本地图片作为头像
	 */
	public void doPickPhotoFromGallery() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			Intent intent = new Intent(Intent.ACTION_GET_CONTENT,null);
			intent.setType("image/*");
			//intent.setAction(Intent.ACTION_GET_CONTENT);
			intent.putExtra("crop", "true");
			intent.putExtra("aspectX", 1);
			intent.putExtra("aspectY", 1);
			intent.putExtra("outputX", 240);
			intent.putExtra("outputY", 240);
			intent.putExtra("return-data", false);
			intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
			intent.putExtra("outputFormat", Bitmap.CompressFormat.PNG.toString());
			intent.putExtra(MediaStore.EXTRA_SCREEN_ORIENTATION,
					ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

			activity.startActivityForResult(Intent.createChooser(
					intent, "choose photo"),
					GALLERY_PICKED_DATA);
		} else {
			Intent intent = new Intent(Intent.ACTION_GET_CONTENT,null);
			//intent.setAction(Intent.ACTION_GET_CONTENT);
			//Intent intent = new Intent(Intent.ACTION_PICK);
			intent.setType("image/*");
			intent.putExtra("crop", "true");
			intent.putExtra("aspectX", 1);
			intent.putExtra("aspectY", 1);
			intent.putExtra("outputX", 240);
			intent.putExtra("outputY", 240);
			intent.putExtra("return-data", false);
			intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
			intent.putExtra("outputFormat", Bitmap.CompressFormat.PNG.toString());
			intent.putExtra(MediaStore.EXTRA_SCREEN_ORIENTATION,
					ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

			activity.startActivityForResult(Intent.createChooser(
					intent, "choose photo"),
					GALLERY_PICKED_DATA);

		}
	}

	/**
	 * 系统相机拍照获取图片
	 */
	public void doTakePhoto() {
		try {
			// 照片name
			String dateFormat = new SimpleDateFormat("yyMMddHHmmss")
					.format(new Date());
			String imageName = dateFormat + ".png";

			// 照片file
			File fileDir = new File(imagePath);
			fileDir.mkdirs();
			mCurrentPhotoFile = new File(fileDir, imageName);
			mIsPhoto = true;

			Intent intent = new Intent();
			intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
			intent.setAction(MediaStore.ACTION_IMAGE_CAPTURE);
			if(Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP){
				intent.putExtra(MediaStore.EXTRA_OUTPUT,Uri.fromFile(mCurrentPhotoFile));
			}else{
				intent.putExtra(MediaStore.EXTRA_OUTPUT,
						FileProvider.getUriForFile(AppActivity.getInstance(),AppActivity.getInstance().getApplicationContext().getPackageName()+ ".provider",mCurrentPhotoFile));
			}
			intent.putExtra("android.intent.extras.CAMERA_FACING", 1); // 调用前置摄像头， 6.0钓不到
			intent.putExtra("autofocus", true); // 自动对焦
			intent.putExtra("fullScreen", true); // 全屏
			intent.putExtra("showActionIcons", false);
			intent.putExtra(MediaStore.EXTRA_SCREEN_ORIENTATION,
					ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

			AppActivity.getInstance().startActivityForResult(intent,
					CAMERA_PICKED_DATA);
		} catch (ActivityNotFoundException e) {
			Toast.makeText(AppActivity.getInstance(), "store failed", Toast.LENGTH_LONG).show();
		}
	}

	public void doCropPhoto(Intent i) {

		try {
			// 启动gallery去剪辑这个照片
			Uri uri;
			if(Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP){
				 uri = Uri.fromFile(mCurrentPhotoFile);
			}else{
				 uri = FileProvider.getUriForFile(AppActivity.getInstance(),AppActivity.getInstance().getApplicationContext().getPackageName()+ ".provider",mCurrentPhotoFile);
			}

			Intent intent = new Intent("com.android.camera.action.CROP");
			intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
			intent.setDataAndType(uri, "image/*");
			intent.putExtra("crop", "true");
			intent.putExtra("aspectX", 1);
			intent.putExtra("aspectY", 1);
			intent.putExtra("outputX", 240);
			intent.putExtra("outputY", 240);
			intent.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
			intent.putExtra("return-data", false);
			intent.putExtra("outputFormat", Bitmap.CompressFormat.PNG.toString());
			intent.putExtra(MediaStore.EXTRA_SCREEN_ORIENTATION,
					ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

			this.activity.startActivityForResult(intent, GALLERY_PICKED_DATA);
		} catch (Exception e) {
			Toast.makeText(this.activity, "no gallery", Toast.LENGTH_LONG).show();
		}
	}

	public void onSaveBitmap(Intent data) {
		// Bitmap bitmap = data.getParcelableExtra("data")   小图片
		if (null == data) {
			return;
		}

		File temp = new File(imagePath + "temp.png");
		boolean exist = temp.exists();

		if (exist){
			//删除拍照的原图
			if ( mCurrentPhotoFile != null && mCurrentPhotoFile.exists() && mIsPhoto) {
				mCurrentPhotoFile.delete();
				mIsPhoto = false;
			}
			// 保存头像成功，通知lua
			Game.getInstance().getLuaEventCall().luaCallEvent("gamePickImageCallBack", LuaEventCall.kResultSucess, 3, imagePath + "temp.png");
		}else {
			//Game.getInstance().getLuaEventCall().luaCallEvent("gamePickImageCallBack", LuaEventCall.kResultFail, -1, null);
			Uri uri = data.getData();     // android 6.0 选择本地图片不会跳出剪辑图片的界面，所以手动调用剪辑图片,我也不知道为什么。
			if (uri != null){
				String path = checkPath(activity, uri);
				if (path != null){
					mCurrentPhotoFile = new File(path);
					doCropPhoto(data);
				}

			}
		}
	}

	@SuppressLint("NewApi")
	public static String checkPath(final Context context, final Uri uri) {

		final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

		// DocumentProvider
		if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
			// ExternalStorageProvider
			if (isExternalStorageDocument(uri)) {
				final String docId = DocumentsContract.getDocumentId(uri);
				final String[] split = docId.split(":");
				final String type = split[0];

				if ("primary".equalsIgnoreCase(type)) {
					return Environment.getExternalStorageDirectory() + "/"
							+ split[1];
				}

			}
			// DownloadsProvider
			else if (isDownloadsDocument(uri)) {
				final String id = DocumentsContract.getDocumentId(uri);
				final Uri contentUri = ContentUris.withAppendedId(
						Uri.parse("content://downloads/public_downloads"),
						Long.valueOf(id));

				return getDataColumn(context, contentUri, null, null);
			}
			// MediaProvider
			else if (isMediaDocument(uri)) {
				final String docId = DocumentsContract.getDocumentId(uri);
				final String[] split = docId.split(":");
				final String type = split[0];

				Uri contentUri = null;
				if ("image".equals(type)) {
					contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
				} else if ("video".equals(type)) {
					contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
				} else if ("audio".equals(type)) {
					contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
				}

				final String selection = "_id=?";
				final String[] selectionArgs = new String[] { split[1] };

				return getDataColumn(context, contentUri, selection,
						selectionArgs);
			}
		}
		// MediaStore (and general)
		else if ("content".equalsIgnoreCase(uri.getScheme())) {
			// Return the remote address
			if (isGooglePhotosUri(uri))
				return uri.getLastPathSegment();

			return getDataColumn(context, uri, null, null);
		}
		// File
		else if ("file".equalsIgnoreCase(uri.getScheme())) {
			return uri.getPath();
		}

		return null;
	}

	/**
	 * @param uri
	 *            The Uri to check.
	 * @return Whether the Uri authority is ExternalStorageProvider.
	 */
	public static boolean isExternalStorageDocument(Uri uri) {
		return "com.android.externalstorage.documents".equals(uri
				.getAuthority());
	}

	/**
	 * @param uri
	 *            The Uri to check.
	 * @return Whether the Uri authority is DownloadsProvider.
	 */
	public static boolean isDownloadsDocument(Uri uri) {
		return "com.android.providers.downloads.documents".equals(uri
				.getAuthority());
	}

	/**
	 * Get the value of the data column for this Uri. This is useful for
	 * MediaStore Uris, and other file-based ContentProviders.
	 *
	 * @param context
	 *            The context.
	 * @param uri
	 *            The Uri to query.
	 * @param selection
	 *            (Optional) Filter used in the query.
	 * @param selectionArgs
	 *            (Optional) Selection arguments used in the query.
	 * @return The value of the _data column, which is typically a file path.
	 */
	public static String getDataColumn(Context context, Uri uri,
									   String selection, String[] selectionArgs) {

		Cursor cursor = null;
		final String column = "_data";
		final String[] projection = { column };

		try {
			cursor = context.getContentResolver().query(uri, projection,
					selection, selectionArgs, null);
			if (cursor != null && cursor.moveToFirst()) {
				final int index = cursor.getColumnIndexOrThrow(column);
				return cursor.getString(index);
			}
		} finally {
			if (cursor != null)
				cursor.close();
		}
		return null;
	}

	/**
	 * @param uri
	 *            The Uri to check.
	 * @return Whether the Uri authority is MediaProvider.
	 */
	public static boolean isMediaDocument(Uri uri) {
		return "com.android.providers.media.documents".equals(uri
				.getAuthority());
	}

	/**
	 * @param uri
	 *            The Uri to check.
	 * @return Whether the Uri authority is Google Photos.
	 */
	public static boolean isGooglePhotosUri(Uri uri) {
		return "com.google.android.apps.photos.content".equals(uri
				.getAuthority());
	}
}