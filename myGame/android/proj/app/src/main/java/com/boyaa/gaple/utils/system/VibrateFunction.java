package com.boyaa.gaple.utils.system;

import android.content.Context;
import android.os.Vibrator;
import android.util.Log;

import com.boyaa.gaple.Game;

/**
 * Created by HrnryChen on 2016/8/11.
 */
public class VibrateFunction {

    public static void apply(int time) {
        Context ctx = Game.getInstance();
        if(ctx != null) {
            Vibrator vibrator = (Vibrator) ctx.getSystemService(Context.VIBRATOR_SERVICE);
            if(vibrator != null) {
                vibrator.vibrate(time);
            } else {
                Log.e("VibrateFunction", "VIBRATOR_SERVICE not availiable");
            }
        }
    }

}
