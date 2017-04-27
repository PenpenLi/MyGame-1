package com.boyaa.adNormal;

import android.content.Context;
import android.util.Log;

import com.boyaa.gaple.Game;
import com.boyaa.gaple.nativeEvent.LuaEventCall;
import com.boyaa_sdk.data.BoyaaAPI;

import org.json.JSONObject;

/**
 * Created by HrnryChen on 2016/5/24.
 */
public class AdNormalWrapper {
    private static final String TAG = AdNormalWrapper.class.getSimpleName();
    private Context context;

    // 这是测试的id,实际的配置在Domino的strings里面,在构造函数中会被重新赋值
    private static String _appid = "981742001430280263";
    private static String _appSec = "$2Y$10$B2XJP.34BEKYX/IXUTJ7T./YE";
    private static String _channel = "1";
    private static boolean _isShowAd = false;
    private static String _mid;

    //广告悬浮窗开关
    private static int _entranceOn = 0;
    //广告退出弹窗开关
    private static int _leaveOn = 0;
    //广告弹窗大小
    private static int _size = 2;

    public AdNormalWrapper(){

    }

    public static void init(String appid, String appSec) {
        _appid = appid;
        _appSec = appSec;
    }

    // ---------------------------------------------------------
    // 活动中心 activity
    // ---------------------------------------------------------

    /**
     * 活动中心初始化
     *
     * @param json
     */
    public static void initActiveByLua(final JSONObject json) {
        Log.d(TAG, "initActiveByLua");
        Game.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    //另外, isDebug是bug输出接口,默认不输出; 有需要查看可以打开
                    //还增加了限制强推次数的功能 , 次数限制由运营在运营平台上设置 SDK会根据获取的数据限制每一天的强推次数
                    BoyaaAPI boyaa_api = BoyaaAPI.getInstance(Game.getInstance());
                    BoyaaAPI.BoyaaData boyaa_data = boyaa_api.getBoyaaData(Game.getInstance());
                    boyaa_data.setMid(json.optString("mid"));
                    boyaa_data.setVersion(json.optString("version"));
                    boyaa_data.setApi(json.optString("api"));
                    boyaa_data.setAppid(json.optString("appid"));
                    boyaa_data.setSecret_key(json.optString("secretKey"));
                    boyaa_data.setUrl(json.optString("url"));
                    boyaa_data.setChanneID(json.optString("channeID"));
                    boyaa_data.setSitemid(json.optString("sitemid"));
                    boyaa_data.setUsertype(json.optString("usertype"));
                    boyaa_data.setDeviceno(json.optString("deviceno"));
                    boyaa_data.set_lua_class("com.boyaa.adNormal.AdNormalCallBack"); // 设定sdk调用lua的类名
                    boyaa_data.set_lua_method("callLua"); // 设定sdk调用lua 的方法名
                    boyaa_data.set_language(2);//0中文(默认),1是泰语,2是印尼语
                    boyaa_data.finish();
                    //强推弹窗 0,1,2分别代表小、中、大
                    Log.d(TAG, "related size = " + _size);
                    boyaa_api.related(_size);

                } catch (Exception e) {
                    Log.d(TAG, e.getMessage());
                    LuaEventCall.luaCallEvent("activityCallBack", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                }
            }
        });
    }

    /**
     * 打开活动中心
     */
    public static void openActiveByLua() {
        Game.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // 点击活动，准备跳入活动中心页面时，调用以下代码：
                BoyaaAPI boyaa_api = BoyaaAPI.getInstance(Game.getInstance());
                boyaa_api.display(); // 执行sdk，进入活动中心
            }
        });
    }

    /**
     * @param param
     *            切换正测试服
     */
    public static void cutService(final int param) {
        Game.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // 点击活动，准备跳入活动中心页面时，调用以下代码：
                BoyaaAPI boyaa_api = BoyaaAPI.getInstance(Game.getInstance());
                BoyaaAPI.BoyaaData boyaa_data = boyaa_api.getBoyaaData(Game.getInstance());
                boyaa_data.cut_service(param); //这里1代表测试服务器，0代表正式服务器，传其他的值没有用的哦
                boyaa_api.related(2);
            }
        });

    }
}
