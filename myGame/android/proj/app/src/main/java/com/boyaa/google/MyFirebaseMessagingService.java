package com.boyaa.google;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import android.os.Build;

import com.boyaa.gaple.Game;
import com.boyaa.xiaojian.R;

import android.os.Vibrator;
import android.app.PendingIntent;

public class MyFirebaseMessagingService extends FirebaseMessagingService {
	private static final String TAG = "MyFirebaseMsgService";

	    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    // [START receive_message]
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // [START_EXCLUDE]
        // There are two types of messages data messages and notification messages. Data messages are handled
        // here in onMessageReceived whether the app is in the foreground or background. Data messages are the type
        // traditionally used with GCM. Notification messages are only received here in onMessageReceived when the app
        // is in the foreground. When the app is in the background an automatically generated notification is displayed.
        // When the user taps on the notification they are returned to the app. Messages containing both notification
        // and data payloads are treated as notification messages. The Firebase console always sends notification
        // messages. For more see: https://firebase.google.com/docs/cloud-messaging/concept-options
        // [END_EXCLUDE]

        // TODO(developer): Handle FCM messages here.
        // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
        Log.d(TAG, "From: " + remoteMessage.getFrom());

        // Check if message contains a data payload.
        if (remoteMessage.getData().size() > 0) {
            Log.d(TAG, "Message data payload: " + remoteMessage.getData());
        }

        
        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
        // if (remoteMessage.getNotification() != null){
        // 	String title = remoteMessage.getNotification().getTitle();
        // 	String body = remoteMessage.getNotification().getBody();
        // 	this.sendNotification(title, body);
        // }
        // else{
            String title = remoteMessage.getData().get("t");
            String body = remoteMessage.getData().get("sender");
            if (title != null && body != null){
                this.sendNotification(title, body);
            }
        // }
    }
    // [END receive_message]

    /**
     * Create and show a simple notification containing the received GCM message.
     *
     * @param title GCM message title received.
     * @param content GCM message content received.
     */
    private void sendNotification(String title, String content) {
        Log.d(TAG, "title: " + title + ", content: " + content);
        Intent notificationIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.push)
                .setContentTitle(title)
                .setContentText(content)
                .setAutoCancel(true)
                .setPriority(1)
                .setCategory("reminder")
                .setSound(defaultSoundUri)
                .setContentIntent(contentIntent);
        // Wif (Build.VERSION.SDK_INT >= 21) notificationBuilder.setVibrate(new long[0]);
        // Vibrator vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        // if(vibrator != null) {
        //     vibrator.vibrate(100);  //vibrate 100 ms
        // }

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }
}