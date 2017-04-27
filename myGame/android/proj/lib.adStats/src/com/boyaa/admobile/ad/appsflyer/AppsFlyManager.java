package com.boyaa.admobile.ad.appsflyer;

import android.content.Context;
import com.appsflyer.AppsFlyerLib;
import com.boyaa.admobile.ad.AdManager;
import com.boyaa.admobile.util.BDebug;
import com.boyaa.admobile.util.BUtility;
import com.boyaa.admobile.util.Constant;

import java.util.HashMap;

/**
 * @author Carrywen
 */
public class AppsFlyManager implements AdManager {
    public static final String AF_TAG = "AppsFlyManager";
    public static AppsFlyManager mAppsFlyManager;
    private static byte[] sync = new byte[1];


    private AppsFlyManager(Context context) {
        AppsFlyerLib.sendTracking(context);
        AppsFlyerLib.setCurrencyCode(Constant.CURRENCY_CODE_DEFAULT);
    }


    public static AppsFlyManager getInstance(Context context) {
        if (mAppsFlyManager == null) {
            mAppsFlyManager = new AppsFlyManager(context);
        }
        return mAppsFlyManager;
    }


    /**
     * start
     *
     * @param context
     * @param paraterMap
     */
    public void start(Context context, HashMap paraterMap) {
        try {     
        	BDebug.e(AF_TAG,"Start<------>方法调用启动中");
            AppsFlyerLib.setAppsFlyerKey(Constant.AF_KEY);
            AppsFlyerLib.setAppUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.sendTrackingWithEvent(context, Constant.AF_EVENT_START, "");
        } catch (Exception e) {
            BDebug.e(AF_TAG, "AF异常", e);
        }

    }


    /**
     * register
     *
     * @param context
     * @param paraterMap
     */
    public void register(Context context, HashMap paraterMap) {
        try {
        	BDebug.e(AF_TAG,"注册<------>方法调用启动中");
        	AppsFlyerLib.setAppsFlyerKey(Constant.AF_KEY);
            AppsFlyerLib.setAppUserId((String) paraterMap.get(Constant.APP_USER_ID));

            AppsFlyerLib.sendTrackingWithEvent(context, Constant.AF_EVENT_REGISTER, "");
        } catch (Exception e) {
            BDebug.e(AF_TAG, "AF异常", e);
        }


    }


    /**
     * login
     *
     * @param context
     * @param paraterMap
     */
    public void login(Context context, HashMap paraterMap) {
        try {
        	
        	BDebug.e(AF_TAG,"Login<------>方法调用启动中");
        	AppsFlyerLib.setAppsFlyerKey(Constant.AF_KEY);
            AppsFlyerLib.setAppUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.sendTrackingWithEvent(context, Constant.AF_EVENT_LOGIN, "");
        } catch (Exception e) {
            BDebug.e(AF_TAG, "AF异常", e);
        }


    }


    /**
     * play
     *
     * @param context
     * @param paraterMap
     */
    public void play(Context context, HashMap paraterMap) {
        try {
        	BDebug.e(AF_TAG,"PLAY<-------------->方法调用启动中");
        	AppsFlyerLib.setAppsFlyerKey(Constant.AF_KEY);
            AppsFlyerLib.setAppUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.sendTrackingWithEvent(context, Constant.AF_EVENT_PLAY, "");
        } catch (Exception e) {
            BDebug.e(AF_TAG, "AF异常", e);
        }

    }


    /**
     * pay
     *
     * @param context
     * @param paraterMap
     */
    public void pay(Context context, HashMap paraterMap) {
        try {
        	BDebug.e(AF_TAG,"支付<-------------------->方法调用启动中");
        	AppsFlyerLib.setAppsFlyerKey(Constant.AF_KEY);
            AppsFlyerLib.setAppUserId((String) paraterMap.get(Constant.APP_USER_ID));

            AppsFlyerLib.setCurrencyCode(Constant.CURRENCY_CODE_DEFAULT);
            String amount = (String) paraterMap.get("pay_money");
            double amt = 0;
            double rate = 0;
            try {
                amount = BUtility.getNumericStr(amount);
                amt = Double.parseDouble(amount);
                rate = Double.parseDouble(Constant.UNIT_RATE);
            } catch (Exception e) {
                BDebug.e(AF_TAG, "AF异常", e);
            }
            BDebug.d(AF_TAG, "currencyCode = " + Constant.UNIT + "rate=" + rate + ", amt=" + amt);
            AppsFlyerLib.sendTrackingWithEvent(context, Constant.AF_EVENT_PAY, amt * rate + "");
        } catch (Exception e) {
            BDebug.e(AF_TAG, "AF异常", e);
        }

    }

    @Override
    public void logout(Context context, HashMap paraterMap) {
        try {
        	BDebug.e(AF_TAG,"退出<------>方法调用启动中");
        	AppsFlyerLib.setAppsFlyerKey(Constant.AF_KEY);
            AppsFlyerLib.setAppUserId((String) paraterMap.get(Constant.APP_USER_ID));
            String gameTime = (String) paraterMap.get("gameTime");
            AppsFlyerLib.sendTrackingWithEvent(context, Constant.AF_EVENT_LOGOUT, gameTime);
        } catch (Exception e) {
            BDebug.e(AF_TAG, "AF异常", e);
        }
    }


    /* (non-Javadoc)
     * @see com.boyaa.admobile.ad.AdManager#customEvent(android.content.Context, java.util.HashMap)
     */
    public void customEvent(Context context, HashMap paraterMap) {
        try {
        	BDebug.e(AF_TAG,"自定义方法出<------>方法调用启动中");
        	AppsFlyerLib.setAppsFlyerKey(Constant.AF_KEY);
            AppsFlyerLib.setAppUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.sendTrackingWithEvent(context, (String) paraterMap.get(Constant.AF_EVENT_CUSTOM), "");
        } catch (Exception e) {
            BDebug.e(AF_TAG, "AF异常", e);
        }

    }


	/* (non-Javadoc)
	 * @see com.boyaa.admobile.ad.AdManager#recall(android.content.Context, java.util.HashMap)
	 */
	@Override
	public void recall(Context context, HashMap paraterMap) {
		// TODO Auto-generated method stub
		 try {
	        	BDebug.e(AF_TAG,"自定义方法激活<------>方法调用启动中"+Constant.AF_KEY);
			 	AppsFlyerLib.setAppsFlyerKey(Constant.AF_KEY);
	            AppsFlyerLib.setAppUserId((String) paraterMap.get(Constant.APP_USER_ID));
	            String s = (String) paraterMap.get(Constant.RECALL_EXTRA);
	            AppsFlyerLib.sendTrackingWithEvent(context, Constant.AF_EVENT_RECALL, s);
	        } catch (Exception e) {
	            BDebug.e(AF_TAG, "AF异常", e);
	        }
	}

}
