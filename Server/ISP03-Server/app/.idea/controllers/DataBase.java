package controllers;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.sql.DriverManager;

import objects.Client;
import objects.Habit;
import objects.MapperTrajectory;
import objects.Place;
import play.api.Play;

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
					"endlongitude double precision, standdevstart double precision, standdevend double precision, samplesize integer, weekday integer, userfeedback integer," +
					"starttime int , stoptime int , length double precision,  IDclient int, score int, nbUsedTrajectories int, FOREIGN KEY (IDclient) REFERENCES client(ID));";
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
			statement += "'"+place.getLatitude()+"',";
			statement += "'"+place.getLongitude()+"',";
			statement += "'"+place.getTime()+"',";
			if(place.isTreated())
				statement += "'"+1+"',";
			else
				statement += "'"+0+"',";
			statement += "'"+clientID+"');";
			System.out.println(statement);
			PreparedStatement ps = con.prepareStatement(statement);
			System.out.println(ps.executeQuery());

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
			System.out.println(statement);
			PreparedStatement ps = con.prepareStatement(statement);
			System.out.println(ps.executeQuery());

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
			client.username = rs.getString("username");
			client.homeCountry = rs.getString("homeCountry");
			client.homeZip = rs.getString("homeZip");
			client.homeAddress = rs.getString("homeAddress");
			client.work = rs.getString("work");
			client.workAddress = rs.getString("workAddress");
			client.workZip = rs.getString("workZip");
			client.workCountry = rs.getString("workCountry");
			client.email = rs.getString("email");
		}catch(Exception e){
			System.out.println(e);
		}
	}

	//Select all habits of a user
	public List<Habit> selectHabits(int ID){
		List<Habit> list = new ArrayList<Habit>();
		try{
			String statement = "SELECT * FROM habit Where ID='"+ID+"';";
			PreparedStatement ps = con.prepareStatement(statement);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				double[] coord = {rs.getDouble("startlatitude"),rs.getDouble("startlongitude"),rs.getDouble("endlatitude"),rs.getDouble("endlongitude")};
				Habit habit = new Habit(coord, rs.getInt("starttime"), rs.getInt("endTime"), rs.getDouble("length"),rs.getInt("soore"), rs.getInt("nbUsedTrajectories"));
				list.add(habit);
			}
		}catch(Exception e){
			System.out.println(e);
		}
		return list;
	}


	/*----------------------------DEPRECIATE-----------------------------*/
	
	//prepare and execute a query to insert values into a table
	public Boolean insertIntoTable(String tableName, List<String> columnNames, String condition, List<String> values) {
		if(columnNames.size() != values.size()) {
			System.out.println("Not the same number of columns and elements!");
			return false;
		}
		String statement = "INSERT INTO "+tableName+" (";
		int i=0;
		for (String columnName : columnNames){
			if(i!=0)
				statement = statement + ", ";
			statement += columnName;
			i++;
		}
		
		statement += ") values (";
		
		i=0;
		for (String value : values){
			if(i!=0)
				statement = statement + ", ";
			statement += "'"+value+"'";
			i++;
		}
		statement+=")";
		if(condition != null) {
			statement += " WHERE " + condition;
		}
		statement += ";";
		System.out.println(statement);
		try {
			PreparedStatement stmt = con.prepareStatement(statement);
			System.out.println(stmt.executeQuery());
			return true;
		}catch(SQLException e) {
			System.out.println(e);
			return false;			
		}
	}
	
	//prepare and execute a query to select values into a table
	public ResultSet selectFromTable(String tableName, String columnName, String condition){
		ResultSet set = null;
		if(con !=null) {
			String statement = "Select "+columnName+" FROM "+tableName;
			System.out.println(statement);
			if(condition != null) {

				statement = statement+" WHERE "+condition;
			}
			statement += ";";
			try {
				System.out.println(statement);
				PreparedStatement stmt = con.prepareStatement(statement);
				set = stmt.executeQuery();
			} catch (SQLException e) {
				System.out.println(e);
			}
			
		}
		
		return set;
	}
	
	
	public boolean DeleteFromTable(String tableName, String condition) {
		ResultSet set = null;
		String statement;
		statement = "Delete " + tableName;
		if(condition != null){
			statement = statement + " Where " + condition;
		}
		statement +=";";
		try{
		System.out.println(statement);
			PreparedStatement stmt = con.prepareStatement(statement);
			set = stmt.executeQuery();
		}
		catch(Exception e) {
			System.out.println(e);
			return false;
		}
		return true;
	}
	
	public boolean EditFromTable(String tableName) {
		//TODO if necessary
		return true;
	}
}
