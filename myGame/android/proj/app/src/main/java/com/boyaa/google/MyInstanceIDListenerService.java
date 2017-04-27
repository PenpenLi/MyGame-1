package com.boyaa.google;

import com.google.firebase.iid.FirebaseInstanceIdService;
import com.google.firebase.iid.FirebaseInstanceId;

import android.content.SharedPreferences;

import android.util.Log;

public class MyInstanceIDListenerService extends FirebaseInstanceIdService{
	private static String TAG = "MyInstanceIDListenerService";

	@Override
	public void onTokenRefresh() {
	    // Get updated InstanceID token.
	    String refreshedToken = FirebaseInstanceId.getInstance().getToken();
	    Log.d(TAG, "Refreshed token: " + refreshedToken);
	    
	    // rigister topics and try to notify lua engine
	    MyFirebaseMessagingUtils.init();
	}
}