package com.boyaa.gaple.nativeEvent;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import com.boyaa.adNormal.AdNormalWrapper;
import com.boyaa.cocoslib.godsdk.GodsdkWrapper;
//import com.boyaa.cocoslib.iab.InAppBillingWrapper;
import com.boyaa.engine.made.AppActivity;
import com.boyaa.engine.made.Dict;
import com.boyaa.engine.made.Sys;
import com.boyaa.engine.patchupdate.ApkInstall;
import com.boyaa.engine.patchupdate.ApkMerge;
import com.boyaa.facebook.FacebookWrapper;
import com.boyaa.gaple.Game;
import com.boyaa.gaple.utils.downloader.HttpFileLoad;
import com.boyaa.gaple.utils.head.FeedbackPicture;
import com.boyaa.gaple.utils.head.SaveHeadImage;
import com.boyaa.gaple.utils.patch.ApkMergeUtil;
import com.boyaa.gaple.utils.system.SystemInfoUtil;
import com.boyaa.gaple.utils.system.VibrateFunction;
import com.boyaa.gaple.utils.uuid.GetUUID;
import com.boyaa.gaple.utils.zip.ZipUtil;
import com.boyaa.umeng.UmengWrapper;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;

import adStats.AdStatsWrapper;

import com.unity3d.ads.UnityAds;

import android.content.SharedPreferences;

/**
 * Created by HrnryChen on 2016/5/18.
 */

public class LuaEventCall {
    private static String TAG = LuaEventCall.class.getSimpleName();
    public final static String kLuacallEvent = "event_call"; // 原生语言调用lua 入口方法
    public final static String kcallEvent = "LuaEventCall"; // java调用lua,lua获得指令值的key

    // 结果返回 [-1、调用失败; -2、处理失败; -3、取消; >1、处理成功
    public final static String kCallResult = "CallResult";
    public final static int kResultCancle = -3;
    public final static int kResultFail = -2;
    public final static int kResultSucess = 1;

    // 参数类型 [0、无参数; 1、int; 2、double; 3、string; 4、jsonString; 5、boolean]，
    public final static String kCallParamType = "CallParamType";
    public final static int kCallParamNo = 0;
    public final static int kCallParamInt = 1;
    public final static int kCallParamDouble = 2;
    public final static int kCallParamString = 3;
    public final static int kCallParamJsonString = 4;


    //返回结果后缀 与call_native(key) 中key 连接(key.._result)组成返回结果key
    public final static String kResultPostfix = "_result";
    public final static String kParmPostfix = "_parm";

    public SaveHeadImage saveHeadImage = null;
    public FeedbackPicture feedbackPicture = null;

    public LuaEventCall(){

    }

    /**
     *获取int参数值
     */
    public int getIntParam(String key) {
        int param = Dict.getInt(key, key + kParmPostfix, -1);
        Log.d(TAG,key + " getIntParam " + param);
        return param;
    }

    /**
     *获取string参数值
     */
    public String getStringParam(String key) {
        String param = Dict.getString(key, key + kParmPostfix);
        Log.d(TAG,key + " getStringParam " + param);
        return param;
    }

    /**
     *获取double参数值
     */
    public int getDoubleParam(String key) {
        int param = Dict.getDouble(key, key + kParmPostfix, -1);
        Log.d(TAG,key + " getDoubleParam " + param);
        return param;
    }

    /**
     *获取table参数值
     */
    public JSONObject getJsonParam(String key) {
        String param = Dict.getString(key, key + kParmPostfix);
        Log.d(TAG,key + " getTableParam " + param);
        try {
            return new JSONObject(param);
        }catch (Exception e){
            Log.e(TAG, "getTableParam data was wrong");
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 向lua 传送数据
     *
     * @param key
     *            指令
     * @param result
     *            结果 一般为json 格式字符串
     */
    public static void luaCallEvent(final String key, final int result, final int resultType, final String resultStr) {
        Game.getInstance().runOnLuaThread(new Runnable() {
            @Override
            public void run() {
                Dict.setString(kcallEvent, kcallEvent, key);
                Dict.setInt(key, kCallResult, result);
                Dict.setInt(key, kCallParamType, resultType);
                if (null != resultStr) {

                    switch (resultType) {
                        case kCallParamNo:
                            break;
                        case kCallParamInt:
                            Dict.setInt(key, key + kResultPostfix, Integer.valueOf(resultStr));
                            break;
                        case kCallParamDouble:
                            Dict.setDouble(key, key + kResultPostfix, Double.valueOf(resultStr));
                            break;
                        case kCallParamString:
                            Dict.setString(key, key + kResultPostfix, resultStr);
                            break;
                        case kCallParamJsonString:
                            Dict.setString(key, key + kResultPostfix, resultStr);
                            break;
                        default:
                            Dict.setString(key, key + kResultPostfix, resultStr);
                    }
                }

                Sys.callLua(kLuacallEvent);
            }
        });
    }

    public void handlerCall(String func){
        Log.d(TAG, "handlerCall func " + func);
        //判断实现函数，执行函数<br/>
        if(func.equals("gamePickImage")) {
            gamePickImage();
        }else if(func.equals("mergeNewApk")) {
            mergeNewApk();
        }else if(func.equals("apkInstall")) {
            apkInstall();
        }else if(func.equals("unzip")) {
            unzip();
        }else if(func.equals("openBrowser")) {
            openBrowser();
        }else if(func.equals("readSystemInfo")) {
            readSystemInfo();
        }else if(func.equals("vibrate")) {
            vibrate();
        }else if(func.equals("readUUID")){
            readUUID();
        }else if(func.equals("httpFileDownload")){
            httpFileDownload();
        }else if(func.equals("facebookLogin")) {
            facebookLogin();
         }else if(func.equals("facebookDeleteRequestId")) {
            facebookDeleteRequestId();
        }else if(func.equals("facebookLogout")){
            facebookLogout();
        }else if(func.equals("facebookGetInvitableFriends")){
            facebookGetInvitableFriends();
        }else if(func.equals("facebookInvite")){
            facebookInvite();
        }else if(func.equals("facebookUpload")){
            facebookUpload();
        }else if(func.equals("facebookGetRequestId")) {
            facebookGetRequestId();
        }else if(func.equals("facebookShareFeed")){
            facebookShareFeed();
        }else if(func.equals("facebookOpenPage")){
            facebookOpenPage();
        }else if(func.equals("umengEventCount")) {
            umengEventCount();
        }else if(func.equals("umengEventCountValue")) {
            umengEventCountValue();
        }else if(func.equals("umengError")) {
            umengError();
        }else if(func.equals("adStatisticsStart")) {
            adStatisticsStart();
        }else if(func.equals("adStatisticsReg")) {
            adStatisticsReg();
        }else if(func.equals("adStatisticsLogin")) {
            adStatisticsLogin();
        }else if(func.equals("adStatisticsPlay")) {
            adStatisticsPlay();
        }else if(func.equals("adStatisticsPay")) {
            adStatisticsPay();
        }else if(func.equals("adStatisticsRecall")) {
            adStatisticsRecall();
        }else if(func.equals("adStatisticsLogout")) {
            adStatisticsLogout();
        }else if(func.equals("adStatisticsCustom")) {
            adStatisticsCustom();
        }else if(func.equals("activityInt")) {
            activityInt();
        }else if(func.equals("activityOpen")) {
            activityOpen();
        }else if(func.equals("activityCutServer")) {
            activityCutServer();
        }else if(func.equals("godsdkPay")){
            godsdkPay();
        }else if(func.equals("googlePay")) {
            googlePay();
        }else if(func.equals("googleToken")){
            googleToken();
        }else if(func.equals("shareApk")){
            shareApk();
        }else if(func.equals("closeLaunchScreen")){
            Game.getInstance().getGameHandler().sendEmptyMessage(Game.HANDLER_CLOSE_START_DIALOG);
        }else if(func.equals("gamePickPicture")){
            gamePickPicture();
        }else if(func.equals("deleteUpdate")){
            deleteUpdate();
        }else if (func.equals("unityAdsIsReady")){
            unityAdsIsReady();
        }
        else if (func.equals("unityAdsShow")){
            unityAdsShow();
        }
        else if(func.equals("facebookBinding")){
            facebookBinding();
        }
        else if(func.equals("getCampaignReferrer")){
            getCampaignReferrer();
        }
    }

    // unity ads
    public final static String placementId = "rewardedVideo";
    public void unityAdsShow()
    {
//        Message msg = new Message();
//        msg.what = Game.HANDLER_TOAST;
//        msg.obj = "isReady:" + UnityAds.isReady(placementId);
//        Game.getInstance().getGameHandler().sendMessage(msg);msg

        if (UnityAds.isReady(placementId))
        {
            UnityAds.show(Game.getInstance(), placementId);
        }
    }

    public void unityAdsIsReady() //1表示加载好，0表示没有加载好
    {
        int isReady = UnityAds.isReady(placementId) ? 1 : 0;

        String name = "unityAdsIsReady";
        Dict.setInt(name, name + kResultPostfix, isReady);
    }


    // 反馈的图片
    public void gamePickPicture(){
        Log.d(TAG,"gamePicPicture");
        String path = getStringParam("gamePickPicture");
        feedbackPicture = new FeedbackPicture(Game.getInstance());
        feedbackPicture.getPicture(path);

    }

    public void shareApk(){
        PackageManager packageManager =  Game.getInstance().getBaseContext().getPackageManager();
        try {
            ApplicationInfo applicationInfo = packageManager.getApplicationInfo(Game.getInstance().getBaseContext().getPackageName(), 0);
            File sourceFile = new File(applicationInfo.sourceDir);
            //調用android系統的分享窗口
            Intent intent = new Intent();
            intent.setAction(Intent.ACTION_SEND);
            intent.setType("*/*");
            intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(sourceFile));
            Game.getInstance().startActivity(intent);
        }catch (PackageManager.NameNotFoundException e){
            return;
        }

    }

//    -- game --
//    选择手机中图片
    public void gamePickImage(){
        Log.d(TAG, "gamePickImage");
        JSONObject data = getJsonParam("gamePickImage");
       // luaCallEvent("gamePickImageCallBack", kCallParamJsonString, data);
        saveHeadImage =  SaveHeadImage.getInstance();
        saveHeadImage.setActivity(Game.getInstance());
        saveHeadImage.doPickPhotoAction(data);

    }

//    合并apk包
    public void mergeNewApk(){
        ApkMergeUtil loader = new ApkMergeUtil();
        loader.Execute();
    }

//    安装apk
    public void apkInstall(){
        String data = getStringParam("apkInstall");
        ApkInstall loader = new ApkInstall();
        loader.startInstall(data);
    }

    public void deleteUpdate(){
        JSONObject data = getJsonParam("deleteUpdate");
        try {
            String patch = data.getString("patch");
            String apk = data.getString("apk");
            String update = data.getString("update");

            File filePatch = new File(patch);
            Log.d("DELETE","filePatch = " + filePatch);
            if (filePatch.exists()){
                Log.d("DELETE","filePatch.exists() = " + filePatch.exists());
                filePatch.delete();
            }

            File fileApk = new File(apk);
            Log.d("DELETE","filePatch = " + filePatch);
            if (fileApk.exists()){
                Log.d("DELETE","filePatch.exists() = " + filePatch.exists());
                fileApk.delete();
            }

            File fileUpdate = new File(update);
            Log.d("DELETE","filePatch = " + filePatch);
            if (fileUpdate.exists()){
                Log.d("DELETE","filePatch.exists() = " + filePatch.exists());
                fileUpdate.delete();
            }

            String path = AppActivity.getInstance().getApplication().getFilesDir().getAbsolutePath() + "/update";
            File test = new File(path);
            Log.d("DELETE","update.exists = " + test.exists());
            if (test.exists()){
//                test.delete();
                boolean isWrite = test.canWrite();
                if (isWrite){
                   File[] files = test.listFiles();
                    for (int i = 0; i<files.length; i++){
                        files[i].delete();
                    }
                }
            }
            String haha = "";
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

//    解压zip
    public void unzip(){
        JSONObject data = getJsonParam("unzip");
        try {
            ZipUtil.UnZipFolder(data.getString("zipPath"), data.getString("outPath"));
        }catch(Exception e){
            Log.e(TAG, e.getMessage());
        }
    }

//    Lua 调用 Http 下载
    public void httpFileDownload(){
        HttpFileLoad loader = new HttpFileLoad();
        loader.Execute();
    }

//    打开浏览器
    public void openBrowser(){
        String url = getStringParam("openBrowser");
        if (url == null || "".equals(url)) {
            Log.i(TAG,"openBrowser not url");
            return;
        }
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse(url));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        Game.getInstance().startActivity(intent);
    }

//    获取系统信息
    public void readSystemInfo(){
        String mac = SystemInfoUtil.getSystemInfo();
        Dict.setString("readSystemInfo", "readSystemInfo" + kResultPostfix, mac);
    }

    public void vibrate(){
        int time = getIntParam("vibrate");
        VibrateFunction.apply(time);
    }

    public void readUUID(){
        String uuid = GetUUID.getUUID();
        Dict.setString("readUUID", "readUUID" + kResultPostfix, uuid);
    }
//    -- game end --


//    -- facebook --
    public void facebookLogin(){
        Log.d(TAG, "facebookLogin");
        FacebookWrapper.getInstance().login();
    }

    public void facebookBinding(){
        FacebookWrapper.getInstance().binding();
    }

    public void facebookDeleteRequestId(){
        Log.d(TAG, "facebookDeleteRequestId");
        String id = getStringParam("facebookDeleteRequestId");
        FacebookWrapper.getInstance().deleteRequestId(id);
    }

    public void facebookLogout(){
        Log.d(TAG, "facebookLogout");
        FacebookWrapper.getInstance().logout();
    }

    public void facebookGetInvitableFriends(){
        int limit = getIntParam("facebookGetInvitableFriends");
        FacebookWrapper.getInstance().getInvitableFriends(limit);
    }

    public void facebookInvite(){
        JSONObject data = getJsonParam("facebookInvite");
        FacebookWrapper.getInstance().invite(data);
    }

    public void facebookUpload(){
        JSONObject data = getJsonParam("facebookUpload");
        FacebookWrapper.getInstance().uploadPhoto(data);
    }

    public void facebookShareFeed(){
        JSONObject data = getJsonParam("facebookShareFeed");
        FacebookWrapper.getInstance().shareLink(data);
    }

    public void facebookGetRequestId(){
        FacebookWrapper.getInstance().getRequestId();
    }

    public void facebookOpenPage(){
        String facebookUserId = getStringParam("facebookOpenPage");
        FacebookWrapper.getInstance().openFacebookPage(facebookUserId);
    }

//    -- facebook end--

//    -- umeng --
    public void umengEventCount(){
        String data = getStringParam("umengEventCount");
        UmengWrapper.onEventCount(data);
    }

    public void umengEventCountValue(){
        JSONObject data = getJsonParam("umengEventCountValue");
        UmengWrapper.onEventCountValue(data);
    }

    public void umengError(){
        String data = getStringParam("umengError");
        UmengWrapper.reportError(data);
    }
//    -- umeng end

//    -- adStatistics --
    public void adStatisticsStart(){
        AdStatsWrapper.reportStart();
    }

    public void adStatisticsReg(){
        AdStatsWrapper.reportReg();
    }

    public void adStatisticsLogin(){
        AdStatsWrapper.reportLogin();
    }

    public void adStatisticsPlay(){
        AdStatsWrapper.reportPlay();
    }

    public void adStatisticsPay(){
        JSONObject data = getJsonParam("facebookInvite");
        AdStatsWrapper.reportPay(data);
    }

    public void adStatisticsRecall(){
        String data = getStringParam("adStatisticsRecall");
        AdStatsWrapper.reportRecall(data);
    }

    public void adStatisticsLogout(){
        AdStatsWrapper.reportLogout();
    }

    public void adStatisticsCustom(){
        String data = getStringParam("adStatisticsCustom");
        AdStatsWrapper.reportCustom(data);
    }
//    -- adStatistics end --

//    -- adNormal ad for change --
    public void adNormalInit(){
        JSONObject data = getJsonParam("adNormalInit");
//        AdNormalWrapper.initByLua(data);
    }

    public void adNormalLoadData(){
//        AdNormalWrapper.loadData();
    }
//    -- adNormal ad for change end --

//    -- adNormal activity --
    public void activityInt(){
        JSONObject data = getJsonParam("activityInt");
        AdNormalWrapper.initActiveByLua(data);
    }

    public void activityOpen(){
        AdNormalWrapper.openActiveByLua();
    }

    public void activityCutServer(){
        int data = getIntParam("activityCutServer");
        AdNormalWrapper.cutService(data);
    }
//    -- adNormal activity end --

//    -- godsdk --
    public void godsdkPay(){
        String data = getStringParam("godsdkPay");
        GodsdkWrapper.callPayment(data);
    }
//    -- godsdk end --

//    -- google --
    public void googlePay(){
        JSONObject data = getJsonParam("googlePay");
//        InAppBillingWrapper.makePurchase(data);
    }

    public void googleToken(){
        String token = Game.getInstance().googleToken;
        if(token!=null) {
            LuaEventCall.luaCallEvent("googleTokenCallBack", LuaEventCall.kResultSucess, LuaEventCall.kCallParamString, token);
        }
    }
//    -- google end --

    public void getCampaignReferrer(){
        SharedPreferences sharedPreferences = Game.getInstance().getSharedPreferences("gaple-qiuqiu-campaign", 0);
        String strReferrer = sharedPreferences.getString("referrer", "");
        // String strReferrer = "getCampaignReferrer";
        Dict.setString("getCampaignReferrer", "getCampaignReferrer" + kResultPostfix, strReferrer);
    }
}
