package org.cathassist.radio.model;

import java.io.Serializable;

/**
 * Created by LiYake on 15/6/21.
 */

public class TrackItem implements Serializable
{
    private String title = "";
    private String src = "";
    private String singer = "";

    public String getTitle()
    {
        return title;
    }
    public void setTitle(String title)
    {
        this.title = title;
    }

    public String getSrc()
    {
        return src;
    }
    public void setSrc(String src)
    {
        this.src = src;
    }

    public String getSinger()
    {
        return singer;
    }
    public void setSinger(String singer)
    {
        this.singer = singer;
    }

    @Override
    public String toString()
    {
        return title;
    }
}