package com.boyaa.admobile.ad.facebook;

import java.math.BigDecimal;
import java.util.Currency;
import java.util.HashMap;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.boyaa.admobile.ad.AdManager;
import com.boyaa.admobile.util.BDebug;
import com.boyaa.admobile.util.BUtility;
import com.boyaa.admobile.util.Constant;
import com.facebook.appevents.AppEventsConstants;
import com.facebook.appevents.AppEventsLogger;

/**
 * @author Carrywen
 */
public class FaceBookManager implements AdManager {
    public static final String APP_ID = "fb_appId";
    public static final String TAG = "FB";
    public static FaceBookManager mFaceBookManager;
    public AppEventsLogger logger;
    private static byte[] sync = new byte[1];


    private FaceBookManager() {
    }


    public static FaceBookManager getInstance() {
        if (mFaceBookManager == null) {
            mFaceBookManager = new FaceBookManager();
        }
        return mFaceBookManager;
    }

    /**
     * start
     *
     * @param context
     * @param paraterMap
     */
    public void start(Context context, HashMap paraterMap) {
        try {
            String fb_appId = (String) paraterMap.get(APP_ID);
          //增加上报start事件
            logger = AppEventsLogger.newLogger(context,fb_appId);
            logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_START);
            logger.activateApp(context);
        } catch (Exception e) {
            BDebug.e(TAG, "FB异常", e);
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
            String fb_appId = (String) paraterMap.get(APP_ID);
            logger = AppEventsLogger.newLogger(context, fb_appId);
            logger.logEvent(AppEventsConstants.EVENT_NAME_COMPLETED_REGISTRATION);
        } catch (Exception e) {
            BDebug.e(TAG, "FB异常", e);
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
            String fb_appId = (String) paraterMap.get(APP_ID);
            logger = AppEventsLogger.newLogger(context, fb_appId);
            logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_LOGIN);
        } catch (Exception e) {
            BDebug.e(TAG, "FB异常", e);
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
            String fb_appId = (String) paraterMap.get(APP_ID);
            logger = AppEventsLogger.newLogger(context, fb_appId);
            logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_PLAY);
        } catch (Exception e) {
            BDebug.e(TAG, "FB异常", e);
        }

    }


    /**
     * ֧pay
     *
     * @param context
     * @param paraterMap
     */
    public void pay(Context context, HashMap paraterMap) {
        try {
            String fb_appId = (String) paraterMap.get(APP_ID);
            String amount = (String) paraterMap.get("pay_money");
            double amt = 0;
            double rate = 0;
            try {
                amount = BUtility.getNumericStr(amount);
                amt = Double.parseDouble(amount);
                rate = Double.parseDouble(Constant.UNIT_RATE);
            } catch (Exception e) {
                BDebug.e(TAG, "FB异常", e);
            }
            logger = AppEventsLogger.newLogger(context, fb_appId);
            logger.logPurchase(BigDecimal.valueOf(amt * rate), Currency.getInstance("USD"));
        } catch (Exception e) {
            BDebug.e(TAG, "FB异常", e);
        }

    }

    @Override
    public void logout(Context context, HashMap paraterMap) {
        try {
            String fb_appId = (String) paraterMap.get(APP_ID);
            logger = AppEventsLogger.newLogger(context, fb_appId);
//            logger = AppEventsLogger.newL
            Bundle bundle = new Bundle();
            bundle.putString("gameTime", (String) paraterMap.get("gameTime"));
            logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_LOGOUT, bundle);
        } catch (Exception e) {
            BDebug.e(TAG, "FB异常", e);

        }
    }


    @Override
    public void customEvent(Context context, HashMap paraterMap) {
        try {
            String fb_appId = (String) paraterMap.get(APP_ID);
            String eventName = (String) paraterMap.get(Constant.AF_EVENT_CUSTOM);
            logger = AppEventsLogger.newLogger(context, fb_appId);
            logger.logEvent(Constant.FB_PRE+eventName);
        } catch (Exception e) {
            BDebug.e(TAG, "FB异常", e);
        }

    }


	/* (non-Javadoc)
	 * @see com.boyaa.admobile.ad.AdManager#remind(android.content.Context, java.util.HashMap)
	 */
	@Override
	public void recall(Context context, HashMap paraterMap) {
		// TODO Auto-generated method stub
		 try {
	            String fb_appId = (String) paraterMap.get(APP_ID);
	            String eventName = (String) paraterMap.get(Constant.AF_EVENT_RECALL);
	            Log.d("FaceBookManager","eventName is "+eventName+fb_appId);
	            logger = AppEventsLogger.newLogger(context, fb_appId);
	            logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_RECALL);
	        } catch (Exception e) {
	            BDebug.e(TAG, "FB异常", e);
	        }
	}

}
