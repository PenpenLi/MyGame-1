package com.boyaa.gaple;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;
import android.app.Activity;

import com.boyaa.adNormal.AdNormalWrapper;
import com.boyaa.cocoslib.godsdk.GodsdkWrapper;
import com.boyaa.cocoslib.godsdk.GodsdkWrapperCallback;
import com.boyaa.engine.common.ExternalStorage;
import com.boyaa.engine.common.UploadDumpFile;
import com.boyaa.engine.made.AppActivity;
import com.boyaa.engine.made.Dict;
import com.boyaa.engine.made.Sys;
import com.boyaa.facebook.FacebookWrapper;
import com.boyaa.gaple.nativeEvent.LuaEventCall;
import com.boyaa.gaple.utils.downloader.HttpFileLoad;
import com.boyaa.gaple.utils.head.FeedbackPicture;
import com.boyaa.gaple.utils.head.SDTools;
import com.boyaa.gaple.utils.head.SaveHeadImage;
import com.boyaa.gaple.utils.logHelper.LoggerUtil;
import com.boyaa.godsdk.core.ActivityAgent;
import com.boyaa.google.MyFirebaseMessagingUtils;
import com.boyaa.umeng.UmengWrapper;
import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;

import java.io.File;

import adStats.AdStatsWrapper;

import android.view.SurfaceView;

import com.unity3d.ads.IUnityAdsListener;
import com.unity3d.ads.UnityAds;

import com.boyaa.xiaojian.R;


/**
 * 1.AppActivity 子类
 * 2.二次开发人员操作Activity类
 */
public class Game extends AppActivity {

    private AppStartDialog mStartDialog;//APP启动画面Dialog对象
    private boolean mIsLuaInitDone = false;
    public final static int HANDLER_CLOSE_START_DIALOG = 1;
    public final static int HANDLER_HTTP_DOWNLOAD_TIMEOUT = 5;
    public final static int HANDLER_TOAST = 6;

    private static Game mThis;
    private GameHandler mGameHandle;

    protected FacebookWrapper facebookWrapper;
    // GCM start
    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;
    private BroadcastReceiver mRegistrationBroadcastReceiver;
    private BroadcastReceiver mDownstreamBroadcastReceiver;
    private boolean isReceiverRegistered;
    public String googleToken;
    // GCM end



    //触发Runtime重新启动, by huang yi(引擎部)
    public static void triggerRebirth(Context context) {
        Intent intent = new Intent(context, Game.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        if (context instanceof Activity) {
            ((Activity) context).finish();
        }
        Runtime.getRuntime().exit(0);
    }

    private LuaEventCall luaCall;
    /**
     * 当Activity程序启动之后会首先调用此方法。<br/>
     * 在这个方法体里，你需要完成所有的基础配置<br/>
     * 这个方法会传递一个保存了此Activity上一状态信息的Bundle对象
     *
     * @param savedInstanceState 保存此Activity上一次状态信息的Bundle对象
     */
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if(mThis != null){
            triggerRebirth(this);
            return;
        }
        mThis = this;
        clearUpdate();
        if (null == savedInstanceState) { //开启APP启动画面
            mStartDialog = new AppStartDialog(this);
        } else {
            mStartDialog = null;
        }
        mGameHandle = new GameHandler();

        luaCall = new LuaEventCall();

        LoggerUtil.init("");
        // ---------------------------------------------------------
        // GODSDK
        // ---------------------------------------------------------
        // GodsdkWrapperCallback gadsdkCallback = new GodsdkWrapperCallback() {
        //     @Override
        //     public void onCallback(String jsonString) {
        //         LuaEventCall.luaCallEvent("godsdkPayCallBack", LuaEventCall.kResultSucess, LuaEventCall.kCallParamJsonString, jsonString);
        //     }
        // };
        // GodsdkWrapper.init(mThis, gadsdkCallback);
        // ---------------------------------------------------------
        // Facebook SDK
        // ---------------------------------------------------------
        // FacebookSdk.sdkInitialize(getApplicationContext());
        // AppEventsLogger.activateApp(this.getApplication());
        // getAppLink();

        // GapleApplication application = (GapleApplication) getApplication();
        // application.getDefaultTracker();
        // ---------------------------------------------------------
        // Google Cloud Messaging
        // ---------------------------------------------------------
        // MyFirebaseMessagingUtils.init();
        // TODO: notify lua if app is started from notification
        // init googlePay in-app-billing
        // InAppBillingWrapper.init(mThis,"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAh6+9U4w+U2C1Hpp2fm0mgU+27ysFT9NOYi5PF51RCfij0KQUMLcPuTP2AvG5w+HWs8VQ2t3ZBudTUfiL+/Duebah1uya/euKSyA8smwTtusDb6D9nlmAiktxQN2WIUGlzIZ2Mx0YB9mF79b4W+MC6qMG2YdlT57TDLZvglWSgxJT9WZI9II47l7/PetCWw3A3nKSBa/4TiLky+FMRzidiqRHRQ23dcmuSSM+H9chOcX1KpPNbNN7qYkEL0m9foF+QOI6psiRXAjMx5MVQJX80t6Pnc923FTY1uylUNBQWoDxXlQJu2JxV8r6sTg2H7q1Nc4K6QKTwrd/i48I08dj+wIDAQAB", true);
		// ---------------------------------------------------------
		// Umeng
		// ---------------------------------------------------------
		// UmengWrapper.init(this.getString(R.string.umeng_appkey),"chanel");

        // ---------------------------------------------------------
        // adStats 广告统计
        // ---------------------------------------------------------
        // AdStatsWrapper.setFbAppId(mThis, this.getString(R.string.facebook_app_id));

        // ---------------------------------------------------------
        // adNormal 广告换量和活动中心结合
        // ---------------------------------------------------------
        // AdNormalWrapper.init(this.getString(R.string.adsdkNormal_app_id),this.getString(R.string.adsdkNormal_app_sec));

        // unity ads
        UnityAds.initialize(mThis, "1224777", new IUnityAdsListener()
                                            {
                                                @Override
                                                public void onUnityAdsReady(final String zoneId) {
//                                                    toast("Ready:", zoneId);
                                                }

                                                @Override
                                                public void onUnityAdsStart(String zoneId) {
//                                                    toast("Start:", zoneId);
                                                }

                                                @Override
                                                public void onUnityAdsFinish(String zoneId, UnityAds.FinishState result) {
//                                                    toast("Finish:", zoneId + ", state:" + result);

                                                    if(zoneId.equals(LuaEventCall.placementId))
                                                    {
                                                        int videoResult;
                                                        if(result == UnityAds.FinishState.COMPLETED)
                                                        {
                                                            videoResult = LuaEventCall.kResultSucess;
                                                        }
                                                        else
                                                        {
                                                            videoResult = LuaEventCall.kResultFail;
                                                        }

                                                        Game.getInstance().getLuaEventCall().luaCallEvent("unityAdsCallBack",
                                                                videoResult,
                                                                LuaEventCall.kCallParamNo, "");
                                                    }


                                                }

                                                @Override
                                                public void onUnityAdsError(UnityAds.UnityAdsError error, String message) {
//                                                    toast("Error:", error + " " + message);
                                                }

                                                private void toast(String callback, String msg) {
                                                    Toast.makeText(getApplicationContext(), callback + ": " + msg, Toast.LENGTH_SHORT).show();
                                                }
                                            });
    }

    //安装第一次启动删除文件夹: /data/data/packageName/update
    public void clearUpdate() {
        if (SDTools.isFirstRun()){
            Log.i("clearUpdate","clearUpdate");
            String path = AppActivity.getInstance().getApplication().getFilesDir().getAbsolutePath() + "/update";
            deleteDir(path);
        }
    }

    private  void deleteDir(String path) {
        File file = new File(path);
        if(file.exists() && file.isDirectory()) {
            File[] files = file.listFiles();

            for(int i = 0; i < files.length; ++i) {
                doDeleteDir(files[i]);
            }
        }

    }

    private  void doDeleteDir(File dir) {
        if(dir.exists()) {
            if(dir.isDirectory()) {
                File[] files = dir.listFiles();

                for(int i = 0; i < files.length; ++i) {
                    doDeleteDir(files[i]);
                }
            }

            dir.delete();
        }
    }

    /**
     * 获取Game对象
     *
     * @return Game 对象
     */
    public static Game getInstance() {
        return mThis;
    }

    /**
     * 获取Handler
     *
     * @return Handler 对象
     */
    public GameHandler getGameHandler() {
        return mGameHandle;
    }

    /**
     * 获取luaCall 对象
     *
     * @return luaCall 对象
     */
    public LuaEventCall getLuaEventCall() {
        return luaCall;
    }

    /**
     * 所有在UI线程中调用引擎c接口的,都需要使用此函数将调用放入到render线程执行
     */
    @Override
    public void runOnLuaThread(Runnable ra) {
        super.runOnLuaThread(ra);
    }

    /**
     * 本函数是在Lua的event_load之前被执行,是在Lua线程被调用
     * param "28" 这是dump 上传时分配的id
     */
    @Override
    public void OnBeforeLuaLoad() {
        super.OnBeforeLuaLoad();
        UploadDumpFile.getInstance().execute(this,"28");
    }

    /**
     * 在结束应用进程前调用
     */
    @Override
    public void onBeforeKillProcess() {
        super.onBeforeKillProcess();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }

    /**
     * 1.Lua调Java OnLuaCall 方法<br/>
     * 2.此方法可作为所有Lua调Java方法统一入口，用获取的值来区分访问实现函数<br/>
     * 示例：<br/>
     * lua: <br/>
     * function callJava()<br/>
     * dict_set_string("funcName","funcKey","uploadImage"); //java 实现函数<br/>
     * call_native("OnLuaCall");//Lua调Java统一方法入口<br/>
     * end<br/>
     * <br/>
     * java:<br/>
     *
     * @Override<br/> public void OnLuaCall() {<br/>
     * super.OnLuaCall();<br/>
     * String func = dict_get_string("funcName","funcKey"); //获取java 实现函数<br/>
     * if(func == "uploadImage"){ //判断实现函数，执行函数<br/>
     * uploadImage();<br/>
     * }<br/>
     * }<br/>
     */
    @Override
    public void OnLuaCall() {
        super.OnLuaCall();
        String func = Dict.getString("LuaCallFuc", "LuaCallFuc"); //获取java 实现函数<br/>
        luaCall.handlerCall(func);
    }


    @Override
    protected void onRestart() {
        super.onRestart();

    }

    @Override
    protected void onResume() {
        super.onResume();
        // UmengWrapper.registOnResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        // UmengWrapper.registOnPause();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        this.dismissStartDialog();
        // FacebookWrapper.releaseInstance(facebookWrapper);
        // InAppBillingWrapper.onDestroy();
    }

    private void onHandleMessage(Message msg) {
        switch (msg.what) {
            case HANDLER_CLOSE_START_DIALOG:
                dismissStartDialog();
                Game.getInstance().getGameHandler().removeMessages(msg.what);
                break;
            case HANDLER_HTTP_DOWNLOAD_TIMEOUT:
                HttpFileLoad.HandleTimeout(msg);
                break;
            case HANDLER_TOAST:
                String str = (String)msg.obj;
                Toast.makeText(getApplicationContext(), str, Toast.LENGTH_SHORT).show();
                break;
            default:
        }
    }

    /**
     * 启动应用画面Dialog
     */
    public void showStartDialog() {
        if (null == mStartDialog) {
            mStartDialog = new AppStartDialog(this);
            mStartDialog.show();
        }
    }

    /**
     * 销毁应用启动画面Dialog
     */
    public void dismissStartDialog() {
        if (null != mStartDialog) {
            mIsLuaInitDone = true;
            if (mStartDialog.isShowing() && mStartDialog.isBootFinish) {
                mStartDialog.dismiss();
                mStartDialog = null;
            }
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (null != mStartDialog) {
            mStartDialog.show();
            // Game.getInstance().getGameHandler().sendEmptyMessageDelayed(HANDLER_CLOSE_START_DIALOG, 5000);
        }
    }

    /**
     * 重写Handler
     */
    public class GameHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            onHandleMessage(msg);
        }
    }

    /**
     * Facebook
     */
    @Override
    protected void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
       /* facebookWrapper=FacebookWrapper.getInstance();
        facebookWrapper.onActivityResult(requestCode, resultCode, data);*/
        // InAppBillingWrapper.onActivityResult(mThis, requestCode, resultCode, data);
        ActivityAgent.onActivityResult(this, requestCode, resultCode, data);

        switch (requestCode){
            case SaveHeadImage.GALLERY_PICKED_DATA:
                if (resultCode == RESULT_OK){
                    if (luaCall.saveHeadImage != null){
                        luaCall.saveHeadImage.onSaveBitmap(data);
                    }
                }
                break;
            case SaveHeadImage.CAMERA_PICKED_DATA:
                if (resultCode == RESULT_OK){
                    if (luaCall.saveHeadImage != null){
                        luaCall.saveHeadImage.doCropPhoto(data);
                    }
                }
            case FeedbackPicture.FEEDBACK_PICKED_PICTURE_DATA:
                if (resultCode == RESULT_OK){
                    if (luaCall.feedbackPicture != null){
                        luaCall.feedbackPicture.saveBitmap(data);
                    }
                }
            default:
                break;
        }
    }

    /**
     * 获取通过 Facebook 邀请 DeepLinking 链接
     */
    private void getAppLink() {
        Uri applink = getIntent().getData();
        do {
            if (applink == null)
                break;

            String scheme = applink.getScheme();
            // DominoGaple 与后端确定的 scheme 为包名, 即 com.boyaa.gaple
            if (scheme == null || !scheme.equalsIgnoreCase(getPackageName()))
                break;

            String host = applink.getHost();
            String path = applink.getPath();
            String query = applink.getQuery();

            // TODO: 将解析出来的参数传递给 lua
            Log.e("APPLINK", "Origin: " + applink);
            Log.e("APPLINK", "Scheme: " + scheme);
            Log.e("APPLINK", "Host: " + host);
            Log.e("APPLINK", "Path: " + path);
            Log.e("APPLINK", "Query: " + query);

        } while (false);
    }

    private boolean checkPlayServices() {
        GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = apiAvailability.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (apiAvailability.isUserResolvableError(resultCode)) {
                // apiAvailability.getErrorDialog(this, resultCode, PLAY_SERVICES_RESOLUTION_REQUEST)
                //         .show();
            } else {
                Log.i("GCM", "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }

    public boolean isLuaInitDone(){
        return mIsLuaInitDone;
    }

}
