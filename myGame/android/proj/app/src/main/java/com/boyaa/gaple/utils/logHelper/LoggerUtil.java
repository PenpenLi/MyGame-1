package com.boyaa.gaple.utils.logHelper;

import android.os.Environment;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;

/**
 * Created by HrnryChen on 2016/6/16.
 */
public class LoggerUtil {
    private static final String TAG = LoggerUtil.class.getSimpleName();
    private static LoggerUtil INSTANCE = null;
    private static String PATH_LOGCAT;
    private static LogDumper mLogDumper = null;
    private static int mPId;

    private static SimpleDateFormat sDateFormatFile = new SimpleDateFormat("yyyy-MM-dd");
    private static SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss SSS");

    /**
     *
     * 初始化目录
     *
     * */
    public static void init(String savePath) {
        Log.d(TAG, "init");
        if (Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED)) {// 优先保存到SD卡中
            PATH_LOGCAT = Environment.getExternalStorageDirectory()
                    .getAbsolutePath() + File.separator + "GapleLog";
        } else {// 如果SD卡不存在，就保存到本应用的目录下
            PATH_LOGCAT = savePath;
        }
        File file = new File(PATH_LOGCAT);
        if (!file.exists()) {
            file.mkdirs();
        }
        Log.d(TAG, "init PATH_LOGCAT:" + PATH_LOGCAT);
        clearFolder(file);
        mPId = android.os.Process.myPid();
    }

    public static void start() {
        Log.d(TAG, "start");
        if (mLogDumper == null){
            mLogDumper = new LogDumper(String.valueOf(mPId), PATH_LOGCAT);
            mLogDumper.stopLogs();
            mLogDumper.start();
        }
    }

    public static void stop() {
        Log.d(TAG, "stop");
        if (mLogDumper != null) {
            mLogDumper.stopLogs();
            mLogDumper = null;
        }
    }


    /**
     * 超过5天的日志将被清理
     * @param file 目录
     */
    public static void clearFolder(File file){
        try {
            File[] fileList = file.listFiles();
            for (int i = 0; i < fileList.length; i++)
            {
                String timeString = "";
                String fileName = fileList[i].getName();
                int dot = fileName.lastIndexOf('.');
                if ((dot >-1) && (dot < (fileName.length()))) {
                    timeString = fileName.substring(0, dot);
                }
                java.util.Date fileDate=sDateFormatFile.parse(timeString);
                long time1 = fileDate.getTime();
                long time2 = (new java.util.Date()).getTime();
                if((time2-time1)/(1000*3600*24)>5){
                    fileList[i].delete();
                }
            }
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        start();
    }

    private static class LogDumper extends Thread {

        private Process logcatProc;
        private BufferedReader mReader = null;
        private boolean mRunning = true;
        String cmds = null;
        private String mPID;
        private FileOutputStream out = null;

        public LogDumper(String pid, String dir) {
            mPID = pid;
            try {
                out = new FileOutputStream(dir+"/"+sDateFormatFile.format(new java.util.Date())+".log", true);
            } catch (FileNotFoundException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            /**
             *
             * 日志等级：*:v , *:d , *:w , *:e , *:f , *:s
             *
             * 显示当前mPID程序的 E和W等级的日志.
             *
             * */

            // cmds = "logcat *:e *:w | grep \"(" + mPID + ")\"";
            // cmds = "logcat  | grep \"(" + mPID + ")\"";//打印所有日志信息
            // cmds = "logcat -s way";//打印标签过滤信息
            cmds = "logcat  | grep \"(" + mPID + ")\"";

        }

        public void stopLogs() {
            mRunning = false;
        }

        @Override
        public void run() {
            try {
                logcatProc = Runtime.getRuntime().exec(cmds);
                mReader = new BufferedReader(new InputStreamReader(
                        logcatProc.getInputStream()), 1024);
                String line = null;
                while (mRunning && (line = mReader.readLine()) != null) {
                    if (!mRunning) {
                        break;
                    }
                    if (line.length() == 0) {
                        continue;
                    }
                    if (out != null && line.contains(mPID)) {
                        out.write(("logByGaple [" + sDateFormat.format(new java.util.Date()) + "]" + line + "\n")
                                .getBytes());
                    }
                }

            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (logcatProc != null) {
                    logcatProc.destroy();
                    logcatProc = null;
                }
                if (mReader != null) {
                    try {
                        mReader.close();
                        mReader = null;
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                if (out != null) {
                    try {
                        out.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    out = null;
                }

            }

        }

    }
}
