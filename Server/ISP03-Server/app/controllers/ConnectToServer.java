package controllers;

import algo.HabitGenerator;
import objects.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import play.mvc.*;

import java.util.*;

import static java.lang.Thread.sleep;

public class ConnectToServer extends Controller{
	public Result connect(){

		System.out.println("Client connecting");

		DataBase db;
		Client client;

		db = new DataBase();

		if(!db.connect())
			return internalServerError("Unable to access the database.");


		//String headers = request().header("Authorization").toString();


		//JSONParser parser = new JSONParser();
		String json;
		try {
			json = request().body().asJson().toString();
		}catch (Exception e){

			return badRequest(e.toString());
		}

		if(json == null)
			return badRequest("Expecting Json file in the body");

		ObjectMapper mapper = new ObjectMapper();
		try{
			client = mapper.readValue(json, Client.class);
		}catch (Exception e){
			System.out.println(e);
			return badRequest("Not usable body");
		}
		client.id = db.getClientID(client);

		if(CheckPassword(client, db)) {
			db.disconnect();
			System.out.println("Connected");
			new Thread() {
				@Override
				public void run() {
					controlUserData(client.id);
				}
			}.start();
			return ok("Connected");
		}
		else {
			db.disconnect();
			return unauthorized("Password or username incorrect");
		}
	}

	private Boolean CheckPassword(Client client, DataBase db){
		System.out.println("testing password");
		String pw = db.selectPasswor(client.username);
		pw = pw.replaceAll("\\s+","");
		return client.password.equals(pw);
	}

	private void controlUserData(int ID){
        DataBase db = new DataBase();
        db.connect();
        Vector<Trajectory> listTraj = db.selectTrajectories(ID);
		Vector<Place> lisPlaces = db.selectPlaces(ID);

		HabitGenerator habitGen = new HabitGenerator(listTraj, lisPlaces);

		Vector<Habit> habits = habitGen.generateHabits();
		if(habits.size()>0){
			for (Habit h : habits) {
				db.insertHabits(h, ID);
			}
		}
	}
}
