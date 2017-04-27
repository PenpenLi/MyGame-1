package adStats;

import android.content.Context;
import android.util.Log;

import com.boyaa.admobile.util.BoyaaADUtil;
import com.boyaa.admobile.util.Constant;

import org.json.JSONObject;

import java.util.HashMap;

/**
 * 博雅广告SDK（facebook）
 * Created by HrnryChen on 2016/5/24.
 */
public class AdStatsWrapper {

    private static final String TAG = AdStatsWrapper.class.getSimpleName();
    private static String pluginId;
    private static String fbAppId;
    private static Context context;

    public static void setFbAppId(Context ctx, String id) {
        Log.d(TAG, "AdSdkPlugin set fbAppId ");
        context = ctx;
        fbAppId = id;
    }

    private static boolean isFbAppIdNull() {
        if (fbAppId == null || "".equals(fbAppId))
            return true;
        else
            return false;
    }

    public static void reportStart() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push start ");
        BoyaaADUtil.push(context, paraterMap,
                BoyaaADUtil.METHOD_START);
    }

    public static void reportReg() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push reg ");
        BoyaaADUtil.push(context, paraterMap,
                BoyaaADUtil.METHOD_REG);
    }

    public static void reportLogin() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push login ");
        BoyaaADUtil.push(context, paraterMap,
                BoyaaADUtil.METHOD_LOGIN);
    }

    public static void reportPlay() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push play ");
        BoyaaADUtil.push(context, paraterMap,
                BoyaaADUtil.METHOD_PLAY);
    }

    public static void reportPay(JSONObject data) {
        if (isFbAppIdNull())
            return;
        try {
            HashMap<String, String> paraterMap = new HashMap<String, String>();
            paraterMap.put("fb_appId", fbAppId);
            paraterMap.put("pay_money", data.getString("payMoney"));
            paraterMap.put("currencyCode", data.getString("currencyCode"));
            Log.d(TAG, "AdSdkPlugin push pay " + data.getString("payMoney") + data.getString("currencyCode"));
            BoyaaADUtil.push(context, paraterMap,
                    BoyaaADUtil.METHOD_PAY);
        }catch (Exception e){
            Log.e(TAG, e.getMessage());
        }
    }

    public static void reportRecall(String fbid) {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        paraterMap.put(Constant.RECALL_EXTRA, fbid);
        Log.d(TAG, "AdSdkPlugin push recall ");
        BoyaaADUtil.push(context, paraterMap,
                BoyaaADUtil.METHOD_RECALL);
    }

    public static void reportLogout() {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        Log.d(TAG, "AdSdkPlugin push logout ");
        BoyaaADUtil.push(context, paraterMap,
                BoyaaADUtil.METHOD_LOGOUT);
    }

    public static void reportCustom(String e_custom) {
        if (isFbAppIdNull())
            return;
        HashMap<String, String> paraterMap = new HashMap<String, String>();
        paraterMap.put("fb_appId", fbAppId);
        paraterMap.put("e_custom", e_custom);
        Log.d(TAG, "AdSdkPlugin push custom ");
        BoyaaADUtil.push(context, paraterMap,
                BoyaaADUtil.METHOD_CUSTOM);
    }
}
