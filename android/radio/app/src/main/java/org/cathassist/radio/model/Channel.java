package org.cathassist.radio.model;

import java.io.Serializable;
import java.util.*;

public class Channel implements Serializable
{
	private String key = "";
	private String title = "";
	private String desc = "";
	private Date date;
	private String logo = "";
	private ArrayList<ChannelItem> items;

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

	public Date getDate()
	{
		return this.date;
	}
	public void setDate(Date date)
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

	public ArrayList<ChannelItem> getItems()
	{
		return this.items;
	}
	public void setItems(ArrayList<ChannelItem> items)
	{
		this.items = items;
	}
}