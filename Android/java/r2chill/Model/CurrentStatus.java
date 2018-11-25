package example.r2chill.Model;

public class CurrentStatus {
    private String statusType;
    private String statusDescription;
    private String timeUntil;
    private String refreshToken;

    private String R2CStatus = "R2C";
    private String NA = "NA";
    private String DND = "DND";

    public CurrentStatus(String id, String description, String time) {
        this.statusType = id;
        this.statusDescription = description;
        this.timeUntil = time;
        this.refreshToken = "";
    }

    // Blank status constructor
    public CurrentStatus() {
        this.statusType = NA;
        this.statusDescription = "Not available";
        this.timeUntil = "0000000000";
        this.refreshToken = "";
    }

    public boolean isBusyOrR2C() {
        String statusType = getStatusType();

        if (statusType.equals("R2C") || statusType.equals("DND")) {
            long time = System.currentTimeMillis() / 1000;
            long statusTime = Long.parseLong(this.getTimeUntil());
            if (statusTime > time) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public boolean isR2C() {
        if (this.statusType.equals("R2C")) {
            long time = System.currentTimeMillis() / 1000;
            long statusTime = Long.parseLong(this.getTimeUntil());
            if (statusTime > time) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public boolean isBusy() {
        if (this.statusType.equals("DND")) {
            long time = System.currentTimeMillis() / 1000;
            long statusTime = Long.parseLong(this.getTimeUntil());
            if (statusTime > time) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public String getRefreshToken() {
        return this.refreshToken;
    }

    public void setRefreshToken(String token) {
        this.refreshToken = token;
    }

    public void setStatusType(String status) {
        this.statusType = status;
    }

    public void setStatusDescription(String desc) {
        this.statusDescription = desc;
    }

    public void setTimeUntil(String time) {
        this.timeUntil = time;
    }

    public String getStatusType() {
        return this.statusType;
    }

    public String getStatusDescription() {
        return this.statusDescription;
    }

    public String getTimeUntil() {
        return this.timeUntil;
    }
}
