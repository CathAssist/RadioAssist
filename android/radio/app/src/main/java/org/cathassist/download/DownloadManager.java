package org.cathassist.download;


/**
 * Created by LiYake on 15/6/21.
 */

import android.content.Context;

import com.koushikdutta.async.future.Future;
import com.koushikdutta.async.future.FutureCallback;
import com.koushikdutta.ion.*;

import com.google.gson.JsonObject;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.security.NoSuchAlgorithmException;
import java.util.Map;

import android.graphics.Path;
import android.os.Environment;
import org.cathassist.utils.*;

public class DownloadManager {
    private static Context appContext = null;
    private static String strCacheDir = "";
    private static String strFileDir = "";
    private static String strRadioDir = "";
    private static Map<String,DownladProgressCallback> mapDownloading;


    public static void initSelf(Context context)
    {
        if(appContext != null)
            return;

        appContext = context;


        if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())
                || !Environment.isExternalStorageRemovable()) {
            strCacheDir = context.getExternalCacheDir().getAbsolutePath() + "/";
            strFileDir = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS) + "/";
            strRadioDir = context.getExternalFilesDir(Environment.DIRECTORY_PODCASTS) + "/";
        } else {
            strCacheDir = appContext.getCacheDir().getAbsolutePath() + "/";
            strFileDir = appContext.getFilesDir().getAbsolutePath() + "/Files/";
            strRadioDir = appContext.getFilesDir().getAbsolutePath() + "/Radio/";

            Common.createDirIfNotExists(strCacheDir);
            Common.createDirIfNotExists(strFileDir);
            Common.createDirIfNotExists(strRadioDir);
        }
    }

    public static String getHashStr(String str)
    {
        String strHash = str;
        try
        {
            java.security.MessageDigest md5 = java.security.MessageDigest.getInstance("MD5");
            md5.update(str.getBytes());
            byte[] m = md5.digest();//加密
            StringBuffer sb = new StringBuffer();
            {
                for(int j = 0; j < m.length; j++)
                {
                    sb.append(Integer.toHexString((0x000000ff & m[j]) | 0xffffff00).substring(6));
                }
            }
            strHash = sb.toString();
        }
        catch (NoSuchAlgorithmException e)
        {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return strHash;
    }

    public static String getCacheLocal(String url)
    {
        return strCacheDir+getHashStr(url);
    }

    public static Future<JsonObject> getJsonObj(String url,boolean uselocal)
    {
        String strRemote = url;

        if(uselocal)
        {
            String strLocal = getCacheLocal(url);
            File fLocal = new File(strLocal);
            if(fLocal.exists())
            {
                strRemote = strLocal;
            }
        }

        return Ion.with(appContext)
                .load(strRemote)
                .asJsonObject();
    }

    public static String getRadioCached(String url)
    {
        String strCached = strRadioDir + getHashStr(url);
        if(Common.isFileExists(strCached))
            return strCached;

        return url;
    }

    public static ProgressCallback DownloadRadio(final String url) {
        if (mapDownloading.containsKey(url))
            return mapDownloading.get(url);

        String strCached = getCacheLocal(url);

        DownladProgressCallback callback = new DownladProgressCallback();

        mapDownloading.put(url, callback);

        Ion.with(appContext)
                .load(url)
// can also use a custom callback
                .progress(callback)
                .write(new File(strCached))
                .setCallback(new FutureCallback<File>() {
                    @Override
                    public void onCompleted(Exception e, File file) {
                        // download done...
                        // do stuff with the File or error
                        file.renameTo(new File(strRadioDir + getHashStr(url)));
                        mapDownloading.remove(url);
                    }
                });

        return callback;
    }

    static public class DownladProgressCallback implements ProgressCallback
    {
        private long downloaded;
        private long total;

        public long getDownloaded()
        {
            return downloaded;
        }

        public long getTotal()
        {
            return total;
        }

        public double getDownloadedPecent()
        {
            return (downloaded*100.0)/total;
        }

        @Override
        public void onProgress(long downloaded, long total)
        {
            this.downloaded = downloaded;
            this.total = total;
        }
    }
}
