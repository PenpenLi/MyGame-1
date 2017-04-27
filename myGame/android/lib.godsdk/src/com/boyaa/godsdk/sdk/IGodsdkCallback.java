package com.boyaa.godsdk.sdk;

public interface IGodsdkCallback {
	
	void onPaymentSuccess(String pmode);
	
	void onPaymentFailed(String pmode);

}
