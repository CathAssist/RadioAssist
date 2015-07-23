package org.cathassist.radio.media;

import org.cathassist.radio.model.*;

public interface RadioEvents
{
	public void onRadioItemChanged(TrackItem item);
	public void onRadioPrepared(int max);
	public void onRadioStoped();
	public void onRadioPaused();
	
	public void onRadioBufferedUpdate(int progress);
	public void onRadioUpdateProgress(int progress);
}
