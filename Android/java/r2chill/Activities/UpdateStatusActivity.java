package example.r2chill.Activities;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.support.annotation.NonNull;
import android.support.design.widget.TextInputEditText;
import android.support.v7.app.AppCompatActivity;
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
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.NumberPicker;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.Spinner;
import android.widget.TextView;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import java.util.ArrayList;
import java.util.Arrays;

import example.r2chill.Model.FriendGroup;
import example.r2chill.Model.UserProfile;
import example.r2chill.Model.YourCurrentStatus;
import example.r2chill.R;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

public class UpdateStatusActivity extends DatabaseActivity {
    private Toolbar toolbar;
    private Button currentStatusButton;
    private TextView newStatusTextView;
    private Spinner statusSpinner;
    private TextInputEditText statusDescriptionEditText;
    private TextView descriptionErrorTextView;
    private TextView descriptionCharacterCountTextView;
    private TextInputEditText durationEditText;
    private TextView durationErrorTextView;
    private Button pickGroupsButton;
    private TextView groupListTextView;
    private ProgressBar progressBar;
    private Button confirmButton;
    private Button cancelButton;

    private NumberPicker hourPicker;
    private NumberPicker minutePicker;

    private ArrayList<String> listOfGroupsToSend = new ArrayList<>();

    private boolean validDescription = true;

    private int hours = 0;
    private int minutes = 0;

    private float helperTextSize;
    private int red;

    @SuppressLint("ClickableViewAccessibility")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_update_status);

        userProfile = accountController.getUserProfile();
        if (userProfile == null) {
            accountController.loadProfileToAccountController(this);
            userProfile = accountController.getUserProfile();
        }

        toolbar = (Toolbar) findViewById(R.id.update_status_toolbar);
        currentStatusButton = (Button) findViewById(R.id.update_status_current_status_button);
        newStatusTextView = (TextView) findViewById(R.id.update_status_new_status_textview);
        statusSpinner = (Spinner) findViewById(R.id.update_status_spinner);
        statusDescriptionEditText = (TextInputEditText) findViewById(R.id.update_status_description_textinputedittext);
        descriptionErrorTextView = (TextView) findViewById(R.id.update_status_description_error);
        descriptionCharacterCountTextView = (TextView) findViewById(R.id.update_status_description_character_count);
        durationEditText = (TextInputEditText) findViewById(R.id.update_status_duration_edittext);
        durationErrorTextView = (TextView) findViewById(R.id.update_status_duration_error);
        pickGroupsButton = (Button) findViewById(R.id.update_status_groups_button);
        groupListTextView = (TextView) findViewById(R.id.update_status_grouplist_textview);
        progressBar = (ProgressBar) findViewById(R.id.update_status_progressbar_spinner);
        confirmButton = (Button) findViewById(R.id.update_status_confirm_button);
        cancelButton = (Button) findViewById(R.id.update_status_cancel_button);

        if (toolbar != null) {
            toolbar.setTitle(getResources().getString(R.string.update_status));
        }

        final CurrentStatusAdapter currentStatusAdapter = new CurrentStatusAdapter(userProfile, this);
        currentStatusButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                currentStatusPopup(currentStatusAdapter);
            }
        });

        newStatusTextView.setPaintFlags(newStatusTextView.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);

        SpinnerAdapter spinnerAdapter = new SpinnerAdapter(this, new ArrayList<>(Arrays.asList("R2C", "DND", "NA")));
        statusSpinner.setAdapter(spinnerAdapter);

        descriptionErrorTextView.setTextSize(helperTextSize);
        descriptionErrorTextView.setTextColor(red);
        descriptionCharacterCountTextView.setTextSize(helperTextSize);
        durationErrorTextView.setTextSize(helperTextSize);
        durationErrorTextView.setTextColor(red);

        statusDescriptionEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Drawable cross = getResources().getDrawable(android.R.drawable.presence_offline);
                cross.setBounds(0, 0, cross.getIntrinsicWidth(), cross.getIntrinsicHeight());

                if (s.length() != 0) {
                    statusDescriptionEditText.setCompoundDrawables(null, null, cross, null);
                } else {
                    statusDescriptionEditText.setCompoundDrawables(null, null, null, null);
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

        statusDescriptionEditText.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    try {
                        if (event.getRawX() >= (statusDescriptionEditText.getRight() -
                                statusDescriptionEditText.getCompoundDrawables()[2].getBounds().width())) {
                            statusDescriptionEditText.setText("");
                        }
                    } catch (Exception e) {
                    }
                }
                return false;
            }
        });

        durationEditText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                durationPopup();
            }
        });
        durationEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                durationErrorTextView.setText("");
            }
            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        final ChangeStatusGroupAdapter groupAdapter = new ChangeStatusGroupAdapter(userProfile, this);
        pickGroupsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (userProfile.getListOfFriendGroups().size() == 0) {
                    toast(getResources().getString(R.string.you_have_no_groups));
                }
                groupPopup(groupAdapter);
            }
        });

        confirmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateStatus();
            }
        });

        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    public void updateStatus() {
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

        String statusType = statusSpinner.getSelectedItem().toString();
        String statusDescription = statusDescriptionEditText.getText().toString();
        if ((hours == 0) && (minutes == 0) && ((statusType.equals("R2C") || (statusType.equals("DND"))))) {
            durationErrorTextView.setText(getResources().getString(R.string.invalid_duration));
            return;
        }
        if (!statusType.equals("NA")) {
            if (listOfGroupsToSend.size() == 0) {
                reDraw();
                return;
            }
        }
        if (!validDescription) {
            return;
        }

        progressBar.setVisibility(VISIBLE);
        isSpinning = true;

        _client.executeFunction("updateStatus", statusType, statusDescription, hours, minutes, listOfGroupsToSend).
                addOnCompleteListener(new OnCompleteListener<Object>() {
                    @Override
                    public void onComplete(@NonNull Task<Object> task) {
                        if (task.isSuccessful()) {
                            String converted = accountController.jsonToString(task.getResult())
                                    .replace("\"", "");
                            if (converted.equals("writeConcernError")) {
                                displayWarningOkAlertDialog(getResources().getString(R.string.update_status_write_concern));
                            } else if (converted.equals("writeError")) {
                                displayWarningOkAlertDialog(getResources().getString(R.string.update_status_write_error));
                            } else if (converted.equals("Successful update")) {
                                toast(getResources().getString(R.string.update_status_success));
                                finish();
                            } else {
                                displayWarningOkAlertDialog(getResources().getString(R.string.update_status_unknown_return));
                            }
                        } else {
                            displayWarningOkAlertDialog(getResources().getString(R.string.update_status_function_failure));
                        }
                        progressBar.setVisibility(GONE);
                        isSpinning = false;
                    }
                });
    }

    @Override
    public void reDraw() {
        int count = 0;
        groupListTextView.setText("");
        String statusType = statusSpinner.getSelectedItem().toString();

        if (listOfGroupsToSend.size() == 0) {
            if (statusType.equals("NA")) {
                return;
            }
            Spanned pleasePickGroups = Html.fromHtml("<font color='" +
                    red + "'>" + getResources().getString(R.string.please_select_groups) + "</font>");
            groupListTextView.setText(pleasePickGroups);
            return;
        }
        for (FriendGroup group : userProfile.getListOfFriendGroups()) {
            if (listOfGroupsToSend.contains(group.getGroupId())) {
                if (count > 0) {
                    groupListTextView.append(", ");
                }
                Spanned groupListName = Html.fromHtml("<font color='" +
                        group.getGroupTextColor() + "'>" + group.getFriendListName() + "</font>");
                groupListTextView.append(groupListName);
                count += 1;
            }
        }
    }

    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(R.anim.left_to_right_enter, R.anim.left_to_right_exit);
    }

    public void currentStatusPopup(ListViewAdapter adapter) {
        LayoutInflater inflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View layout = inflater.inflate(R.layout.popup_window_name_and_checkbox, null);

        int windowWidth = (int) (getResources().getDisplayMetrics().widthPixels * 0.94);
        int windowHeight = (int) (getResources().getDisplayMetrics().heightPixels * 0.4);

        final PopupWindow window = new PopupWindow(layout, windowWidth, windowHeight, true);

        window.setAnimationStyle(android.R.style.Animation_Dialog);
        window.setElevation(20);

        ListView popupWindowListView = (ListView) layout.findViewById(R.id.popup_window_listview);
        popupWindowListView.setAdapter(adapter);

        Button returnButton = layout.findViewById(R.id.popup_window_return_button);
        returnButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                window.dismiss();
            }
        });

        window.setOutsideTouchable(true);
        window.showAtLocation(layout, Gravity.CENTER, 0, -windowHeight/2);
    }

    public void durationPopup() {
        LayoutInflater inflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View layout = inflater.inflate(R.layout.duration_popup, null);

        int windowWidth = (int) (getResources().getDisplayMetrics().widthPixels * 0.94);
        int windowHeight = (int) (getResources().getDisplayMetrics().heightPixels * 0.4);

        final PopupWindow window = new PopupWindow(layout, windowWidth, windowHeight, true);

        window.setAnimationStyle(android.R.style.Animation_Dialog);
        window.setElevation(20);

        hourPicker = layout.findViewById(R.id.duration_hour_number_picker);
        hourPicker.setMinValue(0);
        hourPicker.setMaxValue(23);
        hourPicker.setValue(hours);
        minutePicker = layout.findViewById(R.id.duration_minutes_number_picker);
        minutePicker.setMinValue(0);
        minutePicker.setMaxValue(59);
        minutePicker.setValue(minutes);
        Button returnButton = layout.findViewById(R.id.duration_popup_window_return_button);
        returnButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setTime(hourPicker.getValue(), minutePicker.getValue());
                window.dismiss();
            }
        });

        window.setOutsideTouchable(true);
        window.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                setTime(hourPicker.getValue(), minutePicker.getValue());
            }
        });
        window.showAtLocation(layout, Gravity.CENTER, 0, 0);
    }

    public void setTime(int hours, int minutes) {
        this.hours = hours;
        this.minutes = minutes;

        String duration = Integer.toString(hours) + " hours " + Integer.toString(minutes) + " minutes";
        durationEditText.setText(duration);
    }

    private class CurrentStatusAdapter extends ListViewAdapter {
        private Context context;
        private ArrayList<String> dummyList = new ArrayList<>();
        private YourCurrentStatus yourCurrentStatus;

        public CurrentStatusAdapter(@NonNull UserProfile userProfile, Context context) {
            this.context = context;
            this.yourCurrentStatus = userProfile.getYourCurrentStatus();
            this.dummyList.add("1");
            String statusExpiryTime = yourCurrentStatus.getTimeUntil();
            if (!getReadableTimeIfStillValid(statusExpiryTime).equals("invalid")) {
                this.dummyList.add("2");
            }
        }

        @Override
        public int getCount() {
            return dummyList.size();
        }
        @Override
        public Object getItem(int pos) {
            return dummyList.get(pos);
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
                if (position == 0) {
                    view = inflater.inflate(R.layout.selected_group_list_item, parent, false);
                }
                if (position == 1) {
                    view = inflater.inflate(R.layout.your_status_groups_to, parent, false);
                    TextView groupsTextView = (TextView) view.findViewById(R.id.your_status_groups_to_textview);
                    String withSpace = getResources().getString(R.string.groups_sent_to) + " ";
                    groupsTextView.setText(withSpace);
                    int count = 0;
                    for (FriendGroup group : userProfile.getListOfFriendGroups()) {
                        if (yourCurrentStatus.getListOfGroups().contains(group.getGroupId())) {
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
            }

            if (position == 0) {
                TextView friendName = (TextView) view.findViewById(R.id.selected_group_list_friend_name);
                ImageView statusImage = (ImageView) view.findViewById(R.id.selected_group_image_view);
                TextView description = (TextView) view.findViewById(R.id.selected_group_list_friend_description);

                friendName.setText(userProfile.getUserName());
                friendName.setTextColor(getResources().getColor(R.color.white));

                if (yourCurrentStatus.isBusyOrR2C()) {
                    String statusTimeUntil = yourCurrentStatus.getTimeUntil();
                    String readableTime = getReadableTimeIfStillValid(statusTimeUntil);

                    description.setTextColor(getResources().getColor(R.color.white));
                    description.setText(yourCurrentStatus.getStatusDescription());
                    Spanned until = Html.fromHtml("<font color='#9d9d9d'>" + getResources().getString(R.string.until) + "</font>");

                    description.append(" ");
                    description.append(until);
                    description.append(" ");
                    description.append(readableTime);

                    if (yourCurrentStatus.getStatusType().equals("R2C")) {
                        statusImage.setImageDrawable(getResources().getDrawable(R.drawable.online));
                    } else if (yourCurrentStatus.getStatusType().equals("DND")) {
                        statusImage.setImageDrawable(getResources().getDrawable(R.drawable.busy));
                    } else {
                        statusImage.setImageDrawable(getResources().getDrawable(R.drawable.offline));
                    }
                } else {
                    description.setText(getResources().getString(R.string.not_available));
                }
            }
            return view;
        }
    }

    private class SpinnerAdapter extends ArrayAdapter<String> {
        private Context context;
        private ArrayList<String> stringArray = new ArrayList<>();

        public SpinnerAdapter(Context context, ArrayList<String> statuses) {
            super(context, R.layout.change_status_spinner_item, R.id.change_status_spinner_item_textview, statuses);
            this.context = context;
            this.stringArray = statuses;
        }

        @Override
        public int getCount() {
            return stringArray.size();
        }

        @Override
        public View getView(final int position, View convertView, ViewGroup parent) {
            View view = convertView;
            if (view == null) {
                LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                view = inflater.inflate(R.layout.change_status_spinner_item, parent, false);
            }

            String status = stringArray.get(position);
            TextView statusNameTextView = (TextView) view.findViewById(R.id.change_status_spinner_item_textview);

            ImageView statusNameImageView = (ImageView) view.findViewById(R.id.change_status_spinner_item_imageview);
            if (status.equals("R2C")) {
                statusNameTextView.setText(getResources().getString(R.string.ready_2_chill));
                statusNameImageView.setImageDrawable(getResources().getDrawable(R.drawable.online));
            } else if (status.equals("DND")) {
                statusNameTextView.setText(getResources().getString(R.string.do_not_disturb));
                statusNameImageView.setImageDrawable(getResources().getDrawable(R.drawable.busy));
            } else if (status.equals("NA")) {
                statusNameTextView.setText(getResources().getText(R.string.not_available));
                statusNameImageView.setImageDrawable(getResources().getDrawable(R.drawable.offline));
            }
            return view;
        }

        @Override
        public View getDropDownView(final int position, View convertView, ViewGroup parent) {
            return getView(position, convertView, parent);
        }
    }

    private class ChangeStatusGroupAdapter extends ListViewAdapter {
        private ArrayList<FriendGroup> completeGroupList;
        private Context context;

        public ChangeStatusGroupAdapter(@NonNull UserProfile userProfile, Context context) {
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

            TextView groupName = (TextView) view.findViewById(R.id.name_and_checkbox_textview);
            FriendGroup currentGroup = completeGroupList.get(position);
            final String groupId = currentGroup.getGroupId();
            groupName.setText(currentGroup.getFriendListName());
            groupName.setTextColor(currentGroup.getGroupTextColorInt());

            final CheckBox checkBox = (CheckBox) view.findViewById(R.id.name_and_checkbox_checkbox);
            if (listOfGroupsToSend.contains(currentGroup.getGroupId())) {
                checkBox.setChecked(true);
            } else {
                checkBox.setChecked(false);
            }

            checkBox.setOnClickListener(new View.OnClickListener() {
                public void onClick(View view) {
                    if (checkBox.isChecked()) {
                        if (!listOfGroupsToSend.contains(groupId)) {
                            listOfGroupsToSend.add(groupId);
                        }
                    } else {
                        if (listOfGroupsToSend.contains(groupId)) {
                            listOfGroupsToSend.remove(groupId);
                        }
                    }
                }
            });
            return view;
        }
    }
}
