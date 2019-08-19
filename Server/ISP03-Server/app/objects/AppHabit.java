package objects;

import java.util.Date;
import java.util.Timer;

public class AppHabit{

    public double[] startCoordinate;
    public double[] endCoordinate;
    public String weekday;
    public String locomotion;
    public double scoring;
    public String startTime;
    public String endTime;
    public String timing;


    public AppHabit(Habit habit){
        this.startCoordinate = habit.getStartCoordinates();
        this.endCoordinate = habit.getEndCoordinates();
        this.weekday = habit.getDay();
        this.locomotion ="in_car";
        this.scoring = habit.getScore();
        int wd = habit.getIntDay();
        if(wd==0)
            wd =7;
        int start = habit.getStartTime();
        int stop = habit.getEndTime();

        this.startTime = TimeFromInt(start, wd);
        this.endTime = TimeFromInt(stop, wd);
        int tim = stop-start;
        this.timing = tim+" min";
    }

    private String TimeFromInt(int time, int wd){
        int ref = time-(wd*1440);

        int hour = ref/60;
        int min = ref%60;

        String t = hour+":"+min;
        return t;
    }

}
