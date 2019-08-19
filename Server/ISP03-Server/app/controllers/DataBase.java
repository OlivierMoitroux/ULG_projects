package controllers;


import java.sql.*;
import java.sql.DriverManager;
import java.util.Vector;

import objects.*;
import objects.MapperTrajectory;

public class DataBase {

	private Connection con;
	private String url = "jdbc:postgresql://localhost/ispdb2";
	private String user="shared";
	private String password ="uGhee1Ra[u";
	
	public DataBase() {
	}

	public Boolean connect() {
		try {
			con = DriverManager.getConnection(url,user,password);
			return true;
		}catch(Exception ex) {
			System.out.println(ex);
			return false;
		}
	}

	public Boolean disconnect(){
		try{
			con.close();
			return true;
		}catch (Exception e){
			System.out.println(e);
			return false;
		}
	}

	public boolean createTableClient(){
		try{
			String statement = "CREATE TABLE client(ID serial primary key, name char(255), surname char(255), password char(255), email char(255), work char(255), username char(255), " +
					"homeAddress char(255), homeZip char(255), homeCountry char(255), workAddress char(255), workZip char(255), workCountry char(255), nbtraj INTEGER);";
			PreparedStatement stmt = con.prepareStatement(statement);
			stmt.executeQuery();
			return true;
		}catch(Exception e){
			System.out.println(e);
			return true;
		}
	}
	public boolean createTableTrajectory(){
		try{
			String statement = "CREATE TABLE trajectory(ID serial primary key, startlatitude double precision , startlongitude double precision, endlatitude double precision, " +
					"endlongitude double precision, " +
					"starttime timestamp, stoptime timestamp, length double precision,  IDclient int, FOREIGN KEY (IDclient) REFERENCES client(ID));";
			PreparedStatement stmt = con.prepareStatement(statement);
			stmt.executeQuery();
			return true;
		}catch(Exception e){
			System.out.println(e);
			return true;
		}
	}
	public boolean createTableHabit(){
		try{
			String statement = "CREATE TABLE habit(ID serial primary key, startlatitude double precision , startlongitude double precision, endlatitude double precision, " +
					"endlongitude double precision, nbusedtraj integer, weekday integer, score double precision," +
					"starttime integer , stoptime integer , length double precision,  IDclient int, FOREIGN KEY (IDclient) REFERENCES client(ID));";
			PreparedStatement stmt = con.prepareStatement(statement);
			stmt.executeQuery();
			return true;
		}catch(Exception e){
			System.out.println(e);
			return true;
		}
	}
	public boolean createTablePlace(){
		try{
			String statement = "CREATE TABLE place(ID serial primary key, latitude double precision , longitude double precision, time timestamp, threated integer, IDclient int, FOREIGN KEY (IDclient) REFERENCES client(ID));";
			PreparedStatement stmt = con.prepareStatement(statement);
			stmt.executeQuery();
			return true;
		}catch(Exception e){
			System.out.println(e);
			return true;
		}
	}

	public String selectPasswor(String username){
		String statement = "SELECT password FROM client WHERE username='"+username+"';";
		try {
			PreparedStatement ps = con.prepareStatement(statement);
			ResultSet rs = ps.executeQuery();
			rs.next();
			return rs.getString("password");
		}catch (Exception e){
			System.out.println(e);
			return null;
		}
	}

	public void insertPlace(Place place, int clientID){
		System.out.println("Inserting place");
		try{
			String statement = "INSERT INTO place VALUES (";
			statement += "default, ";
			statement += "'"+place.getCoordinates()[0]+"',";
			statement += "'"+place.getCoordinates()[1]+"',";
			statement += "'"+place.getTime()+"',";
			if(place.isUntreated())
				statement += "'"+0+"',";
			else
				statement += "'"+1+"',";
			statement += "'"+clientID+"');";
			PreparedStatement ps = con.prepareStatement(statement);
			System.out.println(ps.executeUpdate());

		}catch (Exception e){
			System.out.println(e);
		}
	}

	public void insertHabits(Habit habit, int clientID){
		System.out.println("Inserting place");
		try{
			String statement = "INSERT INTO habit VALUES (";
			statement += "default, ";
			statement += "'"+habit.getStartAndEndCoordinates()[0]+"',";
			statement += "'"+habit.getStartAndEndCoordinates()[1]+"',";
			statement += "'"+habit.getStartAndEndCoordinates()[2]+"',";
			statement += "'"+habit.getStartAndEndCoordinates()[3]+"',";
			statement += "'"+habit.getIntDay()+"',";
			statement += "'"+habit.getScore()+"',";
			statement += "'"+habit.getStartTime()+"',";
			statement += "'"+habit.getEndTime()+"',";
			statement += "'"+habit.getLength()+"',";
			statement += "'"+clientID+"');";
			PreparedStatement ps = con.prepareStatement(statement);
			ps.executeUpdate();
		}catch (Exception e){
			System.out.println(e);
		}
	}

	public void insertTrajectory(MapperTrajectory mtraj, int clientID){
		System.out.println("Inserting trajectory");
		try{
			String statement = "INSERT INTO trajectory VALUES (";
			statement += "default, ";
			statement += "'"+mtraj.startStayPoint.latitude+"',";
			statement += "'"+mtraj.startStayPoint.longitude+"',";
			statement += "'"+mtraj.endStayPoint.latitude+"',";
			statement += "'"+mtraj.endStayPoint.longitude+"',";
			statement += "'"+mtraj.startStayPoint.dateTime+"',";
			statement += "'"+mtraj.endStayPoint.dateTime+"',";
			statement += "'"+mtraj.length+"',";
			statement += "'"+clientID+"');";
			PreparedStatement ps = con.prepareStatement(statement);
			ps.executeUpdate();

		}catch (Exception e){
			System.out.println(e);
		}
	}

	public boolean insertClient(Client client){
		try{
			String statement = "INSERT INTO client VALUES (";
			statement += "default, ";
			statement += "'anonymous', 'anonymous',";
			statement += "'"+client.password+"',";
			statement += "'"+client.email+"',";
			statement += "'"+client.work+"',";
			statement += "'"+client.username+"',";
			statement += "'"+client.homeAddress+"',";
			statement += "'"+client.homeZip+"',";
			statement += "'"+client.homeCountry+"',";
			statement += "'"+client.workAddress+"',";
			statement += "'"+client.workZip+"',";
			statement += "'"+client.workCountry+"',";
			statement += "0);";

			PreparedStatement ps = con.prepareStatement(statement);
			System.out.println(ps.executeUpdate());
			return true;

		}catch (Exception e){
			System.out.println(e);
			return true;
		}
	}

	public void deleteMyHabits(int ID){
		try{
			String statement;
			PreparedStatement ps;
			statement ="Delete FROM habit WHERE IDclient ='"+ID+"';";
			ps = con.prepareStatement(statement);
			ps.executeUpdate();
		}catch(Exception e){
			System.out.println(e);
		}
	}

	public void deleteMyTrajectories(int ID){
		try{
			String statement;
			PreparedStatement ps;
			statement ="Delete FROM trajectory WHERE IDclient ='"+ID+"';";
			ps = con.prepareStatement(statement);
			ps.executeUpdate();
		}catch(Exception e){
			System.out.println(e);
		}
	}
	public void deleteMyPlaces(int ID){
		try{
			String statement;
			PreparedStatement ps;
			statement ="Delete FROM place WHERE IDclient ='"+ID+"';";
			ps = con.prepareStatement(statement);
			ps.executeUpdate();
		}catch(Exception e){
			System.out.println(e);
		}
	}

	public void deleteAccount(int ID){
		deleteMyHabits(ID);
		deleteMyTrajectories(ID);
		deleteMyPlaces(ID);

		try{
			String statement;
			PreparedStatement ps;
			statement ="Delete FROM client WHERE ID ='"+ID+"';";
			ps = con.prepareStatement(statement);
			ps.executeUpdate();
		}catch(Exception e){
			System.out.println(e);
		}
	}

	public int getClientID(Client client){
		int ID = -1;
		try{
			String statement ="SELECT ID FROM client WHERE username='"+client.username+"';";
			PreparedStatement ps = con.prepareStatement(statement);
			ResultSet rs = ps.executeQuery();
			rs.next();
			ID = rs.getInt("ID");
		}catch(Exception e){
			System.out.println(e);
		}
		return ID;
	}

	public int getClientCounter(int ID){
		int count = -1;
		try{
			String statement ="SELECT nbtraj FROM client WHERE id='"+ID+"';";
			PreparedStatement ps = con.prepareStatement(statement);
			ResultSet rs = ps.executeQuery();
			rs.next();
			count = rs.getInt("nbtraj");
		}catch(Exception e){
			System.out.println(e);
		}
		return count;
	}

	public void editCounter(int count, int ID){
		try{
			String statement ="UPDATE client SET nbtraj ="+count+" WHERE id="+ID+";";
			PreparedStatement ps = con.prepareStatement(statement);
			ps.executeUpdate();
		}catch(Exception e){
			System.out.println(e);
		}
	}

	//Find if a username already exist
	public String checkUsername(String username){
		String un = null;
		try{
			String statement = "SELECT username FROM client Where username='"+username+"';";
			PreparedStatement ps = con.prepareStatement(statement);
			ResultSet rs = ps.executeQuery();
			rs.next();
			un = rs.getString("username");
		}catch(Exception e){
			System.out.println(e);
		}
		return un;
	}

	//Fetch a client on the database using the id stored in the Client strucure
	public void selectClient(Client client){
		try{
			String statement = "SELECT * FROM client Where ID='"+client.id+"';";
			PreparedStatement ps = con.prepareStatement(statement);
			ResultSet rs = ps.executeQuery();
			rs.next();
			client.username = rs.getString("username").replaceAll("\\s+","");
			client.homeCountry = rs.getString("homeCountry").replaceAll("\\s+","");
			client.homeZip = rs.getString("homeZip").replaceAll("\\s+","");
			client.homeAddress = rs.getString("homeAddress").replaceAll("\\s+","");
			client.work = rs.getString("work").replaceAll("\\s+","");
			client.workAddress = rs.getString("workAddress").replaceAll("\\s+","");
			client.workZip = rs.getString("workZip").replaceAll("\\s+","");
			client.workCountry = rs.getString("workCountry").replaceAll("\\s+","");
			client.email = rs.getString("email").replaceAll("\\s+","");
		}catch(Exception e){
			System.out.println(e);
		}
	}

	//Select all habits of a user
	public Vector<AppHabit> selectHabits(int ID){
		Vector<AppHabit> list = new Vector<AppHabit>();
		try{
			String statement = "SELECT * FROM habit WHERE idclient="+ID+";";
			PreparedStatement ps = con.prepareStatement(statement);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				double[] coord = {rs.getDouble("startlatitude"),rs.getDouble("startlongitude"),rs.getDouble("endlatitude"),rs.getDouble("endlongitude")};
				Habit habit = new Habit(coord, rs.getInt("starttime"), rs.getInt("stoptime"), rs.getDouble("length"),rs.getInt("score"), rs.getInt("nbusedtraj"));
				AppHabit appHabit = new AppHabit(habit);
				list.add(appHabit);
			}
		}catch(Exception e){
			System.out.println(e);
		}
		return list;
	}

    public Vector<Trajectory> selectTrajectories(int ID){
        Vector<Trajectory> list = new Vector<Trajectory>();
        try{
            String statement = "SELECT * FROM trajectory WHERE idclient="+ID+";";
            PreparedStatement ps = con.prepareStatement(statement);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                Trajectory traj = new Trajectory(rs.getInt("ID"), rs.getTimestamp("starttime"));
                list.add(traj);
            }
        }catch(Exception e){
            System.out.println(e);
        }
        return list;
    }

	public Vector<Place> selectPlaces(int ID){
		Vector<Place> list = new Vector<Place>();
		try{
			String statement = "SELECT * FROM place WHERE idclient="+ID+";";
			PreparedStatement ps = con.prepareStatement(statement);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				Place place = new Place(rs.getDouble("latitude"), rs.getDouble("longitude"), rs.getTimestamp("time"));
				list.add(place);
			}
		}catch(Exception e){
			System.out.println(e);
		}
		return list;
	}
}
