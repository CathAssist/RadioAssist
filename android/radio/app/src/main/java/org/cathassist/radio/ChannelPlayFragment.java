package org.cathassist.radio;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.*;
import android.view.View.OnClickListener;
import android.widget.*;

import org.cathassist.radio.model.Channel;

import java.text.SimpleDateFormat;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link ChannelPlayFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link ChannelPlayFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ChannelPlayFragment extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_CHANNEL_PLAY = "channel";
    private static final String ARG_SECTION_NUMBER = "section_number";

    // TODO: Rename and change types of parameters
    private Channel mChannel;
    private int mSectionNumber;


    private FrameLayout mainLayout = null;
    //定义标题栏上的按钮
    private ImageButton playlistBtn = null;
    //电台播放列表显示
    private ListView playlistView = null;

    //CD把手
    private PlayHandleView cdHandle = null;
    //播放、暂停按钮
    private ImageView playButton = null;
    private ImageView pauseButton = null;
    //旋转的ICON
    private PlayIconView iconButton = null;
    //上一首、下一首、当前歌曲名称
    private ImageView prevButton = null;
    private ImageView nextButton = null;
    private TextView musicText = null;

    //当前播放的时间、总时间、拖动条
    private TextView curTime = null;
    private TextView maxTime = null;
    private SeekBar seekProgress = null;

    //当前电台日期
    private TextView curDateText = null;

    private TextView downloadText = null;
    private TextView clearText = null;

    private OnFragmentInteractionListener mListener;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment ChannelPlayFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static ChannelPlayFragment newInstance(Channel channel, int sectionNumber) {
        ChannelPlayFragment fragment = new ChannelPlayFragment();
        Bundle args = new Bundle();
        args.putSerializable(ARG_CHANNEL_PLAY, channel);
        args.putInt(ARG_SECTION_NUMBER,sectionNumber);
        fragment.setArguments(args);
        return fragment;
    }

    public ChannelPlayFragment() {
        // Required empty public constructor
    }


    private void initPlayer()
    {
        //初始化播放器里的旋转icon
        iconButton = (PlayIconView)mainLayout.findViewById(R.id.imageView_icon);
        iconButton.initAnimate();
        //初始化播放器的handle
        cdHandle = (PlayHandleView)mainLayout.findViewById(R.id.imageView_handle);
        //初始化播放/暂停按钮
        playButton = (ImageView)mainLayout.findViewById(R.id.imageView_play);
        pauseButton = (ImageView)mainLayout.findViewById(R.id.imageView_pause);

        playButton.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {
            }
        });

        pauseButton.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {
            }
        });
        //初始化上一首、下一首、当前歌曲
        prevButton = (ImageView)mainLayout.findViewById(R.id.imageView_prev);
        nextButton = (ImageView)mainLayout.findViewById(R.id.imageView_next);
        musicText = (TextView)mainLayout.findViewById(R.id.textView_music);
        prevButton.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {
            }
        });
        nextButton.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {
            }
        });

        //初始化进度控制控件
        seekProgress = (SeekBar)mainLayout.findViewById(R.id.seekBar_progress);
        curTime = (TextView)mainLayout.findViewById(R.id.textView_current);
        maxTime = (TextView)mainLayout.findViewById(R.id.textView_max);
//        seekProgress.setOnSeekBarChangeListener(this);

        //日期选择
        //初始化上一日、下一日、当前日期
        curDateText = (TextView)mainLayout.findViewById(R.id.textView_day);
        TextView prevDay = (TextView)mainLayout.findViewById(R.id.textView_prev);
        TextView nextDay = (TextView)mainLayout.findViewById(R.id.textView_next);
        prevDay.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {
            }
        });
        nextDay.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {

            }
        });
        curDateText.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {

            }
        });

        /*
        //发送反馈、晨星与小助手的copyright
        TextView feedback = (TextView)mainLayout.findViewById(R.id.textView_feedback);
        TextView cxcopyright = (TextView)mainLayout.findViewById(R.id.textView_cxcopyright);
        TextView cacopyright = (TextView)mainLayout.findViewById(R.id.textView_cacopyright);

        feedback.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {
                feedbackAgent.startFeedbackActivity();
            }
        });

        cxcopyright.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {
                openUrlInBrowser("http://www.cxsm.org/bbs/");
            }
        });
        cacopyright.setOnClickListener(new OnClickListener(){
            @Override
            public void onClick(View v)
            {
                openUrlInBrowser("http://www.cathassist.org/3rd/aboutus.html");
            }
        });
        */
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mChannel = MainActivity.channelShowing;
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
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        mainLayout = (FrameLayout)inflater.inflate(
                R.layout.fragment_channel_play, container, false);

        //Change actionbar's title
        ActionBarActivity act = (ActionBarActivity)getActivity();
        if(act != null)
        {
            ActionBar bar = act.getSupportActionBar();
            if(bar != null)
            {
                bar.setTitle(mChannel.getTitle());
            }
        }

        initPlayer();

        return mainLayout;
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
            Toast.makeText(getActivity(), "Example tracklist.", Toast.LENGTH_SHORT).show();
            return true;
        }

        return super.onOptionsItemSelected(item);
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
        public void onFragmentInteraction(Uri uri);
    }

}
