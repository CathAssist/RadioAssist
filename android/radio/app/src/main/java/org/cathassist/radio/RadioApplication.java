package org.cathassist.radio;

import android.app.Application;

import org.cathassist.download.DownloadManager;

/**
 * Created by LiYake on 15/6/21.
 */
public class RadioApplication extends Application {

    @Override
    public void onCreate()
    {
        super.onCreate();

        DownloadManager.initSelf(this.getApplicationContext());
    }
}
