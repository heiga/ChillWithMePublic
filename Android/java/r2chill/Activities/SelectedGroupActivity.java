package example.r2chill.Activities;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.widget.SwipeRefreshLayout;

import android.text.Html;
import android.text.Spanned;
import android.text.util.Linkify;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.PopupMenu;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.support.v7.widget.Toolbar;
import android.support.v7.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.mongodb.stitch.android.StitchClient;

import java.util.ArrayList;

import example.r2chill.Model.Friend;
import example.r2chill.Model.FriendGroup;
import example.r2chill.Model.UserProfile;
import example.r2chill.R;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

public class SelectedGroupActivity extends DatabaseActivity {
    private ListView selectedGroupListView;
    private Toolbar selectedGroupToolbar;
    private SwipeRefreshLayout mySwipeRefreshLayout;
    private ProgressBar progressBar;

    private int index;

    public void onReady(StitchClient stitchClient) {
        this._client = stitchClient;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_selected_group);

        progressBar = (ProgressBar) findViewById(R.id.selected_group_screen_spinner);

        userProfile = accountController.getUserProfile();

        index = getIntent().getIntExtra("index", 0);

        selectedGroupListView = (ListView) findViewById(R.id.selected_group_screen_groupslistview);
        selectedGroupListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
                String friendUsername;
                if (userProfile != null) {
                    // a group with description
                    if (index != 0) {
                        if (arg2 == 0) {
                            // go to edit group activity
                            editGroup();
                            return;
                        }
                    }
                    if (index == 0) {
                        friendUsername = userProfile.getCompleteFriendList().
                                getFriendArrayList().get(arg2).getOwnerUsername();
                    } else {
                        friendUsername = userProfile.getListOfFriendGroups().get(index - 1).
                                getFriendArrayList().get(arg2 - 1).getOwnerUsername();
                    }

                    if (friendUsername != null) {
                        editFriend(friendUsername);
                    }
                }
            }
        });

        mySwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.selected_group_screen_swiperefresh);
        mySwipeRefreshLayout.setOnRefreshListener(
                new SwipeRefreshLayout.OnRefreshListener() {
                    @Override
                    public void onRefresh() {
                        refresh();
                    }
                }
        );

        selectedGroupToolbar = (Toolbar) findViewById(R.id.selected_group_screen_toolbar);
        setToolbarTitle(index);

        if (index != 0) {
            setSupportActionBar(selectedGroupToolbar);
        }
    }

    private void setToolbarTitle(int index) {
        if (selectedGroupToolbar != null) {
            if (index == 0) {
                selectedGroupToolbar.setTitle(R.string.friend_list);
            } else {
                selectedGroupToolbar.setTitle(
                        userProfile.getListOfFriendGroups().get(index - 1).getFriendListName());
                selectedGroupToolbar.setTitleTextColor(
                        userProfile.getListOfFriendGroups().get(index - 1).getGroupTextColorInt());
            }
        }
    }

    @Override
    public void onBackPressed() {
        finish();
        overridePendingTransition(R.anim.left_to_right_enter, R.anim.left_to_right_exit);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.selected_group_toolbar_menu, menu);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        switch (id) {
            case R.id.selected_group_toolbar_edit_group:
                editGroup();
                break;

            case R.id.selected_group_toolbar_delete_group:
                if (index > 0) {
                    FriendGroup friendGroup = userProfile.getListOfFriendGroups().get(index - 1);
                    displayWarningDeleteGroupDialog(friendGroup);
                }
                break;
        }
        return super.onOptionsItemSelected(item);
    }

    public void editFriend(String username) {
        Intent intent = new Intent(getApplicationContext(), AddOrEditFriendActivity.class);
        intent.putExtra("addOrEdit", "edit");
        intent.putExtra("friendUsername", username);
        startActivity(intent);
        overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
    }

    public void editGroup() {
        Intent intent = new Intent(getApplicationContext(), AddOrEditGroupActivity.class);
        intent.putExtra("addOrEdit", "edit");
        intent.putExtra("groupIndex", index - 1);
        startActivity(intent);
        overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
    }


    public void deleteFriend(String username) {
        if (_client == null) {
            toast(getResources().getString(R.string.authentication_error));
            return;
        }
        if (!accountController.checkInternetConnection(this) || (!_client.isAuthenticated())) {
            toast(getResources().getString(R.string.waiting_for_connection));
            return;
        }

        progressBar.setVisibility(VISIBLE);
        _client.executeFunction("deleteFriend", username).addOnCompleteListener(
                new OnCompleteListener<Object>() {
                    @Override
                    public void onComplete(@NonNull Task<Object> task) {
                        if (task.isSuccessful()) {
                            String converted = accountController.jsonToString(task.getResult()).
                            replace("\"", "");

                            if (converted.equals("Invalid input")) {
                                displayWarningOkAlertDialog(getResources().getString(
                                        R.string.selected_group_delete_friend_invalid_username));
                                progressBar.setVisibility(GONE);
                            } else if (converted.equals("writeConcernError")) {
                                displayWarningOkAlertDialog(getResources().getString(
                                        R.string.selected_group_delete_friend_write_concern_error));
                                refresh();
                            } else if (converted.equals("writeError")) {
                                displayWarningOkAlertDialog(getResources().getString(
                                        R.string.selected_group_delete_friend_write_error));
                                refresh();
                            } else if (converted.equals("Successful delete")) {
                                toast(getResources().getString(R.string.friend_deleted));
                                refresh();
                            } else {
                                displayWarningOkAlertDialog(getResources().getString(
                                        R.string.selected_group_delete_friend_unknown_return));
                                progressBar.setVisibility(GONE);
                            }
                        } else {
                            displayWarningOkAlertDialog(getResources().getString(
                                    R.string.selected_group_delete_friend_backend_failure));
                            progressBar.setVisibility(GONE);
                        }

                    }
                }
        );
    }

    public void deleteGroup(String groupId) {
        if (_client == null) {
            toast(getResources().getString(R.string.authentication_error));
            return;
        }
        if (!accountController.checkInternetConnection(this) || (!_client.isAuthenticated())) {
            toast(getResources().getString(R.string.waiting_for_connection));
            return;
        }

        progressBar.setVisibility(VISIBLE);
        _client.executeFunction("deleteGroup", groupId).addOnCompleteListener(
                new OnCompleteListener<Object>() {
                    @Override
                    public void onComplete(@NonNull Task<Object> task) {
                        if (task.isSuccessful()) {
                            String converted = accountController.jsonToString(task.getResult()).
                                    replace("\"", "");

                            if (converted.equals("Invalid input")) {
                                displayWarningOkAlertDialog(getResources().getString(
                                        R.string.selected_group_delete_group_invalid_id));
                                progressBar.setVisibility(GONE);
                            } else if (converted.equals("writeConcernError")) {
                                toast(getResources().getString(R.string.selected_group_delete_group_write_concern_error));
                                finish();
                            } else if (converted.equals("writeError")) {
                                toast(getResources().getString(R.string.selected_group_delete_group_write_error));
                                finish();
                            } else if (converted.equals("Successful delete")) {
                                toast(getResources().getString(R.string.group_deleted));
                                finish();
                            } else {
                                displayWarningOkAlertDialog(getResources().getString(
                                        R.string.selected_group_delete_group_unknown_return));
                                progressBar.setVisibility(GONE);
                            }
                        } else {
                            displayWarningOkAlertDialog(getResources().getString(
                                    R.string.selected_group_delete_group_backend_failure));
                            progressBar.setVisibility(GONE);
                        }
                    }
                }
        );
    }


    public void displayWarningDeleteFriendDialog(String username, String alias, String color) {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setTitle(getResources().getString(R.string.warning));
        Spanned friendName = Html.fromHtml("<font color='" +
                color + "'>" + alias + "</font>");
        Spanned string = Html.fromHtml(getResources().getString(R.string.are_you_sure_you_want_to_delete) +
                        " " + friendName + " (" + username + ")?");
        ad.setMessage(string);

        final String usernameToDelete = username;

        ad.setPositiveButton(R.string.yes,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        deleteFriend(usernameToDelete);
                    }
                });

        ad.setNegativeButton(R.string.no,
                new DialogInterface.OnClickListener() {
                     public void onClick(DialogInterface dialog, int arg1) {
                     }
                });

        ad.create().show();
    }

    public void displayWarningDeleteGroupDialog(FriendGroup group) {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setTitle(getResources().getString(R.string.warning));
        String message = getResources().getString(R.string.are_you_sure_you_want_to_delete) +
                " " + group.getFriendListName() + "?";
        final String groupIdToDelete = group.getGroupId();
        ad.setMessage(message);
        ad.setPositiveButton(R.string.yes,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        deleteGroup(groupIdToDelete);
                    }
                });
        ad.setNegativeButton(R.string.no,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                    }
                });
        ad.create().show();
    }

    @Override
    protected void onStart() {
        super.onStart();

        // if coming from main screen, profile should be loaded into accountController already
        if (userProfile == null) {
            if (accountController.isProfileOnFile(getApplicationContext())) {
                accountController.loadProfileToAccountController(getApplicationContext());
                userProfile = accountController.getUserProfile();
            } else {
                toast(getResources().getString(R.string.selected_group_onstart_error));
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (accountController.isNeedRefresh()) {
            refresh();
        } else {
            reDraw();
            accountController.setNeedRefresh(true);
        }
    }

    public void refresh() {
        Context appContext = this.getApplicationContext();
        boolean hasInternet = accountController.checkInternetConnection(appContext);

        if (_client == null || !_client.isAuthenticated()) {
            toast(getResources().getString(R.string.authentication_error));
            if (mySwipeRefreshLayout.isRefreshing()) {
                mySwipeRefreshLayout.setRefreshing(false);
            }
            return;
        }
        // if no internet or no connection to server do nothing
        if ((!hasInternet)) {
            toast(getResources().getString(R.string.no_internet));
            if (mySwipeRefreshLayout.isRefreshing()) {
                mySwipeRefreshLayout.setRefreshing(false);
            }
        } else {
            // if has internet, pull from DB
            progressBar.setVisibility(VISIBLE);
            getProfileFromDB();
        }
    }

    @Override
    public void reDraw() {
        SelectedGroupScreenAdapter  adapter =
                new SelectedGroupScreenAdapter(userProfile, index, this);
        selectedGroupListView.setAdapter(adapter);

        if (index != 0) {
            FriendGroup friendGroup = userProfile.getListOfFriendGroups().get(index - 1);
            selectedGroupToolbar.setTitleTextColor(friendGroup.getGroupTextColorInt());
            setToolbarTitle(index);
        }

        if (mySwipeRefreshLayout.isRefreshing()) {
            mySwipeRefreshLayout.setRefreshing(false);
        }
        progressBar.setVisibility(GONE);
    }

    @Override
    public void signIn() {
        finish();
    }

    private class SelectedGroupScreenAdapter extends BaseAdapter implements ListAdapter {
        private ArrayList<Friend> friendList = new ArrayList<Friend>();
        private Context context;
        private String description;
        private int index;

        public SelectedGroupScreenAdapter(@NonNull UserProfile userProfile, int index, Context context) {
            this.context = context;
            this.index = index;
            if (index == 0) {
                this.friendList = userProfile.getCompleteFriendList().getFriendArrayList();
                description = "";
            } else {
                this.friendList = userProfile.getListOfFriendGroups().get(index - 1).getFriendArrayList();
                description = userProfile.getListOfFriendGroups().get(index - 1).getGroupDescription();
            }
        }

        @Override
        public int getCount() {
            if (index != 0) {
                return friendList.size() + 1;
            } else {
                return friendList.size();
            }
        }
        @Override
        public Object getItem(int pos) {
            if (index != 0) {
                if (pos > 0) {
                    return friendList.get(pos - 1);
                } else {
                    return null;
                }

            } else {
                return friendList.get(pos);
            }
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

                // if completeFriendList only need to inflate the list items
                if (index == 0) {
                    view = inflater.inflate(R.layout.selected_group_list_item, parent, false);
                } else {
                    // if not completeFriendList then have to inflate one for position
                    if (position == 0) {
                        view = inflater.inflate(R.layout.selected_group_description_item, parent, false);
                    } else {
                        view = inflater.inflate(R.layout.selected_group_list_item, parent, false);
                    }
                }
            }

            Friend currentFriend = new Friend();
            // if NOT completeFriendList
            if (index != 0) {
                // first item is description
                if (position == 0) {
                    TextView groupDesc = (TextView) view.findViewById(R.id.selected_group_desc);
                    groupDesc.setText(description);
                    TextView notification = (TextView) view.findViewById(R.id.selected_group_notification_status);
                    if (userProfile.getListOfFriendGroups().get(index - 1).isNotificationsOn()) {
                        notification.setText(R.string.on);
                        notification.setTextColor(getResources().getColor(R.color.red));
                    } else {
                        notification.setText(R.string.off);
                    }
                } else {
                    // every other item is from list
                    currentFriend = friendList.get(position - 1);
                }
            } else {
                // if IS completeFriendList (index == 0)
                currentFriend = friendList.get(position);
            }

            if ((position != 0) | ((index == 0) & (position == 0))) {
                TextView friendName = (TextView) view.findViewById(R.id.selected_group_list_friend_name);
                final String username = currentFriend.getOwnerUsername();
                final String alias = currentFriend.getAlias();
                final String friendColor = currentFriend.getTextColor();
                friendName.setText(currentFriend.getAlias());
                friendName.setTextColor(currentFriend.getTextColorInt());

                TextView friendDesc = (TextView) view.findViewById(R.id.selected_group_list_friend_description);
                ImageView statusImage = (ImageView) view.findViewById(R.id.selected_group_image_view);

                ImageButton kebab = (ImageButton) view.findViewById(R.id.selected_group_kebab);
                kebab.setOnClickListener(new View.OnClickListener() {
                    public void onClick(View view) {
                        try {
                            showPopup(view, username, alias, friendColor);
                        } catch (Exception e) {
                            displayWarningOkAlertDialog(e.getMessage());
                        }
                    }
                });

                String statusTimeUntil = currentFriend.getCurrentStatus().getTimeUntil();
                String readableTime = getReadableTimeIfStillValid(statusTimeUntil);
                if ((currentFriend.isR2C() || currentFriend.isBusy()) &&
                        (!readableTime.equals("invalid"))) {
                    friendDesc.setTextColor(getResources().getColor(R.color.white));
                    Spanned until = Html.fromHtml("<font color='#9d9d9d'>" + getResources().getString(R.string.until) + "</font>");

                    friendDesc.setText(currentFriend.getCurrentStatus().getStatusDescription());
                    friendDesc.append(" ");
                    friendDesc.append(until);
                    friendDesc.append(" ");
                    friendDesc.append(readableTime);
                } else {
                    friendDesc.setText(getResources().getString(R.string.not_available));
                }
                if (currentFriend.isR2C()) {
                    statusImage.setImageDrawable(getResources().getDrawable(R.drawable.online));
                } else if (currentFriend.isBusy()) {
                    statusImage.setImageDrawable(getResources().getDrawable(R.drawable.busy));
                } else {
                    statusImage.setImageDrawable(getResources().getDrawable(R.drawable.offline));
                }
            }
            return view;
        }

        public void showPopup(View view, final String username, final String alias, final String color) {
            PopupMenu popup = new PopupMenu(getApplicationContext(), view);
            MenuInflater inflater = popup.getMenuInflater();
            inflater.inflate(R.menu.selected_group_item, popup.getMenu());

            popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                @Override
                public boolean onMenuItemClick(MenuItem item) {
                    switch (item.getItemId()) {
                        case R.id.selected_group_kebab_view_or_edit:
                            editFriend(username);
                            return true;
                        case R.id.selected_group_kebab_delete:
                            displayWarningDeleteFriendDialog(username, alias, color);
                            return true;
                    default:
                        return false;

                    }
                }
            });
            popup.show();
        }
    }
}
