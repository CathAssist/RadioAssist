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

public class DownloadManager {
    private static Context appContext = null;
    private static String strCacheDir = "";
    private static String strFileDir = "";

    public static void initSelf(Context context)
    {
        if(appContext != null)
            return;

        appContext = context;
        strCacheDir = appContext.getCacheDir().getAbsolutePath() + "/";
        strFileDir = appContext.getFilesDir().getAbsolutePath() + "/";
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


}
