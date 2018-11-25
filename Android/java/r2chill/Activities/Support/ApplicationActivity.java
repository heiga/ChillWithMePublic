package example.r2chill.Activities;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.view.Gravity;
import android.widget.Toast;

import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.mongodb.stitch.android.StitchClient;
import com.mongodb.stitch.android.auth.oauth2.google.GoogleAuthProvider;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import example.r2chill.Model.AccountController;
import example.r2chill.R;

// provides some basic functionality
public abstract class ApplicationActivity extends AppCompatActivity {
    long millisInADay = 86400000;

    public void toast(String string) {
        Toast toast = Toast.makeText(this, string, Toast.LENGTH_SHORT);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.show();
    }

    public void longToast(String string) {
        Toast toast = Toast.makeText(this, string, Toast.LENGTH_LONG);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.show();
    }

    public String sanitizeName(String input) {
        //String regex = "[ !@#$%^&*()+|,/'\"]";
        if (input.length() > 30) {
            return "too long";
        }
        if (input.length() == 0) {
            return "empty";
        }
        String regex = ".*\\W+.*";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(input);
        if (matcher.find()) {
            return "wtf";
        }
        return "clean";
    }

    public String sanitizeDescription(String input) {
        //String regex = "[ !@#$%^&*()+|,/'\"]";
        if (input.length() > 140) {
            return "too long";
        }
        String regex = ".*\\W+.*";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(input);
        if (matcher.find()) {
            return "wtf";
        }
        return "clean";
    }

    public void displayRegularOkAlertDialog(String message) {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setMessage(message);

        ad.setPositiveButton(
                R.string.ok,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        // do nothing
                    }
                }
        );
        ad.create().show();
    }

    public void displayWarningOkAlertDialog(String message) {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setTitle(getResources().getString(R.string.error));
        ad.setMessage(message);

        ad.setPositiveButton(
                R.string.ok,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        // do nothing
                    }
                }
        );
        ad.create().show();
    }

    public String getReadableTimeIfStillValid(String timeNumber) {
        long time = System.currentTimeMillis();
        long statusTime = Long.parseLong(timeNumber) * 1000;

        String returnString = "";

        if (statusTime > time) {
            Date current = new Date(time);
            Date expiry = new Date(statusTime);

            String readableTime = new SimpleDateFormat("h:mm a").format(expiry);
            returnString += (readableTime);

            if (statusTime - millisInADay > time) {
                String formattedTime = new SimpleDateFormat("h:mm a, MMM F yyyy").format(expiry);
                return formattedTime;
            } else if ((expiry.getDay() != current.getDay()) && (statusTime - millisInADay < time)) {
                returnString += (" " + "tomorrow");
            }

            return returnString;
        } else {
            return "invalid";
        }
    }

    public abstract void reDraw();
    public abstract void signIn();
}
