package com.boyaa.gaple;

import android.content.res.AssetFileDescriptor;
import android.graphics.PixelFormat;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import java.io.IOException;

/**
 * Created by BrianLi on 2016/4/19. Denny Modified and used in Gaple
 */
public class BootLoader implements SurfaceHolder.Callback {
    private MediaPlayer mediaPlayer;
    private BootListener mListener;
    private String fileName;
    private boolean hasActiveSurface;
    SurfaceView surfaceView;

    public BootLoader(SurfaceView surfaceView, String fileName, BootListener bootListener) {
        this.fileName = fileName;
        this.mListener = bootListener;
        hasActiveSurface = false;
        surfaceView.getHolder().addCallback(this);
        //surfaceView.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        this.surfaceView = surfaceView;
    }

    private void play(String fileName) {
        try {
            AssetFileDescriptor fileDescriptor = Game.getInstance().getAssets().openFd(fileName);
            //mediaPlayer = MediaPlayer.create(Game.getInstance(), R.raw.start_screen_anim);
            mediaPlayer = new MediaPlayer();
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            // 设置播放的视频源
            long length = fileDescriptor.getLength();
            mediaPlayer.setDataSource(fileDescriptor.getFileDescriptor(), fileDescriptor.getStartOffset(), length);
            this.surfaceView.setZOrderMediaOverlay(true);
            // 设置显示视频的SurfaceHolder
            if (!hasActiveSurface) {
                return;
            }
            mediaPlayer.setDisplay(this.surfaceView.getHolder());
            mediaPlayer.prepareAsync();
            mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mp) {
                    mediaPlayer.start();
                }
            });
            mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {

                @Override
                public void onCompletion(MediaPlayer mp) {
                    //release();
                    if (mListener != null) {
                        mListener.complete();
                        mListener = null;
                    }
                }
            });
            mediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {

                @Override
                public boolean onError(MediaPlayer mp, int what, int extra) {
                    release();
                    if (mListener != null) {
                        mListener.complete();
                        mListener = null;
                    }
                    return false;
                }
            });
        } catch (Exception e) {
            release();
            if (mListener != null) {
                mListener.complete();
                mListener = null;
            }
        }

    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        if (fileName != null) {
            hasActiveSurface = true;
            play(fileName);
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        release();
    }


    private void release() {
        hasActiveSurface = false;
        if (mediaPlayer != null) {
            mediaPlayer.setDisplay(null);
            mediaPlayer.release();
        }
        mediaPlayer = null;
    }

    public interface BootListener {
        void complete();
    }

}
