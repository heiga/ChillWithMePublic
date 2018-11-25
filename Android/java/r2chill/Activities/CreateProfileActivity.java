package example.r2chill.Activities;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.TextInputEditText;
import android.support.design.widget.TextInputLayout;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.text.method.LinkMovementMethod;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.mongodb.stitch.android.StitchClient;

import example.r2chill.Model.AccountController;
import example.r2chill.R;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

public class CreateProfileActivity extends DatabaseActivity {
    private Toolbar toolbar;
    private Button confirmButton;
    private Button cancelButton;
    private GoogleSignInClient mGoogleSignInClient;
    private TextInputLayout usernameTextInputLayout;
    private TextInputEditText usernameEditText;
    private TextView errorTextView;
    private TextView characterCountTextView;
    private TextView termsOfServiceTextView;
    private ProgressBar progressBar;
    private StitchClient _client;

    private int tooLong = 1;
    private int tooShort = 1;
    private int strangeChar = 1;

    public void onReady(StitchClient stitchClient) {
        this._client = stitchClient;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_profile);

        mGoogleSignInClient = accountController.getGoogleSignInClient();

        progressBar = (ProgressBar) findViewById(R.id.create_profile_screen_spinner);

        toolbar = (Toolbar) findViewById(R.id.create_profile_toolbar);
        if (toolbar != null) {
            toolbar.setTitle(R.string.create_profile_toolbar_title);
            toolbar.setTitleTextColor(Color.WHITE);
        }

        cancelButton = (Button) findViewById(R.id.create_profile_cancel_button);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                signOut();
            }
        });

        usernameEditText = (TextInputEditText) findViewById(R.id.create_profile_username_edittext);
        usernameTextInputLayout = (TextInputLayout) findViewById(R.id.create_profile_username_textinputlayout);
        errorTextView = (TextView) findViewById(R.id.create_profile_username_error_textview);
        errorTextView.setTextSize(12);
        characterCountTextView = (TextView) findViewById(R.id.create_profile_username_character_count_textview);
        characterCountTextView.setTextSize(12);
        termsOfServiceTextView = (TextView) findViewById(R.id.create_profile_terms_of_service_textview);
        termsOfServiceTextView.setMovementMethod(LinkMovementMethod.getInstance());

        usernameEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.length() > 20) {
                    String characterCounter = Integer.toString(s.length()) +
                            getResources().getString(R.string.out_of_30);
                    characterCountTextView.setText(characterCounter);
                } else {
                    characterCountTextView.setText("");
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        confirmButton = (Button) findViewById(R.id.create_profile_confirmation_button);
        confirmButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                String pulledUsername = usernameEditText.getText().toString();
                String sanitizedName = sanitizeName(pulledUsername);
                if (sanitizedName.equals("clean")) {
                    errorTextView.setText("");
                    confirmUsernameDialog(pulledUsername);

                    // don't mind all this, it's just an easter egg
                } else if (sanitizedName.equals("empty")) {
                    if (tooShort == 1) displayWarningOkAlertDialog(getResources().getString(R.string.username_empty_1));
                    if (tooShort == 2) displayWarningOkAlertDialog(getResources().getString(R.string.username_empty_2));
                    if (tooShort == 3) displayWarningOkAlertDialog(getResources().getString(R.string.username_empty_3));
                    if (tooShort == 4) displayWarningOkAlertDialog(getResources().getString(R.string.username_empty_4));
                    if (tooShort > 4 & tooShort < 7) displayWarningOkAlertDialog(getResources().getString(R.string.username_empty_1));
                    if (tooShort == 7) displayWarningOkAlertDialog(getResources().getString(R.string.username_empty_5));
                    if (tooShort == 8) displayWarningOkAlertDialog(getResources().getString(R.string.username_empty_1));
                    errorTextView.setText(getResources().getString(R.string.too_short));
                    if (tooShort < 8) tooShort += 1;
                } else if (sanitizedName.equals("too long")) {
                    if (tooLong == 1) displayWarningOkAlertDialog(getResources().getString(R.string.username_long_1));
                    if (tooLong == 2) displayWarningOkAlertDialog(getResources().getString(R.string.username_long_2));
                    if (tooLong == 3) displayWarningOkAlertDialog(getResources().getString(R.string.username_long_3));
                    if (tooLong == 4) displayWarningOkAlertDialog(getResources().getString(R.string.username_long_4));
                    if (tooLong == 5) displayWarningOkAlertDialog(getResources().getString(R.string.username_long_5));
                    if (tooLong == 6) tooLongFinalDialog();
                    if (tooLong == 7) displayWarningOkAlertDialog(getResources().getString(R.string.username_long_1));
                    if (tooLong < 7) tooLong += 1;
                    errorTextView.setText(getResources().getString(R.string.too_long));
                } else if (sanitizedName.equals("wtf")) {
                    if (strangeChar == 1) displayWarningOkAlertDialog(getResources().getString(R.string.username_strange_1));
                    if (strangeChar == 2) displayWarningOkAlertDialog(getResources().getString(R.string.username_strange_2));
                    if (strangeChar == 3) displayWarningOkAlertDialog(getResources().getString(R.string.username_strange_3));
                    if (strangeChar == 4) displayWarningOkAlertDialog(getResources().getString(R.string.username_strange_1));
                    errorTextView.setText(getResources().getString(R.string.letters_and_numbers));
                    if (strangeChar < 4) strangeChar += 1;
                }
            }
        });
    }

    @Override
    public void onBackPressed() {
        signOut();
        finish();
    }

    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
    }

    private void createProfile(String username) {
        if (_client == null) {
            toast(getResources().getString(R.string.no_internet));
            return;
        }

        progressBar.setVisibility(VISIBLE);
        _client.executeFunction("createProfile", username).addOnCompleteListener(
                new OnCompleteListener<Object>() {
                    @Override
                    public void onComplete(@NonNull Task<Object> task) {
                        if (task.isSuccessful()) {
                            String converted = accountController.jsonToString(task.getResult()).replace("\"", "");
                            if (converted.equals("success")) {
                                // get profile from DB
                                profileCreatedSuccessfullyDialog();
                            } else if (converted.equals("Profile already exists")) {
                                displayWarningOkAlertDialog(getResources().getString(R.string.error_create_profile_already_exists));
                            } else if (converted.equals("Invalid username")) {
                                displayWarningOkAlertDialog(getResources().getString(R.string.error_create_profile_hack));
                            } else if (converted.equals("Username already taken")) {
                                displayRegularOkAlertDialog(getResources().getString(R.string.username_already_taken));
                            } else {
                                displayWarningOkAlertDialog(getResources().getString(R.string.error_create_profile_etc));
                            }
                        } else {
                            displayWarningOkAlertDialog(getResources().getString(R.string.something_wrong_database));
                        }
                        progressBar.setVisibility(GONE);
                    }
                }
        );
    }


    private void signOut() {
        mGoogleSignInClient.signOut().addOnCompleteListener(this, new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
                accountController.setGoogleSignInAccount(null);
                finish();
            }
        });
    }

    private void confirmUsernameDialog(String username) {
        final String user = username;
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setTitle(getResources().getString(R.string.warning));
        ad.setMessage(getResources().getString(R.string.are_you_sure_1) + " " + username + "?\n" +
                getResources().getString(R.string.are_you_sure_2));
        ad.setPositiveButton(getResources().getString(R.string.yes),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        createProfile(user);
                    }
                });
        ad.setNegativeButton(R.string.no,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        // do nothing
                    }
                }
        );
        ad.create().show();
    }

    private void profileCreatedSuccessfullyDialog() {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setMessage(getResources().getString(R.string.username_success));
        ad.setPositiveButton(R.string.ok,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        finish();
                    }
                });
        ad.create().show();
    }

    private void tooLongFinalDialog() {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setMessage(getResources().getString(R.string.username_long_6));
        ad.setPositiveButton(R.string.no_friends,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        displayWarningOkAlertDialog(getResources().getString(R.string.username_long_7));
                    }
                }
        );
        ad.setNegativeButton(R.string.cancel_literal_text,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        // do nothing
                    }
                }
        );
        ad.create().show();
    }

    private void displayConfirmationAlertDialog(String message) {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setMessage(message);

        ad.setPositiveButton(
                R.string.yes,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {

                    }
                }
        );
        ad.setNegativeButton(
                R.string.no,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        // do nothing
                    }
                }
        );
        ad.create().show();
    }

    public void signIn() {}
    public void reDraw() {}
}
