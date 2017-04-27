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

import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;
import com.boyaa.godsdk.sdk.GodSDKHelper;
import com.boyaa.godsdk.sdk.IGodsdkCallback;
import com.boyaa.godsdk.util.BDebug;

public class GodsdkPlugin extends LifecycleObserverAdapter implements IPlugin {
	
	public static final int Payment_Success = 1;
	public static final int Payment_Failed = 0;
	
	//当前发起支付的参数
	private JSONObject paymentParams;
	
	private String pluginId;
	
	private GodSDKHelper godsdkHelper;
	
	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);
	}

	@Override
	public void setId(String id) {
		pluginId = id;
	}
	
	public String getId() {
		return pluginId;
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		godsdkHelper = new GodSDKHelper(activity);
		godsdkHelper.init(godsdkCallback);
	}

	@Override
	public void onResume(Activity activity) {
		godsdkHelper.onResume();
	}
	
	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
		godsdkHelper.onActivityResult(requestCode, resultCode, data);
	}

    @Override
    public void onPause(Activity activity) {
    	godsdkHelper.onPause();
    }

	@Override
	public void onDestroy(Activity activity) {
		godsdkHelper.onDestroy();
	}

	@Override
	public void onStart(Activity activity) {
		godsdkHelper.onStart();
	}

	@Override
	public void onStop(Activity activity) {
		godsdkHelper.onStop();
	}

	@Override
	public void onRestart(Activity activity) {
		godsdkHelper.onRestart();
	}
	
	private IGodsdkCallback godsdkCallback = new IGodsdkCallback() {
		
		@Override
		public void onPaymentSuccess(String pmode) {
			if(paymentParams == null) {
				paymentParams = new JSONObject();
			}
			
			try {
				paymentParams.put("result", Payment_Success);
			} catch (JSONException e) {
				BDebug.print("call back onPaymentSuccess error");
				e.printStackTrace();
			}
			String jsonResult = paymentParams.toString();
			GodsdkBridge.callLuaPaymentResult(jsonResult, true);
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
			GodsdkBridge.callLuaPaymentResult(jsonResult, true);
		}
	};
	
	public String getChannelId() {
		String channelId = godsdkHelper.getChannelId();
		BDebug.print("godsdk channel id:" + channelId);
		if(channelId == null || channelId == ""){
			Context ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				try {
					ApplicationInfo appInfo = ctx.getPackageManager().getApplicationInfo(ctx.getPackageName(), PackageManager.GET_META_DATA);
					channelId = appInfo.metaData.getString("BM_CHANNEL_ID");
					if(channelId != null) {
						channelId = channelId.trim();
					}
				} catch(Exception e) {
					Log.e("get metadata channel error", e.getMessage(), e);
				}
			}
		}
		BDebug.print(">>> channel id:" + channelId);
		return channelId;
	}

	/**
	 * 支付接口
	 * **/
	public void callPayment(String jsonParams) {
		try {
			paymentParams = new JSONObject(jsonParams);
			godsdkHelper.callPayment(jsonParams);
		} catch (JSONException e) {
			BDebug.print("payment error:" + jsonParams);
			e.printStackTrace();
		}
	}
}
