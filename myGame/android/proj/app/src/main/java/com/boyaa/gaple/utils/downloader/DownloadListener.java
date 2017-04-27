package com.boyaa.gaple.utils.downloader;

import java.io.File;

/**
 * Created by HrnryChen on 2016/5/30.
 */
public interface DownloadListener {
    public static final int ERROR_UNKNOWN_ERROR = 0;
    public static final int ERROR_UNKNOWN_FILE_SIZE = 1;
    public static final int ERROR_SERVER_NO_RESPONSE = 2;
    public static final int ERROR_PROTOCOL_EXCEPTION = 3;
    public static final int ERROR_INCORRECT_URL = 4;

    public void onGetTargetDownloadFileSize(int targetFileSize);

    public void onDownloadFailed(int errorCode);

    public void onDownloadingSize(int downloadedSize, int sourceFileSize);

    public void onDownloadSuccess(File file, String fileAbsolutePath);

    public void onDownloadPause();
}
