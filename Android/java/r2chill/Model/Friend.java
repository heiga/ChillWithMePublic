package example.r2chill.Model;

import android.graphics.Color;

import java.util.ArrayList;
import java.util.Date;

public class Friend {
    private String ownerUsername;
    private String alias;
    private String description;
    private String textColor;
    private CurrentStatus currentStatus;
    private boolean acknowledged;

    private ArrayList<String> listOfGroupIds;

    public Friend(String userName, String name, String descript, String color,
                  CurrentStatus currentStatus, ArrayList<String> groupList) {
        this.ownerUsername = userName;
        this.alias = name;
        this.description = descript;
        this.textColor = color;
        this.currentStatus = currentStatus;
        this.acknowledged = false;
        this.listOfGroupIds = groupList;
    }

    public Friend() {
        this.ownerUsername = null;
        this.alias = null;
        this.description = null;
        this.textColor = "#FFFFFF";
        this.currentStatus = new CurrentStatus();
        this.acknowledged = false;
        this.listOfGroupIds = new ArrayList<String>();
    }

    public boolean isR2C() {
        return this.currentStatus.isR2C();
    }

    public boolean isBusy() {
        return this.currentStatus.isBusy();
    }

    public void setOwnerUsername(String newEmail) {
        ownerUsername = newEmail;
    }

    public String getOwnerUsername() {
        return ownerUsername;
    }

    public void setAlias(String newAlias) {
        alias = newAlias;
    }

    public String getAlias() {
        return alias;
    }

    public void setDescription(String newDescription) {
        description = newDescription;
    }

    public String getDescription() {
        return description;
    }

    public void setTextColor(String color) {
        this.textColor = color;
    }

    public String getTextColor() {
        return this.textColor;
    }
    public int getTextColorInt() {
        if (this.textColor.length() == 8) {
            return Color.parseColor("#" + this.textColor.substring(2));
        }
        return Color.parseColor(this.textColor);
    }

    public void setCurrentStatus(CurrentStatus updatedStatus) {
        this.currentStatus = updatedStatus;
    }

    public CurrentStatus getCurrentStatus() {
        return currentStatus;
    }

    public void setAcknowledged(boolean ack) {
        this.acknowledged = ack;
    }

    public boolean isAcknowledged() {
        return this.acknowledged;
    }

    public void setListOfGroupIds(ArrayList<String> list) {
        this.listOfGroupIds = list;
    }
    public ArrayList<String> getListOfGroupIds() {
        return this.listOfGroupIds;
    }
}
