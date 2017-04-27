package com.boyaa.google;

import com.boyaa.gaple.Game;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.iid.FirebaseInstanceId;

import com.boyaa.gaple.nativeEvent.LuaEventCall;


public class MyFirebaseMessagingUtils {

	private static final String[] TOPICS = {"global"};

	public static void init(){
		for (String topic : TOPICS) {
            FirebaseMessaging.getInstance().subscribeToTopic(topic);
        }
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        // 通知 Activity 将refreshedToken 发给Lua
	    if(Game.getInstance() != null){
	    	Game.getInstance().googleToken = refreshedToken;
	    	LuaEventCall.luaCallEvent("googleTokenCallBack", LuaEventCall.kResultSucess, LuaEventCall.kCallParamString, refreshedToken);
	    }
	}

}