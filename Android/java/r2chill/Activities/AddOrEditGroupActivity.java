package example.r2chill.Activities;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.annotation.NonNull;
import android.support.design.widget.TextInputEditText;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.Html;
import android.text.Spanned;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ListAdapter;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.Switch;
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

public class AddOrEditGroupActivity extends ColorPickerActivity {
    private Toolbar toolbar;

    private TextInputEditText groupNameEditText;
    private TextView groupNameErrorTextView;
    private TextView groupNameCharacterCount;

    private TextInputEditText groupDescriptionEditText;
    private TextView groupDescriptionErrorTextView;
    private TextView groupDescriptionCharacterCount;

    private Switch notificationsSwitch;

    private ColorPickerDialog colorPickerDialog;
    private Button colorPickerButton;
    private Button friendPickerButton;
    private TextView listOfFriendsTextView;
    private Button confirmButton;
    private Button cancelButton;

    private ProgressBar progressBar;

    private boolean validGroupName = false;
    private boolean validDescription = true;

    private String selectedColor = "#FFFFFF";

    private boolean isEdit = false;
    private int index;
    private FriendGroup passedInGroup;

    private ArrayList<String> listOfFriendsToSend;

    @SuppressLint("ClickableViewAccessibility")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_or_edit_group);

        progressBar = (ProgressBar) findViewById(R.id.add_or_edit_group_spinner);

        userProfile = accountController.getUserProfile();
        if (userProfile == null) {
            accountController.loadProfileToAccountController(this);
            userProfile = accountController.getUserProfile();
        }

        String addOrEdit = getIntent().getStringExtra("addOrEdit");
        if (addOrEdit == null) {
            addOrEdit = "";
        }
        if (addOrEdit.equals("edit")) {
            index = getIntent().getIntExtra("groupIndex", -1);
            if (index == -1) {
                longToast(getResources().getString(R.string.something_wrong_app));
                finish();
            } else {
                passedInGroup = userProfile.getListOfFriendGroups().get(index);
                if (passedInGroup == null) {
                    longToast(getResources().getString(R.string.something_wrong_app));
                    finish();
                } else {
                    isEdit = true;
                    validGroupName = true;
                    validDescription = true;
                    listOfFriendsToSend = passedInGroup.getListOfFriendsUsernames();
                }
            }
        } else {
            // add group
            listOfFriendsToSend = new ArrayList<>();
        }

        toolbar = findViewById(R.id.add_or_edit_group_toolbar);
        if (toolbar != null) {
            if (isEdit) {
                toolbar.setTitle(getResources().getString(R.string.edit) + " " +
                        passedInGroup.getFriendListName());
            } else {
                toolbar.setTitle(getResources().getString(R.string.add_group));
            }
        }

        groupNameEditText = (TextInputEditText) findViewById(R.id.add_or_edit_group_name_edittext);
        groupNameErrorTextView = (TextView) findViewById(R.id.add_or_edit_group_name_error_textview);
        groupNameErrorTextView.setTextColor(red);
        groupNameErrorTextView.setTextSize(helperTextSize);
        groupNameCharacterCount = (TextView) findViewById(R.id.add_or_edit_group_name_character_count);
        groupNameCharacterCount.setTextSize(helperTextSize);
        if (isEdit) {
            groupNameEditText.setText(passedInGroup.getFriendListName());
            validGroupName = true;
        }

        groupNameEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.length() > 60) {
                    String characterCounter = Integer.toString(s.length()) +
                            getResources().getString(R.string.out_of_80);
                    groupNameCharacterCount.setText(characterCounter);
                    if (s.length() < 81) {
                        groupNameErrorTextView.setText("");
                        validGroupName = true;
                    }
                    if (s.length() > 80) {
                        groupNameErrorTextView.setText(getResources().getString(R.string.too_long));
                        validGroupName = false;
                    }
                } else if (s.length() == 0) {
                    validGroupName = false;
                    groupNameErrorTextView.setText(getResources().getString(R.string.too_short));
                } else {
                    validGroupName = true;
                    groupNameErrorTextView.setText("");
                    groupNameCharacterCount.setText("");
                }
            }
            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        groupDescriptionEditText = (TextInputEditText) findViewById(R.id.add_or_edit_group_description_edittext);
        groupDescriptionErrorTextView = (TextView) findViewById(R.id.add_or_edit_group_description_error);
        groupDescriptionErrorTextView.setTextSize(helperTextSize);
        groupDescriptionErrorTextView.setTextColor(red);
        groupDescriptionCharacterCount = (TextView) findViewById(R.id.add_or_edit_group_description_character_count);
        groupDescriptionCharacterCount.setTextSize(helperTextSize);
        if (isEdit) {
            groupDescriptionEditText.setText(passedInGroup.getGroupDescription());
            validDescription = true;
        }

        groupDescriptionEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Drawable cross = getResources().getDrawable(android.R.drawable.presence_offline);
                cross.setBounds(0, 0, cross.getIntrinsicWidth(), cross.getIntrinsicHeight());
                if (s.length() != 0) {
                    groupDescriptionEditText.setCompoundDrawables(null, null, cross, null);
                } else {
                    groupDescriptionEditText.setCompoundDrawables(null, null, null, null);
                }

                if (s.length() > 100) {
                    String characterCount = Integer.toString(s.length()) +
                            getResources().getString(R.string.out_of_140);
                    groupDescriptionCharacterCount.setText(characterCount);
                    if (s.length() < 141) {
                        validDescription = true;
                        groupDescriptionErrorTextView.setText("");
                    }
                    if (s.length() > 140) {
                        groupDescriptionErrorTextView.setText(getResources().getString(R.string.too_long));
                        validDescription = false;
                    }
                } else {
                    validDescription = true;
                    groupDescriptionErrorTextView.setText("");
                    groupDescriptionCharacterCount.setText("");
                }
            }
            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        groupDescriptionEditText.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    try {
                        if (event.getRawX() >= (groupDescriptionEditText.getRight() -
                                groupDescriptionEditText.getCompoundDrawables()[2].getBounds().width())) {
                            groupDescriptionEditText.setText("");
                        }
                    } catch (Exception e) {
                    }
                }
                return false;
            }
        });

        notificationsSwitch = (Switch) findViewById(R.id.add_or_edit_group_notification_switch);
        if (isEdit) {
            notificationsSwitch.setChecked(passedInGroup.isNotificationsOn());
        }

        colorPickerButton = (Button) findViewById(R.id.add_or_edit_group_pick_color_button);
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
            colorPickerButton.setTextColor(passedInGroup.getGroupTextColorInt());
            selectedColor = passedInGroup.getGroupTextColor();
        }

        final FriendListAdapter adapter = new FriendListAdapter(userProfile, this);
        friendPickerButton = (Button) findViewById(R.id.add_or_edit_group_pick_friends_button);
        friendPickerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (userProfile.getCompleteFriendList().getFriendArrayList().size() == 0) {
                    toast(getResources().getString(R.string.you_have_no_friends));
                }
                groupPopup(adapter);
            }
        });

        listOfFriendsTextView = (TextView) findViewById(R.id.add_or_edit_group_friendlist_textview);
        if (isEdit) {
            reDraw();
        }

        cancelButton = findViewById(R.id.add_or_edit_group_cancel_button);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                accountController.setNeedRefresh(false);
                finish();
            }
        });

        confirmButton = findViewById(R.id.add_or_edit_group_confirm_button);
        if (isEdit) {
            confirmButton.setText(R.string.edit_group);
        }
        confirmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addGroup();
            }
        });
    }

    private void addGroup() {
        if (isSpinning) {
            return;
        }
        if ((_client == null) || (!_client.isAuthenticated())) {
            toast(getResources().getString(R.string.authentication_error));
            return;
        }
        if (!accountController.checkInternetConnection(this) ) {
            toast(getResources().getString(R.string.waiting_for_connection));
            return;
        }

        if (groupNameEditText.getText().toString().length() == 0) {
            groupNameErrorTextView.setText(getResources().getString(R.string.too_short));
            return;
        }

        if (validDescription && validGroupName) {
            progressBar.setVisibility(VISIBLE);
            isSpinning = true;

            String groupId = "";
            if (isEdit) {
                groupId = passedInGroup.getGroupId();
            }

            String groupName = groupNameEditText.getText().toString();
            String description = groupDescriptionEditText.getText().toString();
            boolean notifications = notificationsSwitch.isChecked();

            _client.executeFunction("addOrEditGroup", groupId, groupName, description, notifications,
                    selectedColor, listOfFriendsToSend).addOnCompleteListener(new OnCompleteListener<Object>() {
                        @Override
                        public void onComplete(@NonNull Task<Object> task) {
                            if (task.isSuccessful()) {
                                String converted = accountController.jsonToString(task.getResult()).
                                replace("\"", "");

                                if (converted.equals("Invalid input")) {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.error_invalid_input_group_hack));
                                } else if (converted.equals("Successful add")) {
                                    toast(getResources().getString(R.string.group_added));
                                    finish();
                                } else if (converted.equals("Successful edit")) {
                                    toast(getResources().getString(R.string.group_edited));
                                    finish();
                                } else if (converted.equals("writeConcernError")) {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.group_write_concern_error));
                                } else if (converted.equals("writeError")) {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.group_write_error));
                                } else {
                                    displayWarningOkAlertDialog(getResources().getString(R.string.group_unknown_return));
                                }
                            } else {
                                displayWarningOkAlertDialog(getResources().getString(R.string.error_add_or_edit_group));
                            }
                            progressBar.setVisibility(GONE);
                            isSpinning = false;
                        }
                    });
        }
    }

    @Override
    public void reDraw() {
        int count = 0;
        listOfFriendsTextView.setText("");
        for (Friend friend : userProfile.getCompleteFriendList().getFriendArrayList()) {
            if (listOfFriendsToSend.contains(friend.getOwnerUsername())) {
                if (count > 0) {
                    listOfFriendsTextView.append(", ");
                }
                Spanned friendName = Html.fromHtml("<font color='" +
                        friend.getTextColor() + "'>" + friend.getAlias() + "</font>");
                listOfFriendsTextView.append(friendName);
                count += 1;
            }
        }
    }

    private class FriendListAdapter extends ListViewAdapter {
        private ArrayList<Friend> completeFriendList;
        private Context context;

        public FriendListAdapter(@NonNull UserProfile userProfile, Context context) {
            this.completeFriendList = userProfile.getCompleteFriendList().getFriendArrayList();
            this.context = context;
        }

        @Override
        public int getCount() {
            return completeFriendList.size();
        }
        @Override
        public Object getItem(int pos) {
            return completeFriendList.get(pos);
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

            TextView friendNameTextView = (TextView) view.findViewById(R.id.name_and_checkbox_textview);
            Friend currentFriend = completeFriendList.get(position);

            final String username = currentFriend.getOwnerUsername();
            friendNameTextView.setText(currentFriend.getAlias());
            friendNameTextView.setTextColor(currentFriend.getTextColorInt());

            final CheckBox checkBox = (CheckBox) view.findViewById(R.id.name_and_checkbox_checkbox);
            if (listOfFriendsToSend.contains(username)) {
                checkBox.setChecked(true);
            } else {
                checkBox.setChecked(false);
            }
            checkBox.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (checkBox.isChecked()) {
                        if (!listOfFriendsToSend.contains(username)) {
                            listOfFriendsToSend.add(username);
                        }
                    } else {
                        if (listOfFriendsToSend.contains(username)) {
                            listOfFriendsToSend.remove(username);
                        }
                    }
                }
            });
            return view;
        }
    }

    @Override
    public void onBackPressed() {
        accountController.setNeedRefresh(false);
        super.onBackPressed();
    }

    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(R.anim.left_to_right_enter, R.anim.left_to_right_exit);
    }
}
