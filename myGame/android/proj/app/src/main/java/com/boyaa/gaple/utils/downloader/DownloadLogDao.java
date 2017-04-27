package com.boyaa.gaple.utils.downloader;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Created by HrnryChen on 2016/5/30.
 * 下载记录数据访问对象
 */
public class DownloadLogDao {
    private static final String TAG = DownloadLogDao.class.getSimpleName();

    private DownloadDBOpenHelper openHelper;

    public DownloadLogDao(Context context) {
        openHelper = new DownloadDBOpenHelper(context);
    }

    public List<DownloadedTaskEntity> getDownloadedRecord(String downloadUrlStr) {

        SQLiteDatabase db = openHelper.getReadableDatabase();
        Cursor cursor = db.rawQuery("select "
                        + DownloadDBOpenHelper.COL_THREAD_ID + ", "
                        + DownloadDBOpenHelper.COL_SAVE_FILE_PATH + ", "
                        + DownloadDBOpenHelper.COL_DOWNLOADED_SIZE + ", "
                        + DownloadDBOpenHelper.COL_LAST_MODIFY_TIME + " from "
                        + DownloadDBOpenHelper.DB_TABLE_NAME + " where "
                        + DownloadDBOpenHelper.COL_DOWNLOAD_URL_STR + "=?",
                new String[] { downloadUrlStr });

        List<DownloadedTaskEntity> recordList = new LinkedList<DownloadedTaskEntity>();
        while(cursor.moveToNext()){
            DownloadedTaskEntity entity = new DownloadedTaskEntity();
            entity.setDownloadUrlStr(downloadUrlStr);
            entity.setThreadId(cursor.getInt(cursor.getColumnIndex(DownloadDBOpenHelper.COL_THREAD_ID)));
            entity.setSaveFilePath(cursor.getString(cursor.getColumnIndex(DownloadDBOpenHelper.COL_SAVE_FILE_PATH)));
            entity.setDownloadedBlockSize(cursor.getInt(cursor.getColumnIndex(DownloadDBOpenHelper.COL_DOWNLOADED_SIZE)));
            entity.setLastModifiedTime(Long.valueOf(cursor.getString(cursor.getColumnIndex(DownloadDBOpenHelper.COL_LAST_MODIFY_TIME))));
            recordList.add(entity);
        }
        cursor.close();
        db.close();

        return recordList;
    }

    public void createDownloadRecord(Map<Integer, DownloadedTaskEntity> map, String modifyTimeStamp){
        SQLiteDatabase db = openHelper.getWritableDatabase();
        db.beginTransaction();

        try{
            for(Map.Entry<Integer, DownloadedTaskEntity> entry : map.entrySet()){
                DownloadedTaskEntity entity = entry.getValue();
                db.execSQL("insert into " + DownloadDBOpenHelper.DB_TABLE_NAME
                                + "(" + DownloadDBOpenHelper.COL_DOWNLOAD_URL_STR + ", "
                                + DownloadDBOpenHelper.COL_SAVE_FILE_PATH + ", "
                                + DownloadDBOpenHelper.COL_THREAD_ID + ", "
                                + DownloadDBOpenHelper.COL_DOWNLOADED_SIZE + ", "
                                + DownloadDBOpenHelper.COL_LAST_MODIFY_TIME
                                + ") values(?,?,?,?,?)",
                        new Object[] {
                                entity.getDownloadUrlStr(),
                                entity.getSaveFilePath(),
                                entity.getThreadId(),
                                entity.getDownloadedBlockSize(),
                                modifyTimeStamp});
            }

            db.setTransactionSuccessful();
        }finally{
            db.endTransaction();
        }

        db.close();
    }

    public void updateDownloadRecord(Map<Integer, DownloadedTaskEntity> map, String modifyTimeStamp){

        SQLiteDatabase db = openHelper.getWritableDatabase();
        db.beginTransaction();

        try{
            for(Map.Entry<Integer, DownloadedTaskEntity> entry : map.entrySet()){
                DownloadedTaskEntity entity = entry.getValue();
                db.execSQL("update " + DownloadDBOpenHelper.DB_TABLE_NAME
                                + " set "
                                + DownloadDBOpenHelper.COL_DOWNLOADED_SIZE + "=?, "
                                + DownloadDBOpenHelper.COL_LAST_MODIFY_TIME + "=? "
                                + " where "
                                + DownloadDBOpenHelper.COL_DOWNLOAD_URL_STR + "=? and "
                                + DownloadDBOpenHelper.COL_THREAD_ID + "=?",
                        new Object[] {
                                entity.getDownloadedBlockSize(),
                                modifyTimeStamp,
                                entity.getDownloadUrlStr(),
                                entity.getThreadId()});
            }

            db.setTransactionSuccessful();
        }finally{
            db.endTransaction();
        }

        db.close();
    }

    public void clearDownloadedRecord(String downloadUrlStr){
        SQLiteDatabase db = openHelper.getWritableDatabase();
        db.execSQL("delete from " + DownloadDBOpenHelper.DB_TABLE_NAME
                        + " where " + DownloadDBOpenHelper.COL_DOWNLOAD_URL_STR + "=?",
                new Object[] { downloadUrlStr });
        db.close();
    }

    public void clearDownloadedRecordBefore(String modifyTimeStamp) {
        SQLiteDatabase db = openHelper.getWritableDatabase();
        db.execSQL("delete from " + DownloadDBOpenHelper.DB_TABLE_NAME
                        + " where " + DownloadDBOpenHelper.COL_LAST_MODIFY_TIME + "<?",
                new Object[] {modifyTimeStamp});
        db.close();
    }
}
