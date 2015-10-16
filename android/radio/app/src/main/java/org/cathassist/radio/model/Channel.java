package org.cathassist.radio.model;

import java.io.Serializable;
import java.util.*;

public class Channel implements Serializable
{
	private String key = "";
	private String title = "";
	private String desc = "";
	private String date;
	private String logo = "";
	private ArrayList<TrackItem> items;

	public String getKey()
	{
		return this.key;
	}
	public void setKey(String key)
	{
		this.key = key;
	}

	public String getTitle()
	{
		return this.title;
	}
	public void setTitle(String title)
	{
		this.title = title;
	}

	public String getDesc()
	{
		return this.desc;
	}
	public void setDesc(String desc)
	{
		this.desc = desc;
	}

	public String getDate()
	{
		return this.date;
	}
	public void setDate(String date)
	{
		this.date = date;
	}

	public String getLogo()
	{
		return  this.logo;
	}
	public void setLogo(String logo)
	{
		this.logo = logo;
	}

	public ArrayList<TrackItem> getItems()
	{
		return this.items;
	}
	public void setItems(ArrayList<TrackItem> items)
	{
		this.items = items;
	}
}
