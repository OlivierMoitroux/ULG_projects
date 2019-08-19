package objects;

import java.util.Date;

/******************************************************************************
 * TRAJECTORY CLASS
 * A trajectory is represented by the geographical coordinates, date and time
 * of its start and end places, and its length.
 ******************************************************************************/

public class Trajectory {

    private int id;
    private double startLatitude;
    private double startLongitude;
    private double endLatitude;
    private double endLongitude;
    private Date startTime;
    private Date endTime;
    private double length;

    /**************************************************************************
     * CONSTRUCTOR
     * @param startLatitude the latitude of the starting place
     * @param startLongitude the longitude of the starting place
     * @param endLatitude the latitude of the ending place
     * @param endLongitude the longitude of the ending place
     * @param startTime the start date and hour
     * @param endTime the end date and hour
     * @param length the length of the trajectory (in meters)
     **************************************************************************/

    public Trajectory(double startLatitude, double startLongitude, double endLatitude, double endLongitude,
                      Date startTime, Date endTime, double length) {

        this.startLatitude = startLatitude;
        this.startLongitude = startLongitude;
        this.endLatitude = endLatitude;
        this.endLongitude = endLongitude;
        this.startTime = startTime;
        this.endTime = endTime;
        this.length = length;

    }

    public Trajectory(int id, Date startTime){
        this.id = id;
        this.startTime = startTime;
    }

    /**************************************************************************
     * PUBLIC METHODS
     *************************************************************************/

    /**
     * Performs a deep copy of the current trajectory
     *
     * @return a copy of this trajectory
     */
    public Trajectory copy() {

        double[] coordinates = this.getStartAndEndCoordinates();
        Date startTime = (Date) this.getStartTime().clone();
        Date endTime = (Date) this.getEndTime().clone();
        double length = this.getLength();

        return new Trajectory(coordinates[0], coordinates[1], coordinates[2], coordinates[3], startTime, endTime,
                length);

    }

    public double[] getStartCoordinates() {
        return new double[]{startLatitude, startLongitude};
    }

    public double[] getEndCoordinates() {
        return new double[]{endLatitude, endLongitude};
    }

    public double[] getStartAndEndCoordinates() {
        return new double[]{startLatitude, startLongitude, endLatitude, endLongitude};
    }

    public void setCoordinates(double[] startCoordinates, double[] endCoordinates) {

        startLatitude = startCoordinates[0];
        startLongitude = startCoordinates[1];
        endLatitude = endCoordinates[0];
        endLongitude = endCoordinates[1];

    }

    public Date getStartTime() {
        return startTime;
    }

    public Date getEndTime() {
        return endTime;
    }

    public int getId(){return this.id;}

    public double getLength() {
        return length;
    }

    public String print() {
        return "(" + startLatitude + ", " + startLongitude + ", " + endLatitude + ", " + endLongitude + ", "
                + startTime + ", " + endTime + ", " + length + ")";
    }

}