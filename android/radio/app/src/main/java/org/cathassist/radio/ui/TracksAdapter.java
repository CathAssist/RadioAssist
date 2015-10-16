package org.cathassist.radio.ui;

import android.app.Activity;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import org.cathassist.download.DownloadManager;
import org.cathassist.image.SmartImageView;
import org.cathassist.radio.R;
import org.cathassist.radio.model.Channel;
import org.cathassist.radio.model.TrackItem;

import java.util.ArrayList;

/**
 * Created by LiYake on 15/7/26.
 */
public class TracksAdapter extends BaseAdapter {
    private Activity context;
    private ArrayList<TrackItem> tracks;

    public TracksAdapter(Activity context, ArrayList<TrackItem> tracks) {
        this.context = context;
        this.tracks = tracks;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = context.getLayoutInflater();
        View itemView = inflater.inflate(R.layout.track_list_item, null);
        TrackItem track = tracks.get(position);

        TextView titleView = (TextView) itemView.findViewById(R.id.track_item_title);
        TextView descView = (TextView) itemView.findViewById(R.id.track_item_percent);

        titleView.setText(track.getTitle());

        if (TextUtils.equals(DownloadManager.getRadioCached(track.getSrc()), "")) {
            descView.setText(R.string.text_undownloaded);
        } else {
            descView.setText(R.string.text_downloaded);
        }


        return itemView;
    }

    @Override
    public int getCount() {
        return tracks.size();
    }

    @Override
    public Object getItem(int position) {
        return tracks.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }
}
