package objects;

/******************************************************************************
 * HABIT CLASS
 * An habit is represented by the geographical coordinates and time of the week
 * of its start and end places, its score, its length, and the number of
 * trajectories that were used to compute it.
 ******************************************************************************/

public class Habit {

    static private String[] daysOfTheWeek = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
            "Saturday"};
    private double startLatitude;
    private double startLongitude;
    private double endLatitude;
    private double endLongitude;
    private int weekDay; // index of the week day in table daysOfTheWeek
    private int startTime;
    private int endTime;
    private double score;
    private double length;
    private int nbUsedTrajectories;

    /**************************************************************************
     * CONSTRUCTOR
     * @param startAndEndCoordinates structured as {start latitude, start longitude, end latitude, end longitude}
     * @param startTime the start time of the week (number of minutes passed starting from Sunday midnight)
     * @param endTime the end time of the week (number of minutes passed starting from Sunday midnight)
     * @param length the length of the trajectory that is represented by this habit (in meters)
     * @param score a score in the interval [0: very bad, 4: very good] based on the standard deviations of the start
     *              and end times of the trajectories that were used to compute this habit
     * @param nbUsedTrajectories the number of trajectories that were used to compute this habit
     **************************************************************************/

    public Habit(double[] startAndEndCoordinates, int startTime, int endTime, double length, double score,
                 int nbUsedTrajectories) {

        this.startLatitude = startAndEndCoordinates[0];
        this.startLongitude = startAndEndCoordinates[1];
        this.endLatitude = startAndEndCoordinates[2];
        this.endLongitude = startAndEndCoordinates[3];
        this.startTime = startTime;
        this.endTime = endTime;
        this.score = score;
        this.length = length;
        this.nbUsedTrajectories = nbUsedTrajectories;
        this.weekDay = startTime / 1440;

    }

    /**************************************************************************
     * PUBLIC METHODS
     *************************************************************************/

    public double[] getStartCoordinates() {
        return new double[]{startLatitude, startLongitude};
    }

    public double[] getEndCoordinates() {
        return new double[]{endLatitude, endLongitude};
    }

    public double[] getStartAndEndCoordinates() {
        return new double[]{startLatitude, startLongitude, endLatitude, endLongitude};
    }

    public String getDay() {
        return daysOfTheWeek[weekDay];
    }

    public int getIntDay() {return weekDay;}

    public int getStartTime() {
        return startTime;
    }

    public int getEndTime() {
        return endTime;
    }

    public double getScore() {
        return score;
    }

    public double getLength() {
        return length;
    }

    public int getNbTrajectories() {
        return nbUsedTrajectories;
    }

    public String print() {
        return "(" + startLatitude + ", " + startLongitude + ", " + endLatitude + ", " + endLongitude + ", "
                + daysOfTheWeek[weekDay] + ", " + startTime + ", " + endTime + ", " + score + ", " + length + ", "
                + nbUsedTrajectories + ")";
    }


}