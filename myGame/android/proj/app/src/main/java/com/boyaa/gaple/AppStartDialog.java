package com.boyaa.gaple;




import android.app.Activity;
import android.app.AlertDialog;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import com.boyaa.xiaojian.R;

/**
 * APP启动画面类
 */
public class AppStartDialog extends AlertDialog {

	SurfaceView mBootSurfaceView;
	BootLoader mBootLoader;
	public boolean isBootFinish = false;
	/**
	 * 应用启动画面构造函数
	 * @param context
	 * @return void
	 */
	public AppStartDialog(Activity context) {
		super(context, R.style.appStartDialog_style);
	}
	
	/**
	 * 当Dialog程序启动之后会首先调用此方法。<br/>
	 * 在这个方法体里，你需要完成所有的基础配置<br/>
	 * 这个方法会传递一个保存了此Dialog上一状态信息的Bundle对象
	 * @param savedInstanceState 保存此Dialog上一次状态信息的Bundle对象 
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		LayoutInflater inflater = LayoutInflater.from(getContext());
		ViewGroup view = (ViewGroup)inflater.inflate(R.layout.start_screen, null);
		setContentView(view);
		DisplayMetrics dm = getContext().getResources().getDisplayMetrics();
		mBootSurfaceView = new SurfaceView(getContext());
		FrameLayout.LayoutParams surfaceLp = new FrameLayout.LayoutParams(dm.widthPixels, dm.heightPixels);
		mBootSurfaceView.setLayoutParams(surfaceLp);
		view.addView(mBootSurfaceView);

		mBootLoader = new BootLoader(mBootSurfaceView, "start_screen_anim.mp4", new BootLoader.BootListener() {
			@Override
			public void complete() {
				isBootFinish = true;
				if (Game.getInstance().isLuaInitDone()) {
					Game.getInstance().dismissStartDialog();
				}
			}
		});
	}
	
	/**
	 * 监听物理按键
	 * @return 相应返回键 返回true ; 否则返回 false
	 */
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)  {
	    if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
	        return true;
	    }
	    return super.onKeyDown(keyCode, event);
	}

	@Override
	public void dismiss() {
		super.dismiss();
		mBootLoader = null;
		mBootSurfaceView = null;
	}
}
