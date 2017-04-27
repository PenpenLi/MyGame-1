package com.boyaa.umeng;

import android.content.Context;
import android.util.Log;

import com.boyaa.gaple.Game;
import com.umeng.analytics.AnalyticsConfig;
import com.umeng.analytics.MobclickAgent;

import org.json.JSONObject;

import java.util.Map;

/**
 * Created by HrnryChen on 2016/5/23.
 */
public class UmengWrapper {

    private static final String TAG = UmengWrapper.class.getSimpleName();

    public static void init(String appkey,String channelId)
    {
        Log.d(TAG, "init appkey=" + appkey + "  channelId=" +channelId);

        Context ctx = Game.getInstance();
        if (ctx != null )
        {
            Log.d(TAG, "start init");
            AnalyticsConfig.setAppkey(ctx,appkey);
            AnalyticsConfig.setChannel(channelId);

            MobclickAgent.setSessionContinueMillis(1000 * 60);     //启动次数计算的间隔，详情见友盟官方文档
        }
    }
    public static void registOnResume()
    {
        Log.d(TAG, "onResume");
        MobclickAgent.onResume(Game.getInstance());
    }
    public static void registOnPause()
    {
        Log.d(TAG, "onPause");
        MobclickAgent.onPause(Game.getInstance());
    }

    //计数事件统计
    public static void onEventCount(String eventId)
    {
        Log.d(TAG, "onEventCount:"+ eventId);
        MobclickAgent.onEvent(Game.getInstance(), eventId);
    }

    //计算事件统计
    public static void onEventCountValue(JSONObject jsonObject)
    {
        try {
            String eventId = jsonObject.getString("eventId");
            String value = jsonObject.getString("value");
            Log.d(TAG, "onEventCountValue:" + eventId + " value=" + value);

            MobclickAgent.onEventValue(Game.getInstance(), eventId, null, Integer.parseInt(value));
        }catch(Exception e){
            Log.e(TAG,"data error");
        }
    }

    //自定义错误上报
    public static void reportError(String errorStr)
    {
        Log.d(TAG, "reportError=" +errorStr);
        MobclickAgent.reportError(Game.getInstance(), errorStr);
    }

}
