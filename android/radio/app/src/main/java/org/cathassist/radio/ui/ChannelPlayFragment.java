package org.cathassist.radio.ui;

import android.app.Activity;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.view.*;
import android.view.View.OnClickListener;
import android.widget.*;

import org.cathassist.radio.R;
import org.cathassist.radio.model.Channel;
import org.cathassist.radio.model.TrackItem;
import org.cathassist.utils.TimeFormatter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link ChannelPlayFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link ChannelPlayFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ChannelPlayFragment extends Fragment implements TracksFragmentCallbacks {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_CHANNEL_PLAY = "channel";
    private static final String ARG_SECTION_NUMBER = "section_number";

    // TODO: Rename and change types of parameters
    private Channel mChannel;
    private int mSectionNumber;

    private TracksFragment mTracksFragment;

    //定义标题栏上的按钮
    private ImageButton playlistBtn;
    //电台播放列表显示
    private ListView playlistView;

    //CD把手
    private PlayHandleView cdHandle;
    //播放、暂停按钮
    private ImageView playButton;
    private ImageView pauseButton;
    //旋转的ICON
    private PlayIconView iconButton;
    //上一首、下一首、当前歌曲名称
    private ImageView prevButton;
    private ImageView nextButton;
    private TextView musicText;

    //当前播放的时间、总时间、拖动条
    private TextView curTime;
    private TextView maxTime;
    private SeekBar seekProgress;

    //当前电台日期
    private TextView curDateText;

    private TextView downloadText;
    private TextView clearText;

    private OnFragmentInteractionListener mListener;

    private MediaPlayer mMediaPlayer;

    private Timer mTimer;
    private TimerTask mTimerTask;
    private boolean isChanging = false;

    private int mCurrentPosition;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param channel       Parameter 1.
     * @param sectionNumber Parameter 2.
     * @return A new instance of fragment ChannelPlayFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static ChannelPlayFragment newInstance(Channel channel, int sectionNumber) {
        ChannelPlayFragment fragment = new ChannelPlayFragment();
        Bundle args = new Bundle();
        args.putSerializable(ARG_CHANNEL_PLAY, channel);
        args.putInt(ARG_SECTION_NUMBER, sectionNumber);
        fragment.setArguments(args);
        return fragment;
    }

    public ChannelPlayFragment() {
        // Required empty public constructor
    }


    private void initView(View layout) {
        //初始化播放器里的旋转icon
        iconButton = (PlayIconView) layout.findViewById(R.id.imageView_icon);
        iconButton.initAnimate();
        //初始化播放器的handle
        cdHandle = (PlayHandleView) layout.findViewById(R.id.imageView_handle);
        //初始化播放/暂停按钮
        playButton = (ImageView) layout.findViewById(R.id.imageView_play);
        pauseButton = (ImageView) layout.findViewById(R.id.imageView_pause);

        playButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mMediaPlayer.start();
                playButton.setVisibility(View.GONE);
                pauseButton.setVisibility(View.VISIBLE);
                iconButton.setStart();
                cdHandle.setOn(1000);
            }
        });

        pauseButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mMediaPlayer.pause();
                pauseButton.setVisibility(View.GONE);
                playButton.setVisibility(View.VISIBLE);
                iconButton.setPause();
                cdHandle.setOff(1000);
            }
        });
        //初始化上一首、下一首、当前歌曲
        prevButton = (ImageView) layout.findViewById(R.id.imageView_prev);
        nextButton = (ImageView) layout.findViewById(R.id.imageView_next);
        musicText = (TextView) layout.findViewById(R.id.textView_music);
        prevButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ArrayList<TrackItem> list = mChannel.getItems();
                if (mCurrentPosition - 1 >= 0) {
                    mCurrentPosition--;
                    TrackItem trackItem = list.get(mCurrentPosition);
                    musicText.setText(trackItem.getTitle());
                    mMediaPlayer.reset();
                    try {
                        mMediaPlayer.setDataSource(trackItem.getSrc());
                        mMediaPlayer.prepare();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    initSeekbar();
                    mMediaPlayer.start();
                }
            }
        });
        nextButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ArrayList<TrackItem> list = mChannel.getItems();
                if (mCurrentPosition + 1 < list.size() - 1) {
                    mTimer.cancel();

                    mCurrentPosition++;
                    TrackItem trackItem = list.get(mCurrentPosition);
                    musicText.setText(trackItem.getTitle());
                    mMediaPlayer.reset();
                    try {
                        mMediaPlayer.setDataSource(trackItem.getSrc());
                        mMediaPlayer.prepare();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    initSeekbar();
                    mMediaPlayer.start();
                }
            }
        });

        //初始化进度控制控件
        seekProgress = (SeekBar) layout.findViewById(R.id.seekBar_progress);
        curTime = (TextView) layout.findViewById(R.id.textView_current);
        maxTime = (TextView) layout.findViewById(R.id.textView_max);
        seekProgress.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                isChanging = true;
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mMediaPlayer.seekTo(seekBar.getProgress() * 1000);
                isChanging = false;
            }
        });

        //日期选择
        //初始化上一日、下一日、当前日期
        curDateText = (TextView) layout.findViewById(R.id.textView_day);
        TextView prevDay = (TextView) layout.findViewById(R.id.textView_prev);
        TextView nextDay = (TextView) layout.findViewById(R.id.textView_next);
        prevDay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
            }
        });
        nextDay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
        curDateText.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });


        //init data
        musicText.setText(mChannel.getDesc());

        initPlayer();
    }

    private void initPlayer() {
        mMediaPlayer = new MediaPlayer();
        try {
            mMediaPlayer.setDataSource(mChannel.getItems().get(0).getSrc());
            mMediaPlayer.prepare();
        } catch (IOException e) {
            e.printStackTrace();
        }
        initSeekbar();
        mTimer = new Timer();
        mTimerTask = new TimerTask() {
            @Override
            public void run() {
                if (isChanging) {
                    return;
                }
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        seekProgress.setProgress(mMediaPlayer.getCurrentPosition() / 1000);
                        curTime.setText(TimeFormatter.getMMSSTime(mMediaPlayer.getCurrentPosition()));
                    }
                });
            }
        };
        mTimer.schedule(mTimerTask, 0, 100);
        mMediaPlayer.start();
    }

    private void initSeekbar() {
        seekProgress.setMax(mMediaPlayer.getDuration() / 1000);
        maxTime.setText(TimeFormatter.getMMSSTime(mMediaPlayer.getDuration()));
        seekProgress.setProgress(0);
        curDateText.setText(mChannel.getDate().toString());
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mTracksFragment = ((MainActivity) getActivity()).getmTracksFragment();
        mTracksFragment.setLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
        mTracksFragment.setTracksFragmentCallbacks(this);

        if (getArguments() != null) {
            mChannel = MainActivity.getMainActivity().getChannelShowing();
            mSectionNumber = getArguments().getInt(ARG_SECTION_NUMBER);
        }
    }


    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        // Indicate that this fragment would like to influence the set of actions in the action bar.
        setHasOptionsMenu(true);
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = (FrameLayout) inflater.inflate(
                R.layout.fragment_channel_play, container, false);

        //Change actionbar's title
        AppCompatActivity act = (AppCompatActivity) getActivity();
        if (act != null) {
            ActionBar bar = act.getSupportActionBar();
            if (bar != null) {
                bar.setTitle(mChannel.getTitle());
            }
        }

        initView(view);

        return view;
    }

    // TODO: Rename method, update argument and hook method into UI event
    public void onButtonPressed(Uri uri) {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        ((MainActivity) activity).onSectionAttached(mSectionNumber);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
        mTimer.cancel();
        mTimerTask.cancel();
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        // If the drawer is open, show the global app actions in the action bar. See also
        // showGlobalContextActionBar, which controls the top-left area of the action bar.
        inflater.inflate(R.menu.channel, menu);
        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_tracklist) {
            if (mTracksFragment.isDrawerOpen()) {
                mTracksFragment.closeDrawer();
            } else {
                mTracksFragment.openDrawer();
            }
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onTracksFragmentItemClicked(TrackItem item) {
        musicText.setText(item.getTitle());
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p/>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        void onFragmentInteraction(Uri uri);
    }
}
