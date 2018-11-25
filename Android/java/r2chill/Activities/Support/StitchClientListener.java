package example.r2chill.Activities;

import com.mongodb.stitch.android.StitchClient;

// Interface that Activities should inherit when they need a StitchClient
public interface StitchClientListener {
    int REFRESH_INTERVAL = 180000;

    // Method that will be called once in an Activity's lifetime with an initialized StitchClient
    void onReady(StitchClient stitchClient);
}
