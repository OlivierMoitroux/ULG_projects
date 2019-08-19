package controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import objects.Client;
import play.mvc.*;

public class Register extends Controller {

    public Result register() {

        System.out.println("Client registering");

        DataBase db;
        Client client;
        db = new DataBase();
        if(!db.connect())
            return internalServerError("Unable to access the database.");

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

        if(db.checkUsername(client.username)!=null) {
            System.out.println("Username already taken");
            return unauthorized("Username already taken");
        }

        if(db.insertClient(client)) {
            db.disconnect();
            return ok("Registered");
        }
        else {
            db.disconnect();
            return internalServerError("Error while registering");
        }
    }
}
