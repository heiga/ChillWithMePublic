package example.r2chill.Model;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.gson.Gson;
import com.mongodb.stitch.android.StitchClient;
import com.mongodb.stitch.android.StitchClientFactory;

import org.bson.Document;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.ListIterator;

import example.r2chill.Activities.Support.StitchClientListener;

public class AccountController {

    private static AccountController accountControllerSingleton;
    private String fileName;

    private boolean needRefresh = true;

    private StitchClient stitchClient;
    private List<StitchClientListener> listeners = new ArrayList<>();

    private UserProfile userProfile;

    private GoogleSignInClient mGoogleSignInClient;
    private GoogleSignInAccount account;

    public boolean isNeedRefresh() {
        return needRefresh;
    }

    public void setNeedRefresh(boolean refresh) {
        this.needRefresh = refresh;
    }

    private AccountController(Context context) {
        fileName = "ProfileSaveData";

        StitchClientFactory.create(context, "r2c-lkroe").addOnSuccessListener(
                new OnSuccessListener<StitchClient>() {
                    @Override
                    public void onSuccess(StitchClient stitchClient) {
                        accountControllerSingleton.stitchClient = stitchClient;
                        ListIterator<StitchClientListener> it = accountControllerSingleton.listeners.listIterator();
                        while (it.hasNext()) {
                            StitchClientListener nextListener = it.next();
                            nextListener.onReady(accountControllerSingleton.stitchClient);
                            it.remove();
                        }
                    }
                });
    }

    // singleton from:
    // https://www.journaldev.com/1377/java-singleton-design-pattern-best-practices-examples
    public static synchronized AccountController getInstance(Context context) {
        if(accountControllerSingleton == null) {
            accountControllerSingleton = new AccountController(context);
        }
        return accountControllerSingleton;
    }

    // Call on  onCreate of every activity that uses DB
    public synchronized static void registerListener(StitchClientListener listener) {
        accountControllerSingleton.listeners.add(listener);

        if (accountControllerSingleton.stitchClient != null) {
            ListIterator<StitchClientListener> it = accountControllerSingleton.listeners.listIterator();
            while (it.hasNext()) {
                StitchClientListener nextListener = it.next();
                nextListener.onReady(accountControllerSingleton.stitchClient);
                it.remove();
            }
        }
    }

    public void setGoogleSignInClient(GoogleSignInClient client) {
        this.mGoogleSignInClient = client;
    }
    public GoogleSignInClient getGoogleSignInClient() {
        return this.mGoogleSignInClient;
    }
    public void setGoogleSignInAccount(GoogleSignInAccount account) {
        this.account = account;
    }
    public GoogleSignInAccount getGoogleSignInAccount() {
        return this.account;
    }

    public String jsonToString(Object object) {
        Gson gson = new Gson();
        try {
            return gson.toJson(object);
        } catch (Exception e) {
            return "Exception occurred using Gson";
        }
    }

    // returns userprofile from inputted bson document
    // also loads the userprofile to accountcontroller and to file
    public UserProfile bsonToUserProfile(Object object, Context context) {
        Gson gson = new Gson();
        Document docu = (Document) object;

        String jsonProfile = docu.toJson();
        UserProfile completeProfile = gson.fromJson(jsonProfile, UserProfile.class);

        setUserProfile(completeProfile);
        writeProfileToFile(context);

        return completeProfile;
    }

    public UserProfile jsonStringToProfile(String jsonString) {
        Gson gson = new Gson();
        UserProfile returnProfile = null;
        try {
            returnProfile = gson.fromJson(jsonString, UserProfile.class);
        } catch (Exception e) {
            return null;
        }
        return returnProfile;
    }

    public String writeProfileToFile(Context context) {
        if(userProfile == null) {
            return "profile null";
        }

        Gson gson = new Gson();
        // https://stackoverflow.com/questions/5571092/convert-object-to-json-in-android
        String jsonOfProfile = gson.toJson(userProfile);

        // if file exists, delete it
        // https://stackoverflow.com/questions/3554722/how-to-delete-internal-storage-file-in-android
        if(fileExists(context)) {
            deleteProfileFileFromDevice(context);
        }

        // else write the profile to file
        FileOutputStream outputStream;
        try {
            outputStream = context.openFileOutput(fileName, Context.MODE_PRIVATE);
            outputStream.write(jsonOfProfile.getBytes());
            outputStream.close();
        } catch (Exception e) {
            return e.toString();
        }
        return "profile written to file successfully";
    }

    public boolean isProfileOnFile(Context context) {
        if (fileExists(context)) {
            return true;
        }
        return false;
    }

    public String loadProfileToAccountController(Context context) {
        String line = null;
        File dir = context.getFilesDir();
        if (!isProfileOnFile(context)) {
            return "Profile not on file";
        } else {
            try {
                FileInputStream fileInputStream = new FileInputStream(new File(dir, fileName));
                InputStreamReader inputStreamReader = new InputStreamReader(fileInputStream);
                BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                StringBuilder stringBuilder = new StringBuilder();

                while ((line = bufferedReader.readLine()) != null) {
                    stringBuilder.append(line);
                }
                fileInputStream.close();
                line = stringBuilder.toString();
                bufferedReader.close();
            } catch (Exception e) {
                return e.getMessage();
            }

            try {
                userProfile = jsonStringToProfile(line);
            } catch (Exception e) {
                return "jsonStringToProfile bad";
            }

            return "Profile loaded successfully";
        }
    }

    public UserProfile getUserProfile() {
        return userProfile;
    }

    public void setUserProfile(UserProfile profile) {
        userProfile = profile;
    }

    // https://stackoverflow.com/questions/8867334/
    // check-if-a-file-exists-before-calling-openfileinput
    private boolean fileExists(Context context) {
        File file = context.getFileStreamPath(fileName);
        if (file == null || !file.exists()) {
            return false;
        }
        return true;
    }

    private void deleteFile(Context context, String filename) {
        File file = new File(context.getFilesDir(), filename);
        if (file.delete()) {
            //return("profile deleted");
        }
    }

    public void deleteProfileFileFromDevice(Context context) {
        deleteFile(context, fileName);
    }

    public boolean checkInternetConnection(Context context) {
        ConnectivityManager cm = (ConnectivityManager)context.getSystemService(
                Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        return activeNetwork != null && activeNetwork.isConnected();
    }
}
