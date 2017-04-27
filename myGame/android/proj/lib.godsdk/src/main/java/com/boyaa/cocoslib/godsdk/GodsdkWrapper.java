package com.boyaa.cocoslib.godsdk;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import com.boyaa.godsdk.sdk.GodSDKHelper;
import com.boyaa.godsdk.sdk.IGodsdkCallback;
import com.boyaa.godsdk.util.BDebug;

public class GodsdkWrapper {

	private static final String TAG = GodsdkWrapper.class.getSimpleName();
	public static final int Payment_Success = 1;
	public static final int Payment_Failed = 0;
	
	//当前发起支付的参数
	private static JSONObject paymentParams;
	
	private static GodSDKHelper godsdkHelper;

	private static Activity mActivity;

	private static GodsdkWrapperCallback gameCallback;

	private static IGodsdkCallback godsdkCallback = new IGodsdkCallback() {
		
		@Override
		public void onPaymentSuccess(Map map, String pmode) {
//			if(paymentParams == null) {
//				paymentParams = new JSONObject();
//			}
//
//			try {
//				paymentParams.put("result", Payment_Success);
//			} catch (JSONException e) {
//				BDebug.print("call back onPaymentSuccess error");
//				e.printStackTrace();
//			}
//			String jsonResult = paymentParams.toString();

			//			TODO
			//if(pmode.equals("12")) {
				String OriginalBase = "";
				OriginalBase = (String) map.get("OriginalJson");
				String Signature = (String) map.get("Signature");
				JSONObject json = new JSONObject();
				try {
					json.put("pmode", pmode);
					json.put("OriginalBase", OriginalBase);
					json.put("Signature", Signature);
				}catch (Exception e){

				}
				gameCallback.onCallback(json.toString());
			//}
		}
		
		@Override
		public void onPaymentFailed(String pmode) {
			if(paymentParams == null) {
				paymentParams = new JSONObject();
			}
			
			try {
				paymentParams.put("result", Payment_Failed);
			} catch (JSONException e) {
				BDebug.print("call back onPaymentFailed error");
				e.printStackTrace();
			}
			String jsonResult = paymentParams.toString();
			//			TODO
		}
	};
	
	public String getChannelId() {
		String channelId = godsdkHelper.getChannelId();
		BDebug.print("godsdk channel id:" + channelId);
		if(channelId == null || channelId == ""){
			Context ctx = (Context) mActivity;
			if(ctx != null) {
				try {
					ApplicationInfo appInfo = ctx.getPackageManager().getApplicationInfo(ctx.getPackageName(), PackageManager.GET_META_DATA);
					channelId = appInfo.metaData.getString("BM_CHANNEL_ID");
					if(channelId != null) {
						channelId = channelId.trim();
					}
				} catch(Exception e) {
					Log.e(TAG, e.getMessage(), e);
				}
			}
		}
		BDebug.print(">>> channel id:" + channelId);
		return channelId;
	}

	public static void init(Activity activity, GodsdkWrapperCallback gameCallbacks){
		mActivity = activity;
		godsdkHelper = new GodSDKHelper(mActivity);
		godsdkHelper.init(godsdkCallback);
		gameCallback = gameCallbacks;
	}

	/**
	 * 支付接口
	 * **/
	public static void callPayment(final String jsonParams) {
		mActivity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				try {
					paymentParams = new JSONObject(jsonParams);
					godsdkHelper.callPayment(jsonParams);
				} catch (JSONException e) {
					BDebug.print("payment error:" + jsonParams);
					e.printStackTrace();
				}
			}
		});

	}
}
