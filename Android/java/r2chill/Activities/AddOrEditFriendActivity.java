package example.r2chill.Activities;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.annotation.NonNull;
import android.support.design.widget.TextInputEditText;
import android.support.design.widget.TextInputLayout;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.Html;
import android.text.Spanned;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.android.colorpicker.ColorPickerDialog;
import com.android.colorpicker.ColorPickerSwatch;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import java.util.ArrayList;

import example.r2chill.Model.Friend;
import example.r2chill.Model.FriendGroup;
import example.r2chill.Model.UserProfile;
import example.r2chill.R;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

public class AddOrEditFriendActivity extends ColorPickerActivity {
    private Toolbar toolbar;
    private ProgressBar progressBar;

    private TextInputLayout usernameTextInputLayout;
    private TextInputEditText usernameEditText;
    private TextView usernameErrorTextView;

    private TextInputEditText nicknameEditText;
    private TextView nicknameErrorTextView;
    private TextView nicknameCharacterCountTextView;

    private TextInputEditText descriptionEditText;
    private TextView descriptionErrorTextView;
    private TextView descriptionCharacterCountTextView;

    private TextView groupsTextView;

    private ColorPickerDialog colorPickerDialog;
    private Button colorPickerButton;
    private Button pickGroupsButton;
    private Button confirmButton;
    private Button cancelButton;

    private boolean validUsername = false;
    private boolean validNickname = true;
    private boolean validDescription = true;

    private String selectedColor = "#FFFFFF";

    private boolean isEdit = false;
    private boolean isFromRequests = false;
    private String passedInUsername = "";
    private Friend passedInFriend;

    private ArrayList<String> listOfGroupIdsToSend;

    @SuppressLint("ClickableViewAccessibility")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_or_edit_friend);

        userProfile = accountController.getUserProfile();
        if (userProfile == null) {
            accountController.loadProfileToAccountController(this);
            userProfile = accountController.getUserProfile();
        }

        String addOrEdit = getIntent().getStringExtra("addOrEdit");
        if (addOrEdit == null) {
            addOrEdit = "";
        }
        isFromRequests = getIntent().getBooleanExtra("fromFriendRequest", false);

        if (addOrEdit.equals("edit")) {
            passedInUsername = getIntent().getStringExtra("friendUsername");
            if (passedInUsername != null) {
                passedInFriend = userProfile.getCompleteFriendList().getFriendFromUsername(passedInUsername);
                if (passedInFriend != null) {
                    isEdit = true;
                    listOfGroupIdsToSend = passedInFriend.getListOfGroupIds();
                } else {
                    listOfGroupIdsToSend = new ArrayList<>();
                }
            } else {
                listOfGroupIdsToSend = new ArrayList<>();
            }
        } else {
            // add friend
            listOfGroupIdsToSend = new ArrayList<>();
        }

        toolbar = (Toolbar) findViewById(R.id.add_or_edit_friend_toolbar);
        progressBar = (ProgressBar) findViewById(R.id.add_or_edit_friend_spinner);
        groupsTextView = (TextView) findViewById(R.id.add_or_edit_friend_grouplist_textview);

        colorPickerButton = (Button) findViewById(R.id.add_or_edit_friend_pick_color_button);
        pickGroupsButton = (Button) findViewById(R.id.add_or_edit_friend_pick_groups_button);

        confirmButton = (Button) findViewById(R.id.add_or_edit_friend_confirm_button);
        cancelButton = (Button) findViewById(R.id.add_or_edit_friend_cancel_button);

        if (isEdit) {
            toolbar.setTitle(getResources().getString(R.string.edit) + " " + passedInUsername);
            reDraw();
            confirmButton.setText(R.string.edit_friend);
        } else {
            toolbar.setTitle(getResources().getString(R.string.add_friend));
        }

        usernameTextInputLayout = (TextInputLayout) findViewById(R.id.add_or_edit_friend_username_textinputlayout1);
        usernameEditText = (TextInputEditText) findViewById(R.id.add_or_edit_friend_username_textinputedittext);
        usernameErrorTextView = (TextView) findViewById(R.id.add_or_edit_friend_username_error);
        usernameErrorTextView.setTextSize(helperTextSize);
        usernameErrorTextView.setTextColor(red);
        if (isEdit) {
            usernameEditText.setText(passedInFriend.getOwnerUsername());
            validUsername = true;
            usernameEditText.setFocusable(false);
        } else if (isFromRequests) {
            String passedInUsername = getIntent().getStringExtra("friendUsername");
            if (passedInUsername != null) {
                usernameEditText.setText(passedInUsername);
                validUsername = true;
                usernameEditText.setFocusable(false);
            } else {
                toast(getResources().getString(R.string.something_wrong_app));
            }
        } else {
            usernameEditText.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    if (!hasFocus) {
                        if (sanitizeName(usernameEditText.getText().toString()).equals("clean")) {
                            validUsername = true;
                            usernameErrorTextView.setText("");
                        } else {
                            validUsername = false;
                            usernameErrorTextView.setText(getResources().getString(R.string.invalid_username));
                        }
                    }
                }
            });

            usernameEditText.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }
                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    String sanitized = sanitizeName(s.toString());
                    if (sanitized.equals("clean")) {
                        validUsername = true;
                        usernameErrorTextView.setText("");
                    } else {
                        validUsername = false;
                    }
                }
                @Override
                public void afterTextChanged(Editable s) {
                }
            });
        }

        nicknameEditText = (TextInputEditText) findViewById(R.id.add_or_edit_friend_nickname_edittext);
        nicknameErrorTextView = (TextView) findViewById(R.id.add_or_edit_friend_nickname_error_textview);
        nicknameErrorTextView.setTextSize(helperTextSize);
        nicknameErrorTextView.setTextColor(red);
        nicknameCharacterCountTextView = (TextView) findViewById(R.id.add_or_edit_friend_nickname_character_count);
        nicknameCharacterCountTextView.setTextSize(helperTextSize);
        if (isEdit) {
            nicknameEditText.setText(passedInFriend.getAlias());
        }

        nicknameEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.length() > 20) {
                    String characterCounter = Integer.toString(s.length()) +
                            getResources().getString(R.string.out_of_30);
                    nicknameCharacterCountTextView.setText(characterCounter);
                    if (s.length() < 31) {
                        nicknameErrorTextView.setText("");
                        validNickname = true;
                    }
                    if (s.length() > 30) {
                        nicknameErrorTextView.setText(getResources().getString(R.string.too_long));
                        validNickname = false;
                    }
                } else {
                    validNickname = true;
                    nicknameCharacterCountTextView.setText("");
                    nicknameErrorTextView.setText("");
                }
            }
            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        descriptionEditText = (TextInputEditText) findViewById(R.id.add_or_edit_friend_description_edittext);
        descriptionErrorTextView = (TextView) findViewById(R.id.add_or_edit_friend_description_error_textview);
        descriptionErrorTextView.setTextSize(helperTextSize);
        descriptionErrorTextView.setTextColor(red);
        descriptionCharacterCountTextView = (TextView) findViewById(R.id.add_or_edit_friend_description_character_count);
        descriptionCharacterCountTextView.setTextSize(helperTextSize);
        if (isEdit) {
            descriptionEditText.setText(passedInFriend.getDescription());
        }

        descriptionEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Drawable cross = getResources().getDrawable(android.R.drawable.presence_offline);
                cross.setBounds(0, 0, cross.getIntrinsicWidth(), cross.getIntrinsicHeight());
                if (s.length() != 0) {
                    descriptionEditText.setCompoundDrawables(null, null, cross, null);
                } else {
                    descriptionEditText.setCompoundDrawables(null, null, null, null);
                }

                if (s.length() > 100) {
                    String characterCounter = Integer.toString(s.length()) +
                            getResources().getString(R.string.out_of_140);
                    descriptionCharacterCountTextView.setText(characterCounter);
                    if (s.length() < 141) {
                        validDescription = true;
                        descriptionErrorTextView.setText("");
                    }
                    if (s.length() > 140) {
                        descriptionErrorTextView.setText(getResources().getString(R.string.too_long));
                        validDescription = false;
                    }
                } else {
                    validDescription = true;
                    descriptionCharacterCountTextView.setText("");
                    descriptionErrorTextView.setText("");
                }
            }
            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        descriptionEditText.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    try {
                        if (event.getRawX() >= (descriptionEditText.getRight() -
                                descriptionEditText.getCompoundDrawables()[2].getBounds().width())) {
                            descriptionEditText.setText("");
                        }
                    } catch (Exception e) {
                    }
                }
                return false;
            }
        });

        colorPickerDialog = new ColorPickerDialog();
        colorPickerDialog.initialize(
                R.string.color_picker_title, colorArray, R.color.white, 4, 16);
        colorPickerButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                colorPickerDialog.show(getFragmentManager(), "etc");
            }
        });
        colorPickerDialog.setOnColorSelectedListener(new ColorPickerSwatch.OnColorSelectedListener() {
            @Override
            public void onColorSelected(int color) {
                colorPickerButton.setTextColor(color);
                selectedColor = "#" + Integer.toHexString(color).substring(2);

            }
        });
        if (isEdit) {
            colorPickerButton.setTextColor(passedInFriend.getTextColorInt());
            selectedColor = passedInFriend.getTextColor();
        }

        final GroupListAdapter adapter = new GroupListAdapter(userProfile, this);
        pickGroupsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (userProfile.getListOfFriendGroups().size() == 0) {
                    toast(getResources().getString(R.string.you_have_no_groups));
                }
                groupPopup(adapter);
            }
        });

        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                accountController.setNeedRefresh(false);
                finish();
            }
        });

        confirmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addFriend();
            }
        });
    }

    private void addFriend() {
        if (isSpinning) {
            return;
        }
        if ((_client == null) || (!_client.isAuthenticated())) {
            toast(getResources().getString(R.string.authentication_error));
            return;
        }
        if (!accountController.checkInternetConnection(this)) {
            toast(getResources().getString(R.string.waiting_for_connection));
            return;
        }

        if (!validUsername) {
            usernameErrorTextView.setText(getResources().getString(R.string.invalid_username));
            return;
        }

        if (validUsername && validNickname && validDescription) {
            progressBar.setVisibility(VISIBLE);
            isSpinning = true;

            String usernameToSend = usernameEditText.getText().toString();
            String nicknameToSend = nicknameEditText.getText().toString();
            String descriptionToSend = descriptionEditText.getText().toString();

            _client.executeFunction("addOrEditFriend", usernameToSend, nicknameToSend,
                    descriptionToSend, selectedColor, listOfGroupIdsToSend).addOnCompleteListener(
                    new OnCompleteListener<Object>() {
                        @Override
                        public void onComplete(@NonNull Task<Object> task) {
                            if (task.isSuccessful()) {
                                String converted = accountController.jsonToString(task.getResult()).
                                replace("\"", "");

                                if (converted.equals("Invalid input")) {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.error_invalid_input_add_hack));
                                } else if (converted.equals("User does not exist")) {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.error_user_does_not_exist));
                                } else if (converted.equals("Successful add")) {
                                    toast(getResources().getString(R.string.friend_added));
                                    finish();
                                } else if (converted.equals("Successful edit")) {
                                    toast(getResources().getString(R.string.friend_edited));
                                    finish();
                                } else if (converted.equals("writeConcernError")) {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.friend_write_concern_error));
                                } else if (converted.equals("writeError")) {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.friend_write_error));
                                } else {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.friend_unknown_return));
                                }
                            } else {
                                displayWarningOkAlertDialog(getResources().getString(R.string.error_add_or_edit_friend_backend_failure));
                            }
                            progressBar.setVisibility(GONE);
                            isSpinning = false;
                        }
                    }
            );
        }
    }

    @Override
    public void reDraw() {
        int count = 0;
        groupsTextView.setText("");
        for (FriendGroup group : userProfile.getListOfFriendGroups()) {
            if (listOfGroupIdsToSend.contains(group.getGroupId())) {
                if (count > 0) {
                    groupsTextView.append(", ");
                }
                Spanned groupListName = Html.fromHtml("<font color='" +
                        group.getGroupTextColor() + "'>" + group.getFriendListName() + "</font>");
                groupsTextView.append(groupListName);
                count += 1;
            }
        }
    }

    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(R.anim.left_to_right_enter, R.anim.left_to_right_exit);
    }

    @Override
    public void onBackPressed() {
        accountController.setNeedRefresh(false);
        super.onBackPressed();
    }

    private class GroupListAdapter extends ListViewAdapter {
        private ArrayList<FriendGroup> completeGroupList;
        private Context context;

        public GroupListAdapter(@NonNull UserProfile userProfile, Context context) {
            this.completeGroupList = userProfile.getListOfFriendGroups();
            this.context = context;
        }

        @Override
        public int getCount() {
            return completeGroupList.size();
        }
        @Override
        public Object getItem(int pos) {
            return completeGroupList.get(pos);
        }
        @Override
        public long getItemId(int pos) {
            return 0;
        }

        @Override
        public View getView(final int position, View convertView, ViewGroup parent) {
            View view = convertView;
            if (view == null) {
                LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                view = inflater.inflate(R.layout.name_and_checkbox, parent, false);
            }

            TextView groupNameTextView = (TextView) view.findViewById(R.id.name_and_checkbox_textview);
            FriendGroup currentGroup = completeGroupList.get(position);
            final String groupId = currentGroup.getGroupId();
            groupNameTextView.setText(currentGroup.getFriendListName());
            groupNameTextView.setTextColor(currentGroup.getGroupTextColorInt());

            final CheckBox checkBox = (CheckBox) view.findViewById(R.id.name_and_checkbox_checkbox);
            if (listOfGroupIdsToSend.contains(currentGroup.getGroupId())) {
                checkBox.setChecked(true);
            } else {
                checkBox.setChecked(false);
            }
            checkBox.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (checkBox.isChecked()) {
                        if (!listOfGroupIdsToSend.contains(groupId)) {
                            listOfGroupIdsToSend.add(groupId);
                        }
                    } else {
                        if (listOfGroupIdsToSend.contains(groupId)) {
                            listOfGroupIdsToSend.remove(groupId);
                        }
                    }
                }
            });
            return view;
        }
    }
}
