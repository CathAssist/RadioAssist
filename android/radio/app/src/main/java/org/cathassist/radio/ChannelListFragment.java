package org.cathassist.radio;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.FrameLayout;
import android.widget.ListView;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.future.FutureCallback;

import org.cathassist.download.DownloadManager;
import org.cathassist.radio.model.*;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Handler;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link ChannelListFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link ChannelListFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ChannelListFragment extends Fragment
        implements SwipeRefreshLayout.OnRefreshListener {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_SECTION_NUMBER = "section_number";
    private static final String CHANNEL_LIST_API = "http://www.cathassist.org/radio/getradio.php";

    private SwipeRefreshLayout mSRLayout;
    private ListView mListView;

    // TODO: Rename and change types of parameters
    private int mSectionNumber;

    private OnFragmentInteractionListener mListener;

    private ArrayList<Channel> channels;



    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param sectionNumber Section index.
     * @return A new instance of fragment ChannelListFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static ChannelListFragment newInstance(int sectionNumber) {
        ChannelListFragment fragment = new ChannelListFragment();
        Bundle args = new Bundle();
        args.putInt(ARG_SECTION_NUMBER, sectionNumber);
        fragment.setArguments(args);
        return fragment;
    }

    public ChannelListFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mSectionNumber = getArguments().getInt(ARG_SECTION_NUMBER);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View root = (View) inflater.inflate(
                R.layout.fragment_channel_list, container, false);

        //Change actionbar's title
        ActionBarActivity act = (ActionBarActivity)getActivity();
        if(act != null)
        {
            ActionBar bar = act.getSupportActionBar();
            if(bar != null)
            {
                bar.setTitle(R.string.app_name);
            }

        }



        mSRLayout = (SwipeRefreshLayout) root.findViewById(R.id.channel_list_srlayout);
        mListView = (ListView) root.findViewById(R.id.channel_list_listview);

        mSRLayout.setOnRefreshListener(this);
        mListView.setOnItemClickListener(
                new AdapterView.OnItemClickListener() {
                    @Override
                    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                        Channel channel = channels.get(position);

                        MainActivity.channelShowing = channel;
                        MainActivity mainAct = (MainActivity)getActivity();
//                        mainAct.onNavigationDrawerItemSelected(1);
                        mainAct.getmNavigationDrawerFragment().selectItem(1);
                    }
                }
        );

        return root;
    }

    @Override
    public void onActivityCreated(Bundle savedBundle) {
        super.onActivityCreated(savedBundle);

        mSRLayout.setRefreshing(true);

        Future<JsonObject> fJson = DownloadManager.
                getJsonObj(CHANNEL_LIST_API, true);
        fJson.setCallback(new FutureCallback<JsonObject>() {
            @Override
            public void onCompleted(Exception e, JsonObject result) {
                // do stuff with the result or error
                ArrayList<Channel> listChannels = new ArrayList<>();
                Gson gson = new GsonBuilder()
                        .setDateFormat("yyyy-MM-dd")
                        .create();

                Set<Map.Entry<String,JsonElement>> entrySet=result.entrySet();
                for(Map.Entry<String,JsonElement> entry:entrySet) {
                    Channel cc = gson.fromJson(entry.getValue(), Channel.class);
                    cc.setKey(entry.getKey());
                    listChannels.add(cc);
                }

                channels = listChannels;
                MainActivity.channelShowing = channels.get(0);
                mListView.setAdapter(new ChannelListAdapter(getActivity(), channels));

                try {
                    PrintWriter writer = new PrintWriter(DownloadManager.getCacheLocal(CHANNEL_LIST_API), "UTF-8");
                    writer.write(result.toString());
                    writer.close();
                }
                catch (Exception err)
                {
                    err.printStackTrace();
                }


                mSRLayout.setRefreshing(false);
            }
        });
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
    public void onRefresh(){

        Future<JsonObject> fJson = DownloadManager.
                getJsonObj("http://www.cathassist.org/radio/getradio.php", false);
        fJson.setCallback(new FutureCallback<JsonObject>() {
            @Override
            public void onCompleted(Exception e, JsonObject result) {
                // do stuff with the result or error
                ArrayList<Channel> listChannels = new ArrayList<>();
                Gson gson = new GsonBuilder()
                        .setDateFormat("yyyy-MM-dd")
                        .create();

                Set<Map.Entry<String, JsonElement>> entrySet = result.entrySet();
                for (Map.Entry<String, JsonElement> entry : entrySet) {
                    Channel cc = gson.fromJson(entry.getValue(), Channel.class);
                    cc.setKey(entry.getKey());
                    listChannels.add(cc);
                }

                channels = listChannels;
                mListView.setAdapter(new ChannelListAdapter(getActivity(), channels));

                try {
                    PrintWriter writer = new PrintWriter(DownloadManager.getCacheLocal(CHANNEL_LIST_API), "UTF-8");
                    writer.write(result.toString());
                    writer.close();
                }
                catch (Exception err)
                {
                    err.printStackTrace();
                }

                mSRLayout.setRefreshing(false);
            }
        });
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
