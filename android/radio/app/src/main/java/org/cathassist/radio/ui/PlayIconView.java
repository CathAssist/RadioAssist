package org.cathassist.radio.ui;

import org.cathassist.radio.R;

import android.content.Context;
import android.util.AttributeSet;
import android.view.animation.*;
import android.widget.*;

public class PlayIconView extends ImageView
{
	Animation animIcon;
	long animOffset = 0;
	public PlayIconView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}

	public PlayIconView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public PlayIconView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}
	
	public void initAnimate()
	{
		animIcon = AnimationUtils.loadAnimation(this.getContext(), R.anim.playicon);
        LinearInterpolator lin = new LinearInterpolator(); // 设置旋转速度 此处设置为匀速旋转
        animIcon.setInterpolator(lin);//将旋转速度配置给动画。
		animIcon.setFillAfter(true);
	}
	
	public void setStart()
	{
        this.startAnimation(animIcon);
//		animIcon.setStartOffset(animOffset);
	}
	
	public void setPause()
	{
		animOffset = animIcon.getStartOffset();
		this.clearAnimation();
	}

}