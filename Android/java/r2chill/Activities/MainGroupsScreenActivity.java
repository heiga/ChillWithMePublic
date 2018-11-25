package example.r2chill.Activities;

import android.app.AlertDialog;
import android.app.Fragment;
import android.app.job.JobInfo;
import android.app.job.JobScheduler;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.app.ActivityOptionsCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v4.widget.DrawerLayout;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.support.v7.widget.Toolbar;

import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.mongodb.stitch.android.StitchClient;
import com.mongodb.stitch.android.auth.oauth2.google.GoogleAuthProvider;

import java.util.ArrayList;
import java.util.Locale;

import example.r2chill.Model.FriendGroup;
import example.r2chill.Model.UserProfile;
import example.r2chill.R;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

public class MainGroupsScreenActivity extends DatabaseActivity {
    private Toolbar mainToolBar;
    private ActionBarDrawerToggle actionBarDrawerToggle;
    private NavigationView navigationView;
    private DrawerLayout drawerLayout;
    private ProgressBar progressBar;
    private SwipeRefreshLayout mySwipeRefreshLayout;
    private ListView mainGroupScreenListView;
    private ImageView navigationStatusImageView;

    private JobScheduler mJobScheduler;

    private GoogleSignInClient mGoogleSignInClient;

    public static final int RC_SIGN_IN = 1;

    public void onReady(StitchClient stitchClient) {
        this._client = stitchClient;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.AppTheme_NoActionBar);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_groups_screen);

        mainToolBar = (Toolbar) findViewById(R.id.main_screen_toolbar);
        if (mainToolBar != null) {
            mainToolBar.setTitle(R.string.groups_screen_toolbar_title);
            mainToolBar.setTitleTextColor(Color.WHITE);
        }

        mainGroupScreenListView = (ListView) findViewById(R.id.main_screen_groupslistview);
        mainGroupScreenListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
                if (userProfile == null) {
                    accountController.loadProfileToAccountController(getApplicationContext());
                    userProfile = accountController.getUserProfile();
                }

                // arg2 is index
                Intent intent = new Intent(getApplicationContext(), SelectedGroupActivity.class);
                intent.putExtra("index", arg2);
                accountController.setNeedRefresh(false);
                startActivity(intent);
                overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
            }
        });

        mySwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.main_screen_swiperefresh);
        mySwipeRefreshLayout.setOnRefreshListener(
                new SwipeRefreshLayout.OnRefreshListener() {
                    @Override
                    public void onRefresh() {
                        initialize();
                    }
                }
        );

        progressBar = (ProgressBar) findViewById(R.id.main_screen_spinner);

        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(
                GoogleSignInOptions.DEFAULT_SIGN_IN).requestServerAuthCode(
                getString(R.string.new_server_client_id)).build();
        mGoogleSignInClient = GoogleSignIn.getClient(this, gso);
        accountController.setGoogleSignInClient(mGoogleSignInClient);

        navigationView = (NavigationView) findViewById(R.id.group_screen_navigation_view);
        navigationView.setNavigationItemSelectedListener(
                new NavigationView.OnNavigationItemSelectedListener() {

                    @Override
                    public boolean onNavigationItemSelected(final MenuItem menuItem) {
                        drawerLayout.closeDrawers();

                        if (menuItem.isChecked()) menuItem.setChecked(false);
                        else menuItem.setChecked(true);

                        Handler handler = new Handler();
                        Runnable r = new Runnable() {
                            public void run() {
                                switch (menuItem.getItemId()) {
                                    case R.id.login_button:
                                        if (accountController.checkInternetConnection(getApplicationContext())) {
                                            signIn();
                                        } else {
                                            toast(getResources().getString(R.string.no_internet));
                                        }
                                        break;

                                    case R.id.change_status_button:
                                        if (userProfile != null) {
                                            Intent changeStatusIntent = new Intent(getApplicationContext(),
                                                    UpdateStatusActivity.class);
                                            startActivity(changeStatusIntent);
                                            overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
                                        }
                                        break;

                                    case R.id.add_friend_button:
                                        if (userProfile != null) {
                                            Intent intentAddFriend = new Intent(getApplicationContext(),
                                                    AddOrEditFriendActivity.class);
                                            intentAddFriend.putExtra("addOrEdit", "add");
                                            startActivity(intentAddFriend);
                                            overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
                                        }
                                        break;

                                    case R.id.add_group_button:
                                        if (userProfile != null) {
                                            Intent intentAddGroup = new Intent(getApplicationContext(),
                                                    AddOrEditGroupActivity.class);
                                            intentAddGroup.putExtra("addOrEdit", "add");
                                            startActivity(intentAddGroup);
                                            overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
                                        }
                                        break;

                                    case R.id.friend_requests_button:
                                        if (userProfile != null) {
                                            Intent friendRequestIntent = new Intent(getApplicationContext(),
                                                    FriendRequestsActivity.class);
                                            startActivity(friendRequestIntent);
                                            overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
                                        }
                                        break;

                                    case R.id.help_button:
                                        emailSendDialog("help");
                                        break;

                                    case R.id.feedback_button:
                                        emailSendDialog("feedback");
                                        break;

                                    case R.id.logout_button:
                                        signOut();
                                        break;

                                    default:
                                        break;
                                }
                            }
                        };

                        // delay for drawer to close
                        handler.postDelayed(r, 250);

                        return true;
                    }
                });

        drawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        actionBarDrawerToggle = new ActionBarDrawerToggle(this,
                drawerLayout, mainToolBar, R.string.drawer_open, R.string.drawer_close) {

            @Override
            public void onDrawerClosed(View drawerView) {
                for (int i = 0; i < navigationView.getMenu().size(); i++) {
                    navigationView.getMenu().getItem(i).setChecked(false);
                }
                super.onDrawerClosed(drawerView);
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
            }
        };

        mJobScheduler = (JobScheduler) getSystemService(Context.JOB_SCHEDULER_SERVICE);
        JobInfo builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            builder = new JobInfo.Builder(1,
                    new ComponentName(getPackageName(), NotificationService.class.getName()))
                    .setMinimumLatency(REFRESH_INTERVAL)
                    //.setRequiresDeviceIdle(true)
                    .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
                    .build();
        } else {
            builder = new JobInfo.Builder( 1,
                    new ComponentName(getPackageName(), NotificationService.class.getName()))
                    .setPeriodic(REFRESH_INTERVAL)
                    //.setRequiresDeviceIdle(true)
                    .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
                    .build();
        }
        mJobScheduler.schedule(builder);

        drawerLayout.setDrawerListener(actionBarDrawerToggle);
        actionBarDrawerToggle.syncState();
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (accountController.isNeedRefresh()) {
            initialize();
        } else {
            accountController.setNeedRefresh(true);
        }
    }

    private void initialize() {
        Context appContext = this.getApplicationContext();
        // 1. Check if has internet
        // 1a. if not then check for profile file on file
        // 1a1. if profile is on file then render it to screen and toast no internet connection
        // 1a2. if profile not on file then there is nothing we can do, toast no internet
        boolean hasInternet = accountController.checkInternetConnection(appContext);
        if (!hasInternet) {
            if (accountController.isProfileOnFile(appContext)) {
                // loads profile from file to account controller
                if (accountController.loadProfileToAccountController(appContext).equals("Profile loaded successfully")) {
                    userProfile = accountController.getUserProfile();
                    reDraw();
                    setMenuIfLoggedInOrOut(true);
                } else {
                    // profile not loaded
                    setMenuIfLoggedInOrOut(false);
                }
            } else {
                // no profile on file
                setMenuIfLoggedInOrOut(false);
            }

            // no internet so no ability to add friend or group or change status or sign out
            toast(getResources().getString(R.string.no_internet));

        // 1b. there is internet connection
            // Check if signed in before
        } else {
            accountController.setGoogleSignInAccount(GoogleSignIn.getLastSignedInAccount(this));
            // Already signed in && has internet
            if (accountController.getGoogleSignInAccount() != null) {
                // been signed in before
                setMenuIfLoggedInOrOut(true);

                // Check database for profile
                if (accountController.isProfileOnFile(this)) {
                    accountController.loadProfileToAccountController(this);
                }

                if (_client != null) {
                    if (_client.isAuthenticated()) {
                        try {
                            if (accountController.getUserProfile() != null) {
                                progressBar.setVisibility(VISIBLE);
                                checkIfProfileUpdated();
                            } else {
                                progressBar.setVisibility(VISIBLE);
                                queryProfileFromDB();
                            }
                        } catch (Exception e) {
                            displayWarningOkAlertDialog(getResources().getString(R.string.error_check_if_profile_in_main_screen));
                        }
                    } else {
                        if (accountController.loadProfileToAccountController(appContext).equals("Profile loaded successfully")) {
                            reDraw();
                        }
                    }
                }
            } else {
                // if account is null then there should be no profile on file!!!
                // account is null if never signed in or if user signed out voluntarily
                signIn();
            }
        }
    }

    private void setMenuIfLoggedInOrOut(boolean loggedIn) {
        Menu menu = navigationView.getMenu();
        if (loggedIn) {
            menu.setGroupVisible(R.id.top_group, true);
            menu.setGroupVisible(R.id.bottom_group, true);
            menu.setGroupVisible(R.id.logged_out_group, false);
        } else {
            menu.setGroupVisible(R.id.top_group, false);
            menu.setGroupVisible(R.id.bottom_group, false);
            menu.setGroupVisible(R.id.logged_out_group, true);
        }
    }

    public void signIn() {
        if (!accountController.checkInternetConnection(this.getApplicationContext())) {
            longToast(getResources().getString(R.string.no_internet));
            return;
        }
        if (accountController.getGoogleSignInAccount() == null) {
            progressBar.setVisibility(VISIBLE);
            Intent signInIntent = mGoogleSignInClient.getSignInIntent();
            startActivityForResult(signInIntent, RC_SIGN_IN);

        } else {
            toast(getResources().getString(R.string.error_already_logged_in));
        }
        reDraw();
    }

    @Override
    public void reDraw() {
        try {
            View headerView = navigationView.getHeaderView(0);
            TextView navUsername = (TextView) headerView.findViewById(R.id.drawer_information);
            navigationStatusImageView = (ImageView) headerView.findViewById(R.id.main_screen_navigation_status);
            userProfile = accountController.getUserProfile();
            if (userProfile != null) {
                if (userProfile.getUserName() != null) {
                    // render username to navigation drawer
                    navUsername.setText(userProfile.getUserName());

                    // render number of friend requests to navigation drawer
                    int numberOfFriendRequests = userProfile.getNumberOfFriendRequests();
                    TextView friendRequestCount = (TextView) navigationView.getMenu().
                            findItem(R.id.friend_requests_button).getActionView();
                    friendRequestCount.setGravity(Gravity.CENTER_VERTICAL);
                    friendRequestCount.setTypeface(null, Typeface.BOLD);
                    friendRequestCount.setTextColor(getResources().getColor(R.color.white));
                    if (numberOfFriendRequests < 99) {
                        friendRequestCount.setText(Integer.toString(numberOfFriendRequests));
                    } else {
                        friendRequestCount.setText(getResources().getString(R.string.ninety_nine_plus));
                    }

                    if (userProfile.getYourCurrentStatus().isR2C()) {
                        navigationStatusImageView.setImageDrawable(getResources().getDrawable(R.drawable.online));
                    } else if (userProfile.getYourCurrentStatus().isBusy()) {
                        navigationStatusImageView.setImageDrawable(getResources().getDrawable(R.drawable.busy));
                    } else {
                        navigationStatusImageView.setImageDrawable(getResources().getDrawable(R.drawable.offline));
                    }

                    if (mainGroupScreenListView != null) {
                        MainGroupScreenAdapter adapter = new MainGroupScreenAdapter(userProfile, this);
                        mainGroupScreenListView.setAdapter(adapter);
                        progressBar.setVisibility(GONE);
                    }
                }
            } else {
                navUsername.setText(getResources().getString(R.string.not_signed_in));
                navigationStatusImageView.setImageDrawable(getResources().getDrawable(R.drawable.offline));
                if (mainGroupScreenListView.getAdapter() != null) {
                    mainGroupScreenListView.setAdapter(null);
                    progressBar.setVisibility(GONE);
                }
            }
        } catch (Exception e) {
            displayRegularOkAlertDialog(getString(R.string.main_screen_redraw_error_fatal));
        }

        if (mySwipeRefreshLayout.isRefreshing()) {
            mySwipeRefreshLayout.setRefreshing(false);
        }
        progressBar.setVisibility(GONE);
    }

    // called by GoogleSignIn after user signs in
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        Task<GoogleSignInAccount> task;
        try {
            task = GoogleSignIn.getSignedInAccountFromIntent(data);
        } catch (Exception e) {
            // clicked outside of login dialog
            toast(getResources().getString(R.string.account_not_selected));
            setMenuIfLoggedInOrOut(false);
            accountController.setNeedRefresh(false);
            progressBar.setVisibility(GONE);
            return;
        }

        final GoogleAuthProvider googleProvider;
        try {
            googleProvider =
                    GoogleAuthProvider.fromAuthCode(GoogleSignIn.getLastSignedInAccount(this).
                            getServerAuthCode());
        } catch (Exception e) {
            toast(getResources().getString(R.string.account_not_selected));
            setMenuIfLoggedInOrOut(false);
            accountController.setNeedRefresh(false);
            progressBar.setVisibility(GONE);
            return;
        }

        _client.logInWithProvider(googleProvider).addOnCompleteListener(new OnCompleteListener<String>() {
            @Override
            public void onComplete(@NonNull final Task<String> task) {
                if (task.isSuccessful()) {
                    accountController.setGoogleSignInAccount(GoogleSignIn.getLastSignedInAccount(getApplicationContext()));
                    // Check here if there is a profile in the DB
                    if (accountController.getGoogleSignInAccount() != null) {
                        queryProfileFromDB();
                    }
                    setMenuIfLoggedInOrOut(true);
                } else {
                    signOut();
                    displayWarningOkAlertDialog(getResources().getString(R.string.error_logging_into_mongodb));
                }
            }
        });
    }

    // This function
    // 1. Checks database for a profile
    // 1a. If no profile, go make a profile (CreateProfileActivity)
    // 2. If profile, check it against the one in file if exists
    // 2a. If it has not been updated, then render the one on file
    // 2b. If it has been updated, download from database and render it
    private void queryProfileFromDB() {
        if (!accountController.checkInternetConnection(this)) {
            return;
        }
        if (_client == null) {
            return;
        }
        if (!_client.isAuthenticated()) {
            return;
        }

        _client.executeFunction("checkForProfile").addOnCompleteListener(new OnCompleteListener<Object>() {
            @Override
            public void onComplete(@NonNull Task<Object> task) {
                if (task.isSuccessful()) {
                    String converted = accountController.jsonToString(task.getResult()).replace("\"", "");
                    if (converted.equals("false")) {
                        gotoCreateProfileActivity();
                    } else {
                        getProfileFromDB();
                    }
                } else {
                    longToast(getResources().getString(R.string.error_query_profile));
                    progressBar.setVisibility(GONE);
                }
            }
        });
    }

    private void gotoCreateProfileActivity() {
        progressBar.setVisibility(GONE);
        Intent createProfileIntent = new Intent(getApplicationContext(),
                CreateProfileActivity.class);
        startActivity(createProfileIntent);
        overridePendingTransition(R.anim.right_to_left_enter, R.anim.right_to_left_exit);
    }

    private void signOut() {
        progressBar.setVisibility(VISIBLE);

        accountController.setGoogleSignInAccount(null);
        accountController.deleteProfileFileFromDevice(
                getApplicationContext());
        accountController.setUserProfile(null);
        userProfile = null;
        setMenuIfLoggedInOrOut(false);

        mGoogleSignInClient.signOut()
                .addOnCompleteListener(this, new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        toast(getResources().getString(R.string.signed_out));
                        reDraw();
                    }
                });
    }

    public void composeEmail(String emailAddress, String subject) {
        Intent intent = new Intent(Intent.ACTION_SENDTO);
        intent.setData(Uri.parse("mailto:"));
        String[] emailArray = {emailAddress};
        intent.putExtra(Intent.EXTRA_EMAIL, emailArray);
        intent.putExtra(Intent.EXTRA_SUBJECT, subject);
        if (intent.resolveActivity(getPackageManager()) != null) {
            startActivity(intent);
        }
    }

    public void emailSendDialog(String type) {
        AlertDialog.Builder ad = new AlertDialog.Builder(this);
        if (type.equals("feedback")) {
            ad.setTitle(getResources().getString(R.string.feedback));
            ad.setMessage(getResources().getString(R.string.email_feedback));
            ad.setPositiveButton(R.string.yes,
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int arg1) {
                            composeEmail(getResources().getString(R.string.email_address_feedback),
                                    getResources().getString(R.string.feedback));
                        }
                    });
        } else {
            ad.setTitle(getResources().getString(R.string.help));
            ad.setMessage(getResources().getString(R.string.email_help));
            ad.setPositiveButton(R.string.yes,
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int arg1) {
                            composeEmail(getResources().getString(R.string.email_address_help),
                                    getResources().getString(R.string.help));
                        }
                    });
        }
        ad.setNegativeButton(R.string.no,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int arg1) {

                    }
                });
        ad.create().show();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        return super.onOptionsItemSelected(item);
    }

    private class MainGroupScreenAdapter extends BaseAdapter implements ListAdapter {
        private ArrayList<FriendGroup> groupList = new ArrayList<FriendGroup>();
        private Context context;

        public MainGroupScreenAdapter(@NonNull UserProfile userProfile, Context context) {
            this.groupList = (ArrayList<FriendGroup>) userProfile.getListOfFriendGroups().clone();
            this.groupList.add(0, userProfile.getCompleteFriendList());
            this.context = context;
        }

        @Override public int getCount() {
            return groupList.size();
        }
        @Override
        public Object getItem(int pos) {
            return groupList.get(pos);
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
                view = inflater.inflate(R.layout.group_list_item, parent, false);
            }

            FriendGroup currentGroup = groupList.get(position);
            TextView groupName = (TextView) view.findViewById(R.id.grouplistgroupname);
            groupName.setText(currentGroup.getFriendListName());
            groupName.setTextColor(currentGroup.getGroupTextColorInt());

            TextView groupDesc = (TextView) view.findViewById(R.id.grouplistgroupdesc);
            groupDesc.setText(currentGroup.getGroupDescription());

            TextView numberR2C = (TextView) view.findViewById(R.id.grouplistnumberready);
            String numberReadyFraction = Integer.toString(currentGroup.getNumberOfFriendsR2C()) +
                    "/" + Integer.toString(currentGroup.getTotalNumberOfFriends());
            String numberReady = Integer.toString(currentGroup.getNumberOfFriendsR2C());

            ImageView statusImage = view.findViewById(R.id.group_list_item_imageview);
            if (currentGroup.getNumberOfFriendsR2C() > 0) {
                numberR2C.setText(numberReady);
                numberR2C.setTextColor(getResources().getColor(R.color.white));
                statusImage.setImageDrawable(getResources().getDrawable(R.drawable.online));
            } else {
                numberR2C.setText("–");
                numberR2C.setTextColor(getResources().getColor(R.color.medium_grey));
                statusImage.setImageDrawable(null);
            }
            return view;
        }
    }
}
