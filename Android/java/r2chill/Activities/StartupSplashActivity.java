package example.r2chill.Activities;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import example.r2chill.Model.AccountController;
import example.r2chill.R;

public class StartupSplashActivity extends AppCompatActivity {
    AccountController accountController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        accountController = AccountController.getInstance(getApplicationContext());

        Intent intent = new Intent(this, MainGroupsScreenActivity.class);
        startActivity(intent);
        finish();
    }
}
