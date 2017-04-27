package com.boyaa.godsdk.sdk;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Process;

import com.boyaa.godsdk.callback.CallbackStatus;
import com.boyaa.godsdk.callback.IAPListener;
import com.boyaa.godsdk.callback.SDKListener;
import com.boyaa.godsdk.core.ActivityAgent;
import com.boyaa.godsdk.core.GodSDK;
import com.boyaa.godsdk.core.GodSDKIAP;
import com.boyaa.godsdk.core.GodSDK.IGodSDKIterator;
import com.boyaa.godsdk.util.BDebug;

public class GodSDKHelper {
	
	private Activity mActivity;
	private IGodsdkCallback godsdkCallback;
	
	//判断SDK是否需要在退出的时候调用第三方SDK的退出
	private boolean mIsQuitRequired = false;
	//是否需要显示悬浮窗
	private boolean mIsFloatViewRequired = false;
	//是否应该Destory
	private boolean mShouldDestoryAndKillProcess = false;
	
	private SDKListener mSDKListner = new SDKListener() {

		@Override
		public void onQuitSuccess(CallbackStatus status) {
			//退出成功
			BDebug.print("onQuitSuccess:" + status);
			mShouldDestoryAndKillProcess = true;
		}

		@Override
		public void onQuitCancel(CallbackStatus status) {
			//取消退出
			BDebug.print("onQuitCancel:" + status);
		}

		@Override
		public void onInitSuccess(CallbackStatus status) {
			//初始化成功
			BDebug.print("onInitSuccess:" + status);

		}

		@Override
		public void onInitFailed(CallbackStatus status) {
			//初始化失败
			BDebug.print("onInitFailed:" + status);
		}
	};
	
	private IAPListener mIAPListener = new IAPListener() {

		@Override
		public void onPaySuccess(CallbackStatus status, String pmode) {
			GodSDK.getInstance().getDebugger().i("godpay 支付成功 pmode = " + pmode + status);
			BDebug.print("支付成功 pmode = " + pmode + "status:" + status);
			Map<String, String> map = status.getExtras();
			godsdkCallback.onPaymentSuccess(map, pmode);
		}

		@Override
		public void onPayFailed(CallbackStatus status, String pmode) {
			BDebug.print("支付失败 pmode = " + pmode + "status:" + status);
			godsdkCallback.onPaymentFailed(pmode);
		}
	};
	
	public GodSDKHelper(Activity activity){
		mActivity = activity;
	}
	
	public void init(IGodsdkCallback callback){
		
		godsdkCallback = callback;
		
		// 设置各种功能的回调
		GodSDK.getInstance().setSDKListener(mSDKListner);
		GodSDKIAP.getInstance().setIAPListener(mIAPListener);

		// 设置调试日志开关
		boolean isDebugMode = true;
		GodSDK.getInstance().setDebugMode(isDebugMode);
		GodSDKIAP.getInstance().setDebugMode(isDebugMode);
		
		// 初始化GodSDK，并把GodSDK内部可用的startActivityForResult的请求码范围设定好。
		boolean b = GodSDK.getInstance().initSDK(mActivity, new IGodSDKIterator<Integer>() {
			private int i = 200000;
			private final int end = 200100;
			
			@Override
			public Integer next() {
				i = i + 1;
				return i;
			}
			
			@Override
			public boolean hasNext() {
				if (i < end) {
					return true;
				} else {
					return false;
				}
			}
		});
		mIsQuitRequired = GodSDK.getInstance().isQuitRequired();
		BDebug.print("godsdk init:"+b);
	}
	
	public void onBackPressed() {
		if (mIsQuitRequired) {
			GodSDK.getInstance().quit(mActivity);
		}
	}
	
	public void onNewIntent(Intent intent) {
		ActivityAgent.onNewIntent(mActivity, intent);
	}
	
	public void onStart() {
		ActivityAgent.onStart(mActivity);
	}
	
	public void onRestart() {
		ActivityAgent.onRestart(mActivity);
	}
	
	public void onPause() {
		ActivityAgent.onPause(mActivity);
	}
	
	public void onResume() {
		// TODO Auto-generated method stub
		ActivityAgent.onResume(mActivity);
	}
	
	public void onStop() {
		ActivityAgent.onStop(mActivity);
	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		ActivityAgent.onActivityResult(mActivity, requestCode, resultCode, data);
	}
	
	public void onDestroy() {
		ActivityAgent.onDestroy(mActivity);
		if (mShouldDestoryAndKillProcess) {
			GodSDK.getInstance().release(mActivity);
			Process.killProcess(Process.myPid());
		}
	}
	
	public String getChannelId(){
		return GodSDK.getChannelSymbol(mActivity);
	}
	
	/**
	 * 支付接口
	 * */
	public void callPayment(final String params) {
		BDebug.print("pay params:"+params);
		GodSDKIAP.getInstance().requestPay(mActivity, params);
	}
}
