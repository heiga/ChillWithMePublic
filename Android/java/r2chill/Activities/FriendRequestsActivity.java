package example.r2chill.Activities;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.widget.SwipeRefreshLayout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import java.util.ArrayList;

import example.r2chill.Model.UserProfile;
import example.r2chill.R;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

public class FriendRequestsActivity extends DatabaseActivity {
    private ProgressBar progressBar;
    private SwipeRefreshLayout mySwipeRefreshLayout;
    private ListView friendRequestListView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_friend_requests);

        progressBar = (ProgressBar) findViewById(R.id.friend_request_spinner);
        friendRequestListView = (ListView) findViewById(R.id.friend_request_listview);
        mySwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.friend_request_swiperefresh);
        mySwipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                refreshAndReDraw();
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        refreshAndReDraw();
    }

    private void refreshAndReDraw() {
        if (_client == null) {
            toast(getResources().getString(R.string.authentication_error));
            return;
        }
        if (!accountController.checkInternetConnection(this)) {
            toast(getResources().getString(R.string.waiting_for_connection));
            return;
        }

        checkIfProfileUpdated();
    }

    public void reDraw() {
        userProfile = accountController.getUserProfile();
        FriendRequestsAdapter adapter = new FriendRequestsAdapter(userProfile, this);
        friendRequestListView.setAdapter(adapter);

        if (mySwipeRefreshLayout.isRefreshing()) {
            mySwipeRefreshLayout.setRefreshing(false);
        }
        progressBar.setVisibility(GONE);
    }

    private class FriendRequestsAdapter extends BaseAdapter implements ListAdapter {
        private ArrayList<String> friendRequests;
        private Context context;

        public FriendRequestsAdapter(@NonNull UserProfile userProfile, Context context) {
            this.friendRequests = userProfile.getFriendRequestList();
            this.context = context;
        }

        @Override
        public int getCount() {
            return friendRequests.size();
        }
        @Override
        public Object getItem(int pos) {
            return friendRequests.get(pos);
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
                view = inflater.inflate(R.layout.friend_request_item, parent, false);
            }

            final String friendUsername = friendRequests.get(position);
            TextView friendUsernameTextView = (TextView) view.findViewById(R.id.friend_request_textview);
            friendUsernameTextView.setText(friendUsername);

            Button acceptButton = (Button) view.findViewById(R.id.friend_request_accept_button);
            acceptButton.setOnClickListener(new View.OnClickListener() {
                public void onClick(View view) {
                    addFriend(friendUsername);
                }
            });

            Button deleteButton = (Button) view.findViewById(R.id.friend_request_delete_button);
            deleteButton.setOnClickListener(new View.OnClickListener() {
                public void onClick(View view) {
                    displayWarningDeleteFriendRequestDialog(friendUsername);
                }
            });

            return view;
        }
    }

    public void addFriend(String username) {
        Intent intent = new Intent(getApplicationContext(), AddOrEditFriendActivity.class);
        intent.putExtra("fromFriendRequest", true);
        intent.putExtra("friendUsername", username);
        startActivity(intent);
        overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
    }

    public void deleteFriendRequest(String username) {
        if (_client == null) {
            toast(getResources().getString(R.string.no_internet));
            return;
        }
        progressBar.setVisibility(VISIBLE);
        _client.executeFunction("deleteFriendRequest", username).addOnCompleteListener(
                new OnCompleteListener<Object>() {
                    @Override
                    public void onComplete(@NonNull Task<Object> task) {
                        if (task.isSuccessful()) {
                            String converted = accountController.jsonToString(task.getResult()).
                                    replace("\"", "");

                            if (converted.equals("Successful delete")) {
                                toast(getResources().getString(R.string.friend_request_deleted));
                                refreshAndReDraw();
                            } else {
                                displayWarningOkAlertDialog(getResources().getString(R.string.delete_friend_request_error));
                                progressBar.setVisibility(GONE);
                            }
                        } else {
                            displayWarningOkAlertDialog(getResources().getString(R.string.delete_friend_request_error_2));
                            progressBar.setVisibility(GONE);
                        }
                    }
                }
        );
    }

    public void displayWarningDeleteFriendRequestDialog(final String username) {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        ad.setTitle(getResources().getString(R.string.warning));
        String message = getResources().getString(R.string.are_you_sure_you_want_to_delete) +
                " " + username + getResources().getString(R.string.s_friend_request);
        ad.setMessage(message);
        ad.setPositiveButton(R.string.yes,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {
                        deleteFriendRequest(username);
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
    public void finish() {
        super.finish();
        overridePendingTransition(R.anim.left_to_right_enter, R.anim.left_to_right_exit);
    }

    public void signIn() {}
}
