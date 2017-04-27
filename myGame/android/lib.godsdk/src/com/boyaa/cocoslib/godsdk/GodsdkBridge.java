package com.boyaa.cocoslib.godsdk;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.boyaa.cocoslib.core.Cocos2dxActivityUtil;
import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.godsdk.util.BDebug;

public class GodsdkBridge {
	
	private static int peymentResultCallback = -1;
	
	private static GodsdkPlugin getGodsdkPlugin() {
		if(Cocos2dxActivityWrapper.getContext() != null) {
			List<IPlugin> list = Cocos2dxActivityWrapper.getContext().getPluginManager().findPluginByClass(GodsdkPlugin.class);
			if(list != null && list.size() > 0) {
				return (GodsdkPlugin) list.get(0);
			}else {
				BDebug.print("FacebookLoginPlugin not found");
			}
		}
		return null;
	}
	
	//for lua
	public static void setPaymentCallback(final int callback) {
		BDebug.print("setPaymentCallback:" + callback);
		if(GodsdkBridge.peymentResultCallback != -1) {
			BDebug.print("release lua function " + GodsdkBridge.peymentResultCallback);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(GodsdkBridge.peymentResultCallback);
			GodsdkBridge.peymentResultCallback = -1;
		}
		GodsdkBridge.peymentResultCallback = callback;
	}
	
	public static String getChannelId(){
		GodsdkPlugin plugin = getGodsdkPlugin();
		return plugin.getChannelId();
	}
	
	public static void makePurchase(final String jsonParams) {
		final GodsdkPlugin plugin = getGodsdkPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					plugin.callPayment(jsonParams);
				}
			}, 50);
		}
	}
	
	static void callLuaPaymentResult(final String result, boolean delay) {
		BDebug.print("callLuaPaymentResult " + result);
		if(delay) {
			Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				Cocos2dxActivityUtil.runOnResumed(new Runnable() {
					@Override
					public void run() {
						Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
							@Override
							public void run() {
								BDebug.print("call lua function peymentResultCallback " + GodsdkBridge.peymentResultCallback + " " + result);
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(GodsdkBridge.peymentResultCallback, result);
							}
						}, 50);
					}
				});
			}
		} else {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							BDebug.print("call lua function peymentResultCallback " + GodsdkBridge.peymentResultCallback + " " + result);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(GodsdkBridge.peymentResultCallback, result);
						}
					});
				}
			});
		}
	}
}
