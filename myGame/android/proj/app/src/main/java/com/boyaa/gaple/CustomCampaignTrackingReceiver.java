package com.boyaa.gaple;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

public class CustomCampaignTrackingReceiver extends BroadcastReceiver{
	@Override
	public void onReceive(Context context, Intent intent) {
		String action = intent.getAction();
		if ("com.android.vending.INSTALL_REFERRER".equals(action)){
			String referrer = intent.getStringExtra("referrer");
			if (referrer != null){
				SharedPreferences sharedPreferences = context.getSharedPreferences("gaple-qiuqiu-campaign", 0);
				SharedPreferences.Editor editor = sharedPreferences.edit();
				editor.putString("referrer", referrer);
				editor.commit();
			}
		}
	}
}