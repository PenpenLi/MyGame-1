package com.boyaa.gaple.utils.patch;

import com.skywds.android.bsdiffpatch.JniApi;

/**
 * 合并patch文件和老apk，生成新apk
 */
public class PatchUpdateUtil {
    private static boolean loadLibrary = false;
    static{
        try {
            System.loadLibrary("bsdiff");
            loadLibrary = true;
        } catch (Exception e) {
            //SCH-1779 无法加载库文件
            e.printStackTrace();
            loadLibrary = false;
        }
    }
    //部分机型无法加载so库文件，先判断是否加载成功再调用
    public static int bspatchUpdate(String oldApkPath, String newApkPath, String patch){
        int code = -1;
        if(loadLibrary){
            code = bspatch(oldApkPath, newApkPath, patch);
        }
        return code;
    }
    //调用合并新apk库方法
    public static native int bspatch(String oldApkPath, String newApkPath, String patch);

    public static void load() {
        //放在AppActivity.getInstance().getApplicationContext()后会挂掉 ， 所以添加一个方法先调用，让其先加载lib
    }

    public static int bspatchUpdate2(String oldApkPath, String newApkPath, String patch){
        int code = -1;
        if(loadLibrary){
            code = JniApi.bspatch(oldApkPath, newApkPath, patch);
            if(code == 0) code = 1;
        }
        return code;
    }
}
