package org.cathassist.radio.ui;

import android.content.Context;
import android.util.AttributeSet;
import android.view.animation.*;
import android.widget.*;

public class PlayHandleView extends ImageView
{
	RotateAnimation animIcon = null;
	public PlayHandleView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}

	public PlayHandleView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public PlayHandleView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}
	
	@Override
	public void setImageResource(int resId)
	{
		super.setImageResource(resId);
	}
	
	public void setOff(int duration)
	{
		animIcon = new RotateAnimation(0,-20,getWidth(),0f);
		animIcon.setDuration(duration);
		animIcon.setFillAfter(true);
        this.startAnimation(animIcon);
	}
	
	public void setOn(int duration)
	{
		animIcon = new RotateAnimation(-20,0,getWidth(),0f);
		animIcon.setDuration(duration);
		animIcon.setFillAfter(true);
        this.startAnimation(animIcon);
	}
}