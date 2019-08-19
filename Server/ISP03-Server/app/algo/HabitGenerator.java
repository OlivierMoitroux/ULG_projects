package algo;

import objects.Habit;
import objects.Place;
import objects.Trajectory;

import java.util.*;

/******************************************************************************
 * HABIT GENERATOR CLASS
 * This class contains the algorithms that are used to extract the habits of an
 * user out of its trajectories. The two key algorithms are location clustering
 * (clusterPlaces method) and habit clustering (clusterTraj method).
 ******************************************************************************/

public class HabitGenerator {

    private Vector<Trajectory> trajectories;
    private Vector<Place> places;
    private Vector<Habit> habits; // a list of the habits of an user as defined in objects/Habit.java (initially empty)

    // Parameters for the algorithms
    private int radius; // radius for location clustering (in meters)
    private final int radiusStep;
    private final int maxRadius;
    private final long timeThreshold; // time threshold for habit clustering (in minutes)
    private final float ratioThreshold; // ratio threshold to control parameters tuning
    private final int minSizeClusterPlaces; // Minimum size of a cluster of places to be kept as a location
    private final int minSizeClusterTraj; // Minimum size of a cluster of trajectories to be considered as a habit
    private final int nbStepsCentering; // Number of steps for location and habit clustering
    private int lengthFilteredTraj;
    private int nbUsedTrajectories;

    /**************************************************************************
     * CONSTRUCTOR
     * @param trajectories a list of the trajectories of an user as defined in objects/Trajectory.java
     * @param places a list of the places of an user extracted from its trajectories as defined in objects/Place.java
     **************************************************************************/

    public HabitGenerator(Vector<Trajectory> trajectories, Vector<Place> places) {

        this.trajectories = trajectories;
        this.places = places;
        habits = new Vector<>();
        radius = 150;
        radiusStep = 50;
        maxRadius = 1000;
        timeThreshold = 120;
        ratioThreshold = (float) 0.2;
        minSizeClusterPlaces = 5;
        minSizeClusterTraj = 4;
        nbStepsCentering = 10;
        lengthFilteredTraj = 0;
        nbUsedTrajectories = 0;

    }

    /**************************************************************************
     * PUBLIC METHODS
     *************************************************************************/

    /**
     * Extracts the habits out of the lists of places and trajectories
     *
     * @return the extracted list of habits
     */
    public Vector<Habit> generateHabits() {

        lengthFilteredTraj = 0;

        // Executes the algorithms until either a good ratio for parameters tuning is reached or radius has become
        // too large, meaning that no habits could be found
        while ((lengthFilteredTraj == 0 || (float) nbUsedTrajectories / lengthFilteredTraj < ratioThreshold)
                && radius < maxRadius) {

            radius += radiusStep;
            habits.clear();
            resetPlaces();

            // Performs location clustering
            Vector<double[]> locations = clusterPlaces();

            // Filters trajectories joining two locations
            Hashtable<Integer, Vector<Trajectory>> filteredTraj = filterTraj(locations);

            // Performs habit clustering
            clusterTraj(filteredTraj);

        }

        if ((float) nbUsedTrajectories / lengthFilteredTraj < ratioThreshold)
            habits.clear();

        return habits;

    }

    /**
     * Computes the distance between two geographical points
     *
     * @param coord1 the coordinates of the first point
     * @param coord2 the coordinates of the second point
     * @return the distance in meters
     */
    public static double getDist(double[] coord1, double[] coord2) {

        double earthRadius = 6371000;
        double dLat = Math.toRadians(coord2[0] - coord1[0]);
        double dLng = Math.toRadians(coord2[1] - coord1[1]);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(Math.toRadians(coord1[0]))
                * Math.cos(Math.toRadians(coord2[0])) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return earthRadius * c;

    }

    /**************************************************************************
     * PRIVATE METHODS
     **************************************************************************/

    private void resetPlaces() {

        places.forEach(Place::setToUntreated);

    }

    /**
     * Clusters the places of the user into locations (geographical coordinates) by doing K-mean clustering
     *
     * @return the list of clustered locations
     */
    private Vector<double[]> clusterPlaces() {

        Vector<double[]> locations = new Vector<>();

        // Performs clustering until all places have been treated
        while (placesNotAllTreated()) {

            Vector<double[]> tmpCluster = new Vector<>();
            Random rand = new Random();
            int randIndex = rand.nextInt(places.size());
            // Randomly chooses a place as the center of the cluster for the first step
            double[] center = places.get(randIndex).getCoordinates();

            for (int i = 0; i < nbStepsCentering; i++) {

                tmpCluster.clear();

                // Selects places that are in the radius of the cluster
                for (Place place : places) {

                    if (getDist(center, place.getCoordinates()) < radius && place.isUntreated()) {

                        tmpCluster.add(place.getCoordinates());
                        // If this is the final step of centering, marks the places of the cluster as treated
                        if (i == nbStepsCentering - 1)
                            place.setToTreated();

                    }

                }

                // Computes new center for the next step
                center = getMeanCoordinates(tmpCluster);

            }

            // Only keeps a location if the cluster is large enough
            if (tmpCluster.size() >= minSizeClusterPlaces)
                locations.add(center);
        }

        return locations;

    }

    private boolean placesNotAllTreated() {

        for (Place place : places) {
            if (place.isUntreated()) {
                return true;
            }
        }

        return false;

    }

    /**
     * Computes the mean geographical coordinates of some geographical points
     *
     * @param coordinates the list of points
     * @return the mean coordinates
     */
    private double[] getMeanCoordinates(Vector<double[]> coordinates) {

        double sumLat = 0.0;
        double sumLng = 0.0;

        for (double[] coordinate : coordinates) {
            sumLat += coordinate[0];
            sumLng += coordinate[1];
        }

        return new double[]{sumLat / coordinates.size(), sumLng / coordinates.size()};

    }

    /**
     * Filters the trajectories of the user to only keep the ones that link two locations
     *
     * @param locations a list of locations
     * @return the dictionary of filtered trajectories grouped by the pairs of locations they link in an oriented way
     */
    private Hashtable<Integer, Vector<Trajectory>> filterTraj(Vector<double[]> locations) {

        Hashtable<Integer, Vector<Trajectory>> filteredTraj = new Hashtable<>();
        lengthFilteredTraj = 0;

        // For all the trajectories of the user...
        for (Trajectory trajectory : trajectories) {

            boolean startIsLoc = false;
            boolean endIsLoc = false;
            double[] startCoordinates = {0.0, 0.0};
            double[] endCoordinates = {0.0, 0.0};

            // ...searches for start and end locations
            for (double[] location : locations) {

                if (getDist(location, trajectory.getStartCoordinates()) < radius) {

                    startIsLoc = true;
                    startCoordinates = location;

                } else if (getDist(location, trajectory.getEndCoordinates()) < radius) {

                    endIsLoc = true;
                    endCoordinates = location;

                }

                // If current trajectory links two locations, adds it to the dictionary
                if (startIsLoc && endIsLoc) {

                    Trajectory trajToAdd = trajectory.copy();
                    trajToAdd.setCoordinates(startCoordinates, endCoordinates);
                    int newKey = Arrays.hashCode(trajToAdd.getStartAndEndCoordinates());

                    if (filteredTraj.containsKey(newKey))
                        filteredTraj.get(newKey).add(trajToAdd);
                    else {
                        Vector<Trajectory> newVec = new Vector<>();
                        newVec.add(trajToAdd);
                        filteredTraj.put(newKey, newVec);
                    }

                    lengthFilteredTraj++;
                    break;

                }

            }

        }

        return filteredTraj;

    }

    /**
     * Clusters the filtered trajectories of the user into habits by doing K-mean clustering
     *
     * @param filteredTraj a dictionary of filtered trajectories grouped by the pairs of locations they link in an
     *                     oriented way
     */
    private void clusterTraj(Hashtable<Integer, Vector<Trajectory>> filteredTraj) {

        Set<Integer> keys = filteredTraj.keySet();
        nbUsedTrajectories = 0;

        // For each group of trajectories, performs clustering
        for (int key : keys) {

            Vector<Trajectory> trajLocToLoc = filteredTraj.get(key);

            // Performs clustering until the group is empty
            while (!trajLocToLoc.isEmpty()) {

                Vector<Trajectory> tmpCluster = new Vector<>();
                Random rand = new Random();
                int randIndex = rand.nextInt(trajLocToLoc.size());
                // Randomly chooses start and end times of a trajectory as the centers of the cluster for the first step
                int startTimeCenter = convertToWeekTime(trajLocToLoc.get(randIndex).getStartTime());
                int endTimeCenter = convertToWeekTime(trajLocToLoc.get(randIndex).getEndTime());

                // Selects trajectories that start at the same time of the week as the start center or end at the
                // same time of the week as the end center (with a tolerance of timeThreshold)
                for (int i = 0; i < nbStepsCentering; i++) {

                    tmpCluster.clear();

                    Iterator<Trajectory> it = trajLocToLoc.iterator();
                    while (it.hasNext()) {

                        Trajectory traj = it.next();
                        if (getTimeDifference(startTimeCenter, traj.getStartTime()) < timeThreshold
                                || getTimeDifference(endTimeCenter, traj.getEndTime()) < timeThreshold) {

                            tmpCluster.add(traj);
                            // If this is the final step of centering, removes the trajectories of the cluster from
                            // the dictionary
                            if (i == nbStepsCentering - 1)
                                it.remove();

                        }

                    }

                    // Computes new centers for the next step
                    int[] timeCenters = getMeanTimes(tmpCluster);
                    startTimeCenter = timeCenters[0];
                    endTimeCenter = timeCenters[1];

                }

                // Only keeps a habit if the cluster is large enough
                if (tmpCluster.size() >= minSizeClusterTraj) {

                    // Computes the new habit from the cluster and adds it to the habit list
                    double[] startAndEndCoordinates = tmpCluster.lastElement().getStartAndEndCoordinates();
                    double meanLength = getMeanLength(tmpCluster);
                    double[] stdDevTimes = getStdDevTimes(tmpCluster, startTimeCenter, endTimeCenter);
                    double score = getScore(stdDevTimes);
                    Habit habitToAdd = new Habit(startAndEndCoordinates, startTimeCenter, endTimeCenter, meanLength,
                            score, tmpCluster.size());
                    habits.add(habitToAdd);
                    nbUsedTrajectories += tmpCluster.size();

                }

            }

        }

    }

    /**
     * Computes the week time difference between two times
     *
     * @param timeRef the first time (time of the week: number of minutes passed starting from Sunday midnight)
     * @param date2   the second time (date and hour)
     * @return time difference in a week (in minutes)
     */
    private int getTimeDifference(int timeRef, Date date2) {

        int weekTime2 = convertToWeekTime(date2);
        int nonCyclicDiff = Math.abs(timeRef - weekTime2);

        return Math.min(nonCyclicDiff, 10080 - nonCyclicDiff);

    }

    /**
     * Computes the mean start and end times of some trajectories
     *
     * @param cluster the list of trajectories
     * @return the mean start and end times
     */
    private int[] getMeanTimes(Vector<Trajectory> cluster) {

        int sumStartTime = 0;
        int sumEndTime = 0;

        for (Trajectory trajectory : cluster) {

            sumStartTime += convertToWeekTime(trajectory.getStartTime());
            sumEndTime += convertToWeekTime(trajectory.getEndTime());

        }

        return new int[]{(sumStartTime / cluster.size()), (sumEndTime / cluster.size())};

    }

    /**
     * Converts a date and hour into a time of the week
     *
     * @param time the date and hour
     * @return the time of the week (number of minutes passed starting from Sunday midnight)
     */
    private int convertToWeekTime(Date time) {

        Calendar cal = Calendar.getInstance();
        cal.setTime(time);

        int day = cal.get(Calendar.DAY_OF_WEEK);
        int hour = cal.get(Calendar.HOUR_OF_DAY);
        int minute = cal.get(Calendar.MINUTE);

        return minute + 60 * (hour + 24 * (day - 1));

    }

    /**
     * Computes the mean length of some trajectories
     *
     * @param cluster the list of trajectories
     * @return the mean length (in meters)
     */
    private double getMeanLength(Vector<Trajectory> cluster) {

        double sumLength = 0.0;

        for (Trajectory trajectory : cluster) sumLength += trajectory.getLength();

        return sumLength / cluster.size();

    }

    /**
     * Computes the standard deviations of the start and end times of some trajectories
     *
     * @param cluster       the list of trajectories
     * @param meanStartTime the mean start time of the list
     * @param meanEndTime   the mean end time of the list
     * @return the two expected standard deviations {stdDevStartTime, stdDevEndTime}
     */
    private double[] getStdDevTimes(Vector<Trajectory> cluster, int meanStartTime, int meanEndTime) {

        int sumStart = 0;
        int sumEnd = 0;

        for (Trajectory trajectory : cluster) {

            sumStart += Math.pow(getTimeDifference(meanStartTime, trajectory.getStartTime()), 2);
            sumEnd += Math.pow(getTimeDifference(meanEndTime, trajectory.getEndTime()), 2);

        }

        return new double[]{Math.sqrt((double) sumStart / cluster.size()), Math.sqrt((double) sumEnd / cluster.size())};

    }

    /**
     * Computes a score out of two standard deviations
     *
     * @param stdDevTimes the standard deviations
     * @return the score in the interval [0, 4]
     */
    private double getScore(double[] stdDevTimes) {

        return Math.max(0.0, 2 * timeThreshold - stdDevTimes[0] - stdDevTimes[1]) * 2 / timeThreshold;

    }

    public Vector<Habit> getHabits() {
        return habits;
    }

}