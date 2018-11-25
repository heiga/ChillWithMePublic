package example.r2chill.Model;

import java.util.ArrayList;

public class UserProfile {
    private String userName;
    private YourCurrentStatus yourCurrentStatus;
    private FriendGroup completeFriendList;
    private ArrayList<FriendGroup> listOfFriendGroups;
    private ArrayList<String> friendRequestList;
    private String refreshToken;

    public UserProfile(String name, String newRefreshToken) {
        this.userName = name;
        this.refreshToken = newRefreshToken;
        this.listOfFriendGroups = new ArrayList<FriendGroup>();
        this.friendRequestList = new ArrayList<String>();
        this.yourCurrentStatus = new YourCurrentStatus();
        this.completeFriendList = new FriendGroup();
    }

    public UserProfile(String name, String newRefreshToken, ArrayList<FriendGroup> friendGroupList,
                       ArrayList<String> friendRequests, YourCurrentStatus status,
                       FriendGroup friendList) {
        this.userName = name;
        this.refreshToken = newRefreshToken;

        this.listOfFriendGroups = friendGroupList;
        this.friendRequestList = friendRequests;

        this.yourCurrentStatus = status;
        this.completeFriendList = friendList;
    }

    public UserProfile() {
        this.userName = "";
        this.refreshToken = "";
        this.listOfFriendGroups = new ArrayList<FriendGroup>();
        this.friendRequestList = new ArrayList<String>();
        this.yourCurrentStatus = new YourCurrentStatus();
        this.completeFriendList = new FriendGroup();
    }

    public FriendGroup getFriendListFromName(String name) {
        for (FriendGroup friendList : listOfFriendGroups) {
            if (friendList.getFriendListName().equals(name)) {
                return friendList;
            }
        }
        return null;
    }

    public boolean hasGroupsWithNotificationsOn() {
        for (FriendGroup group : this.listOfFriendGroups) {
            if (group.isNotificationsOn()) {
                return true;
            }
        }
        return false;
    }

    public int getNumberOfFriendRequests() {
        return friendRequestList.size();
    }

    public void setUserName(String username) {
        this.userName = username;
    }
    public String getUserName() {
        return this.userName;
    }

    public void setRefreshToken(String newRefreshToken) {
        this.refreshToken = newRefreshToken;
    }
    public String getRefreshToken() {
        return this.refreshToken;
    }

    public void setListOfFriendGroups(ArrayList<FriendGroup> friendGroups) {
        this.listOfFriendGroups = friendGroups;
    }
    public ArrayList<FriendGroup> getListOfFriendGroups() {
        return this.listOfFriendGroups;
    }

    public void setFriendRequestList(ArrayList<String> requestList) {
        this.friendRequestList = requestList;
    }
    public ArrayList<String> getFriendRequestList() {
        return this.friendRequestList;
    }

    public void setYourCurrentStatus(YourCurrentStatus status) {
        this.yourCurrentStatus = status;
    }
    public YourCurrentStatus getYourCurrentStatus() {
        return yourCurrentStatus;
    }

    public void setCompleteFriendList(FriendGroup friendList) {
        this.completeFriendList = friendList;
    }
    public FriendGroup getCompleteFriendList() {
        return this.completeFriendList;
    }
}
