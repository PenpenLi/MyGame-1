package com.boyaa.adNormal;

import android.util.Log;

import com.boyaa.gaple.nativeEvent.LuaEventCall;

/**
 * Created by HrnryChen on 2016/5/24.
 */
public class AdNormalCallBack {
    private static final String TAG = AdNormalCallBack.class.getSimpleName();

    /**
     * 活动中心使用的回调
     *
     * @param param1
     * @param json
     */
    public void callLua(String param1, String json) {
        Log.d(TAG, json);
        LuaEventCall.luaCallEvent("activityCallBack", LuaEventCall.kResultSucess, LuaEventCall.kCallParamJsonString, json);
    }
}
