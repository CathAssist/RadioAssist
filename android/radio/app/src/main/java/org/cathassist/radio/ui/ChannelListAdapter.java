package org.cathassist.radio.ui;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import org.cathassist.image.SmartImage;
import org.cathassist.image.SmartImageView;
import org.cathassist.radio.R;
import org.cathassist.radio.model.Channel;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by LiYake on 15/6/21.
 */
public class ChannelListAdapter extends BaseAdapter {
    private Activity context;
    private ArrayList<Channel> channels;

    public ChannelListAdapter(Activity context, ArrayList<Channel> channels)
    {
        this.context = context;
        this.channels = channels;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = context.getLayoutInflater();
        View itemView = inflater.inflate(R.layout.channel_list_item, null);
        Channel channel = channels.get(position);
        SmartImageView imageView = (SmartImageView) itemView
                .findViewById(R.id.channel_list_item_logo);
        TextView titleView = (TextView) itemView.findViewById(R.id.channel_list_item_title);
        TextView descView = (TextView) itemView.findViewById(R.id.channel_list_item_desc);

        imageView.setImageUrl(channel.getLogo());
        titleView.setText(channel.getTitle());
        descView.setText(channel.getDesc());

        return itemView;
    }

    @Override
    public int getCount() {
        return channels.size();
    }

    @Override
    public Object getItem(int position) {
        return channels.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }
}
