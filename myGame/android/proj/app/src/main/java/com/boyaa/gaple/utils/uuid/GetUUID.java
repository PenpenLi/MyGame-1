package com.boyaa.gaple.utils.uuid;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Environment;

import com.boyaa.gaple.Game;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.UUID;

/**
 * Created by HrnryChen on 2016/8/17.
 */
public class GetUUID {
    public static String PATH_ENGINE_FILE_ACCOUNTS = "";
    public static String PATH_DATA_FILE_ACCOUNTS = "";
    public static String PATH_ROOT_FILE_ACCOUNTS = "";
    public static String PATH_INTERNEL_FILE_ACCOUNTS = "";
    public static final String FILE_ACCOUNTS = "accounts.dat";
    public static final String STORE_NAME = "GetUUID";
    public static final String STORE_KEY_UUID = "UUID";
    public static Context ctx ;

    static {

        ctx = Game.getInstance();
        String pkg = ctx.getPackageName().substring(ctx.getPackageName().lastIndexOf('.') + 1);
        PATH_ENGINE_FILE_ACCOUNTS = Environment.getExternalStorageDirectory() + File.separator + "."
                + ctx.getPackageName() + "/dict" ;
        PATH_DATA_FILE_ACCOUNTS = Environment.getExternalStorageDirectory() + File.separator + "Android/data/"
                + ctx.getPackageName() + "/dict" ;
        PATH_ROOT_FILE_ACCOUNTS = Environment.getExternalStorageDirectory() + "";
        PATH_INTERNEL_FILE_ACCOUNTS = ctx.getDir("dict", Activity.MODE_PRIVATE).getAbsolutePath();

    }

    /**
     * 获取uuid
     */
    public static String getUUID() {
        String uuid = "";
        SharedPreferences sp = ctx.getSharedPreferences(STORE_NAME, Activity.MODE_PRIVATE);
        uuid = sp.getString(STORE_KEY_UUID, "");
        if (uuid.equals("") || uuid==null) {
            uuid = readFile(PATH_ENGINE_FILE_ACCOUNTS);
            if (uuid.equals("") || uuid==null) {
                uuid = readFile(PATH_DATA_FILE_ACCOUNTS);
                if (uuid.equals("") || uuid==null) {
                    uuid = readFile(PATH_ROOT_FILE_ACCOUNTS);
                    if (uuid.equals("") || uuid==null) {
                        uuid = readFile(PATH_INTERNEL_FILE_ACCOUNTS);
                        if (uuid.equals("") || uuid==null) {
                            uuid = UUID.randomUUID().toString().replace("-", "");
                        }
                    }
                }
            }
        }
        saveUUID(uuid);
        return uuid;
    }

    public static void saveUUID(String uuid) {
        SharedPreferences.Editor ed = ctx.getSharedPreferences(STORE_NAME, Activity.MODE_PRIVATE).edit();
        ed.putString(STORE_KEY_UUID, uuid);
        ed.commit();
        saveFile(PATH_ENGINE_FILE_ACCOUNTS,uuid);
        saveFile(PATH_DATA_FILE_ACCOUNTS,uuid);
        saveFile(PATH_ROOT_FILE_ACCOUNTS,uuid);
        saveFile(PATH_INTERNEL_FILE_ACCOUNTS,uuid);
    }

    public static void saveFile(String filePath,String content) {
        File foder = new File(filePath);
        if(foder.exists()==false){
            foder.mkdirs();// 多级目录
        }
        FileWriter fw1 = null;
        String name =filePath + File.separator+ "."+FILE_ACCOUNTS;
        try {
            fw1 = new FileWriter(name,false);
            fw1.write(content);
            fw1.flush();
            fw1.close();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                fw1.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }


    public static String readFile(String filePath) {
        String name =filePath + File.separator+ "."+FILE_ACCOUNTS;
        File file = new File(name);
        StringBuffer sb = new StringBuffer();
        if (file.exists()) {
            FileReader fr = null;
            try {
                fr = new FileReader(name);
                BufferedReader br = new BufferedReader(fr);
                while (br.ready()) {
                    sb.append(br.readLine());
                }
                br.close();
                fr.close();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return sb.toString();
    }


    public static boolean exists(String filePath) {
        File file = new File(filePath+ File.separator+ "."+FILE_ACCOUNTS);
        return file.exists();
    }


    public static String readInfo() {
        String info = "/data/data/com.boyaa.domino/shared_pref/GetUUID.xml";
        SharedPreferences sp = ctx.getSharedPreferences(STORE_NAME, Activity.MODE_PRIVATE);
        String uuid = sp.getString(STORE_KEY_UUID, "");
        info = info + ":"+ (uuid.equals("")?"false":"true");
        info = info +";" +PATH_ENGINE_FILE_ACCOUNTS+ File.separator+ "."+FILE_ACCOUNTS + ":"+ (exists(PATH_ENGINE_FILE_ACCOUNTS )?"true":"false");
        info = info +";" +PATH_DATA_FILE_ACCOUNTS+ File.separator+ "."+FILE_ACCOUNTS + ":"+ (exists(PATH_DATA_FILE_ACCOUNTS)?"true":"false");
        info = info +";" +PATH_ROOT_FILE_ACCOUNTS+ File.separator+ "."+FILE_ACCOUNTS + ":"+ (exists(PATH_ROOT_FILE_ACCOUNTS)?"true":"false");
        info = info +";" +PATH_INTERNEL_FILE_ACCOUNTS + File.separator+ "."+FILE_ACCOUNTS+ ":"+ (exists(PATH_INTERNEL_FILE_ACCOUNTS)?"true":"false");
        return info;
    }
}
