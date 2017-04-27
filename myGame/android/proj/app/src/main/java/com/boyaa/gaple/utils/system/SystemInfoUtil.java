package com.boyaa.gaple.utils.system;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.WindowManager;

import com.boyaa.gaple.Game;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by HrnryChen on 2016/6/29.
 */
public class SystemInfoUtil {

    public static String mac;
    private static final String EMPTY_MAC = "00:00:00:00:00:00";

    public static int screen_w = 0;
    public static int screen_h = 0;

    public static String brand;
    public static String release;
    public static int sdk_int;

    public static String getSystemInfo(){
        String encodeString = "";
        getScreen();
        try {
            JSONObject json = new JSONObject();
            json.put("mac", getMAC());
            json.put("imei", getIMEI());
            json.put("deviceName", getDeviceAccount());
            json.put("deviceModel", getDeviceModel());
            json.put("simNum", getSimNumber());
            json.put("networkType", getNetworkType());
            json.put("sdkVer", brand + "_" + release + "|" + sdk_int);
            json.put("widthPixels", screen_w);
            json.put("heightPixels", screen_h);
            json.put("appVersion",getAppVersion());
            encodeString = json.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return encodeString;
    }

    private static String getMAC() {
        if (mac == null) {
            WifiManager managergr = (WifiManager) Game.getInstance().getApplication()
                    .getSystemService(Context.WIFI_SERVICE);
            if (managergr != null) {
                WifiInfo wifiinfo = managergr.getConnectionInfo();
                if (wifiinfo != null) {
                    mac = wifiinfo.getMacAddress();
                }
            }
            if (mac == null) {
                mac = EMPTY_MAC;
            }
            return mac;
        }else{
            return mac;
        }
    }

    private static String getIMEI() {
        String imei = null;
        try{
            TelephonyManager teleMgr = (TelephonyManager) Game.getInstance().getSystemService(Context.TELEPHONY_SERVICE);
            if(teleMgr != null) {
                imei = teleMgr.getDeviceId();
                if(TextUtils.isEmpty(imei) || "000000000000000".equals(imei)) {
                    imei = "";
                }
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        return imei == null ? "" : imei;
    }

    // 设备名称
    private static String getDeviceAccount() {
        String account = null;
        try{
            AccountManager accMgr = (AccountManager) Game.getInstance().getSystemService(Context.ACCOUNT_SERVICE);
            if(accMgr != null) {
                Account[] accounts = accMgr.getAccountsByType("com.google");
                List<String> possibleEmails = new ArrayList<String>();
                if(accounts != null && accounts.length > 0){
                    for(Account ac : accounts){
                        possibleEmails.add(ac.name);
                    }
                }
                if(!possibleEmails.isEmpty() && possibleEmails.get(0) != null){
                    String email = possibleEmails.get(0);
                    String[] parts = email.split("@");
                    if(parts != null && parts.length > 0 && parts[0] != null){
                        account = parts[0];
                    }
                }
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        return account == null ? "" : account;
    }

    // 设备型号
    private static String getDeviceModel(){
        brand = "";
        String model = "";
        sdk_int = 0;
        release = "";
        try{
            brand = android.os.Build.BRAND;
            model = Build.MODEL;
            sdk_int = Build.VERSION.SDK_INT;
            release = Build.VERSION.RELEASE;
        }catch(Exception e){
            e.printStackTrace();
        }
        return brand + "_" + model;
    }

    //SIM
    private static String getSimNumber(){
        String SimSerialNumber = null;
        try{
            TelephonyManager tm = (TelephonyManager) Game.getInstance().getSystemService(Context.TELEPHONY_SERVICE);
            SimSerialNumber = tm.getSimSerialNumber();
        }catch(Exception e){
            e.printStackTrace();
        }
        return SimSerialNumber == null ? "" : SimSerialNumber;
    }

    //NetworkType
    private static String getNetworkType() {
        String netType = null;
        try{
            ConnectivityManager connectivityManager = (ConnectivityManager) Game.getInstance().getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
            if (networkInfo == null) {
                netType =  "";
            }
            int nType = networkInfo.getType();
            if (nType == ConnectivityManager.TYPE_MOBILE) {
                netType = "mobile" + "_" + networkInfo.getSubtypeName();
            } else if (nType == ConnectivityManager.TYPE_WIFI) {
                netType = "wifi";
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        return netType == null ? "" : netType;
    }

    // 获取屏幕分辨率
    private static void getScreen(){
        WindowManager wm = (WindowManager) Game.getInstance().getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics dm = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(dm);
        screen_w = dm.widthPixels;
        screen_h = dm.heightPixels;
    }

    // 获取App版本号
    private static String getAppVersion(){
        try {
            PackageManager packageManager = Game.getInstance().getPackageManager();
            PackageInfo packInfo;
            //0代表是获取版本信息
            packInfo = packageManager.getPackageInfo(Game.getInstance().getPackageName(), 0);
            return packInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return "";
    }
}
