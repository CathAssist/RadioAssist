
package org.cathassist.download;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.ConnectTimeoutException;

import android.accounts.NetworkErrorException;
import android.net.http.AndroidHttpClient;
import android.os.AsyncTask;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.MalformedURLException;
import java.net.URL;

public class DownloadTask extends AsyncTask<Void, Integer, Long> {

    public final static int TIME_OUT = 30000;
    private final static int BUFFER_SIZE = 1024 * 8;

    private static final String TAG = "DownloadTask";
    private static final boolean DEBUG = true;
    private static final String TEMP_SUFFIX = ".download";

    private URL URL;
    private File file;
    private File tempFile;
    private String url;
    private RandomAccessFile outputStream;
    private DownloadTaskListener listener;

    private long downloadSize;
    private long previousFileSize;
    private long totalSize;
    private long downloadPercent;
    private long networkSpeed;
    private long previousTime;
    private long totalTime;
    private Throwable error = null;
    private boolean interrupt = false;

    private final class ProgressReportingRandomAccessFile extends RandomAccessFile {
        private int progress = 0;

        public ProgressReportingRandomAccessFile(File file, String mode)
                throws FileNotFoundException {

            super(file, mode);
        }

        @Override
        public void write(byte[] buffer, int offset, int count) throws IOException
        {
            if(interrupt)
            {
                throw new IOException("Write Error, Interrupted!");
            }
            
            super.write(buffer, offset, count);
            progress += count;
            publishProgress(progress);
        }
    }

    public DownloadTask(String url, String path, String fileName) throws MalformedURLException
    {
        this(url, path, fileName, null);
    }

    public DownloadTask(String url, String path, String fileName, DownloadTaskListener listener)
            throws MalformedURLException {

        super();
        this.url = url;
        this.URL = new URL(url);
        this.listener = listener;

        if(fileName=="")
        {
        	fileName = new File(URL.getFile()).getName();
        }
        
        this.file = new File(path, fileName);
        this.tempFile = new File(path, fileName + TEMP_SUFFIX);
    }

    public String getUrl() {

        return url;
    }

    public boolean isInterrupt() {

        return interrupt;
    }
    
    public boolean setCancel()
    {
    	interrupt = true;
    	return super.cancel(true);
    }

    public long getDownloadPercent() {

        return downloadPercent;
    }

    public long getDownloadSize() {

        return downloadSize + previousFileSize;
    }

    public long getTotalSize() {

        return totalSize;
    }

    public long getDownloadSpeed() {

        return this.networkSpeed;
    }

    public long getTotalTime() {

        return this.totalTime;
    }

    public DownloadTaskListener getListener() {

        return this.listener;
    }

    @Override
    protected void onPreExecute() {

        previousTime = System.currentTimeMillis();
        if (listener != null)
            listener.preDownload(this);
    }

    @Override
    protected Long doInBackground(Void... params) {

        long result = -1;
        try {
            result = download();
        } catch (NetworkErrorException e) {
            error = e;
        } catch (IOException e) {
            error = e;
        } finally {
            if (client != null) {
                client.close();
            }
        }

        return result;
    }

    @Override
    protected void onProgressUpdate(Integer... progress) {

        if (progress.length > 1) {
            totalSize = progress[1];
            if (totalSize == -1) {
                if (listener != null)
                    listener.errorDownload(this, error);
            } else {

            }
        } else {
            totalTime = System.currentTimeMillis() - previousTime;
            downloadSize = progress[0];
            downloadPercent = (downloadSize + previousFileSize) * 100 / totalSize;
            networkSpeed = downloadSize / totalTime;
            if (listener != null)
                listener.updateProcess(this);
        }
    }

    @Override
    protected void onPostExecute(Long result) {

        if (result == -1 || interrupt || error != null) {
            if (DEBUG && error != null) {
                Log.v(TAG, "Download failed." + error.getMessage());
            }
            if (listener != null) {
                listener.errorDownload(this, error);
            }
            return;
        }
        // finish download
        tempFile.renameTo(file);
        if (listener != null)
            listener.finishDownload(this);
    }

    @Override
    public void onCancelled() {

        super.onCancelled();
        interrupt = true;
    }

    private AndroidHttpClient client;
    private HttpGet httpGet;
    private HttpResponse response;

    private long download() throws NetworkErrorException, IOException
    {
        /*
         * check file length
         */
        client = AndroidHttpClient.newInstance("Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) CxRadioForAndroid/1.0");
        httpGet = new HttpGet(url);
        response = client.execute(httpGet);
        totalSize = response.getEntity().getContentLength();
        
        Log.d(TAG, "totalSize: " + totalSize);
        if(totalSize==-1)
        {
            throw new IOException("Download Error, TotalSize:"+ totalSize);
        }
        
        if (file.exists() && totalSize == file.length())
        {
        	if (DEBUG)
        	{
        		Log.v(null, "Output file already exists. Skipping download.");
            }
        }
        else if (tempFile.exists())
        {
        	httpGet.addHeader("Range", "bytes=" + tempFile.length() + "-");
        	previousFileSize = tempFile.length();
        	
            client.close();
            client = AndroidHttpClient.newInstance("DownloadTask");
            response = client.execute(httpGet);

            if (DEBUG) {
                Log.v(TAG, "File is not complete, download now.");
                Log.v(TAG, "File length:" + tempFile.length() + " totalSize:" + totalSize);
            }
        }

        /*
         * start download
         */
        outputStream = new ProgressReportingRandomAccessFile(tempFile, "rw");

        publishProgress(0, (int) totalSize);

        InputStream input = response.getEntity().getContent();
        int bytesCopied = copy(input, outputStream);

        if ((previousFileSize + bytesCopied) != totalSize && totalSize != -1 && !interrupt) {
            throw new IOException("Download incomplete: " + bytesCopied + " != " + totalSize);
        }

        if (DEBUG) {
            Log.v(TAG, "Download completed successfully.");
        }

        return bytesCopied;

    }

    public int copy(InputStream input, RandomAccessFile out) throws IOException,
            NetworkErrorException {

        if (input == null || out == null) {
            return -1;
        }

        byte[] buffer = new byte[BUFFER_SIZE];

        BufferedInputStream in = new BufferedInputStream(input, BUFFER_SIZE);
        if (DEBUG) {
            Log.v(TAG, "length" + out.length());
        }

        int count = 0, n = 0;
        long errorBlockTimePreviousTime = -1, expireTime = 0;

        try {

            out.seek(out.length());

            while (!interrupt) {
                n = in.read(buffer, 0, BUFFER_SIZE);
                if (n == -1) {
                    break;
                }
                out.write(buffer, 0, n);
                count += n;

                if (networkSpeed == 0) {
                    if (errorBlockTimePreviousTime > 0) {
                        expireTime = System.currentTimeMillis() - errorBlockTimePreviousTime;
                        if (expireTime > TIME_OUT) {
                            throw new ConnectTimeoutException("connection time out.");
                        }
                    } else {
                        errorBlockTimePreviousTime = System.currentTimeMillis();
                    }
                } else {
                    expireTime = 0;
                    errorBlockTimePreviousTime = -1;
                }
            }
        } finally {
            client.close(); // must close client first
            client = null;
            out.close();
            in.close();
            input.close();
        }
        return count;

    }

}
