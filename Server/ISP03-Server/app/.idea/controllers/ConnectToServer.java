package controllers;

import objects.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import play.mvc.*;

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
			return unauthorized("Password or userName incorrect");
		}
	}

	private Boolean CheckPassword(Client client, DataBase db){
		System.out.println("testing password");
		String pw = db.selectPasswor(client.username);
		pw = pw.replaceAll("\\s+","");
		return client.password.equals(pw);
	}

	private void controlUserData(int ID){
		try{
			wait(300000);
		}catch(Exception e){
			System.out.println(e);
		}
		System.out.println("coucou");
	}
}
