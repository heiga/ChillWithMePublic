package example.r2chill.Activities;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.job.JobInfo;
import android.app.job.JobParameters;
import android.app.job.JobScheduler;
import android.app.job.JobService;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.mongodb.stitch.android.StitchClient;

import com.mongodb.stitch.android.StitchClient;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import example.r2chill.Model.AccountController;
import example.r2chill.Model.Friend;
import example.r2chill.Model.FriendGroup;
import example.r2chill.Model.UserProfile;
import example.r2chill.R;

public class NotificationService extends JobService implements StitchClientListener {
    private String CHANNEL_ID = "default";
    private StitchClient _client;
    private AccountController accountController;
    private UserProfile userProfile;

    public void onReady(StitchClient stitchClient) {
        this._client = stitchClient;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        accountController = AccountController.getInstance(this);
        accountController.registerListener(this);

        createNotificationChannel();
    }


    @Override
    public boolean onStartJob(JobParameters params) {
        notificationHandler.sendMessage(Message.obtain(notificationHandler, 1, params));

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            scheduleRefresh();
        }

        return false;
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        notificationHandler.removeMessages(1);
        return false;
    }

    private void scheduleRefresh() {
        JobScheduler mJobScheduler = (JobScheduler) getApplicationContext().getSystemService(JOB_SCHEDULER_SERVICE);
        JobInfo.Builder mJobBuilder = new JobInfo.Builder(1, new ComponentName(getPackageName(),
                NotificationService.class.getName()))
                .setMinimumLatency(REFRESH_INTERVAL)
                .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY);
        mJobScheduler.schedule(mJobBuilder.build());
    }

    private Handler notificationHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message msg) {
            try {
                if (accountController.checkInternetConnection(getApplicationContext())) {
                    userProfile = accountController.getUserProfile();
                    if (userProfile != null) {
                        if (userProfile.hasGroupsWithNotificationsOn()) {
                            checkProfile();
                        } else {
                            return true;
                        }
                    } else {
                        return true;
                    }
                } else {
                    return true;
                }
            } catch (Exception e) {
                jobFinished((JobParameters) msg.obj, false);
            }
            return true;
        }
    });

    private void checkProfile() {
        Context appContext = getApplicationContext();
        if (accountController.isProfileOnFile(appContext)) {
            if (accountController.loadProfileToAccountController(appContext).equals("Profile loaded successfully")) {
               userProfile = accountController.getUserProfile();
               if (_client == null) {
                   return;
               }
               _client.executeFunction("checkIfProfileUpdated", userProfile.getRefreshToken()).addOnCompleteListener(
                       new OnCompleteListener<Object>() {
                           @Override
                           public void onComplete(@NonNull Task<Object> task) {
                               if (task.isSuccessful()) {
                                   String converted = accountController.jsonToString(task.getResult()).replace("\"", "");
                                   if (converted.equals("true")) {
                                        getProfileFromDB();
                                   } else {
                                       return;
                                   }
                               } else {
                                   return;
                               }
                           }
                       }
               );
            }
        }
    }

    private void getProfileFromDB() {
        if (_client == null) {
            return;
        }
        _client.executeFunction("getProfile").addOnCompleteListener(new OnCompleteListener<Object>() {
            @Override
            public void onComplete(@NonNull Task<Object> task) {
                if (task.isSuccessful()) {
                    UserProfile oldProfile = accountController.getUserProfile();
                    userProfile = accountController.bsonToUserProfile(task.getResult(),
                            getApplicationContext());
                    if (userProfile == null) {
                        return;
                    } else {
                        calculateAndSendNotification(oldProfile, userProfile);
                    }
                } else {
                    return;
                }
            }
        });
    }

    private void calculateAndSendNotification(UserProfile oldProfile, UserProfile newProfile) {
        // get hashmap of every ready friend in new profile
        HashMap<String, String> readyFriendsMap = new HashMap<>();
        for (Friend friend : newProfile.getCompleteFriendList().getFriendArrayList()) {
            if (friend.isR2C()) {
                readyFriendsMap.put(friend.getOwnerUsername(), friend.getCurrentStatus().getRefreshToken());
            }
        }

        // go through old profile and remove friends from the hashmap that haven't updated since last check
        for (Friend friend : oldProfile.getCompleteFriendList().getFriendArrayList()) {
            if (readyFriendsMap.containsKey(friend.getOwnerUsername())) {
                if (friend.getCurrentStatus().getRefreshToken().equals(readyFriendsMap.get(friend.getOwnerUsername()))) {
                    readyFriendsMap.remove(friend.getOwnerUsername());
                }
            }
        }

        HashMap<String, Integer> messageHashMap = new HashMap<>();
        // hashmap now only contains updated friends
        // go through every friendgroup with notifications on and count number
        // of friends ready -> add this to a new hashsmap
        for (FriendGroup group : newProfile.getListOfFriendGroups()) {
            if (group.isNotificationsOn()) {
                Integer number = 0;
                for (Friend friend : group.getFriendArrayList()) {
                    if (readyFriendsMap.containsKey(friend.getOwnerUsername())) {
                        number += 1;
                    }
                }
                if (number > 0) {
                    messageHashMap.put(group.getFriendListName(), number);
                }
            }
        }

        int numberOfGroupsReady = messageHashMap.entrySet().size();
        String message;
        if (numberOfGroupsReady == 1) {
            for (Map.Entry<String, Integer> entry : messageHashMap.entrySet()) {
                String friendOrFriends;
                if (entry.getValue() == 1) {
                    friendOrFriends = getResources().getString(R.string.friend_in);
                } else {
                    friendOrFriends = getResources().getString(R.string.friends_in);
                }
                message = getResources().getString(R.string.you_have) + " " + Integer.toString(entry.getValue()) +
                        " " + friendOrFriends + " " +
                        entry.getKey() + " " + getResources().getString(R.string.available);
                sendNotification(message);
            }
        } else if (numberOfGroupsReady == 2) {
            boolean addAnd = false;
            message = getResources().getString(R.string.you_have) + " " + getResources().getString(R.string.friends_in) + " ";
            for (Map.Entry<String, Integer> entry : messageHashMap.entrySet()) {
                if (addAnd) {
                    message += "and ";
                } else {
                    addAnd = true;
                }
                message += entry.getKey() + " ";
            }
            message += getResources().getString(R.string.available);
            sendNotification(message);
        } else if (numberOfGroupsReady > 2) {
            boolean addAnd = false;
            int count = 0;
            message = getResources().getString(R.string.you_have) + " " + getResources().getString(R.string.friends_in) + " ";
            for (Map.Entry<String, Integer> entry : messageHashMap.entrySet()) {
                if (addAnd) {
                    message += ", ";
                } else {
                    addAnd = true;
                }
                if (count == 2) {
                    break;
                }
                message += entry.getKey();
                count ++;
            }
            int remainder = numberOfGroupsReady - 2;
            if (remainder == 1) {
                message += getResources().getString(R.string.and_one_other_group) + " " +
                        getResources().getString(R.string.available);
            } else {
                message += getResources().getString(R.string.and) + " " + Integer.toString(remainder)
                        + " " + getResources().getString(R.string.other_groups) + " " +
                        getResources().getString(R.string.available);
            }
            sendNotification(message);
        }
    }

    private void sendNotification(String notification) {
        Intent intent = new Intent(this, StartupSplashActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.notification)
                .setContentTitle(getResources().getString(R.string.notification_title))
                .setContentText(notification)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setCategory(NotificationCompat.CATEGORY_MESSAGE)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true);

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
        notificationManager.notify(69, mBuilder.build());
    }

    private void createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = getString(R.string.channel_name);
            String description = getString(R.string.channel_description);
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);

            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

}
