package com.boyaa.admobile.ad;

import android.content.Context;

import java.util.HashMap;

/**
 * 管理实现方法
 * 需要跟踪记录的事件节点
 *
 * @author Carrywen
 */
public interface AdManager {
	
    /**
     * start
     *
     * @param context
     * @param paraterMap
     */
    public void start(Context context, HashMap paraterMap);

    /**
     * register
     *
     * @param context
     * @param paraterMap
     */
    public void register(Context context, HashMap paraterMap);

    /**
     * login
     *
     * @param context
     * @param paraterMap
     */
    public void login(Context context, HashMap paraterMap);

    /**
     * play
     *
     * @param context
     * @param paraterMap
     */
    public void play(Context context, HashMap paraterMap);

    /**
     * pay
     *
     * @param context
     * @param paraterMap
     */
    public void pay(Context context, HashMap paraterMap);

    /**
     * logout
     *
     * @param context
     * @param paraterMap
     */
    public void logout(Context context, HashMap paraterMap);
    
    /**
     * remind
     *
     * @param context
     * @param paraterMap
     */
    public void recall(Context context,HashMap paraterMap);
    
    

    /**
     * 自定义事件拓展
     *
     * @param context
     * @param paraterMap
     */
    public void customEvent(Context context, HashMap paraterMap);
}
