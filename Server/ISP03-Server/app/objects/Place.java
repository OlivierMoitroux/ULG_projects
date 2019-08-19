package objects;

import java.util.Date;

/******************************************************************************
 * PLACE CLASS
 * A place is represented by geographical coordinates (latitude, longitude), a
 * date and time, and a boolean that states whether the place has already been
 * used for location clustering or not.
 ******************************************************************************/

public class Place {

    private double latitude;
    private double longitude;
    private Date time;
    private boolean isTreated;

    /**************************************************************************
     * CONSTRUCTOR
     * @param latitude the latitude of the place
     * @param longitude the longitude of the place
     * @param time the date and hour at which it has been collected
     **************************************************************************/

    public Place(double latitude, double longitude, Date time) {

        this.latitude = latitude;
        this.longitude = longitude;
        this.time = time;
        this.isTreated = false;

    }

    /**************************************************************************
     * PUBLIC METHODS
     **************************************************************************/

    public double[] getCoordinates() {
        return new double[]{latitude, longitude};
    }

    public Date getTime() {
        return time;
    }

    public boolean isUntreated() {
        return !isTreated;
    }

    public void setToTreated() {
        isTreated = true;
    }

    public void setToUntreated() {
        isTreated = false;
    }

    public String print() {
        return "(" + latitude + ", " + longitude + ", " + time + ", " + isTreated + ")";
    }

}