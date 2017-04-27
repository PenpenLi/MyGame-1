package com.boyaa.admobile.util;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;
import com.boyaa.admobile.ad.appsflyer.AppsFlyManager;
import com.boyaa.admobile.ad.boya.BoyaaManager;
import com.boyaa.admobile.ad.facebook.FaceBookManager;
import com.boyaa.admobile.exception.CrashHandler;
import com.boyaa.admobile.service.ComitManager;

import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 供业务调用
 * 
 * @author Carrywen
 */
public class BoyaaADUtil {
	public static final String IS_REGISTER_PLAY = "is_register_play";
	public static final String TAG = "BoyaaADUtil";
    protected static ExecutorService executorService = Executors
            .newCachedThreadPool();
    public static final int METHOD_START = 1;
    public static final int METHOD_REG = 2;
    public static final int METHOD_LOGIN = 3;
    public static final int METHOD_PLAY = 4;
    public static final int METHOD_PAY = 5;
    public static final int METHOD_CUSTOM = 6;
    public static final int METHOD_RECALL = 7;
    public static final int METHOD_LOGOUT = 8;
    
    
    public static void push(final Context context,final HashMap<String, String> paraterMap,int type){
    	switch(type){
    	case METHOD_START:{
    		CrashHandler crashHandler = CrashHandler.getInstance();
    		crashHandler.init(context);
    		if (context instanceof Activity) {
    			((Activity) context).runOnUiThread(new Runnable() {

    				@Override
    				public void run() {
    					new AsyncTask<Void, Void, Void>() {
    						@Override
    						protected Void doInBackground(Void... params) {
    							// TODO Auto-generated method stub
    							return null;
    						}
    					};

    				}
    			});
    		}
    		executorService.execute(new Runnable() {
    			
    			@Override
    			public void run() {
    				try {
    					BDebug.d(TAG, "app start");
    					AppsFlyManager.getInstance(context).start(context,
    								paraterMap);
    					FaceBookManager.getInstance()
    								.start(context, paraterMap);
    				} catch (Exception e) {
    					BDebug.e(TAG, "BoyaaAd异常", e);
    				} finally {
/*    					// 先判断服务是否开启(避免重复创建开启服务)
    					if (!BUtility.isServiceLaunch(context,
    							Constant.NEED_SERVICE)) {
    						BoyaaManager.getInstance().startCommitService(context);
    					}*/
    				}
    			}
    		});
    	}
    		break;
    	case METHOD_REG:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				BDebug.d(TAG, "app register");
    				String udid = (String) paraterMap.get("udid");
    				if (TextUtils.isEmpty(udid)) {
    					udid = BUtility.getUniqueDeviceId(context);
    				}

    				if (TextUtils.isEmpty(udid)) {
    					return;
    				} else {
    					String regTime = ComitManager.getStringValue(context,
    							ComitManager.F_REGISTER);
    					if (TextUtils.isEmpty(regTime)) {
    						ComitManager.saveValue(context,
    								ComitManager.F_REGISTER,
    								BUtility.getDayTimeStamp(0));
    						ComitManager.saveValue(context, ComitManager.REG_PLAY,
    								"1111");
    						try {
    							AppsFlyManager.getInstance(context).register(
    										context, paraterMap);
    							FaceBookManager.getInstance().register(context,
    										paraterMap);
    						} catch (Exception e) {
    							BDebug.e(TAG, "BoyaaAd异常", e);
    						}
    					}

    				}
    			}
    		});
    		}
    		break;
    	case METHOD_LOGIN:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				try {
    					BDebug.d(TAG, "app login");
    					
    					AppsFlyManager.getInstance(context).login(context,
    								paraterMap);
    					FaceBookManager.getInstance()
    								.login(context, paraterMap);
    				} catch (Exception e) {
    					BDebug.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    	}
    		break;
    	case METHOD_PLAY:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				try {
    					BDebug.d(TAG, "app play");
    					String regPlay = ComitManager.getStringValue(context,
    							ComitManager.REG_PLAY);
    					if (regPlay.equals("0000")) {
    						BDebug.d("task", "reg and play true");
    					} else if (regPlay.equals("1111")) {
    						String regTime = ComitManager.getStringValue(context,
    								ComitManager.F_REGISTER);
    						boolean regFlag = BUtility
    								.isWithinDayRecord(regTime, 0);
    						if (regFlag) {
    							ComitManager.saveValue(context,
    									ComitManager.REG_PLAY, "0000");
    							AppsFlyManager.getInstance(context).play(
    										context, paraterMap);
    							FaceBookManager.getInstance().play(context,
    										paraterMap);
    						}
    					} else {

    					}

    				} catch (Exception e) {
    					BDebug.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    		}
    		break;
    	case METHOD_PAY:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				try {
    					BDebug.d(TAG, "app pay");
    					String unit = paraterMap.get("currencyCode");
    					String updateTime = ComitManager.getStringValue(context,
    							Constant.UNIT_UPDATE_TIME);
    					String rate = "";
    					if (TextUtils.isEmpty(updateTime)
    							|| "0".endsWith(updateTime)) {
    					} else {
    						boolean isUpdate = BUtility.isWithUnixTime(updateTime,
    								-15);
    					}
    					rate = Constant.rateMap.get(unit);
    					Constant.UNIT = unit;
    					Constant.UNIT_RATE = rate;
    					AppsFlyManager.getInstance(context).pay(context,
    								paraterMap);
    					FaceBookManager.getInstance()
    								.pay(context, paraterMap);
    				} catch (Exception e) {
    					BDebug.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    	}
    		break;
    	case METHOD_CUSTOM:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				try {
    					BDebug.d(TAG, "app customEvent");
    					AppsFlyManager.getInstance(context).customEvent(context,
    								paraterMap);
    					FaceBookManager.getInstance()
    								.customEvent(context, paraterMap);
    				} catch (Exception e) {
    					BDebug.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    	}
    		break;
    	case METHOD_RECALL:
    		
    		executorService.execute(new Runnable() {
    			
    			@Override
    			public void run() {
    				try {
    					BDebug.d(TAG, "app recall");
    					AppsFlyManager.getInstance(context).recall(context,
    								paraterMap);
    					FaceBookManager.getInstance()
    								.recall(context, paraterMap);
    				} catch (Exception e) {
    					BDebug.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    		
    		
    		break;
    	case METHOD_LOGOUT:

    		executorService.execute(new Runnable() {
    			
    			@Override
    			public void run() {
    				try {
    					BDebug.d(TAG, "app logout");
    					AppsFlyManager.getInstance(context).logout(context,
    								paraterMap);
    					FaceBookManager.getInstance()
    								.logout(context, paraterMap);
    				} catch (Exception e) {
    					BDebug.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    		break;
    	}
    }

}
