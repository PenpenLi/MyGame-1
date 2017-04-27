package com.boyaa.godsdk.sdk;

import java.util.Map;

public interface IGodsdkCallback {
	
	void onPaymentSuccess(Map map, String pmode);
	
	void onPaymentFailed(String pmode);

}
