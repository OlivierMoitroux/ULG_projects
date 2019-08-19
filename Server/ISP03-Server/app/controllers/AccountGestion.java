package controllers;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import play.mvc.*;
import objects.*;

import java.util.Vector;

public class AccountGestion extends Controller {

    private DataBase db;
    private Client client;
    public Result deleteData(){
        db = new DataBase();
        System.out.println("Deleting local data");
        if (!db.connect())
            return internalServerError("Unable to access the database.");

        String headers = request().header("Authorization").toString();
        String tempWord = "Optional";
        headers = headers.replaceAll(tempWord,"").replaceAll("\\[", "").replaceAll("\\]","");;
        System.out.println(headers);

        ObjectMapper mapper = new ObjectMapper();
        try {
            client = mapper.readValue(headers, Client.class);
        } catch (Exception e) {
            System.out.println(e);
            System.out.println("Not usable header");
            return badRequest("Not usable header");
        }

        if (!CheckPassword(client, db)) {
            System.out.println("Password or userName incorrect");
            return unauthorized("Password or userName incorrect");
        }

        //Retrieving the client ID

        client.id = db.getClientID(client);
        if (client.id < 0)
            return internalServerError("Internal database error");

        db.deleteMyHabits(client.id);
        db.deleteMyTrajectories(client.id);
        db.deleteMyPlaces(client.id);

        return ok("Data deleted");
    }

    public Result deleteAccount(){
        db = new DataBase();
        if (!db.connect())
            return internalServerError("Unable to access the database.");

        String headers = request().header("Authorization").toString();
        String tempWord = "Optional";
        headers = headers.replaceAll(tempWord,"").replaceAll("\\[", "").replaceAll("\\]","");;
        System.out.println(headers);

        ObjectMapper mapper = new ObjectMapper();
        try {
            client = mapper.readValue(headers, Client.class);
        } catch (Exception e) {
            System.out.println(e);
            return badRequest("Not usable header");
        }

        if (!CheckPassword(client, db)) {
            return unauthorized("Password or userName incorrect");
        }

        //Retrieving the client ID

        client.id = db.getClientID(client);
        if (client.id < 0)
            return internalServerError("Internal database error");

        db.deleteAccount(client.id);
        return ok("Account deleted, goodbye");
    }

    public Result getUserData(){
        System.out.println("Sending personal data");
        db = new DataBase();
        if (!db.connect())
            return internalServerError("Unable to access the database.");

        String headers = request().header("Authorization").toString();
        String tempWord = "Optional";
        headers = headers.replaceAll(tempWord,"").replaceAll("\\[", "").replaceAll("\\]","");;
        System.out.println(headers);

        ObjectMapper mapper = new ObjectMapper();
        try {
            client = mapper.readValue(headers, Client.class);
        } catch (Exception e) {
            System.out.println(e);
            return badRequest("Not usable header");
        }

        if (!CheckPassword(client, db)) {
            return unauthorized("Password or userName incorrect");
        }

        //Retrieving the client ID
        client.id = db.getClientID(client);

        if (client.id < 0)
            return internalServerError("Internal database error");
        db.selectClient(client);

        mapper = new ObjectMapper();
        JsonNode rootNode = mapper.createObjectNode();
        JsonNode son1 = mapper.valueToTree(client);
        ((ObjectNode) rootNode).set("client", son1);
        Vector<AppHabit> e = db.selectHabits(client.id);
        ArrayNode array = mapper.valueToTree(e);
        ((ObjectNode) rootNode).putArray("Habits").addAll(array);

        return ok(rootNode);
    }

    private Boolean CheckPassword(Client client, DataBase db){
        System.out.println("testing password");
        String pw = db.selectPasswor(client.username);
        pw = pw.replaceAll("\\s+","");
        return client.password.equals(pw);
    }
}
