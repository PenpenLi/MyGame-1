package com.boyaa.facebook;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.app.AlertDialog;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import com.boyaa.engine.made.AppActivity;
import com.boyaa.gaple.Game;
import com.boyaa.gaple.nativeEvent.LuaEventCall;
import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookRequestError;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphRequestBatch;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.facebook.internal.Utility;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.Sharer;
import com.facebook.share.model.AppInviteContent;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.ShareApi;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.AppInviteDialog;
import com.facebook.share.widget.GameRequestDialog;
import com.facebook.share.widget.ShareDialog;
//import com.google.android.gms.appdatasearch.GetRecentContextCall;

import org.json.JSONArray;
import org.json.JSONObject;

import java.security.AccessControlContext;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Created by mac on 5/13/16.
 */
public class FacebookWrapper {
    private static String TAG = FacebookWrapper.class.getSimpleName();
    private static FacebookWrapper mFacebookWrapper = new FacebookWrapper();

    private CallbackManager callbackManager;
    private FacebookCallback<LoginResult> facebookLoginCall;
    private ProfileTracker profileTracker;
    private AccessTokenTracker accessTokenTracker;
    private AccessToken accessToken;
    private String actionStr;
    private int limitNum;
    private boolean isInit = false;
    private JSONObject inviteJson;
    private JSONObject shareJson;
    private JSONObject uploadJson;
    private String deleteRequestId_;
    private LoginResult loginResult_ = null;

    private int type_;

    public FacebookWrapper() {
        //FacebookSdk.setIsDebugEnabled(true);
        init();
        LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {
                Log.d(TAG, loginResult.toString());
                switch (type_){
                    case 1:LuaEventCall.luaCallEvent("facebookLoginResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamString, loginResult.getAccessToken().getToken());break;
                    case 2:getInvitableFriends(limitNum);break;
                    case 3:shareLink(shareJson);break;
                    case 4:invite(inviteJson);break;
                    case 5:getRequestId();break;
                    case 6:uploadPhoto(uploadJson);break;
                    case 7:deleteRequestId(deleteRequestId_);break;
                    case 10:getFacebookBindingUserInfo(loginResult);break;
                }
            }

            @Override
            public void onCancel() {
                Log.e(TAG, "login cancle");
                switch (type_){
                    case 1:LuaEventCall.luaCallEvent("facebookLoginResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);
                    case 2:LuaEventCall.luaCallEvent("facebookGetInvitableFriendsResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);break;
                    case 3:LuaEventCall.luaCallEvent("facebookShareFeedResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);break;
                    case 4:LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);break;
                    case 5:LuaEventCall.luaCallEvent("facebookGetRequestIdResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);break;
                    case 6:LuaEventCall.luaCallEvent("facebookUploadPhotoResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);break;
                }
            }

            @Override
            public void onError(FacebookException error) {
                Log.e(TAG, "login fail " + error.toString());
                switch (type_){
                    case 1:LuaEventCall.luaCallEvent("facebookLoginResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                    case 2:LuaEventCall.luaCallEvent("facebookGetInvitableFriendsResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);break;
                    case 3:LuaEventCall.luaCallEvent("facebookShareFeedResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);break;
                    case 4:LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);break;
                    case 5:LuaEventCall.luaCallEvent("facebookGetRequestIdResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);break;
                    case 6:LuaEventCall.luaCallEvent("facebookUploadPhotoResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);break;
                }
            }
        });
    }

    public void getFacebookBindingUserInfo(LoginResult loginResult){
        loginResult_ = loginResult;
        Utility.getGraphMeRequestWithCacheAsync(loginResult.getAccessToken().getToken(),
                new Utility.GraphMeRequestWithCacheCallback() {
                    @Override
                    public void onSuccess(JSONObject userInfo) {
                        String name = userInfo.optString("name");
                        JSONArray arr = new JSONArray();
                        JSONObject retJson = new JSONObject();
                        // Ensure that our profile is up to date
//        Profile.fetchProfileForCurrentAccessToken();
                        Profile profile = Profile.getCurrentProfile();
                        try {
                            retJson.put("token", loginResult_.getAccessToken().getToken());
                            retJson.put("name", name);
                        }catch (Exception e){

                        }
                        arr.put(retJson);
                        LuaEventCall.luaCallEvent("facebookBindingResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamJsonString, arr.toString());
                    }

                    @Override
                    public void onFailure(FacebookException error) {

                    }
                });

    }

    public void binding(){
        LoginBehavior loginBehavior = LoginBehavior.WEB_ONLY;
        LoginManager.getInstance().setLoginBehavior(loginBehavior);
        LoginManager.getInstance().logInWithReadPermissions(Game.getInstance(), null);
        type_ = 10;
    }

    public static FacebookWrapper getInstance(){
        if(mFacebookWrapper == null){
            mFacebookWrapper = new FacebookWrapper();
        }
        return mFacebookWrapper;
    }

    public static void releaseInstance(FacebookWrapper mFacebookWrapper){
        if(mFacebookWrapper != null){
            mFacebookWrapper.onDestory();
        }
    }

    /*
    * facebook 获取accessToken
    * */
    public void getAccessToken(final int type){
        if(!isInit)
            init();
        type_ = type;
        if (type == 6){
            LoginManager.getInstance().logInWithPublishPermissions(Game.getInstance(), Arrays.asList("publish_actions"));
        }else{
            List<String> permissionNeeds= Arrays.asList("public_profile", "email", "user_birthday", "user_friends");
            LoginManager.getInstance().logInWithReadPermissions(Game.getInstance(), permissionNeeds);
        }
    }

    /*
    * facebook 登陆
    * */
    public void login() {
        if(AccessToken.getCurrentAccessToken() != null){
            Log.d(TAG, "You've already logged in and accessToken is " + AccessToken.getCurrentAccessToken().getToken());
            LuaEventCall.luaCallEvent("facebookLoginResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamString, AccessToken.getCurrentAccessToken().getToken());
        }else{
            init();
            getAccessToken(1);
        }
    }

    /*
    * facebook 登出
    * */
    public void logout() {
        init();
        LoginManager.getInstance().logOut();
    }

    /*
    * facebook 获取可邀请好友
    * */
    public void getInvitableFriends(final int limit){
        limitNum = limit;
        if(isAlreadyLogin()) {
            Game.getInstance().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    GraphRequest.Callback invitableFriendsCallback = new GraphRequest.Callback() {
                        @Override
                        public void onCompleted(GraphResponse response) {
                            FacebookRequestError error = response.getError();
                            if (error != null) {
                                Log.e(TAG, "invitable_friends error" + error.toString());
                                LuaEventCall.luaCallEvent("facebookGetInvitableFriendsResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                            } else {
                                String rawStr = response.getRawResponse();
                                Log.d(TAG, "invitable_friends ret->" + rawStr);
                                try {
                                    JSONObject rawJson = new JSONObject(rawStr);
                                    JSONArray dataArr = rawJson.getJSONArray("data");
                                    int len = dataArr.length();
                                    JSONArray arr = new JSONArray();
                                    for (int i = 0; i < len; i++) {
                                        JSONObject row = dataArr.getJSONObject(i);
                                        JSONObject picture = row.getJSONObject("picture");
                                        JSONObject retJson = new JSONObject();
                                        retJson.put("id", row.optString("id"));
                                        retJson.put("name", row.optString("name"));
                                        if (picture != null) {
                                            JSONObject data = picture.optJSONObject("data");
                                            if (data != null) {
                                                retJson.put("url", data.optString("url"));
                                            }
                                        }
                                        arr.put(retJson);
                                    }
                                    LuaEventCall.luaCallEvent("facebookGetInvitableFriendsResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamJsonString, arr.toString());
                                } catch (Exception e) {
                                    Log.e(TAG, e.getMessage(), e);
                                    LuaEventCall.luaCallEvent("facebookGetInvitableFriendsResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                                }
                            }
                        }
                    };
                    Bundle invitableParams = new Bundle();
                    invitableParams.putString("limit", String.valueOf(limit));
                    GraphRequest invitableFriendsRequest = new GraphRequest(accessToken, "/me/invitable_friends", invitableParams, HttpMethod.GET, invitableFriendsCallback);
                    invitableFriendsRequest.executeAsync();
                }
            });
        }else{
            getAccessToken(2);
        }
    }

    /*
    *  facebook api邀请
    * */
    public void invite(JSONObject jsonObject) {
        inviteJson = jsonObject;
        if (isAlreadyLogin()) {
            GameRequestDialog requestDialog = new GameRequestDialog(Game.getInstance());
            requestDialog.registerCallback(callbackManager, new FacebookCallback<GameRequestDialog.Result>() {
                @Override
                public void onSuccess(GameRequestDialog.Result result) {
                    String requestId = result.getRequestId();
                    if (requestId != null) {
                        List<String> tos = result.getRequestRecipients();
                        Iterator<String> it = tos.iterator();
//                        Pattern p = Pattern.compile("^to\\[(\\d+)\\]$");
                        StringBuilder idSb = new StringBuilder();
                        while (it.hasNext()) {
                            String key = it.next();
//                            if (p.matcher(key).matches()) {
                                if (idSb.length() > 0) {
                                    idSb.append(",");
                                }
                                idSb.append(key);
//                            }
                        }
                        JSONObject json = new JSONObject();
                        try {
                            json.put("requestId", requestId);
                            json.put("toIds", idSb.toString());
                        } catch (Exception e) {
                            Log.e(TAG, e.getMessage(), e);
                            LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                        }
                        LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamJsonString, json.toString());
                    } else {
                        LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                    }
                }

                @Override
                public void onCancel() {
                    Log.e(TAG, "invite cancle");
                    LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);
                }

                @Override
                public void onError(FacebookException error) {
                    Log.e(TAG, "invite fail " + error.getMessage());
                    LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                }
            });
            try {
                GameRequestContent content = new GameRequestContent.Builder()
                        .setTo(jsonObject.getString("toID"))
                        .setMessage(jsonObject.getString("message"))
                        .setData(jsonObject.getString("data"))
                        .setTitle(jsonObject.getString("title"))
                        .build();
                requestDialog.show(content);
            } catch (Exception e) {
                Log.e(TAG, "invite data was wrong");
                e.printStackTrace();
            }
        }else{
            getAccessToken(4);
        }
    }

    /*
    *  facebook 弹窗邀请
    * */
    public void invite(String appLinkUrl, String previewImageUrl) {
        init();

        appLinkUrl = appLinkUrl != null ? appLinkUrl : "https://www.mydomain.com/myapplink";
        previewImageUrl = previewImageUrl != null ? previewImageUrl : "https://www.mydomain.com/my_invite_image.jpg";

        if (AppInviteDialog.canShow()) {
            AppInviteContent content = new AppInviteContent.Builder()
                    .setApplinkUrl(appLinkUrl)
                    .setPreviewImageUrl(previewImageUrl)
                    .build();

            AppInviteDialog appInviteDialog = new AppInviteDialog(Game.getInstance());
            appInviteDialog.registerCallback(callbackManager, new FacebookCallback<AppInviteDialog.Result>() {
                @Override
                public void onSuccess(AppInviteDialog.Result result) {
                    LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamNo, null);
                }

                @Override
                public void onCancel() {
                    Log.e(TAG, "用户取消了邀请");
                    LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);
                }

                @Override
                public void onError(FacebookException error) {
                    LuaEventCall.luaCallEvent("facebookInviteResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                }
            });
            appInviteDialog.show(content);
        }
    }

    /*
    * facebook 分享
    * */
    public void shareLink(JSONObject jsonObject) {
        shareJson = jsonObject;
        if(isAlreadyLogin()) {
            try {
                ShareLinkContent content = new ShareLinkContent.Builder()
                        .setImageUrl(Uri.parse(jsonObject.getString("picture")))
                        .setContentUrl(Uri.parse(jsonObject.getString("link")))
                        .setContentTitle(jsonObject.getString("caption"))
                        .setContentDescription(jsonObject.getString("name"))
                        .build();

                ShareDialog shareDialog = new ShareDialog(Game.getInstance());

                if (shareDialog.canShow(content)) {
                    shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
                        @Override
                        public void onSuccess(Sharer.Result result) {
                            LuaEventCall.luaCallEvent("facebookShareFeedResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamNo, null);
                        }

                        @Override
                        public void onCancel() {
                            Log.e(TAG, "share cancle");
                            LuaEventCall.luaCallEvent("facebookShareFeedResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);
                        }

                        @Override
                        public void onError(FacebookException error) {
                            Log.e(TAG, "share fail " + error.getMessage());
                            LuaEventCall.luaCallEvent("facebookShareFeedResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                        }
                    });
                    shareDialog.show(content);
                }
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }
        }else{
            getAccessToken(3);
        }
    }

    //private static SharePhotoContent contentOfPhoto = null;
    /*
    * facebook 分享
    * */
    public void uploadPhoto(JSONObject jsonObject) {
        uploadJson = jsonObject;
        if(hasPublishPermission()) {
            try {
                FacebookCallback<Sharer.Result> shareCallback = new FacebookCallback<Sharer.Result>() {
                        @Override
                        public void onCancel() {
                            //contentOfPhoto = null;
                            Log.d("FacebookWrapper", "Canceled");
                            LuaEventCall.luaCallEvent("facebookUploadPhotoResult", LuaEventCall.kResultCancle, LuaEventCall.kCallParamNo, null);
                        }

                        @Override
                        public void onError(FacebookException error) {
                            //contentOfPhoto = null;
                            Log.d("FacebookWrapper", String.format("Error: %s", error.toString()));
                            // String title = getString(R.string.error);
                            // String alertMessage = error.getMessage();
                            // showResult(title, alertMessage);
                            LuaEventCall.luaCallEvent("facebookUploadPhotoResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                        }

                        @Override
                        public void onSuccess(Sharer.Result result) {
                            //contentOfPhoto = null;
                            if (result.getPostId() != null) {
                                //String title = "Success";
                                //String alertMessage = "Upload success!";
                                //showResult(title, alertMessage);
                                LuaEventCall.luaCallEvent("facebookUploadPhotoResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamNo, null);
                            }
                        }

                        private void showResult(String title, String alertMessage) {
                            new AlertDialog.Builder(Game.getInstance())
                                    .setTitle(title)
                                    .setMessage(alertMessage)
                                    .setPositiveButton("OK", null)
                                    .show();
                        }
                    };
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inJustDecodeBounds = true;
                BitmapFactory.decodeFile(uploadJson.getString("path"), options);
                options.outHeight = options.outHeight * 1024 / options.outWidth;
                options.outWidth = 1024;
                options.inJustDecodeBounds = false;
                Bitmap image = BitmapFactory.decodeFile(uploadJson.getString("path"), options);
                SharePhoto photo = new SharePhoto.Builder()
                   .setBitmap(image)
                   .setCaption(uploadJson.optString("caption"))
                   .build();
                SharePhotoContent content = new SharePhotoContent.Builder()
                   .addPhoto(photo)
                   .build();
                //this.contentOfPhoto = content;
                ShareApi.share(content, shareCallback);   
            } catch (Exception e) {
                e.printStackTrace();
                LuaEventCall.luaCallEvent("facebookUploadPhotoResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                return;
            }
        }else{
            getAccessToken(6);
        }
    }

    /*
    * facebook 获取由此游戏玩家发送的请求（用于给其他玩家发奖）
    * facebook 第一次登陆时才会调用
    * */
    public void getRequestId(){
        if(isAlreadyLogin()) {
            Game.getInstance().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    GraphRequest.Callback getIdCallback = new GraphRequest.Callback() {
                        @Override
                        public void onCompleted(GraphResponse response) {
                            FacebookRequestError error = response.getError();
                            if(error != null) {
                                Log.e(TAG, "get apprequests error" + error.toString());
                                LuaEventCall.luaCallEvent("facebookGetRequestIdResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                            } else {
                                String rawStr = response.getRawResponse();
                                Log.d(TAG, "get apprequests ret->" + rawStr);
                                try {
                                    JSONObject rawJson = new JSONObject(rawStr);
                                    JSONArray dataArr = rawJson.getJSONArray("data");
                                    JSONObject ret = new JSONObject();
                                    if(dataArr != null && dataArr.length() > 0) {
                                        JSONObject json = dataArr.getJSONObject(0);
                                        String requestId = json.optString("id");
                                        String requestData = json.optString("data");
                                        ret.putOpt("requestId", requestId);
                                        ret.putOpt("requestData", requestData);
                                    }
                                    LuaEventCall.luaCallEvent("facebookGetRequestIdResult", LuaEventCall.kResultSucess, LuaEventCall.kCallParamJsonString, ret.toString());
                                } catch(Exception e) {
                                    Log.e(TAG, e.getMessage(), e);
                                    LuaEventCall.luaCallEvent("facebookGetRequestIdResult", LuaEventCall.kResultFail, LuaEventCall.kCallParamNo, null);
                                }
                            }
                        }
                    };
                    GraphRequest getIdRequest = new GraphRequest(accessToken, "/me/apprequests", null, HttpMethod.GET, getIdCallback);
                    getIdRequest.executeAsync();
                }
            });
        }else{
            getAccessToken(5);
        }
    }

    public void deleteRequestId(String requestId){
        deleteRequestId_ = requestId;
        if(isAlreadyLogin()) {
            Game.getInstance().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    GraphRequest.Callback getIdCallback = new GraphRequest.Callback() {
                        @Override
                        public void onCompleted(GraphResponse response) {
                            FacebookRequestError error = response.getError();
                            if(error != null) {
                                Log.e(TAG, "deleteRequestId error" + error.toString());
                            } else {
                                String rawStr = response.getRawResponse();
                                Log.d(TAG, "deleteRequestId ret->" + rawStr);
                            }
                        }
                    };
                    GraphRequest getIdRequest = new GraphRequest(accessToken, deleteRequestId_, null, HttpMethod.DELETE, getIdCallback);
                    getIdRequest.executeAsync();
                }
            });
        }else{
            getAccessToken(7);
        }
    }

    public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        if(callbackManager != null) {
            callbackManager.onActivityResult(requestCode, resultCode, data);
        }
    }

    public void onDestory() {
        accessTokenTracker.stopTracking();
        profileTracker.stopTracking();
    }

    private void init() {
        if (!FacebookSdk.isInitialized()) {
            Log.e(TAG, "FacebookSDK is not initialized yet!");
            return;
        }

        if (profileTracker == null) {
            profileTracker = new ProfileTracker() {
                @Override
                protected void onCurrentProfileChanged(Profile oldProfile, Profile currentProfile) {
                    Profile.setCurrentProfile(currentProfile);
                }
            };
        }

        if (accessTokenTracker == null) {
            accessTokenTracker = new AccessTokenTracker() {
                @Override
                protected void onCurrentAccessTokenChanged(AccessToken oldAccessToken, AccessToken currentAccessToken) {
                    String oldToken = oldAccessToken == null ? "null" : oldAccessToken.toString();
                    String curToken = currentAccessToken == null ? "null" : currentAccessToken.toString();
                    Log.e(TAG, "AccessToken Changed [OLD]: " + oldToken + " [CUR]: " + curToken);
                    AccessToken.setCurrentAccessToken(currentAccessToken);
                }
            };
        }

        if (callbackManager == null) {
            callbackManager = CallbackManager.Factory.create();
        }

        isInit = true;
    }

    /*
    * facebook 授权管理
    * */
    private boolean isAlreadyLogin() {
        if(!isInit)
            init();
        accessToken = AccessToken.getCurrentAccessToken();
        if (accessToken != null && !accessToken.isExpired()) {
            Profile profile = Profile.getCurrentProfile();
//            Log.w(TAG, profile.getName());
            return true;
        } else {
            return false;
        }
    }

    private boolean hasPublishPermission(){
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        return accessToken != null && !accessToken.isExpired() && accessToken.getPermissions().contains("publish_actions");
    }

    public void openFacebookPage(String userId){
        Intent intent = newFacebookIntent(Game.getInstance().getPackageManager(), "https://www.facebook.com/" + userId);
        Game.getInstance().startActivity(intent);
    }

    /**
    * <p>Intent to open the official Facebook app. If the Facebook app is not installed then the
    * default web browser will be used.</p>
    *
    * <p>Example usage:</p>
    *
    * {@code newFacebookIntent(ctx.getPackageManager(), "https://www.facebook.com/JRummyApps");}
    *
    * @param pm
    *     The {@link PackageManager}. You can find this class through {@link
    *     Context#getPackageManager()}.
    * @param url
    *     The full URL to the Facebook page or profile.
    * @return An intent that will open the Facebook page/profile.
    */
    public static Intent newFacebookIntent(PackageManager pm, String url) {
        Uri uri = Uri.parse(url);
        try {
            ApplicationInfo applicationInfo = pm.getApplicationInfo("com.facebook.katana", 0);
            if (applicationInfo.enabled) {
              // http://stackoverflow.com/a/24547437/1048340
              uri = Uri.parse("fb://facewebmodal/f?href=" + url);
            }
        } catch (PackageManager.NameNotFoundException ignored) {
        }
        return new Intent(Intent.ACTION_VIEW, uri);
    }
}
