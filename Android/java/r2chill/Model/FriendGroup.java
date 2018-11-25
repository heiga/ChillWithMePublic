package example.r2chill.Model;

import android.graphics.Color;

import java.util.ArrayList;

public class FriendGroup {
    private String friendListName;
    private String groupTextColor;
    private String groupId;

    private String groupDescription;
    private boolean notificationsOn;

    private ArrayList<String> listOfFriendsUsernames;
    private ArrayList<Friend> friendArrayList;

    public FriendGroup(String groupName, String groupDescription, boolean notifications,
                       String textColor, String groupId,
                       ArrayList<String> listOfFriends) {

        this.friendListName = groupName;
        this.groupTextColor = textColor;
        this.groupId = groupId;
        this.groupDescription = groupDescription;
        this.notificationsOn = notifications;
        this.listOfFriendsUsernames = listOfFriends;
        this.friendArrayList = new ArrayList<Friend>();
    }

    public FriendGroup() {
        this.friendListName = "Friend List";
        this.groupTextColor = "#FFFFFF";
        this.groupId = "";
        this.groupDescription = "";
        this.notificationsOn = false;
        this.listOfFriendsUsernames = new ArrayList<String>();
        this.friendArrayList = new ArrayList<Friend>();
    }

    public int getTotalNumberOfFriends() {
        return friendArrayList.size();
    }

    public int getNumberOfFriendsR2C() {
        int friendsReady = 0;
        for (Friend friend : friendArrayList) {
            if (friend.isR2C()) friendsReady += 1;
        }
        return friendsReady;
    }

    public Friend getFriendFromUsername(String username) {
        for (Friend friend : friendArrayList) {
            if (friend.getOwnerUsername().equals(username)) return friend;
        }
        return null;
    }

    public void addFriend(Friend friend) {
        this.friendArrayList.add(friend);
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
        if (this.groupTextColor.length() == 8) {
            return Color.parseColor("#" + this.groupTextColor.substring(2));
        }
        return Color.parseColor(this.groupTextColor);
    }

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public void setGroupDescription(String groupDescription) {
        this.groupDescription = groupDescription;
    }
    public String getGroupDescription() {
        return this.groupDescription;
    }

    public void setNotifications(boolean notifications) {
        this.notificationsOn = notifications;
    }
    public boolean isNotificationsOn() {
        return this.notificationsOn;
    }

    public void setFriendArrayList(ArrayList<Friend> friendArrayList) {
        this.friendArrayList = friendArrayList;
    }
    public ArrayList<Friend> getFriendArrayList() {
        return this.friendArrayList;
    }

    public ArrayList<String> getListOfFriendsUsernames() {
        return listOfFriendsUsernames;
    }

    public void setListOfFriendsUsernames(ArrayList<String> listOfFriendsUsernames) {
        this.listOfFriendsUsernames = listOfFriendsUsernames;
    }
}
