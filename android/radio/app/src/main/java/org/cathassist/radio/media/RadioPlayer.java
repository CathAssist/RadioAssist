package org.cathassist.radio.media;

import org.cathassist.radio.model.*;

import android.app.Service;
import android.content.Intent;
import android.media.*;
import android.media.MediaPlayer.OnBufferingUpdateListener;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.media.MediaPlayer.OnInfoListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.os.*;
import android.util.Log;
import org.cathassist.download.DownloadManager;

public class RadioPlayer extends Service implements OnBufferingUpdateListener, OnCompletionListener, OnPreparedListener, OnInfoListener, OnErrorListener
{
	private Channel channel = null;
	private MediaPlayer player = null;
	private TrackItem curItem = null;
	private RadioEvents radioEvents = null;
	private static RadioPlayer _self = new RadioPlayer();

    private Handler handler = new Handler();
	
	private Runnable runnableUpdateProgress = new Runnable()
	{
		public void run()
		{
			if(player.isPlaying())
			{
				radioEvents.onRadioUpdateProgress(player.getCurrentPosition());
			}
			handler.postDelayed(this,1000);
		}
	};
		
	public static RadioPlayer getRadioPlayer()
	{
		return _self;
	}
	
    
	private RadioPlayer()
	{
	}
	
	public void setChannel(Channel c)
	{
		if(c == channel)
			return;
		this.release();
		channel = c;
		if(channel.getItems().size()>0)
			curItem = channel.getItems().get(0);
		radioEvents.onRadioStoped();
	}
	
	public Channel getChannel()
	{
		return channel;
	}
	
	public TrackItem getCurItem()
	{
		return curItem;
	}
	
	public boolean isPlaying()
	{
		if(player!=null)
		{
			return player.isPlaying();
		}
		
		return false;
	}
	
	public int getDuration()
	{
		if(player!=null)
		{
			if(player.isPlaying())
			{
				return player.getDuration();
			}
		}
		
		return 0;
	}
	
	public int getCurrentPosition()
	{
		if(player!=null)
		{
			return player.getCurrentPosition();
		}
		return 0;
	}

	public void setRadioEventsListener(RadioEvents e)
	{
		radioEvents = e;
	}

	@Override
	public void onCreate()
	{
		super.onCreate();
	}
	
	@Override
	public IBinder onBind(Intent intent)
	{
		return null;
	}
	
	@Override
	public boolean onInfo(MediaPlayer mp, int what, int extra)
	{  //播放过程中的一些返回信息
		switch (what)
		{
		case MediaPlayer.MEDIA_INFO_BUFFERING_START:  //进入缓冲
			break;
		case MediaPlayer.MEDIA_INFO_BUFFERING_END:  //结束缓冲
			break;
		default:
			break;
		}
		return true;
	}

	@Override
	public boolean onError(MediaPlayer mp, int what, int extra)
	{
		//出错时候，会回调这里
		switch (what)
		{
		case MediaPlayer.MEDIA_ERROR_UNKNOWN :
			break;
		default:
			break;
		}
		return false;
	}

	@Override
	public void onCompletion(MediaPlayer mp)
	{
		//一首播放完毕，继续下手
		setPlayNext();
	}
	

	@Override
	public void onPrepared(MediaPlayer mp)
	{
		//初始化播放回调方法
		if(player != null)
		{
			radioEvents.onRadioPrepared(mp.getDuration());
			player.start();
		}
	}

	@Override
	public void onBufferingUpdate(MediaPlayer mp, int percent)
	{
		//获取缓冲进度
		radioEvents.onRadioBufferedUpdate(getDuration() * percent / 100);
	}
	
	private MediaPlayer createPlayer(String src)
	{
		MediaPlayer p = new MediaPlayer();
		
		p.setOnBufferingUpdateListener(this); //监听缓冲数据
		p.setOnPreparedListener(this);  //监听初始化
		p.setOnCompletionListener(this); //监听是否播放完了
		p.setOnErrorListener(this);   //监听出错信息
		p.setOnInfoListener(this);   //监听播放过程中，返回的信息
		
		try
		{
			p.reset();
			p.setDataSource(src);
			p.prepareAsync();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		
		handler.removeCallbacks(runnableUpdateProgress);
		handler.postDelayed(runnableUpdateProgress, 1000);
		
		return p;
	}
	
	private void releasePlayer(MediaPlayer p)
	{
		p.stop();
		p.release();
		handler.removeCallbacks(runnableUpdateProgress);
	}
	
	public void setPlayIndex(int i)
	{
		Log.d("Player", "index:"+i);
		if(channel!=null)
		{
			if(i>-1 && channel.getItems().size()>i)
			{
				curItem = channel.getItems().get(i);
				if(radioEvents!=null)
				{
					radioEvents.onRadioItemChanged(curItem);
				}
				
				setPlaySrc(curItem.getSrc());
				return;
			}
		}
		
		if(player==null || !player.isPlaying())
		{
			if(radioEvents!=null)
			{
				radioEvents.onRadioStoped();
			}
		}
	}
	
	private void setPlaySrc(String src)
	{
		src = DownloadManager.getCacheLocal(src);
		Log.d("Player", "src:"+src);
		if(player != null)
		{
			releasePlayer(player);
			player = null;
		}
		
		player = createPlayer(src);
	}
	
	public void setPlay()
	{
		try
		{
			if(player == null)
			{
				setPlayIndex(0);
			}
			else
			{
				player.start();
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	public void setPause()
	{
		if(player != null)
		{
			player.pause();
		}
	}
	
	public void setStop()
	{
		if(player != null)
		{
			player.stop();
			radioEvents.onRadioStoped();
		}
	}

	//播放上一首
	public void setPlayPrev()
	{
		int i = channel.getItems().indexOf(curItem) - 1;
		setPlayIndex(i);
	}
	
	//播放下一首
	public void setPlayNext()
	{
		int i = channel.getItems().indexOf(curItem) + 1;
		setPlayIndex(i);
	}
	
	//seekto
	public void setSeekTo(int msec)
	{
		Log.d("Player", "set seek to "+msec);
		if(player!=null)
		{
			player.seekTo(msec);
		}
	}
	
	
	public void release()
	{
		if(player != null)
		{
			releasePlayer(player);
			player = null;
		}
	}
	
}
