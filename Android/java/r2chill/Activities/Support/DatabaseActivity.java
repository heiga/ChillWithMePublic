package example.r2chill.Activities;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.PopupWindow;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.mongodb.stitch.android.StitchClient;

import example.r2chill.Model.AccountController;
import example.r2chill.Model.UserProfile;
import example.r2chill.R;

public class DatabaseActivity extends ApplicationActivity implements StitchClientListener {
    protected StitchClient _client;
    protected UserProfile userProfile;
    protected AccountController accountController;
    protected boolean isSpinning;

    float helperTextSize = 12;
    int red;

    public void onReady(StitchClient stitchClient) {
        this._client = stitchClient;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        accountController = AccountController.getInstance(this);
        accountController.registerListener(this);
        isSpinning = false;

        red = getResources().getColor(R.color.red);
    }

    protected void getProfileFromDB() {
        if (!accountController.checkInternetConnection(this)) {
            loadAndReDrawFromFile();
            return;
        }
        if (_client == null) {
            loadAndReDrawFromFile();
            return;
        }
        if (!_client.isAuthenticated()) {
            loadAndReDrawFromFile();
            return;
        }

        _client.executeFunction("getProfile").addOnCompleteListener(new OnCompleteListener<Object>() {
            @Override
            public void onComplete(@NonNull Task<Object> task) {
                if (task.isSuccessful()) {
                    try {
                        userProfile = accountController.bsonToUserProfile(task.getResult(),
                                getApplicationContext());
                        if (userProfile != null) {
                            if (userProfile.getUserName() == null) {
                                displayWarningOkAlertDialog(getResources().getString(R.string.database_activity_corrupt_username));
                                reDraw();
                            } else {
                                accountController.setUserProfile(userProfile);
                                reDraw();
                            }
                        } else {
                            displayWarningOkAlertDialog(getResources().getString(R.string.database_activity_corrupt_profile));
                            reDraw();
                        }

                    } catch (Exception e) {
                        displayWarningOkAlertDialog(getResources().getString(R.string.database_activity_corrupt_bson_function));
                        reDraw();
                    }
                } else {
                    displayWarningOkAlertDialog(getResources().getString(R.string.database_activity_function_failure));
                    loadAndReDrawFromFile();
                }
            }
        });
    }

    protected void checkIfProfileUpdated() {
        if (!accountController.checkInternetConnection(this)) {
            loadAndReDrawFromFile();
            return;
        }
        if (_client == null) {
            loadAndReDrawFromFile();
            return;
        }
        if (!_client.isAuthenticated()) {
            loadAndReDrawFromFile();
            return;
        }

        // Check if profile on file
        // Check DB refreshtoken vs file refreshtoken
        Context appContext = getApplicationContext();
        if (accountController.isProfileOnFile(appContext)) {
            if (accountController.loadProfileToAccountController(appContext).equals("Profile loaded successfully")) {
                userProfile = accountController.getUserProfile();
                _client.executeFunction("checkIfProfileUpdated", userProfile.getRefreshToken()).addOnCompleteListener(
                        new OnCompleteListener<Object>() {
                            @Override
                            public void onComplete(@NonNull Task<Object> task) {
                                if (task.isSuccessful()) {
                                    String converted = accountController.jsonToString(task.getResult()).replace("\"", "");
                                    if (converted.equals("true")) {
                                        getProfileFromDB();
                                    } else {
                                        // no change
                                        loadAndReDrawFromFile();
                                    }
                                } else {
                                    displayRegularOkAlertDialog(getResources().getString(R.string.error_check_profile));
                                    loadAndReDrawFromFile();
                                }
                            }
                        }
                );
            } else {
                // if load fails
                getProfileFromDB();
            }
        } else {
            // if no profile on file
            getProfileFromDB();
        }
    }

    public abstract class ListViewAdapter extends BaseAdapter implements ListAdapter {}

    public void groupPopup(ListViewAdapter adapter) {
        LayoutInflater inflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View layout = inflater.inflate(R.layout.popup_window_name_and_checkbox, null);

        int width = (int) (getResources().getDisplayMetrics().widthPixels * 0.86);
        int height = (int) (getResources().getDisplayMetrics().heightPixels * 0.6);
        final PopupWindow window = new PopupWindow(layout, width, (int) height, true);

        // https://www.codota.com/code/java/methods/android.widget.PopupWindow/setAnimationStyle
        window.setAnimationStyle(android.R.style.Animation_Dialog);
        window.setElevation(20);

        ListView popupWindowListView = (ListView) layout.findViewById(R.id.popup_window_listview);
        popupWindowListView.setAdapter(adapter);

        Button returnButton = layout.findViewById(R.id.popup_window_return_button);
        returnButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                window.dismiss();
                reDraw();
            }
        });
        window.setOutsideTouchable(true);
        window.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                reDraw();
            }
        });
        window.showAtLocation(layout, Gravity.CENTER, 0, 0);
    }

    public void loadAndReDrawFromFile() {
        accountController.loadProfileToAccountController(this);
        reDraw();
    }

    public void signIn() {}
    public void reDraw() {}
}
