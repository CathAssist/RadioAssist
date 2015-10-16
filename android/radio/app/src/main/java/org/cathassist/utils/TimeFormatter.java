package org.cathassist.utils;

import java.text.DecimalFormat;

/**
 * Created by jinpengfei on 15-9-29.
 */
public class TimeFormatter {
    public static DecimalFormat getTimeFormat() {
        return new DecimalFormat("00");
    }

    public static String getMMSSTime(long millisTime) {
        int sTime = (int) (millisTime / 1000);
        int seconds = sTime % 60;
        int minutes = sTime / 60;
        return getTimeFormat().format(minutes) + ":" + getTimeFormat().format(seconds);
    }
}
