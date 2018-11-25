package example.r2chill.Model;

import android.graphics.Color;

import java.util.ArrayList;

public class FriendList {
    private String friendListName;
    private String groupTextColor;

    public FriendList(String nameOfFriendList, String color) {
        this.friendListName = nameOfFriendList;
        this.groupTextColor = color;
    }

    public FriendList() {
        this.friendListName = "Friend List";
        this.groupTextColor = "#FFFFFF";
    }

    public void setFriendListName(String name) {
        this.friendListName = name;
    }
    public String getFriendListName() {
        return friendListName;
    }

    public void setGroupTextColor(String color) {
        this.groupTextColor = color;
    }
    public String getGroupTextColor() {
        return this.groupTextColor;
    }
    public int getGroupTextColorInt() {
        return Color.parseColor(this.groupTextColor);
    }
}
