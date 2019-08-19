package controllers;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import objects.*;
import play.mvc.*;

import java.util.List;
import java.util.Vector;

public class GetHabits extends Controller{
    public Result getHabits(){
        DataBase db = new DataBase();
        Client client = new Client();

        System.out.println("Sending Habits");

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

        mapper = new ObjectMapper();
        JsonNode rootNode = mapper.createObjectNode();
        Vector<AppHabit> e = db.selectHabits(client.id);
        ArrayNode array = mapper.valueToTree(e);
        ((ObjectNode) rootNode).putArray("Habits").addAll(array);

        db.disconnect();
        return ok(rootNode);
    }
    private Boolean CheckPassword(Client client, DataBase db){
        System.out.println("testing password");
        String pw = db.selectPasswor(client.username);
        pw = pw.replaceAll("\\s+","");
        return client.password.equals(pw);
    }
}
