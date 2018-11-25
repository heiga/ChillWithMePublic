package example.r2chill.Model;

import java.util.ArrayList;

public class YourCurrentStatus extends CurrentStatus {
    private ArrayList<String> listOfGroupIds;
    private ArrayList<String> listOfFriends;

    public ArrayList<String> getListOfGroups() {
        return listOfGroupIds;
    }
    public void setListOfGroupIds(ArrayList<String> listOfGroupIds) {
        this.listOfGroupIds = listOfGroupIds;
    }
    public ArrayList<String> getListOfFriends() {
        return this.listOfFriends;
    }
    public void setListOfFriends(ArrayList<String> listOfFriends) {
        this.listOfFriends = listOfFriends;
    }

    public YourCurrentStatus(String id, String desc, String time, ArrayList<String> friendGroupIdList,
                             ArrayList<String> listOfFriends) {
        super(id, desc, time);
        this.listOfGroupIds = friendGroupIdList;
        this.listOfFriends = listOfFriends;
    }

    public YourCurrentStatus() {
        super();
        this.listOfGroupIds = new ArrayList<String>();
        this.listOfFriends = new ArrayList<String>();
    }
}
